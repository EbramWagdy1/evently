import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../core/config/evently_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/logging/logger.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_datasource.dart';
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';

/// Implementation of EventRepository with batching, retry, and offline queue.
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final EventLocalDataSource localDataSource;
  final EventlyConfig config;
  final EventlyLogger logger;

  final List<EventModel> _eventBatch = [];
  Timer? _batchTimer;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.config,
    required this.logger,
  }) {
    _startBatchTimer();
  }

  /// Start the batch timer.
  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(
      Duration(seconds: config.batchIntervalSeconds),
      (_) => _sendBatch(),
    );
  }

  @override
  Future<Either<Failure, void>> trackEvent(Event event) async {
    try {
      // Validate event
      if (!event.isValid()) {
        final failure = ValidationFailure(
          'Invalid event: ${event.name}',
          'name',
        );
        logger.warning(failure.toString());
        return Left(failure);
      }

      final model = EventModel.fromEntity(event);
      _eventBatch.add(model);

      logger.debug(
        'Event added to batch: ${event.name} (batch size: ${_eventBatch.length}/${config.batchSize})',
      );

      // Send immediately if batch is full
      if (_eventBatch.length >= config.batchSize) {
        return await _sendBatch();
      }

      return const Right(null);
    } catch (e, stackTrace) {
      logger.error('Error tracking event', e, stackTrace);
      return Left(
        NetworkFailure('Failed to track event: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> trackEvents(List<Event> events) async {
    try {
      for (final event in events) {
        final result = await trackEvent(event);
        if (result.isLeft()) {
          return result;
        }
      }
      return const Right(null);
    } catch (e, stackTrace) {
      logger.error('Error tracking events', e, stackTrace);
      return Left(
        NetworkFailure('Failed to track events: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getPendingEvents() async {
    try {
      final models = await localDataSource.getEvents();
      final events = models.map((m) => m.toEntity()).toList();
      return Right(events);
    } catch (e, stackTrace) {
      logger.error('Error getting pending events', e, stackTrace);
      return Left(
        StorageFailure('Failed to get pending events: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearPendingEvents() async {
    try {
      await localDataSource.clearEvents();
      return const Right(null);
    } catch (e, stackTrace) {
      logger.error('Error clearing pending events', e, stackTrace);
      return Left(
        StorageFailure('Failed to clear pending events: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> flush() async {
    return await _sendBatch();
  }

  /// Send the current batch of events.
  Future<Either<Failure, void>> _sendBatch() async {
    if (_eventBatch.isEmpty) {
      return const Right(null);
    }

    final eventsToSend = List<EventModel>.from(_eventBatch);
    _eventBatch.clear();

    logger.info('Flushing batch of ${eventsToSend.length} event(s)');

    return await _sendWithRetry(eventsToSend);
  }

  /// Send events with retry logic.
  Future<Either<Failure, void>> _sendWithRetry(
    List<EventModel> events,
  ) async {
    int attempts = 0;
    Duration delay = Duration(milliseconds: config.retryDelayMs);

    while (attempts <= config.maxRetries) {
      try {
        await remoteDataSource.sendEvents(events);
        logger.info('Successfully sent ${events.length} event(s)');
        return const Right(null);
      } on NetworkException catch (e, stackTrace) {
        attempts++;
        logger.warning(
          'Failed to send events (attempt $attempts/${config.maxRetries + 1})',
          e,
        );

        if (attempts > config.maxRetries) {
          // Store offline if queue is enabled
          if (config.enableOfflineQueue) {
            return await _storeOffline(events);
          } else {
            logger.error('Max retries exceeded, events lost', e, stackTrace);
            return Left(
              NetworkFailure(
                'Failed to send events after ${config.maxRetries} retries',
                statusCode: e.statusCode,
              ),
            );
          }
        }

        // Exponential backoff
        await Future.delayed(delay);
        delay *= 2;
      } catch (e, stackTrace) {
        logger.error('Unexpected error sending events', e, stackTrace);
        if (config.enableOfflineQueue) {
          return await _storeOffline(events);
        } else {
          return Left(NetworkFailure('Failed to send events: $e'));
        }
      }
    }

    return const Right(null);
  }

  /// Store events offline.
  Future<Either<Failure, void>> _storeOffline(
    List<EventModel> events,
  ) async {
    try {
      for (final event in events) {
        await localDataSource.addEvent(event);
      }
      logger.info('Stored ${events.length} event(s) offline');
      return const Right(null);
    } catch (e, stackTrace) {
      logger.error('Failed to store events offline', e, stackTrace);
      return Left(
        StorageFailure('Failed to store events offline: $e'),
      );
    }
  }

  /// Dispose resources.
  void dispose() {
    _batchTimer?.cancel();
    _batchTimer = null;
  }
}
