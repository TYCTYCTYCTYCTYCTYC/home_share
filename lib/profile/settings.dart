import 'package:flutter/material.dart';
import 'package:home_share/pages/login_page.dart';
import 'package:home_share/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  String _homeName = '';
  String _homeCode = '';
  String _homeAddress = '';

  final _homeNameController = TextEditingController();
  final _homeNameFocusNode = FocusNode();

  final _homeCodeController = TextEditingController();
  final _homeCodeFocusNode = FocusNode();

  final _homeAddressController = TextEditingController();
  final _homeAddressFocusNode = FocusNode();

  var _loading = false;

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

      //maybe still need to add something
    } catch (error) {
      print('Eror getting the user data');
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    getProfileData();

    _homeNameFocusNode.addListener(() {
      setState(() {});
    });

    _homeCodeFocusNode.addListener(() {
      setState(() {});
    });

    _homeAddressFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _homeNameController.dispose();
    _homeNameFocusNode.dispose();

    _homeCodeController.dispose();
    _homeCodeFocusNode.dispose();

    _homeAddressController.dispose();
    _homeAddressFocusNode.dispose();

    super.dispose();
  }

  void getProfileData() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;

    final response = await supabase
        .from('user_home')
        .select('home_id')
        .eq('user_id', currentUserId)
        .execute();

    final home_id = response.data[0]['home_id'];

    final response2 = await supabase
        .from('home')
        .select('name, code, address')
        .eq('id', home_id)
        .execute();

    if (response.data != null) {
      //response2 will return name, code, address
      final List<dynamic> data = response2.data!;
      setState(() {
        _homeName = data[0]['name'];
        _homeNameController.text = _homeName;

        _homeCode = data[0]['code'];
        _homeCodeController.text = _homeCode;

        _homeAddress = data[0]['address'];
        _homeAddressController.text = _homeAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF103465),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.home, color: Colors.black),
                  title: Text(
                    'Home Settings',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
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
                        child: Text('Name:',
                            style: TextStyle(color: Colors.black)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            focusNode: _homeNameFocusNode,
                            controller: _homeNameController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'please enter your home name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _homeName = value ?? '';
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_homeNameFocusNode.hasFocus) ? true : false,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF103465),
                            ),
                            child: Text('save'),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();

                                // final response = await supabase
                                //     .from('home')
                                //     .update({'name': _homeName})
                                //     .eq('id', currentUserId)
                                //     .execute();

                                final response = await supabase
                                    .from('user_home')
                                    .select('home_id')
                                    .eq('user_id', currentUserId)
                                    .execute();

                                final home_id = response.data[0]['home_id'];

                                final response2 = await supabase
                                    .from('home')
                                    .update({'name': _homeName})
                                    .eq('id', home_id)
                                    .execute();

                                _homeNameFocusNode.unfocus();
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
                        child:
                          Text('Code:', style: TextStyle(color: Colors.black)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            focusNode: _homeCodeFocusNode,
                            controller: _homeCodeController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'please enter your home code';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _homeCode = value ?? '';
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_homeCodeFocusNode.hasFocus) ? true : false,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF103465),
                            ),
                            child: Text('save'),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();

                                final response = await supabase
                                    .from('user_home')
                                    .select('home_id')
                                    .eq('user_id', currentUserId)
                                    .execute();

                                final home_id = response.data[0]['home_id'];

                                final response2 = await supabase
                                    .from('home')
                                    .update({'code': _homeCode})
                                    .eq('id', home_id)
                                    .execute();

                                _homeCodeFocusNode.unfocus();
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
                        child:
                            Text('Address:', style: TextStyle(color: Colors.black)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            focusNode: _homeAddressFocusNode,
                            controller: _homeAddressController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'please enter your home address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _homeAddress = value ?? '';
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_homeAddressFocusNode.hasFocus) ? true : false,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF103465),
                            ),
                            child: Text('save'),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();

                                final response = await supabase
                                    .from('user_home')
                                    .select('home_id')
                                    .eq('user_id', currentUserId)
                                    .execute();

                                final home_id = response.data[0]['home_id'];

                                final response2 = await supabase
                                    .from('home')
                                    .update({'address': _homeAddress})
                                    .eq('id', home_id)
                                    .execute();

                                _homeAddressFocusNode.unfocus();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.black),
                  title: const Text('Logout'),
                  onTap:(){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),



              ],
            ),
          ),
        ),
      ),
      // body: SingleChildScrollView(
      //   child: Container(
      //     padding: EdgeInsets.all(16.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const ListTile(
      //           leading: Icon(Icons.home, color: Colors.black),
      //           title: Text(
      //             'Home Settings',
      //             style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      //           ),
      //         ),

      //         Container(
      //           decoration: BoxDecoration(
      //             border: Border.all(
      //               color: Color(0xFF103465),
      //               width: 5.0,
      //             ),
      //             borderRadius: BorderRadius.circular(10.0),
      //           ),
      //         child: Row(
      //           children: [
      //             const Padding(
      //               padding: EdgeInsets.only(left: 10.0),
      //               child: Text('Name:', style: TextStyle(color: Colors.black)),
      //             ),
      //             Expanded(
      //               child: Padding(
      //                 padding: const EdgeInsets.only(left: 5.0),
      //                 child: TextFormField(
      //                   decoration: const InputDecoration(
      //                     border: InputBorder.none,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //         ),

      //         const Text(
      //           'Home Name(name)',
      //           style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      //         ),
      //         const Text(
      //           'Home Code(code)',
      //           style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      //         ),
      //         const Text(
      //           'Home Address(address)',
      //           style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      //         ),

      //                       const SizedBox(height: 50.0),

      //         Text(
      //           'General Settings',
      //           style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(height: 16.0),
      //         SwitchListTile(
      //           title: Text('Dark Mode'),
      //           value: false,
      //           onChanged: (value) {},
      //         ),
      //         Divider(),
      //         Text(
      //           'Account Settings',
      //           style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(height: 16.0),
      //         ListTile(
      //           leading: Icon(Icons.lock),
      //           title: Text('Change Password'),
      //           onTap: () {},
      //         ),

      //         //logout
      //         ListTile(
      //           leading: Icon(Icons.exit_to_app),
      //           title: Text('Logout'),
      //           onTap: () {
      //             Navigator.pushReplacement(
      //               context,
      //               MaterialPageRoute(builder: (context) => const LoginPage()),
      //             );
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
