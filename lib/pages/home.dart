import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:recoder/pages/recording.dart';
import 'package:recoder/pages/database_helper.dart';
import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<RecordingInfo> recordings = [];
  late Timer timer;
  late AudioPlayer audioPlayer = AudioPlayer();
  int? currentPlayingIndex;
  late bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    loadRecordedFiles();
    // Start a timer to check for updates every 5 seconds
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      loadRecordedFiles();
    });
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          currentPlayingIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  void loadRecordedFiles() async {
    List<RecordingInfo> loadedRecordings =
        await DatabaseHelper().getRecordings();
    setState(() {
      recordings = loadedRecordings;
    });
  }

  void deleteRecording(int index) async {
    await File(recordings[index].path).delete();
    await DatabaseHelper().deleteRecording(recordings[index].id);
    setState(() {
      recordings.removeAt(index);
    });
  }

  Future<void> playRecording(int index, String path) async {
    Source urlSource = UrlSource(path);
    if (isPlaying && currentPlayingIndex == index) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      await audioPlayer.play(urlSource);
      setState(() {
        isPlaying = true;
        currentPlayingIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Recorder",
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: recordings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              path.basename(recordings[index].path),
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: Icon(
                currentPlayingIndex == index && isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () => playRecording(index, recordings[index].path),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () => deleteRecording(index),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Recording(),
                  ),
                ).then((value) {
                  if (value != null && value is RecordingInfo) {
                    setState(() {
                      recordings.add(value);
                    });
                  }
                });
              },
              icon: Icon(Icons.mic),
              color: Colors.white,
              iconSize: 40,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}
