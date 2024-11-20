import 'package:flutter/material.dart';
import 'package:tb_vision/src/screens/check_session.dart';
import 'package:tb_vision/src/screens/login.dart';
import 'package:tb_vision/src/screens/otp.dart';
import 'package:tb_vision/src/screens/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TB Vision',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home:  const LoginPage(), //const Home(),
      routes: {
        "/": (context) => const CheckSession(), 
        "/home": (context)=> const Home(),
        "/login": (context) => const LoginPage(),
        "/otp": (context)=> const OTPPage(),
      },
    );
  }
}
