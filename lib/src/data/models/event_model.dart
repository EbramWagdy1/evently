import '../../domain/entities/event.dart';
import '../../core/error/exceptions.dart';

/// Data model for Event with JSON serialization.
class EventModel {
  final String id;
  final String name;
  final DateTime timestamp;
  final String? screenName;
  final Map<String, dynamic> properties;
  final String? userId;
  final String? sessionId;

  const EventModel({
    required this.id,
    required this.name,
    required this.timestamp,
    this.screenName,
    this.properties = const {},
    this.userId,
    this.sessionId,
  });

  /// Convert domain entity to data model.
  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      name: event.name,
      timestamp: event.timestamp,
      screenName: event.screenName,
      properties: event.properties,
      userId: event.userId,
      sessionId: event.sessionId,
    );
  }

  /// Convert data model to domain entity.
  Event toEntity() {
    return Event(
      id: id,
      name: name,
      timestamp: timestamp,
      screenName: screenName,
      properties: properties,
      userId: userId,
      sessionId: sessionId,
    );
  }

  /// Create from JSON map.
  factory EventModel.fromJson(Map<String, dynamic> json) {
    try {
      return EventModel(
        id: json['id'] as String,
        name: json['name'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        screenName: json['screen_name'] as String?,
        properties: (json['properties'] as Map<String, dynamic>?) ?? {},
        userId: json['user_id'] as String?,
        sessionId: json['session_id'] as String?,
      );
    } catch (e, stackTrace) {
      throw SerializationException(
        'Failed to deserialize EventModel from JSON',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'name': name,
        'timestamp': timestamp.toIso8601String(),
        if (screenName != null) 'screen_name': screenName,
        if (properties.isNotEmpty) 'properties': properties,
        if (userId != null) 'user_id': userId,
        if (sessionId != null) 'session_id': sessionId,
      };
    } catch (e, stackTrace) {
      throw SerializationException(
        'Failed to serialize EventModel to JSON',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validate the model.
  bool isValid() {
    if (name.isEmpty) return false;
    if (name.length > 255) return false;
    if (screenName != null && screenName!.length > 255) return false;
    return true;
  }

  @override
  String toString() => 'EventModel(id: $id, name: $name)';
}
