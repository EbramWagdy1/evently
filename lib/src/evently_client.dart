import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/evently_config.dart';
import 'core/error/exceptions.dart';
import 'core/logging/logger.dart';
import 'data/datasources/event_local_datasource.dart';
import 'data/datasources/event_remote_datasource.dart';
import 'data/repositories/event_repository_impl.dart';
import 'domain/entities/event.dart';
import 'domain/repositories/event_repository.dart';

/// Main client for Evently SDK.
///
/// This is the primary interface for tracking analytics events.
/// Use the singleton instance via [Evently.instance].
class EventlyClient {
  static EventlyClient? _instance;

  final EventlyConfig config;
  final EventlyLogger logger;
  final EventRepository repository;

  EventlyClient._({
    required this.config,
    required this.logger,
    required this.repository,
  });

  /// Get the singleton instance.
  ///
  /// Throws [ConfigurationException] if not initialized.
  static EventlyClient get instance {
    if (_instance == null) {
      throw const ConfigurationException(
        'EventlyClient not initialized. Call EventlyClient.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Check if the client is initialized.
  static bool get isInitialized => _instance != null;

  /// Initialize the Evently SDK.
  ///
  /// This must be called before using any other methods.
  ///
  /// Example:
  /// ```dart
  /// await EventlyClient.initialize(
  ///   config: EventlyConfig(
  ///     serverUrl: 'https://api.example.com',
  ///     debugMode: true,
  ///   ),
  /// );
  /// ```
  static Future<void> initialize({
    required EventlyConfig config,
    EventlyLogger? logger,
    http.Client? httpClient,
    SharedPreferences? sharedPreferences,
  }) async {
    // Validate configuration
    config.validate();

    // Create logger
    final effectiveLogger = logger ??
        (config.debugMode ? const ConsoleLogger() : const SilentLogger());

    effectiveLogger.info('Initializing Evently SDK v2.0.0');
    effectiveLogger.debug('Server URL: ${config.serverUrl}');
    effectiveLogger.debug('Environment: ${config.environment}');

    // Initialize dependencies
    final client = httpClient ?? http.Client();
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();

    // Create data sources
    final remoteDataSource = EventRemoteDataSourceImpl(
      client: client,
      config: config,
      logger: effectiveLogger,
    );

    final localDataSource = EventLocalDataSourceImpl(
      prefs: prefs,
      logger: effectiveLogger,
      maxEvents: config.maxOfflineEvents,
    );

    // Create repository
    final repository = EventRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      config: config,
      logger: effectiveLogger,
    );

    // Create and store instance
    _instance = EventlyClient._(
      config: config,
      logger: effectiveLogger,
      repository: repository,
    );

    effectiveLogger.info('Evently SDK initialized successfully');
  }

  /// Reset the SDK instance (useful for testing).
  static void reset() {
    if (_instance != null) {
      final repo = _instance!.repository;
      if (repo is EventRepositoryImpl) {
        repo.dispose();
      }
    }
    _instance = null;
  }

  /// Track an analytics event.
  ///
  /// Example:
  /// ```dart
  /// await EventlyClient.instance.logEvent(
  ///   name: 'button_click',
  ///   screenName: 'HomeScreen',
  ///   properties: {'button_id': 'login_button'},
  /// );
  /// ```
  Future<void> logEvent({
    required String name,
    String? screenName,
    Map<String, dynamic>? properties,
    String? userId,
    String? sessionId,
  }) async {
    if (name.isEmpty) {
      throw const ValidationException('Event name cannot be empty', 'name');
    }

    final event = Event.create(
      name: name,
      screenName: screenName,
      properties: properties,
      userId: userId,
      sessionId: sessionId,
    );

    logger.debug('Logging event: $name');

    final result = await repository.trackEvent(event);

    result.fold(
      (failure) {
        logger.error('Failed to track event: $failure');
        throw NetworkException(failure.message);
      },
      (_) {
        logger.debug('Event tracked successfully: $name');
      },
    );
  }

  /// Flush all pending events immediately.
  ///
  /// This forces the SDK to send all batched events right away.
  Future<void> flush() async {
    logger.info('Flushing all pending events');
    final result = await repository.flush();

    result.fold(
      (failure) {
        logger.error('Failed to flush events: $failure');
        throw NetworkException(failure.message);
      },
      (_) {
        logger.info('All events flushed successfully');
      },
    );
  }

  /// Get the count of pending offline events.
  Future<int> getPendingEventCount() async {
    final result = await repository.getPendingEvents();
    return result.fold(
      (failure) {
        logger.warning('Failed to get pending event count: $failure');
        return 0;
      },
      (events) => events.length,
    );
  }

  /// Clear all pending offline events.
  Future<void> clearPendingEvents() async {
    logger.info('Clearing all pending events');
    final result = await repository.clearPendingEvents();

    result.fold(
      (failure) {
        logger.error('Failed to clear pending events: $failure');
        throw StorageException(failure.message);
      },
      (_) {
        logger.info('Pending events cleared successfully');
      },
    );
  }
}
