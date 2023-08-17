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
  String _latitude="";
  String _longitude="";
  String _city="";
  String _postalCode="";
  File? _image;
  bool _isLoading = false;


  // Future<void> _showImageDialog() async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Choose Image Source'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               GestureDetector(
  //                 child: Text('Camera'),
  //                 onTap: () async {
  //                   Navigator.pop(context);
  //                   final pickedImage = await ImagePicker().pickImage(
  //                       source: ImageSource.camera, imageQuality: 50);
  //                   // _setImage(pickedImage);
  //                   setState(() {
  //                     if (pickedImage != null) {
  //                       _image = File(pickedImage.path);
  //                     }
  //                   });
  //                 },
  //               ),
  //               SizedBox(height: 10),
  //               GestureDetector(
  //                 child: Text('Gallery'),
  //                 onTap: () async {
  //                   Navigator.pop(context);
  //                   final pickedImage = await ImagePicker().pickImage(
  //                       source: ImageSource.gallery, imageQuality: 50);
  //                   setState(() {
  //                     if (pickedImage != null) {
  //                       _image = File(pickedImage.path);
  //                     }
  //                   });
  //                   // _setImage(pickedImage);
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
      // Handle denied or restricted permissions
      if (status.isDenied) {
        Fluttertoast.showToast(
            msg: "Camera permission denied",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else if (status.isPermanentlyDenied) {
        // You can show a dialog to guide the user to app settings
        Fluttertoast.showToast(
            msg: "Camera permission denied permanently",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }

  }

  // void _getLocation() async {
  //   PermissionStatus status = await Permission.location.request();
  //   if (status.isGranted) {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //
  //     setState(() {
  //       _latitude = position.latitude.toString();
  //       _longitude = position.longitude.toString();
  //     });
  //   } else {
  //     // Handle denied or restricted permissions
  //     if (status.isDenied) {
  //       // You can show a message to the user
  //       print('Location permission denied by user.');
  //     } else if (status.isPermanentlyDenied) {
  //       // You can show a dialog to guide the user to app settings
  //       print('Location permission is permanently denied.');
  //     }
  //   }
  // }

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
      _isLoading = true; // Show progress indicator
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
        'latitude':_latitude,
        'longitude':_longitude,
        "city":_city,
        "postalcode": _postalCode,

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
    finally{
      setState(() {
        _isLoading = false; // Hide progress indicator
        _image = null; // Clear the image after upload
      });
    }
  }

  // void _setImage(XFile? pickedImage) {
  //   if (pickedImage != null) {
  //     setState(() {
  //       _image = File(pickedImage.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                          image: AssetImage('assets/upload.jpg'),
                          fit: BoxFit.cover,
                        ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(10, 3),
                      blurRadius: 10,
                    )
                  ]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _uploadImage();

            },
            child: Text('UPLOAD'),
          ),
          if (_isLoading) CircularProgressIndicator(),
        ],
      ),
    );
  }
}
