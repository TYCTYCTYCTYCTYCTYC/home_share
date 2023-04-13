import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/home.dart';
import 'package:home_share/pages/create_or_join.dart';


class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _homeNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _homeNameController.addListener(_validateInputs);
    _addressController.addListener(_validateInputs);
  }

    @override
  void dispose() {
    _homeNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

    void _validateInputs() {
    final homeName = _homeNameController.text;
    final address = _addressController.text;
    setState(() {
      _canSubmit = homeName.isNotEmpty && address.isNotEmpty;
    });
  }

  //add this to check for null
  //final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Home'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _homeNameController,
                decoration: const InputDecoration(
                  labelText: 'Home Name',
                  labelStyle: TextStyle(color: Colors.amber),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF103465),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.amber,
                    ),
                  ),
                ),
                //validator: _validateHomeName,
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.amber),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF103465),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSubmit ? () async {
                        if (_formKey.currentState!.validate()) {
                          final homeName = _homeNameController.text;
                          final address = _addressController.text;

                          final currentUser =
                              Supabase.instance.client.auth.currentUser;
                          final userId = currentUser?.id;

                          await Supabase.instance.client
                              .rpc('create_home_with_user_id', params: {
                            'home_name': homeName,
                            'home_address': address,
                            'user_id': userId,
                          });

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => Home(initialIndex: 0)),
                            (route) => false,
                          );
                        }
                      } : null,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF103465)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.amber),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}











