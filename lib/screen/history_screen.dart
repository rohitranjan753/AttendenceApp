import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
        title: Text('History'),
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

          final docs = snapshot.data!.docs;

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

              return ListTile(
                leading: Image.network(imageUrl,), // Display the image
                title: Text('Location: $city, $postalCode'),
                subtitle: Text(
                    'Timestamp: ${_formatTimestamp(timestamp)}\nLatitude: $latitude\nLongitude: $longitude'),
              );
            },
          );
        },
      ),
    );
  }
}
