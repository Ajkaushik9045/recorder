// recording.dart

import 'dart:async';
import 'dart:io';
import 'package:battery/battery.dart';


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:recoder/pages/database_helper.dart'; // Correct the import statement for DatabaseHelper class

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
  final Battery _battery = Battery();

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audiorecord = Record();
    startBatteryMonitoring();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audiorecord.dispose();
    timer.cancel();

    super.dispose();
  }

  void startBatteryMonitoring() {
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (state == BatteryState.charging || state == BatteryState.full) {
        if (isPaused) {
          resumeRecording();
        }
      } else if (state == BatteryState.discharging) {
        _battery.batteryLevel.then((level) {
          if (level != null && level <= 5) {
            // Pause the recording if the battery level is <= 5%
            if (isRecording && !isPaused) {
              pauseRecording();
            }
          }
        });
      }
    });
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
      print('Audio path: $audioPath');
    });
  }

  Future<void> saveRecording(BuildContext context) async {
    if (audioPath.isNotEmpty) {
      String? recordingName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController controller = TextEditingController();
          return AlertDialog(
            title: Text('Save Recording'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter Recording Name'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );

      if (recordingName != null && recordingName.isNotEmpty) {
        Directory directory = await getApplicationDocumentsDirectory();
        String directoryPath = '${directory.path}/recordings';
        Directory(directoryPath).createSync(recursive: true);

        String newPath = '$directoryPath/$recordingName.wav';

        // Check if file with the same name already exists
        if (File(newPath).existsSync()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'A file with this name already exists. Please choose a different name.')),
          );
          return; // Exit the method without saving
        }

        // Move the recorded file to the new location
        await File(audioPath).copy(newPath);

        // Save recording details to the database
        await DatabaseHelper().insertRecording(newPath, timeDuration);

        setState(() {
          timeDuration = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid recording name')),
        );
      }
    } else {
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
                    onPressed: () async {
                      await stopRecording(); // Stop the recording first
                      saveRecording(context); // Then save the recording
                    },
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
