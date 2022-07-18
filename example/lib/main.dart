import 'package:flutter/material.dart';
import 'dart:async';
import 'package:biometrics/biometrics.dart';

import 'abc.dart';

void main() {
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> authen(bool isSwitch) async {
    await Biometrics(authenBiometricsOn: (authenBiometricsOn) {
      print("authenBiometricsOn: $authenBiometricsOn");
    }, authenBiometricsOff: (authenBiometricsOff) {
      print("authenBiometricsOff: $authenBiometricsOff");
    }, canEvaluatePolicyFail: (canEvaluatePolicyFail) {
      print("canEvaluatePolicyFail : $canEvaluatePolicyFail");
    }, authenticateUserFail: (authenticateUserFail, type) {
      print("authenticateUserFail: $authenticateUserFail");
    }, notKeySave: (notKeySave) {
      print("notKeySave: $notKeySave");
    }).authenBiometricsConfig(isSwitch);
  }

  Future<void> login(bool isSwitch) async {
    await Biometrics(authenBiometricsOn: (authenBiometricsOn) {
      print("authenBiometricsOn: $authenBiometricsOn");
    }, authenBiometricsOff: (authenBiometricsOff) {
      print("authenBiometricsOff: $authenBiometricsOff");
    }, canEvaluatePolicyFail: (canEvaluatePolicyFail) {
      print("canEvaluatePolicyFail : $canEvaluatePolicyFail");
    }, authenticateUserFail: (authenticateUserFail, type) {
      print("authenticateUserFail: $authenticateUserFail");
    }, notKeySave: (notKeySave) {
      print("notKeySave: $notKeySave");
    }).authenBiometricsLogin(isSwitch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  authen(false);
                },
                icon: Icon(Icons.access_alarm)),
            IconButton(
                onPressed: () {
                  login(true);
                },
                icon: Icon(Icons.access_time)),
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Abc()));
                },
                icon: Icon(Icons.ac_unit)),
          ],
        ),
      ),
    );
  }
}
