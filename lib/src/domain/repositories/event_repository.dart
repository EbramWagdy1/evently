import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/event.dart';

/// Repository interface for event operations.
///
/// This defines the contract for event persistence and transmission.
/// Implementations should handle actual networking and storage.
abstract class EventRepository {
  /// Track a single event.
  ///
  /// Returns [Right] with void on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, void>> trackEvent(Event event);

  /// Track multiple events in a batch.
  ///
  /// Returns [Right] with void on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, void>> trackEvents(List<Event> events);

  /// Get pending (offline) events.
  ///
  /// Returns [Right] with list of events on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, List<Event>>> getPendingEvents();

  /// Clear pending events (after successful transmission).
  ///
  /// Returns [Right] with void on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, void>> clearPendingEvents();

  /// Flush all pending events immediately.
  ///
  /// Returns [Right] with void on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, void>> flush();
}
