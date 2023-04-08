import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/main.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}
//
class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  
  
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    getProfileData();
    _nameFocusNode.addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void getProfileData() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;
    //final currentUserEmail = currentUser?.email;
    final response = await supabase.from('profiles').select('username,email').eq('id', currentUserId).execute();
    if (response.data != null) {
      final List<dynamic> data = response.data!;
      setState(() {
        _username = data[0]['username'];
        _nameController.text = _username;
        _email = data[0]['email'];
        _emailController.text = _email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                focusNode: _nameFocusNode,
                controller: _nameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value ?? '';
                },
              ),
              SizedBox(height: 16.0),
              Visibility(
                visible: (_nameFocusNode.hasFocus) ? true : false,
                child: ElevatedButton(
                  child: Text('Submit Name'),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      // Insert the data to Supabase
                      final response = await supabase.from('profiles').update({'username': _username}).eq('id', currentUserId).execute();
                      // Hide the button after submission
                      _nameFocusNode.unfocus();
                    }
                  },
                ),
              ),
              TextFormField(
                focusNode: _emailFocusNode,
                controller: _emailController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              SizedBox(height: 16.0),
              Visibility(
                visible: (_emailFocusNode.hasFocus) ? true : false,
                child: ElevatedButton(
                  child: Text('Submit Email'),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      // Insert the data to Supabase
                      final response = await supabase.from('profiles').update({'email': _email}).eq('id', currentUserId).execute();
                      // Hide the button after submission
                      _emailFocusNode.unfocus();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

