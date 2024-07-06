import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tumor/HistoryResultPage.dart';

//import 'package:tumor/api_model.dart';
import 'package:tumor/result.dart';
import 'dart:developer' as devtools;

import 'package:tumor/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              //title: const Text('BrainBeacon'),
              ),
          body: TabBarView(
            children: [
              SplashScreen(), // new history result page
              MyHomePage(),
             // Add MyHomePage here
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;

  String label = '';
  double confidence = 0.0;

  Future<void> _tfliteInit() async {
    String? res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    var imageMap = File(image.path);
    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );
    devtools.log('Recognitions: $recognitions');

    if (recognitions == null) {
      devtools.log("recognitions is null");
      return;
    }
    devtools.log(recognitions.toString());

    setState(() {
      // confidence = (recognitions[0]['confidence']);
      // label = recognitions[0]['label'].toString();
      if (recognitions[0]['confidence'] > 0.8) {
        confidence = (recognitions[0]['confidence']);
        label = recognitions[0]['label'].toString();
      } else {
        confidence = (recognitions[0]['confidence']);
        label = 'no_tumor';
      }
      devtools.log(recognitions[0].toString());
    });
  }

  pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    var imageMap = File(image.path);
    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );
    if (recognitions == null) {
      devtools.log("recognitions is null");
      return;
    }
    devtools.log(recognitions.toString());
    setState(() {
      if (recognitions[0]['confidence'] > 0.8) {
        confidence = (recognitions[0]['confidence']);
        label = recognitions[0]['label'].toString();
      } else {
        confidence = (recognitions[0]['confidence']);
        label = 'no_tumor';
      }

      devtools.log(label);
    });
  }

  Future<void> _sendDataToApi() async {
    final url = 'https://reqres.in/api/users';
    final headers = {
      'Content-Type': 'application/json',
    };

    final data = [
      {
        'label': label,
        'confidence': confidence,
        'filePath': null,
      },
    ];

    final jsonBody = jsonEncode(data);

    final response =
        await http.post(Uri.parse(url), headers: headers, body: jsonBody);

    if (response.statusCode == 201) {
      print('Data sent to API successfully!');
    } else {
      print('Error sending data to API: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tfliteInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BrainBeacon"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 18,
                        ),
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                                image: AssetImage('assets/coba.png')),
                          ),
                          child: filePath == null
                              ? const Text("")
                              : Image.file(
                                  filePath!,
                                  fit: BoxFit.fill,
                                ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Accuracy ${confidence.toStringAsFixed(3)}%",
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () async {
                  await pickImageCamera()
                      .then((value) => HistoryResultPage.addResult({
                            'label': label,
                            'confidence': confidence,
                            'filePath': null,
                          }));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ResultPage(
                              label: label,
                              confidence: confidence,
                              filePath: filePath,
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Color(0xFFEB996E)),
                child: const Text("Take Photo"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await pickImageGallery()
                      .then((value) => HistoryResultPage.addResult({
                            'label': label,
                            'confidence': confidence,
                            'filePath': null,
                          }));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ResultPage(
                              label: label,
                              confidence: confidence,
                              filePath: filePath,
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Color(0xFFEB996E)),
                child: const Text("Pick Photo"),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'History Result',
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor:
            Colors.grey, // Change the color of unselected items
        selectedItemColor:
            Color(0xFFEB996E), // Change the color of selected items
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryResultPage()),
            );
          }
        },
      ),
    );
  }
}
