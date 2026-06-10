class AppConfig {
  static const aiEndpointUrl = String.fromEnvironment('AI_ENDPOINT_URL', defaultValue: '');
  static const murottalBaseUrl = String.fromEnvironment('MUROTTAL_BASE_URL', defaultValue: '');
}
