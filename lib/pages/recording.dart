// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class recording extends StatefulWidget {
  const recording({Key? key}) : super(key: key);

  @override
  State<recording> createState() => _RecordingState();
}

class _RecordingState extends State<recording> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Recording",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "00:00:00",
                style: TextStyle(color: Colors.white, fontSize: 50),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: () {},
                    icon: Icon(Icons.mic),
                    color: Colors.white,
                  ),
                  SizedBox(width: 20),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: Icon(Icons.save),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: recording(),
  ));
}

