# ZeroTier API Web Application

A Flutter web application for managing ZeroTier networks and devices.

## Features

- View and manage ZeroTier networks and devices
- Real-time status monitoring
- Cross-platform support (Web, Desktop, Mobile)

## Prerequisites

- Flutter SDK
- Dart SDK
- Chrome browser (for web version)
- ZeroTier API token

## Running the Application

### Web Version (Windows)

1. Double click the `start_app.bat` file
2. Wait for the browser to open automatically
3. The application will start at http://localhost:8080
4. The proxy server will run at http://localhost:3000

### Manual Start

If you prefer to start the components manually:

1. Start the proxy server:
   ```bash
   dart run bin/proxy_server.dart
   ```

2. Start the Flutter web application:
   ```bash
   flutter run -d chrome
   ```

## Configuration

1. On first launch, enter your ZeroTier API token in the configuration screen
2. The application will automatically save your settings

## Development

- Built with Flutter
- Uses Dart shelf package for proxy server
- Implements local storage for settings

# zerotierapi

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
