import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';

class RecognizerScreen extends StatefulWidget {
  final File image;
  RecognizerScreen(this.image);

  @override
  State<RecognizerScreen> createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {
  late TextRecognizer textRecognizer;
  String results = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    doTextRecognition();
  }

  Future<void> doTextRecognition() async {
    try {
      final inputImage = InputImage.fromFile(widget.image);
      final recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        results = recognizedText.text;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        results = "Error occurred while recognizing text: $e";
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: results));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Results copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Recognizer'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(widget.image),
            Card(
              margin: EdgeInsets.all(10),
              color: Colors.grey.shade300,
              child: Column(
                children: [
                  Container(
                    color: Colors.blueAccent,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.document_scanner, color: Colors.white),
                          Text(
                            'Results',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, color: Colors.white),
                            onPressed: copyToClipboard,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(
                      results,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
