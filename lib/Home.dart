import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? image;
  String output = '';

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        runModel();
      });
    }
  }

  runModel() async {
    if (image != null) {
      var predictions = await Tflite.runModelOnImage(
          path: image!.path,
          numResults: 5,
          threshold: 0.05,
          imageMean: 127.5,
          imageStd: 127.5);

      predictions!.forEach((element) {
        setState(() {
          output +=
              '${element['label']}: ${(element['confidence'] as double).toStringAsFixed(2)}\n';
        });
      });
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Based Music Player'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: image == null
                  ? const Center(child: Text('No image selected'))
                  : Image.file(image!),
            ),
          ),
          ElevatedButton(
            onPressed: () => pickImage(),
            child: const Text('Select Image'),
          ),
          const SizedBox(height: 20),
          Text(output,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
        ],
      ),
    );
  }
}
