class RootUrl {
  // Use this for development with the Android Emulator
  static const String _devUrl = "http://192.168.1.7:8080";

  // Use this for production
  static const String _prodUrl = "https://fitness-app-henna-ten.vercel.app";

  // A flag to easily switch between environments
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  static String get url {
    return _isProduction ? _prodUrl : _devUrl;
  }
}