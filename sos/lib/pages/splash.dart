import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sos/pages/auth.dart';
// import 'package:sos/pages/home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1),(){
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AuthPage()));
    });
  }
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color.fromARGB(255, 249, 67, 67),
    body: Center(child: Text('Start'),),
  );
}
}