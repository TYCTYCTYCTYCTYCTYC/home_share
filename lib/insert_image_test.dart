import 'dart:io';
import 'dart:async';
import 'package:home_share/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class UploadImagePage extends StatefulWidget {
  const UploadImagePage({Key? key}) : super(key: key);

  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  final _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;

// 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                width: 200,
                height: 200,
              )
            else
              Text('No image selected.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final pickedFile =
                    await _picker.getImage(source: ImageSource.gallery);
                setState(() {
                  _imageFile = pickedFile != null ? File(pickedFile.path) : null;
                });
              },
              child: Text('Select Image'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              child: _isUploading ? CircularProgressIndicator() : Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isUploading = true;
    });

    final storage = supabase.storage.from('image');

    try {
      final response = await storage.upload(
        '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg',
        _imageFile!,
      );
      print(response);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
