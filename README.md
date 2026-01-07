# Evently

[![pub package](https://img.shields.io/pub/v/evently.svg)](https://pub.dev/packages/evently)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A production-ready Flutter SDK for event tracking and analytics with clean architecture, automatic batching, offline support, and robust error handling.

## ✨ Features

- 🏗️ **Clean Architecture** - Separation of concerns with clear layer boundaries
- 📦 **Automatic Batching** - Efficiently groups events to reduce network requests
- 💾 **Offline Queue** - Stores events locally when network is unavailable
- 🔄 **Retry Logic** - Exponential backoff for failed requests
- 🛡️ **Error Handling** - Comprehensive error handling with custom exceptions
- 📝 **Structured Logging** - Configurable logging for debugging
- 🔐 **Security** - API key support and input validation
- 🧪 **Fully Tested** - Comprehensive test coverage
- 🎯 **Type Safe** - Strong typing with clear contracts

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  evently: ^2.0.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Initialize the SDK

Initialize Evently in your `main.dart` before running your app:

```dart
import 'package:flutter/material.dart';
import 'package:evently/evently.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EventlyClient.initialize(
    config: EventlyConfig(
      serverUrl: 'https://analytics.example.com/api',
      apiKey: 'your-api-key',
      environment: 'production',
      debugMode: false,
    ),
  );

  runApp(MyApp());
}
```

### 2. Track Events

Log events anywhere in your app:

```dart
// Simple event
await EventlyClient.instance.logEvent(
  name: 'button_click',
  screenName: 'HomeScreen',
);

// Event with properties
await EventlyClient.instance.logEvent(
  name: 'purchase_completed',
  screenName: 'CheckoutScreen',
  properties: {
    'product_id': '12345',
    'amount': 99.99,
    'currency': 'USD',
  },
  userId: 'user_123',
);
```

## ⚙️ Configuration

`EventlyConfig` supports the following options:

```dart
EventlyConfig(
  serverUrl: 'https://api.example.com',      // Required: Your analytics server
  apiKey: 'your-api-key',                     // Optional: API authentication
  environment: 'production',                  // Environment name
  debugMode: false,                           // Enable debug logging
  batchSize: 10,                              // Events per batch
  batchIntervalSeconds: 30,                   // Max time before sending batch
  maxRetries: 3,                              // Retry attempts for failed requests
  retryDelayMs: 1000,                         // Initial retry delay
  maxOfflineEvents: 1000,                     // Max events in offline queue
  enableOfflineQueue: true,                   // Store events when offline
  requestTimeoutSeconds: 30,                  // Network timeout
)
```

## 🔧 Advanced Usage

### Manual Flush

Force immediate sending of all batched events:

```dart
await EventlyClient.instance.flush();
```

### Check Pending Events

Get the count of events waiting in the offline queue:

```dart
final count = await EventlyClient.instance.getPendingEventCount();
print('Pending events: $count');
```

### Clear Offline Queue

Remove all stored offline events:

```dart
await EventlyClient.instance.clearPendingEvents();
```

### Custom Logger

Provide your own logger implementation:

```dart
class CustomLogger implements EventlyLogger {
  @override
  void log(LogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    // Your custom logging logic
  }
  
  // Implement other methods...
}

await EventlyClient.initialize(
  config: config,
  logger: CustomLogger(),
);
```

## 🏗️ Architecture

Evently follows Clean Architecture principles:

```
📁 lib/
├── 📁 core/              # Core infrastructure
│   ├── config/           # Configuration
│   ├── error/            # Exceptions & failures
│   └── logging/          # Logging abstraction
├── 📁 domain/            # Business logic
│   ├── entities/         # Core entities
│   └── repositories/     # Repository contracts
└── 📁 data/              # Data layer
    ├── models/           # Data models
    ├── datasources/      # Remote & local data sources
    └── repositories/     # Repository implementations
```

## 🔒 Security Best Practices

1. **Never hardcode API keys** - Use environment variables or secure storage
2. **Use HTTPS** - Always use secure connections for your server URL
3. **Validate input** - The SDK validates all events automatically
4. **Sanitize PII** - Don't include sensitive personal information in events

## 🧪 Testing

Run tests:

```bash
flutter test
```

The SDK includes comprehensive tests for:
- Configuration validation
- Event creation and validation
- Client initialization
- Error handling
- Logging

## 📚 Example

See the [example](example/) directory for a complete demo app showing all features.

## 🔄 Migration from v1.x

**v2.0.0 is a breaking change** with a complete rewrite. Key differences:

### Old (v1.x):
```dart
Evently().initialize(serverUrl: 'https://api.example.com');
Evently().logEvent('event', screenName: 'Screen', description: 'Desc');
```

### New (v2.0.0):
```dart
await EventlyClient.initialize(
  config: EventlyConfig(serverUrl: 'https://api.example.com'),
);
await EventlyClient.instance.logEvent(
  name: 'event',
  screenName: 'Screen',
  properties: {'description': 'Desc'},
);
```

### Benefits of v2:
- Async initialization for better performance
- Configuration object for better organization
- Properties map instead of simple description
- Error handling with exceptions
- Offline support and batching
- Production-ready architecture

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues, feature requests, or questions, please file an issue on the GitHub repository.

---

Made with ❤️ by the Evently team
