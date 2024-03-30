// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:recoder/pages/recording.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            "Recorder",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          backgroundColor: Colors.black,
        ),
        body: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.all(20),
          child: IconButton.filled(
              onPressed: () {
                Navigator.pushNamed(context, '/recording');
              },
              icon: Icon(Icons.mic)),
        ),
      ),
    );
  }
}
