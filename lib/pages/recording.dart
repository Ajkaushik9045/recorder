import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class Recording extends StatefulWidget {
  const Recording({Key? key}) : super(key: key);

  @override
  State<Recording> createState() => _RecordingState();
}

class _RecordingState extends State<Recording> {
  late Record audiorecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  bool isPaused = false;
  String audioPath = "";
  int timeDuration = 0;
  late Timer timer;

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audiorecord = Record();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audiorecord.dispose();
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeDuration++;
      });
    });
  }

  void stopTimer() {
    timer.cancel();
  }

  Future<void> startRecording() async {
    try {
      if (await audiorecord.hasPermission()) {
        audiorecord.start();
        startTimer();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> pauseRecording() async {
    audiorecord.pause();
    stopTimer();
    setState(() {
      isPaused = true;
    });
  }

  Future<void> resumeRecording() async {
    audiorecord.resume();
    startTimer();
    setState(() {
      isPaused = false;
    });
  }

  Future<void> stopRecording() async {
    String? path = await audiorecord.stop();
    stopTimer();
    setState(() {
      isRecording = false;
      audioPath = path!;
    });
  }

  Future<void> saveRecording() async {
    // Check if audioPath is not empty
    if (audioPath.isNotEmpty) {
      // Get the directory for saving recordings
      Directory appDirectory = await getApplicationDocumentsDirectory();
      // Get a unique filename for the recording
      String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      String newPath = '${appDirectory.path}/$currentTime.wav';
      // Move the recorded audio file to the new path
      await File(audioPath).copy(newPath);
      // Display a message indicating the save was successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording saved successfully')),
      );
    } else {
      // If audioPath is empty, display an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No recording to save')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDuration = Duration(seconds: timeDuration)
        .toString()
        .split('.')
        .first
        .padLeft(8, "0");

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
              child: Text(formattedDuration,
                  style: TextStyle(fontSize: 36, color: Colors.white)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isRecording
                        ? (isPaused ? resumeRecording : pauseRecording)
                        : startRecording,
                    child: isRecording
                        ? (isPaused
                            ? Icon(Icons.play_arrow)
                            : Icon(Icons.pause))
                        : Icon(Icons.mic),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: saveRecording,
                    child: Icon(Icons.save),
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
    home: Recording(),
  ));
}
