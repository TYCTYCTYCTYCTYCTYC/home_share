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
  // File? _image;
  late final userId;
  late final homeId;
  late dynamic _imageUrl = null;
  static String supabaseURL = "https://mcedvwisatrnerrojfbe.supabase.co";
  static String supabaseKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jZWR2d2lzYXRybmVycm9qZmJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODA1NDExMjksImV4cCI6MTk5NjExNzEyOX0.zbYqEmU2OtBkl1B_qbQcaKOlPDMfD3UGP02I12ZE_a4";

  final SupabaseClient client = SupabaseClient(supabaseURL, supabaseKey);
  bool uploadState = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> loadDB() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      userId = currentUser?.id;

      //get home_id
      final response = await supabase
          .from('user_home')
          .select('home_id')
          .eq('user_id', userId)
          .single()
          .execute();

      homeId = response.data['home_id'] as int;
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
  }

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
        'Others'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildImageUploadField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _imageUrl != null
            ? Image.network(
                _imageUrl,
                fit: BoxFit.cover,
              )
            : Container(
                child: Column(
                children: [
                  Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        uploadState = false;
                      });
                      await _pickImageFromGallery();
                    },
                    child: Text('Upload Image'),
                  ),
                  if (uploadState) Text("Upload Completed"),
                ],
              )),
      ],
    );
  }

//   // Function to pick an image from the gallery
//   Future<void> _pickImageFromGallery() async {
//     final pickedImage =
//         await ImagePicker().getImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       _image = File(pickedImage.path);
//       await client.storage
//           .from("image")
//           .upload(pickedImage.path, _image!)
//           .then((value) {
//         print(value);
//         setState(() {
//           uploadState = true;
//         });
//       });
//     }
//   }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      // maxWidth: 300,
      // maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;
      await supabase.storage.from('image').uploadBinary(filePath, bytes,
          fileOptions: FileOptions(contentType: imageFile.mimeType));
      final imageUrlResponse = await supabase.storage
          .from('image')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);

      setState(() {
        _imageUrl = imageUrlResponse;
      });
    } on StorageException catch (error) {
      if (mounted) {
        //context.showErrorSnackBar(message: error.message);
      }
    } catch (error) {
      if (mounted) {
        //context.showErrorSnackBar(message: 'Unexpected error occurred');
      }
    }

    setState(() {
      uploadState = true;
    });
  }

// Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final imageFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       // maxWidth: 300,
//       // maxHeight: 300,
//     );
//     if (imageFile == null) {
//       return;
//     }

//     try {
//       final bytes = await imageFile.readAsBytes();
//       final fileExt = imageFile.path.split('.').last;
//       final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
//       final filePath = fileName;
//       await supabase.storage.from('schedule').uploadBinary(
//             filePath,
//             bytes,
//             fileOptions: FileOptions(contentType: imageFile.mimeType),
//           );
//       final imageUrlResponse = await supabase.storage
//           .from('schedule')
//           .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
//       widget.onUpload(imageUrlResponse);
//     } on StorageException catch (error) {
//       if (mounted) {
//         //context.showErrorSnackBar(message: error.message);
//       }
//     } catch (error) {
//       if (mounted) {
//         //context.showErrorSnackBar(message: 'Unexpected error occurred');
//       }
//     }
//   }

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

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: ElevatedButton(
          onPressed: () async {
            if ((_imageUrl == null) ||
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
              // final currentUser = Supabase.instance.client.auth.currentUser;
              // final userId = currentUser?.id;

              final response = await supabase.from('fridge').insert({
                'home_id': homeId,
                'user_id': userId,
                'category': _category,
                'item_name': _item_name,
                'description': _description,
                'item_image_url': _imageUrl,
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

              Navigator.of(context).push(Home.route(initialIndex: 1));
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
  void initState() {
    super.initState();
    loadDB();
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
