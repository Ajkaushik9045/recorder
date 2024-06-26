import 'package:flutter/material.dart';
import 'package:recoder/pages/home.dart';
import 'package:recoder/pages/recording.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        home: Home(),
        routes: {
          '/recording': (context) => Recording(),
        });
  }
}