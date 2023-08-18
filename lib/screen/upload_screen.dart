import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _uploadSuccessful = false;
  String _latitude = "";
  String _longitude = "";
  String _city = "";
  String _postalCode = "";
  File? _image;
  bool _isLoading = false;

  Future<void> _showImageDialog() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
        });
      }
    } else {
      if (status.isDenied) {
        Fluttertoast.showToast(
            msg: "Camera permission denied",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (status.isPermanentlyDenied) {
        Fluttertoast.showToast(
            msg: "Camera permission denied permanently",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  void _getLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];

          setState(() {
            _latitude = position.latitude.toString();
            _longitude = position.longitude.toString();
            _city = placemark.locality ?? '';
            _postalCode = placemark.postalCode ?? '';
          });
        }
      } catch (e) {
        print('Error during reverse geocoding: $e');
      }
    } else {
      if (status.isDenied) {
        print('Location permission denied by user.');
      } else if (status.isPermanentlyDenied) {
        print('Location permission is permanently denied.');
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose Image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      _getLocation();
      final currentUser = FirebaseAuth.instance.currentUser;

      String? uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

      if (currentUser == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images/${currentUser.uid}_${DateTime.now()}.jpg');

      await storageRef.putFile(_image!);

      final imageUrl = await storageRef.getDownloadURL();

      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);

      userDocRef.collection('attendance').doc(uniqueId).set({
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': _latitude,
        'longitude': _longitude,
        "city": _city,
        "postalcode": _postalCode,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _uploadSuccessful = true;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Upload Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                print('Clicking on image');
                _showImageDialog();
              },
              child: Container(
                alignment: Alignment.center,
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: AssetImage('assets/upload_attendance.png'),
                            fit: BoxFit.contain,
                          ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _uploadSuccessful ? Colors.grey : Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
              child: MaterialButton(
                onPressed: () {
                  onPressed:
                  _uploadSuccessful ? null : _uploadImage();
                },
                child: Text(
                  'UPLOAD',
                  style: TextStyle(
                      color: Colors.white, letterSpacing: 3, fontSize: 20),
                ),
              ),
            ),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
