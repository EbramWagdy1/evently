import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/evently_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/logging/logger.dart';
import '../models/event_model.dart';

/// Remote data source for sending events to analytics server.
abstract class EventRemoteDataSource {
  /// Send a single event to the server.
  Future<void> sendEvent(EventModel event);

  /// Send multiple events in a batch.
  Future<void> sendEvents(List<EventModel> events);
}

/// HTTP implementation of remote data source.
class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final http.Client client;
  final EventlyConfig config;
  final EventlyLogger logger;

  const EventRemoteDataSourceImpl({
    required this.client,
    required this.config,
    required this.logger,
  });

  @override
  Future<void> sendEvent(EventModel event) async {
    return sendEvents([event]);
  }

  @override
  Future<void> sendEvents(List<EventModel> events) async {
    if (events.isEmpty) {
      logger.warning('Attempted to send empty event list');
      return;
    }

    try {
      final uri = Uri.parse('${config.serverUrl}/events');
      final headers = {
        'Content-Type': 'application/json',
        if (config.apiKey != null) 'Authorization': 'Bearer ${config.apiKey}',
        'X-Evently-Environment': config.environment,
      };

      final body = jsonEncode({
        'events': events.map((e) => e.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'sdk_version': '2.0.0',
      });

      logger.debug('Sending ${events.length} event(s) to $uri');

      final response = await client
          .post(
            uri,
            headers: headers,
            body: body,
          )
          .timeout(
            Duration(seconds: config.requestTimeoutSeconds),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        logger.info(
          'Successfully sent ${events.length} event(s) (HTTP ${response.statusCode})',
        );
      } else {
        final errorMessage =
            'Failed to send events (HTTP ${response.statusCode}): ${response.body}';
        logger.error(errorMessage);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is NetworkException) rethrow;

      logger.error('Network error while sending events', e, stackTrace);
      throw NetworkException(
        'Failed to send events: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
