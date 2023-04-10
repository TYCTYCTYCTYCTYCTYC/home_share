import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/pages/login_page.dart';
import 'package:home_share/profile/avatar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:date_time_picker/date_time_picker.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _phone = '';
  String _roomNumber = '';
  DateTime? _birthday;

  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  final _birthdayController = TextEditingController();
  final _birthdayFocusNode = FocusNode();

  final _roomNumberController = TextEditingController();
  final _roomNumberFocusNode = FocusNode();

  String? _avatarUrl;
  var _loading = false;
  bool _showSaveButton = false;

  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single() as Map;

      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      Fluttertoast.showToast(
        msg: 'Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected exception occurred');
    }

    setState(() {
      _loading = false;
    });
  }

  // /// Called when user taps `Update` button
  // Future<void> _updateProfile() async {
  //   setState(() {
  //     _loading = true;
  //   });

  //   final user = supabase.auth.currentUser;
  //   final updates = {
  //     'id': user!.id,
  //     'updated_at': DateTime.now().toIso8601String(),
  //   };
  //   try {
  //     await supabase.from('profiles').upsert(updates);
  //     if (mounted) {
  //       Fluttertoast.showToast(
  //         msg: 'Successfully update profile',
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.amber,
  //         textColor: Colors.black,
  //         fontSize: 16.0,
  //       );
  //     }
  //   } on PostgrestException catch (error) {
  //     Fluttertoast.showToast(
  //       msg: 'error',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.amber,
  //       textColor: Colors.black,
  //       fontSize: 16.0,
  //     );
  //   } catch (error) {
  //     //context.showErrorSnackBar(message: 'Unexpeted error occurred');
  //   }
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'profile image updated',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.amber,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    } on PostgrestException catch (error) {
      Fluttertoast.showToast(
        msg: 'error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

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
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
    _birthdayFocusNode.addListener(() {
      setState(() {});
    });
    _roomNumberFocusNode.addListener(() {
      setState(() {});
    });

    _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();

    _phoneController.dispose();
    _phoneFocusNode.dispose();

    _birthdayController.dispose();
    _birthdayFocusNode.dispose();

    _roomNumberController.dispose();
    _roomNumberFocusNode.dispose();

    super.dispose();
  }

  void getProfileData() async {
    //get from authentication table
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;
    final currentUserEmail = currentUser?.email ?? '';

    final response = await supabase
        .from('profiles')
        .select('username,phone_number,birthdate,room_number')
        .eq('id', currentUserId)
        .execute();

    print(response.data);
    final firstElement = response.data[0];
    final birthdate = firstElement['birthdate'];
    print(birthdate.runtimeType);

    if (response.data != null) {
      final List<dynamic> data = response.data!;
      setState(() {
        _username = data[0]['username'];
        _nameController.text = _username;

        _emailController.text = currentUserEmail;

        _phone = data[0]['phone_number'];
        _phoneController.text = _phone;

        _birthday = DateTime.tryParse(data[0]['birthdate']);
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(_birthday!);

        _roomNumber = data[0]['room_number'];
        _roomNumberController.text = _roomNumber;
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Avatar(
                      imageUrl: _avatarUrl,
                      onUpload: _onUpload,
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF103465),
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 5.0),
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              focusNode: _nameFocusNode,
                              controller: _nameController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'please enter your name';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value ?? '';
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (_nameFocusNode.hasFocus) ? true : false,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF103465),
                              ),
                              child: Text('save'),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _formKey.currentState?.save();

                                  final response = await supabase
                                      .from('profiles')
                                      .update({'username': _username})
                                      .eq('id', currentUserId)
                                      .execute();

                                  _nameFocusNode.unfocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF103465),
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 5.0),
                          child: Icon(Icons.email, color: Colors.black),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
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
                          ),
                        ),
                        Visibility(
                          visible: (_emailFocusNode.hasFocus) ? true : false,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF103465),
                              ),
                              child: Text('save'),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  final newEmail = _emailController.text.trim();
                                  _emailFocusNode.unfocus();
                                  bool isConfirmed = await showDialog(
                                    context: context,
                                    builder: (BuildContext contex) {
                                      return AlertDialog(
                                        title: Text('Confirm Email Update'),
                                        content: Text(
                                            'Are you sure you want to update your email? (by doing so, you will be logged out.)'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Update'),
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (isConfirmed != null && isConfirmed) {
                                    await updateUserAndNavigateToLoginPage(
                                        context, newEmail);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF103465),
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 5.0),
                          child: Icon(Icons.phone, color: Colors.black),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              focusNode: _phoneFocusNode,
                              controller: _phoneController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'please enter your phone number';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _phone = value ?? '';
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (_phoneFocusNode.hasFocus) ? true : false,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF103465),
                              ),
                              child: Text('save'),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _formKey.currentState?.save();

                                  final response = await supabase
                                      .from('profiles')
                                      .update({'phone_number': _phone})
                                      .eq('id', currentUserId)
                                      .execute();

                                  _nameFocusNode.unfocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF103465),
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 5.0),
                          child: Icon(Icons.cake, color: Colors.black),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Container(
                              height: 50, // set a fixed height
                              width: double.infinity,
                              child: FormBuilderDateTimePicker(
                                name: 'birthdate',
                                controller: _birthdayController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                format: DateFormat('yyyy-MM-dd'),
                                focusNode: _birthdayFocusNode,
                                inputType: InputType.date,
                                onChanged: (value) {
                                  setState(() {
                                    _birthday = value;
                                    _showSaveButton = true;
                                  });
                                },
                                onSaved: (value) {
                                  if (value != null) {
                                    _birthday = value;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _showSaveButton,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF103465),
                              ),
                              child: Text('Save'),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _formKey.currentState?.save();

                                  final response = await supabase
                                      .from('profiles')
                                      .update({
                                        'birthdate':
                                            _birthday!.toIso8601String()
                                      })
                                      .eq('id', currentUserId)
                                      .execute();
                                }
                                setState(() {
                                  _showSaveButton = false;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF103465),
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 5.0),
                          child: Icon(Icons.key, color: Colors.black),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              focusNode: _roomNumberFocusNode,
                              controller: _roomNumberController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'please enter your phone number';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _roomNumber = value ?? '';
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              (_roomNumberFocusNode.hasFocus) ? true : false,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF103465),
                              ),
                              child: Text('save'),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _formKey.currentState?.save();

                                  final response = await supabase
                                      .from('profiles')
                                      .update({'room_number': _roomNumber})
                                      .eq('id', currentUserId)
                                      .execute();

                                  _roomNumberFocusNode.unfocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

Future<void> updateUserAndNavigateToLoginPage(
    BuildContext context, String newEmail) async {
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
