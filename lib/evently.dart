/// Evently - A production-ready Flutter SDK for event tracking and analytics.
///
/// ## Features
/// - Clean architecture with separation of concerns
/// - Automatic event batching and offline queue
/// - Configurable retry logic with exponential backoff
/// - Type-safe error handling
/// - Structured logging
/// - Production-ready with proper abstractions
///
/// ## Usage
///
/// ### Initialization
/// ```dart
/// import 'package:evently/evently.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await EventlyClient.initialize(
///     config: EventlyConfig(
///       serverUrl: 'https://analytics.example.com',
///       apiKey: 'your-api-key',
///       environment: 'production',
///       debugMode: false,
///       batchSize: 20,
///       batchIntervalSeconds: 30,
///     ),
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// ### Tracking Events
/// ```dart
/// // Simple event
/// await EventlyClient.instance.logEvent(
///   name: 'button_click',
///   screenName: 'HomeScreen',
/// );
///
/// // Event with properties
/// await EventlyClient.instance.logEvent(
///   name: 'purchase_completed',
///   screenName: 'CheckoutScreen',
///   properties: {
///     'product_id': '12345',
///     'amount': 99.99,
///     'currency': 'USD',
///   },
///   userId: 'user_123',
/// );
/// ```
///
/// ### Manual Flush
/// ```dart
/// // Force send all pending events
/// await EventlyClient.instance.flush();
/// ```
library evently;

// Core
export 'src/core/config/evently_config.dart';
export 'src/core/error/exceptions.dart';
export 'src/core/error/failures.dart';
export 'src/core/logging/logger.dart';

// Domain
export 'src/domain/entities/event.dart';

// Client
export 'src/evently_client.dart';
