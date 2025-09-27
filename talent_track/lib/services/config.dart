class AppConfig {
  // Use --dart-define=API_BASE_URL=https://your.server when building/running
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000', // Android emulator -> host machine
  );

  // Prefer on-device push-up processing when true
  static const onDevicePushupPreferred = bool.fromEnvironment(
    'ONDEVICE_PUSHUP',
    defaultValue: false,
  );
}
