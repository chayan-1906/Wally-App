import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AddWallpaperScreen extends StatefulWidget {
  const AddWallpaperScreen({Key? key}) : super(key: key);

  @override
  _AddWallpaperScreenState createState() => _AddWallpaperScreenState();
}

class _AddWallpaperScreenState extends State<AddWallpaperScreen> {
  File? _image;
  List<String> labelsInString = [];
  final ImageLabeler imageLabeler = FirebaseVision.instance.imageLabeler();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool _isUploading = false;
  bool _isCompletedUploading = false;

  void _loadImage() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 95);
    // print(image!.lengthSync());

    final FirebaseVisionImage firebaseVisionImage =
        await FirebaseVisionImage.fromFile(
      File(image!.path),
    );
    List<ImageLabel> labels =
        await imageLabeler.processImage(firebaseVisionImage);
    labelsInString = [];
    for (var label in labels) {
      print('${label.text} [${label.confidence}]');
      labelsInString.add(label.text);
    }
    setState(() {
      _image = File(image.path);
    });
  }

  void _uploadWallpaper() async {
    if (_image != null) {
      // upload image
      String fileName = path.basename(_image!.path);
      print(fileName);
      User user = await _firebaseAuth.currentUser!;
      String uid = user.uid;
      UploadTask task = _firebaseStorage
          .ref()
          .child("wallpapers")
          .child(uid)
          .child(fileName)
          .putFile(_image!);
      task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        if (taskSnapshot.state == TaskState.running) {
          setState(() {
            _isUploading = true;
          });
        }
        if (taskSnapshot.state == TaskState.success) {
          setState(() {
            _isUploading = false;
            _isCompletedUploading = true;
            taskSnapshot.ref.getDownloadURL().then((url) {
              _firebaseFirestore.collection('wallpapers').add({
                'url': url,
                'date': DateTime.now(),
                'uploaded_by': uid,
                'tags': labelsInString,
              });
              Navigator.of(context).pop();
            });
          });
        }
      });
    } else {
      // show dialog
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 8.0,
              title: Text(
                'Error',
                style: GoogleFonts.getFont(
                  'Merriweather',
                  color: Colors.redAccent,
                  letterSpacing: 1.2,
                ),
              ),
              content: Text(
                'Select Image to upload',
                style: GoogleFonts.getFont('Merriweather'),
              ),
              actions: [
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Okay',
                    style: GoogleFonts.getFont('Merriweather'),
                  ),
                ),
              ],
            );
          });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Wallpaper',
          style: GoogleFonts.getFont(
            'Merriweather',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  _loadImage();
                },
                child: _image != null
                    ? Image.file(_image!)
                    : Image(
                        image: AssetImage('assets/images/placeholder.jpg'),
                      ),
              ),
              SizedBox(height: 20.0),
              labelsInString != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 10.0,
                        children: labelsInString.map((label) {
                          return Chip(
                            label: Text(
                              label,
                              style: GoogleFonts.getFont('Merriweather'),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : Container(),
              SizedBox(height: 40.0),
              _isUploading ? Text('Uploading Wallpaper') : Container(),
              _isCompletedUploading ? Text('Wallpaper Uploaded') : Container(),
              SizedBox(height: 40.0),
              RaisedButton(
                onPressed: _uploadWallpaper,
                child: Text(
                  'Upload Wallpaper',
                  style: GoogleFonts.getFont('Merriweather'),
                ),
              ),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}
