import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:images_picker/images_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String path;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            RaisedButton(
              child: Text('pick'),
              onPressed: ()async {
                List<Media> res = await ImagesPicker.pick(
                  count: 1,
                );
                if (res!=null) {
                  print(res[0]?.path);
                  setState(() {
                    path = res[0]?.path;
                  });
                }
              },
            ),
            RaisedButton(
              child: Text('openCamera'),
              onPressed: ()async {
                List<Media> res = await ImagesPicker.openCamera(
//                  pickType: PickType.video,
                );
                if (res!=null) {
                  print(res[0]?.path);
                  setState(() {
                    path = res[0]?.path;
                  });
                }
              },
            ),
            path!=null?Image.file(File(path)):SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
