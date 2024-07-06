import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tumor/HistoryResultPage.dart';

class ResultPage extends StatelessWidget {
  final String label;
  final double confidence;
  final File? filePath;

  const ResultPage({
    required this.label,
    required this.confidence,
    required this.filePath,
    Key? key,
  }) : super(key: key);

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'confidence': confidence,
      'filePath': filePath!.path,
    };
  }

  @override
  Widget build(BuildContext context) {
    String baca = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            filePath != null
                ? Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(filePath!, fit: BoxFit.cover),
                    ),
                  )
                : Text('No image uploaded'),
            //SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '$label',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      'Confidence: ${confidence.toStringAsFixed(3)}%',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder(
              future: _loadFaktaJson(label),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String facts = snapshot.data ?? 'Unknown label';
                  List<String> factList = facts.split('\n');

                  return Container(
                    height: 400, // give it a specific height
                    child: ListView.builder(
                      itemCount: factList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(factList[index]),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
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

  Future<String> _loadFaktaJson(String label) async {
    final jsonString = await rootBundle.loadString('assets/fakta.json');
    final jsonData = jsonDecode(jsonString);
    final facts = jsonData[label];

    if (facts != null) {
      String result = '';
      for (var key in facts.keys) {
        result += '${key}. ${facts[key]}\n';
      }
      return result;
    } else {
      return 'Unknown label';
    }
  }
}
