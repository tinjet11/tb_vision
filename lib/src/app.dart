import 'package:flutter/material.dart';
import 'package:tb_vision/src/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  const Home() //const Login(),
    );
  }
}
