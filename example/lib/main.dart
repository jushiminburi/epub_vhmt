import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:epub_vhmt/epub_vhmt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String authorName = 'Unknown';
  late Future<Image> imagecover;
  final pathEpub =
      '/Users/vhmt/Desktop/epub_vhmt/example/assets/The Adventures Of Sherlock Holmes - Adventure I.epub';
  @override
  void initState() {
    super.initState();
    imagecover = VHEpubParser().parseCoverImage(pathEpub,
        unzipPath: '/Users/vhmt/Desktop/epub_vhmt/example');
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    const pathEpub = '/Users/vhmt/Desktop/epub_vhmt/example/assets/sample.epub';
    VHEpubParser epubParser = VHEpubParser();
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      authorName = await epubParser.parseAuthorName(pathEpub,
          unzipPath: '/Users/vhmt/Desktop/epub_vhmt/example');
    } on PlatformException {
      authorName = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      authorName = authorName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: imagecover,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return MaterialApp(
            home:
                Scaffold(body: Center(child: Text('Error: ${snapshot.error}'))),
          );
        } else {
          return Container(
            child: snapshot.data, // Display the parsed image
          );
        }
      },
    );
  }
}
