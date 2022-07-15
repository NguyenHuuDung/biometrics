import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'biometrics_platform_interface.dart';

/// An implementation of [BiometricsPlatform] that uses method channels.
class MethodChannelBiometrics extends BiometricsPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('biometrics');

  @override
  Future<void> authenBiometricsConfig(bool isSwitch) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('isSwitch', () => isSwitch);
    await methodChannel.invokeMethod('openAuthenConfig', args);
  }

  @override
  Future<void> authenBiometricsLogin(bool isKeySave) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('isKeySave', () => isKeySave);
    await methodChannel.invokeMethod('loginBiometrics', args);
  }
}
