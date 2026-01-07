import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/exceptions.dart';
import '../../core/logging/logger.dart';
import '../models/event_model.dart';

/// Local data source for storing events offline.
abstract class EventLocalDataSource {
  /// Save events to local storage.
  Future<void> saveEvents(List<EventModel> events);

  /// Get all stored events.
  Future<List<EventModel>> getEvents();

  /// Clear all stored events.
  Future<void> clearEvents();

  /// Add a single event to storage.
  Future<void> addEvent(EventModel event);
}

/// SharedPreferences implementation of local data source.
class EventLocalDataSourceImpl implements EventLocalDataSource {
  static const String _storageKey = 'evently_offline_events';

  final SharedPreferences prefs;
  final EventlyLogger logger;
  final int maxEvents;

  const EventLocalDataSourceImpl({
    required this.prefs,
    required this.logger,
    required this.maxEvents,
  });

  @override
  Future<void> saveEvents(List<EventModel> events) async {
    try {
      final jsonList = events.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_storageKey, jsonString);
      logger.debug('Saved ${events.length} event(s) to local storage');
    } catch (e, stackTrace) {
      logger.error('Failed to save events to local storage', e, stackTrace);
      throw StorageException(
        'Failed to save events to local storage',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        logger.debug('No stored events found');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final events = jsonList
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();

      logger.debug('Retrieved ${events.length} event(s) from local storage');
      return events;
    } catch (e, stackTrace) {
      logger.error(
          'Failed to retrieve events from local storage', e, stackTrace);
      throw StorageException(
        'Failed to retrieve events from local storage',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearEvents() async {
    try {
      await prefs.remove(_storageKey);
      logger.debug('Cleared local event storage');
    } catch (e, stackTrace) {
      logger.error('Failed to clear local storage', e, stackTrace);
      throw StorageException(
        'Failed to clear local storage',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> addEvent(EventModel event) async {
    try {
      final existingEvents = await getEvents();

      // Enforce max limit
      if (existingEvents.length >= maxEvents) {
        logger.warning(
          'Local storage at capacity ($maxEvents). Removing oldest event.',
        );
        existingEvents.removeAt(0);
      }

      existingEvents.add(event);
      await saveEvents(existingEvents);
    } catch (e, stackTrace) {
      logger.error('Failed to add event to local storage', e, stackTrace);
      throw StorageException(
        'Failed to add event to local storage',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
