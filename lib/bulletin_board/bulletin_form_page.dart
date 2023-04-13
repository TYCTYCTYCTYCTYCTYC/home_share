import 'package:flutter/material.dart';
import 'package:home_share/bulletin_board/bulletin_board.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:home_share/main.dart';

class BulletinFormPage extends StatefulWidget {
  const BulletinFormPage({Key? key}) : super(key: key);
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const BulletinFormPage());
  }

  @override
  _BulletinFormPageState createState() => _BulletinFormPageState();
}

class _BulletinFormPageState extends State<BulletinFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> _submitPost() async {
    final title = _titleController.text;
    final message = _messageController.text;
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;

    try {
      final response = await supabase.from('bulletin_board').insert(
          {'user_id': userId, 'title': title, 'message': message}).execute();

      if (response.status == 201) {
        Fluttertoast.showToast(
            msg: 'Bulletin message created successfully.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.amber,
            textColor: Colors.black,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to create bulletin message.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.black,
            fontSize: 16.0);
        throw Exception('Failed to create bulletin message: ${response.status}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting post: $e'),
        ),
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BulletinBoard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF103465),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(BulletinBoard.route());
          },
        ),
        title: Text('Create a new bulletin message',
            style: GoogleFonts.arvo(
                textStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                controller: _titleController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Message',
                ),
                controller: _messageController,
                maxLines: null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if ((_titleController.text?.isEmpty ?? true) ||
                      (_messageController.text?.isEmpty ?? true)) {
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
                    _submitPost();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary:
                      const Color(0xFF103465), // Set the background color here
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Done',
                        style: GoogleFonts.arvo(
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
