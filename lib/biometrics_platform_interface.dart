import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'biometrics_method_channel.dart';

abstract class BiometricsPlatform extends PlatformInterface {
  /// Constructs a BiometricsPlatform.
  BiometricsPlatform() : super(token: _token);

  static final Object _token = Object();

  static BiometricsPlatform _instance = MethodChannelBiometrics();

  /// The default instance of [BiometricsPlatform] to use.
  ///
  /// Defaults to [MethodChannelBiometrics].
  static BiometricsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BiometricsPlatform] when
  /// they register themselves.
  static set instance(BiometricsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> authenBiometricsConfig(bool isSwitch) async {
    throw UnimplementedError('authenBiometrics has not been implemented.');
  }

  Future<void> authenBiometricsLogin(bool isKeySave) async {
    throw UnimplementedError('authenBiometricsLogin has not been implemented.');
  }
}
