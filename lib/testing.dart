import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/pages/login_page.dart';


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
    final currentUserEmail = currentUser?.email ?? '';
    final response = await supabase
        .from('profiles')
        .select('username')
        .eq('id', currentUserId)
        .execute();
    if (response.data != null) {
      final List<dynamic> data = response.data!;
      setState(() {
        _username = data[0]['username'];
        _nameController.text = _username;
        //_email = data[0]['email'];
        _emailController.text = currentUserEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;

    //get the current user email to display in the application
    final currentUserEmail = currentUser?.email;

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
                      final response = await supabase
                          .from('profiles')
                          .update({'username': _username})
                          .eq('id', currentUserId)
                          .execute();
                      // Hide the button after submission
                      _nameFocusNode.unfocus();
                    }
                  },
                ),
              ),
              TextFormField(
                focusNode: _emailFocusNode,
                controller: _emailController,
                //initialValue: currentUserEmail,
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
                  child: Text('Update Email'),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final newEmail = _emailController.text.trim();
                      _emailFocusNode.unfocus();
                      bool isConfirmed = await showDialog(
                        context: context,
                        builder: (BuildContext contex){
                          return AlertDialog(
                            title: Text('Confirm Email Update'),
                            content: Text('Are you sure you want to update your email?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: (){
                                  Navigator.pop(context, false);
                                },
                              ),
                              TextButton(
                                child: Text('Update'),
                                onPressed:(){
                                  Navigator.pop(context, true);
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if(isConfirmed != null && isConfirmed){
                        await updateUserAndNavigateToLoginPage(context, newEmail);
                      }
                      // await updateUserAndNavigateToLoginPage(context, newEmail);
                      // _emailFocusNode.unfocus();
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


Future<void> updateUserAndNavigateToLoginPage(BuildContext context, String newEmail) async {
  final currentUser = Supabase.instance.client.auth.currentUser;
  final currentUserId = currentUser?.id;
  final auth = Supabase.instance.client.auth;

  if (currentUser != null) {
    final updatedUser = await auth.updateUser(
      UserAttributes(email: newEmail),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  } else {
    Fluttertoast.showToast(
      msg: 'Email cannot be updated',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.amber,
      textColor: Colors.black,
      fontSize: 16.0,
    );
    // user is not authenticated
  }
}