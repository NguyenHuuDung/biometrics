import 'package:biometrics/biometrics.dart';
import 'package:flutter/material.dart';

class Abc extends StatefulWidget {
  const Abc({Key? key}) : super(key: key);

  @override
  State<Abc> createState() => _AbcState();
}

class _AbcState extends State<Abc> {
  Future<void> authen(bool isSwitch) async {
    await Biometrics(authenBiometricsOn: (authenBiometricsOn) {
      print("authenBiometricsOn: $authenBiometricsOn");
    }, authenBiometricsOff: (authenBiometricsOff) {
      print("authenBiometricsOff: $authenBiometricsOff");
    }, canEvaluatePolicyFail: (canEvaluatePolicyFail) {
      print("canEvaluatePolicyFail : $canEvaluatePolicyFail");
    }, authenticateUserFail: (authenticateUserFail) {
      print("authenticateUserFail: $authenticateUserFail");
    }, notKeySave: (notKeySave) {
      print("notKeySave: $notKeySave");
    }).authenBiometricsConfig(isSwitch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: IconButton(
              onPressed: () {
                authen(false);
              },
              icon: Icon(Icons.access_time)),
        ));
  }
}
