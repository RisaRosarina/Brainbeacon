
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'HistoryResultPage.dart';

class DatabasePage extends StatefulWidget {
  @override
  _DatabasePageState createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  late Database _database;
  List<Map<String, dynamic>> _historyData = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  _initDatabase() async {
    _database = await openDatabase('history_database.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY,
            label TEXT,
            confidence REAL
          )
          ''');
    });
    _loadHistoryData();
  }

  _loadHistoryData() async {
    final List<Map<String, dynamic>> historyData =
        await _database.query('history');
    setState(() {
      _historyData = historyData;
    });
  }

  _saveHistoryData(Map<String, dynamic> result) async {
    await _database.insert('history', result);
    _loadHistoryData();
  }

  _deleteHistoryData() async {
    await _database.delete('history');
    _loadHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Page'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _historyData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> result = _historyData[index];
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
                // Save history data to database
  
               
                print('History data saved to database!');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                foregroundColor: Color(0xFFEB996E),
              ),
              child: Text('Save to Database'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                // Delete history data from database
                _deleteHistoryData();
                print('History data deleted from database!');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                foregroundColor: Color(0xFFEB996E),
              ),
              child: Text('Delete from Database'),
            ),
          ),
        ],
      ),
    );
  }
}