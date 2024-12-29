import 'package:e_mart/Orders.dart';

import 'package:e_mart/firebase_options.dart';
import 'package:e_mart/login.dart';
import 'package:e_mart/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Demo App",
        routes: {
          '/login': (context) => Login(),
          '/register': (context) => Registration(),
          '/orders': (context) => Orders(),
        },
        initialRoute: '/',
        home: Login());
  }
}
