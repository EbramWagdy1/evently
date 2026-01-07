# Changelog

All notable changes to this project will be documented in this file.

## [2.0.1] - 2026-01-08

### 🐛 Fixed
- Fixed `pubspec.yaml` repository URL mismatch to match the actual GitHub repository URL.

## [2.0.0] - 2026-01-08

### 🎉 Major Release - Complete Rewrite

This is a complete architectural rewrite of Evently with breaking changes.

### ✨ Added

#### Security
- **Secure ID Generation** - Used `uuid` (v4) for cryptographically secure event IDs

#### Architecture
- **Clean Architecture** implementation with clear separation of concerns
- **Domain Layer** with entities and repository interfaces
- **Data Layer** with models, datasources, and repository implementations
- **Core Infrastructure** with error handling, configuration, and logging

#### Features
- **Automatic Event Batching** - Configurable batch size and interval
- **Offline Queue** - Local storage for events when network is unavailable
- **Retry Logic** - Exponential backoff for failed network requests
- **Error Handling** - Custom exceptions and functional error handling with `Either`
- **Structured Logging** - Pluggable logger interface with console and silent implementations
- **Configuration System** - Comprehensive `EventlyConfig` with validation
- **API Key Support** - Optional authentication for server requests
- **Environment Support** - Track which environment events come from
- **HTTP Client** - Real HTTP implementation using `http` package
- **Local Storage** - Persistent offline queue using `shared_preferences`
- **Type Safety** - Strong typing throughout with immutable entities
- **Input Validation** - Automatic validation of events and configuration

#### Testing
- **Comprehensive Test Suite** covering all major components
- **Mock Support** using `mocktail` for unit testing
- **Integration Tests** for full event lifecycle

#### Documentation
- **Complete README** with quick start, configuration guide, and examples
- **API Documentation** with inline dartdocs
- **Migration Guide** from v1.x
- **Example App** demonstrating all features

### 🔄 Changed

- **BREAKING**: `Evently()` singleton replaced with `EventlyClient`
- **BREAKING**: Synchronous `initialize()` now async
- **BREAKING**: Configuration now uses `EventlyConfig` object
- **BREAKING**: `logEvent()` parameters changed to named parameters
- **BREAKING**: `description` parameter replaced with `properties` map
- **BREAKING**: Initialization now required before using SDK
- Enhanced error messages and error handling
- Improved performance with batching
- Better developer experience with clear APIs

### 🗑️ Removed

- **BREAKING**: Removed simple `description` field (use `properties` instead)
- **BREAKING**: Removed direct `print()` statements (use logger)
- **BREAKING**: Removed silent failures (now throws exceptions)

### 🔧 Technical Details

#### Dependencies Added
- `dartz: ^0.10.1` - Functional programming utilities
- `equatable: ^2.0.5` - Value equality
- `http: ^1.2.0` - HTTP client
- `shared_preferences: ^2.2.2` - Local storage
- `mocktail: ^1.0.3` (dev) - Testing mocks

#### Version
- Updated from `0.1.0` to `2.0.0`

## [0.1.0] - 2026-01-02

### Initial Release

- Basic event tracking with `logEvent()`
- Simple initialization with server URL
- Console logging for debugging
- Singleton pattern for easy access
- MIT License

---

[2.0.0]: https://github.com/example/evently/compare/v0.1.0...v2.0.0
[0.1.0]: https://github.com/example/evently/releases/tag/v0.1.0
