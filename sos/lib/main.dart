import 'package:flutter/material.dart';
import 'package:sos/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:sos/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  SplashPage(),
      theme: 
        // darkTheme: darkmode,
        // lightmode,
        ThemeData(
          fontFamily: 'Oxanium_bold',
          splashColor: Colors.transparent,
        ),
    );
  }
} 