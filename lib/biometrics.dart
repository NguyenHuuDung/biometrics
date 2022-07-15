import 'package:flutter/services.dart';

import 'biometrics_platform_interface.dart';

class Biometrics {
  late MethodChannel _channel;

  Future<void> authenBiometricsConfig(bool isSwitch) async {
    return BiometricsPlatform.instance.authenBiometricsConfig(isSwitch);
  }

  Future<void> authenBiometricsLogin(bool isKeySave) async {
    return BiometricsPlatform.instance.authenBiometricsLogin(isKeySave);
  }

  final Function(String)? authenBiometricsOn;
  final Function(String)? authenBiometricsOff;
  final Function(String)? canEvaluatePolicyFail;
  final Function(String)? authenticateUserFail;
  final Function(String)? notKeySave;

  Biometrics(
      {this.authenBiometricsOn,
      this.authenBiometricsOff,
      this.canEvaluatePolicyFail,
      this.authenticateUserFail,
      this.notKeySave}) {
    _channel = const MethodChannel('biometrics');
    _channel.setMethodCallHandler(handleMethod);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "authenBiometricsOn":
        authenBiometricsOn!(call.arguments["message"]);
        break;
      case "authenBiometricsOff":
        authenBiometricsOff!(call.arguments["message"]);
        break;
      case "canEvaluatePolicyFail":
        canEvaluatePolicyFail!(call.arguments["message"]);
        break;
      case "authenticateUserFail":
        authenticateUserFail!(call.arguments["message"]);
        break;
      case "notKeySave":
        authenticateUserFail!(call.arguments["message"]);
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }
}
