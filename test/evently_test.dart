import 'package:flutter_test/flutter_test.dart';
import 'package:evently/evently.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventlyConfig', () {
    test('should create config with required parameters', () {
      const config = EventlyConfig(serverUrl: 'https://api.example.com');

      expect(config.serverUrl, 'https://api.example.com');
      expect(config.environment, 'production');
      expect(config.debugMode, false);
      expect(config.batchSize, 10);
    });

    test('should validate server URL', () {
      const config = EventlyConfig(serverUrl: '');

      expect(
        () => config.validate(),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('should require http:// or https:// protocol', () {
      const config = EventlyConfig(serverUrl: 'ftp://api.example.com');

      expect(
        () => config.validate(),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('should create copy with modified fields', () {
      const config = EventlyConfig(
        serverUrl: 'https://api.example.com',
        debugMode: false,
      );

      final newConfig = config.copyWith(debugMode: true);

      expect(newConfig.debugMode, true);
      expect(newConfig.serverUrl, config.serverUrl);
    });
  });

  group('Event', () {
    test('should create event with factory method', () {
      final event = Event.create(
        name: 'test_event',
        screenName: 'TestScreen',
        properties: const {'key': 'value'},
      );

      expect(event.name, 'test_event');
      expect(event.screenName, 'TestScreen');
      expect(event.properties['key'], 'value');
      expect(event.id, isNotEmpty);
      expect(event.timestamp, isNotNull);
    });

    test('should validate event name', () {
      final validEvent = Event.create(name: 'valid_event');
      final invalidEvent = Event.create(name: '');

      expect(validEvent.isValid(), true);
      expect(invalidEvent.isValid(), false);
    });

    test('should reject event name longer than 255 characters', () {
      final longName = 'a' * 256;
      final event = Event.create(name: longName);

      expect(event.isValid(), false);
    });
  });

  group('EventlyClient', () {
    setUp(() async {
      // Reset singleton before each test
      EventlyClient.reset();

      // Clear shared preferences
      SharedPreferences.setMockInitialValues({});
    });

    test('should throw exception when not initialized', () {
      expect(
        () => EventlyClient.instance,
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('should initialize successfully', () async {
      await EventlyClient.initialize(
        config: const EventlyConfig(serverUrl: 'https://api.example.com'),
      );

      expect(EventlyClient.isInitialized, true);
      expect(EventlyClient.instance, isNotNull);
    });

    test('should validate config during initialization', () async {
      expect(
        () => EventlyClient.initialize(
          config: const EventlyConfig(serverUrl: ''),
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('should log event successfully', () async {
      await EventlyClient.initialize(
        config: const EventlyConfig(
          serverUrl: 'https://api.example.com',
          debugMode: true,
        ),
      );

      // Should not throw
      await EventlyClient.instance.logEvent(
        name: 'test_event',
        screenName: 'TestScreen',
        properties: {'test': 'value'},
      );
    });

    test('should reject empty event name', () async {
      await EventlyClient.initialize(
        config: const EventlyConfig(serverUrl: 'https://api.example.com'),
      );

      expect(
        () => EventlyClient.instance.logEvent(name: ''),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('ConsoleLogger', () {
    test('should log debug messages when enabled', () {
      const logger = ConsoleLogger(enabled: true);

      // Should not throw
      logger.debug('Test debug message');
      logger.info('Test info message');
      logger.warning('Test warning');
      logger.error('Test error');
    });

    test('should not log when disabled', () {
      const logger = ConsoleLogger(enabled: false);

      // Should not throw or output
      logger.debug('This should not appear');
      logger.error('This should not appear either');
    });
  });

  group('SilentLogger', () {
    test('should not log anything', () {
      const logger = SilentLogger();

      // Should not throw
      logger.debug('Test');
      logger.info('Test');
      logger.warning('Test');
      logger.error('Test');
    });
  });

  group('Exceptions', () {
    test('should create ConfigurationException', () {
      const exception = ConfigurationException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.code, 'CONFIGURATION_ERROR');
    });

    test('should create NetworkException with status code', () {
      const exception = NetworkException(
        'Network error',
        statusCode: 500,
      );

      expect(exception.message, 'Network error');
      expect(exception.statusCode, 500);
      expect(exception.toString(), contains('HTTP 500'));
    });

    test('should create ValidationException with field', () {
      const exception = ValidationException('Invalid field', 'email');

      expect(exception.message, 'Invalid field');
      expect(exception.field, 'email');
    });
  });

  group('Integration Tests', () {
    test('should handle full event lifecycle', () async {
      await EventlyClient.initialize(
        config: const EventlyConfig(
          serverUrl: 'https://api.example.com',
          batchSize: 5,
          debugMode: true,
        ),
      );

      // Log multiple events
      for (int i = 0; i < 3; i++) {
        await EventlyClient.instance.logEvent(
          name: 'test_event_$i',
          screenName: 'TestScreen',
          properties: {'index': i},
        );
      }

      // Should complete without errors
      expect(EventlyClient.isInitialized, true);
    });

    tearDown(() {
      EventlyClient.reset();
    });
  });
}
