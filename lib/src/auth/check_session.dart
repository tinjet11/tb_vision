import 'package:flutter/material.dart';
import 'package:tb_vision/src/auth/auth.dart';

class CheckSession extends StatefulWidget {
  const CheckSession({super.key});

  @override
  State<CheckSession> createState() => _CheckSessionState();
}

class _CheckSessionState extends State<CheckSession> {
  @override
  void initState() {
    checkSessions().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.restorablePushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
 Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
