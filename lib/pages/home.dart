import 'package:flutter/material.dart';
import 'package:recoder/pages/recording.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> recordedFiles = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
          itemCount: recordedFiles.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(left: 20, right: 90, bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey,
              ),
              child: ListTile(
                title: Text(recordedFiles[index]),
                onTap: () {
                  // Implement navigation to the playback page or file details page
                },
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
                    if (value != null && value is List<String>) {
                      setState(() {
                        recordedFiles = List.from(value);
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
      ),
    );
  }
}
