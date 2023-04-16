import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/main.dart';
import 'package:home_share/home.dart';
import 'package:file_picker/file_picker.dart';

class FridgeFormPage extends StatefulWidget {
  const FridgeFormPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const FridgeFormPage());
  }

  @override
  _FridgeFormPageState createState() => _FridgeFormPageState();
}

class _FridgeFormPageState extends State<FridgeFormPage> {
  String? _category;
  String? _description;
  String? _item_name;
  DateTime? _expiry_date;
  File? _image;

  static String supabaseURL = "https://mcedvwisatrnerrojfbe.supabase.co";
  static String supabaseKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jZWR2d2lzYXRybmVycm9qZmJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODA1NDExMjksImV4cCI6MTk5NjExNzEyOX0.zbYqEmU2OtBkl1B_qbQcaKOlPDMfD3UGP02I12ZE_a4";

  final SupabaseClient client = SupabaseClient(supabaseURL, supabaseKey);
  bool uploadState = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Category'),
      value: _category,
      onChanged: (newValue) => setState(() => _category = newValue),
      items: <String>[
        'Meat',
        'Vegetable',
        'Beverage',
        'Food',
        'Fruit',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }


  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _image = File(pickedImage.path);
      await client.storage
          .from("image")
          .upload(pickedImage.path, _image!)
          .then((value) {
        print(value);
        setState(() {
          uploadState = true;
        });
      });
    }
  }

  // Future<void> _uploadImage() async {
  //   String url = "https://mcedvwisatrnerrojfbe.supabase.co";
  //   var request = url;
  //   request.files.add(await http.MultipartFile.fromPath(
  //       'image', _image?.path)); // Add the image file to the request
  //   var response = await request.send();
  //   if (response.statusCode == 200) {
  //     // Image uploaded successfully
  //     print('Image uploaded successfully');
  //   } else {
  //     // Handle error
  //     print('Failed to upload image');
  //   }
  // }

  // // Function to upload the picked image to a server or storage service
  // Future<void> uploadImageToSupabaseStorage(File imageFile) async {
  //   try {
  //     String fileName = DateTime.now()
  //         .millisecondsSinceEpoch
  //         .toString(); // Set a unique file name
  //     String uploadPath =
  //         'public/$fileName'; // Set the upload path in Supabase Storage
  //     final storage = Supabase.instance.client.storage;
  //     final response = await client.storage.from("image").upload(
  //         imageFile.images.first.path,
  //         imageFile); // Use the upload() method to upload the file
  //     if (response.error == null) {
  //       String downloadUrl = response.data?.url ?? '';
  //       print('Image uploaded successfully. Download URL: $downloadUrl');
  //     } else {
  //       print('Error uploading image to Supabase Storage: ${response.error}');
  //     }
  //   } catch (error) {
  //     print('Error uploading image to Supabase Storage: $error');
  //   }
  // }

  Widget _buildImageUploadField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _image != null
            ? Image.file(_image!)
            : Container(
                child: Column(
                children: [
                  Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        uploadState = false;
                      });
                      _pickImageFromGallery();
                    },
                    child: Text('Upload Image'),
                  ),
                  uploadState
                      ? Text("Upload Completed")
                      : CircularProgressIndicator()
                ],
              )),
      ],
    );
  }

  Widget _buildItemNameField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Item Name'),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter item name.';
        }
        return null;
      },
      onChanged: (newValue) => setState(() => _item_name = newValue),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Item Description'),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter item description';
        }
        return null;
      },
      onChanged: (newValue) => setState(() => _description = newValue),
    );
  }

  Widget _buildExpiryDateField() {
    return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF103465),
            onPrimary: Colors.white,
          ),
        ),
        child: DateTimePicker(
          type: DateTimePickerType.date,
          initialValue: _expiry_date.toString(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          dateLabelText: 'Expiry Date',
          onChanged: (value) {
            setState(() {
              _expiry_date = DateTime.parse(value);
            });
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please state the expiry date';
            }
            return null;
          },
          onSaved: (value) => _expiry_date = DateTime.parse(value!),
        ));
  }

  // Widget _buildEffortPointsField() {
  //   return DropdownButtonFormField<int>(
  //     decoration: const InputDecoration(labelText: 'Effort points'),
  //     value: _effortPoints,
  //     onChanged: (newValue) => setState(() => _effortPoints = newValue),
  //     items: <int>[1, 2, 3].map<DropdownMenuItem<int>>((int value) {
  //       return DropdownMenuItem<int>(
  //         value: value,
  //         child: Text(value.toString()),
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: ElevatedButton(
          onPressed: () async {
            if ((_image == null) ||
                (_category?.isEmpty ?? true) ||
                (_description?.isEmpty ?? true) ||
                (_expiry_date == null) ||
                (_item_name == null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please fill in all fields.',
                      style: GoogleFonts.arvo(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                  backgroundColor: Colors.amber,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              final currentUser = Supabase.instance.client.auth.currentUser;
              final userId = currentUser?.id;

              final response = await supabase.from('fridge').insert({
                'user_id': userId,
                'category': _category,
                'item_name': _item_name,
                'description': _description,
                'item_image_url': _image?.path,
                'date_expiring': _expiry_date.toString().substring(0, 10),
              }).execute();

              if (response.status == 201) {
                Fluttertoast.showToast(
                    msg: 'Item added successfully.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.amber,
                    textColor: Colors.black,
                    fontSize: 16.0);
              } else {
                Fluttertoast.showToast(
                    msg: 'Failed to add item.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey,
                    textColor: Colors.black,
                    fontSize: 16.0);
                throw Exception('Failed to add item: ${response.status}');
              }

              Navigator.of(context).push(Home.route(initialIndex: 2));
            }

            return;
          },
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF103465), // Set the background color here
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Done',
                  style: GoogleFonts.arvo(
                      textStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8.0),
              const Icon(Icons.check),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF103465),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Add a new item',
            style: GoogleFonts.arvo(
                textStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCategoryField(),
                const SizedBox(height: 16.0),
                _buildItemNameField(),
                const SizedBox(height: 16.0),
                _buildDescriptionField(),
                const SizedBox(height: 16.0),
                _buildExpiryDateField(),
                const SizedBox(height: 16.0),
                _buildImageUploadField(),
                const SizedBox(height: 16.0),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
