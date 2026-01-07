import '../error/exceptions.dart';

/// Configuration class for Evently SDK.
class EventlyConfig {
  /// The base URL of your analytics server.
  final String serverUrl;

  /// Optional API key for authentication.
  final String? apiKey;

  /// Environment name (e.g., 'production', 'staging', 'development').
  final String environment;

  /// Enable debug logging.
  final bool debugMode;

  /// Maximum number of events to batch before sending.
  final int batchSize;

  /// Maximum time (in seconds) to wait before sending batched events.
  final int batchIntervalSeconds;

  /// Number of retry attempts for failed requests.
  final int maxRetries;

  /// Initial delay (in milliseconds) for exponential backoff.
  final int retryDelayMs;

  /// Maximum number of events to store offline.
  final int maxOfflineEvents;

  /// Enable offline event queueing.
  final bool enableOfflineQueue;

  /// Timeout for network requests (in seconds).
  final int requestTimeoutSeconds;

  const EventlyConfig({
    required this.serverUrl,
    this.apiKey,
    this.environment = 'production',
    this.debugMode = false,
    this.batchSize = 10,
    this.batchIntervalSeconds = 30,
    this.maxRetries = 3,
    this.retryDelayMs = 1000,
    this.maxOfflineEvents = 1000,
    this.enableOfflineQueue = true,
    this.requestTimeoutSeconds = 30,
  });

  /// Validate the configuration.
  void validate() {
    if (serverUrl.isEmpty) {
      throw const ConfigurationException('Server URL cannot be empty');
    }

    if (!serverUrl.startsWith('http://') && !serverUrl.startsWith('https://')) {
      throw const ConfigurationException(
        'Server URL must start with http:// or https://',
      );
    }

    if (batchSize <= 0) {
      throw const ConfigurationException('Batch size must be positive');
    }

    if (batchIntervalSeconds <= 0) {
      throw const ConfigurationException(
        'Batch interval must be positive',
      );
    }

    if (maxRetries < 0) {
      throw const ConfigurationException(
        'Max retries cannot be negative',
      );
    }

    if (retryDelayMs <= 0) {
      throw const ConfigurationException('Retry delay must be positive');
    }

    if (maxOfflineEvents <= 0) {
      throw const ConfigurationException(
        'Max offline events must be positive',
      );
    }

    if (requestTimeoutSeconds <= 0) {
      throw const ConfigurationException('Request timeout must be positive');
    }
  }

  /// Create a copy with modified fields.
  EventlyConfig copyWith({
    String? serverUrl,
    String? apiKey,
    String? environment,
    bool? debugMode,
    int? batchSize,
    int? batchIntervalSeconds,
    int? maxRetries,
    int? retryDelayMs,
    int? maxOfflineEvents,
    bool? enableOfflineQueue,
    int? requestTimeoutSeconds,
  }) {
    return EventlyConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      apiKey: apiKey ?? this.apiKey,
      environment: environment ?? this.environment,
      debugMode: debugMode ?? this.debugMode,
      batchSize: batchSize ?? this.batchSize,
      batchIntervalSeconds: batchIntervalSeconds ?? this.batchIntervalSeconds,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelayMs: retryDelayMs ?? this.retryDelayMs,
      maxOfflineEvents: maxOfflineEvents ?? this.maxOfflineEvents,
      enableOfflineQueue: enableOfflineQueue ?? this.enableOfflineQueue,
      requestTimeoutSeconds:
          requestTimeoutSeconds ?? this.requestTimeoutSeconds,
    );
  }

  @override
  String toString() => 'EventlyConfig(serverUrl: $serverUrl, '
      'environment: $environment, debugMode: $debugMode)';
}
