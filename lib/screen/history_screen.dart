import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QueryDocumentSnapshot> docs = [];

  Future<void> _exportAttendanceData(List<QueryDocumentSnapshot> docs) async {
    List<List<dynamic>> rows = [];
    rows.add([
      'Timestamp',
      'Location',
      'Latitude',
      'Longitude',
      'City',
      'Postal Code'
    ]);

    for (var doc in docs) {
      final timestamp = _formatTimestamp(doc['timestamp']);
      final latitude = doc['latitude'];
      final longitude = doc['longitude'];
      final city = doc['city'];
      final postalCode = doc['postalcode'];

      rows.add([
        timestamp.toString(),
        '$city, $postalCode',
        latitude,
        longitude,
        city,
        postalCode,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory =
        await getExternalStorageDirectory(); // or getApplicationDocumentsDirectory()
    final file = File('${directory!.path}/attendance_data.csv');
    await file.writeAsString(csvData);

    await Share.shareFiles(
      [file.path],
      text: 'Exported Attendance Data',
      subject: 'Attendance Data',
      mimeTypes: ['text/csv'], // Corrected parameter name
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
    }
    return 'N/A';
  }

  final userDocRef = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              _exportAttendanceData(docs);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userDocRef.collection('attendance').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('No attendance data'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final imageUrl = doc['imageUrl'];
              final timestamp = doc['timestamp'];
              final latitude = doc['latitude'];
              final longitude = doc['longitude'];
              final city = doc['city'];
              final postalCode = doc['postalcode'];

              return Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      )
                    ]),
                child: ListTile(
                  leading: Expanded(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ), // Display the image
                  title: Text('Location: $city, $postalCode'),
                  subtitle: Text(
                      'Timestamp: ${_formatTimestamp(timestamp)}\nLatitude: $latitude\nLongitude: $longitude'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
