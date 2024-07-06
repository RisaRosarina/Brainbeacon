// HistoryResultPage.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // add this import

class HistoryResultPage extends StatefulWidget {
  static List<Map<String, dynamic>> _history = [];

  static void addResult(Map<String, dynamic> result) {
    _history.add(result);
  }

  @override
  _HistoryResultPageState createState() => _HistoryResultPageState();
}

class _HistoryResultPageState extends State<HistoryResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Result'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: HistoryResultPage._history.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> result = HistoryResultPage._history[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      'Label: ${result['label']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Confidence: ${result['confidence'].toStringAsFixed(3)}%',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                // Send history data to API
                final response = await http.post(
                  Uri.parse(
                      'https://reqres.in/api/history'), // replace with your API endpoint
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(HistoryResultPage._history),
                );
                print('Response status code: ${response.statusCode}');
                print('History data sent successfully!');
                print('Response body: ${response.body}');

                if (response.statusCode == 201) {
                  // Clear local history

                  setState(() {
                    HistoryResultPage._history.clear();
                    print('History data Dellete successfully!');
                  });
                } else {
                  print(
                      'Error sending history data to API: ${response.statusCode}');
                  print('Error message: ${response.body}');
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                foregroundColor: Color(0xFFEB996E),
              ),
              child: Text('Clear History'),
            ),
          )
        ],
      ),
    );
  }
}
