import 'package:flutter/material.dart';
import 'package:home_share/pages/login_page.dart';
import 'package:home_share/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeMembers {
  final String username;
  final String effortPoints;

  HomeMembers({
    required this.username,
    required this.effortPoints,
  });
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  String _homeName = '';
  String _homeCode = '';
  String _homeAddress = '';
  List<Map<String, dynamic>> usernames = [];

  final _homeNameController = TextEditingController();
  final _homeNameFocusNode = FocusNode();

  final _homeCodeController = TextEditingController();
  final _homeCodeFocusNode = FocusNode();

  final _homeAddressController = TextEditingController();
  final _homeAddressFocusNode = FocusNode();

  bool _loading = false;

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
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Unexpected error occurred',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getProfileData();
    getHomeMembers();
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

    final currentHome = await supabase
        .from('user_home')
        .select('home_id')
        .eq('user_id', currentUserId)
        .execute();

    final home_id = currentHome.data[0]['home_id'];

    final userData = await supabase
        .from('home')
        .select('name, code, address')
        .eq('id', home_id)
        .execute();

    if (userData.data != null) {
      final List<dynamic> data = userData.data!;
      if (mounted) {
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
  }

  void getHomeMembers() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;

    final currentHome = await supabase
        .from('user_home')
        .select('home_id')
        .eq('user_id', userId)
        .single()
        .execute();

    final homeId = currentHome.data['home_id'] as int;

    final allHomeMembers = await supabase
        .from('user_home')
        .select('user_id')
        .eq('home_id', homeId)
        .execute();

    final userIds = allHomeMembers.data
        .map<String>((item) => item['user_id'] as String)
        .toList();

    final profileAndUsername = await supabase
        .from('profiles')
        .select('username, avatar_url')
        .in_('id', userIds)
        .execute();

    final data = profileAndUsername.data as List<dynamic>;
    final updatedUsernames = data
        .map((dynamic item) => {
              'username': item['username'] as String,
              'avatar_url': item['avatar_url'] as String?,
            })
        .toList();

    setState(() {
      usernames = updatedUsernames;
    });
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
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.black),
                  title: Text(
                    'Home Settings',
                    style: GoogleFonts.arvo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                //home detailes
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF103465),
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                        child: Text(
                          'Name:',
                          style: GoogleFonts.arvo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.arvo(
                              fontSize: 16,
                            ),
                            focusNode: _homeNameFocusNode,
                            controller: _homeNameController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your home name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _homeName = value ?? '';
                            },
                            onTap: () {
                              _homeNameController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    _homeNameController.value.text.length,
                              );
                            },
                          ),
                        ),
                      ),

                      //when user click text field, show Save button
                      Visibility(
                        visible: (_homeNameFocusNode.hasFocus) ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF103465),
                            ),
                            child: const Text('Save'),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();

                                final currentHome = await supabase
                                    .from('user_home')
                                    .select('home_id')
                                    .eq('user_id', currentUserId)
                                    .execute();

                                final home_id = currentHome.data[0]['home_id'];

                                await supabase
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
                      color: const Color(0xFF103465),
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                        child: Text(
                          'Code:',
                          style: GoogleFonts.arvo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.arvo(
                              fontSize: 16,
                            ),
                            focusNode: _homeCodeFocusNode,
                            controller: _homeCodeController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your home code';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _homeCode = value ?? '';
                            },
                            onTap: () {
                              _homeCodeController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    _homeCodeController.value.text.length,
                              );
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_homeCodeFocusNode.hasFocus) ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF103465),
                            ),
                            child: const Text('Save'),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();

                                final currentHome = await supabase
                                    .from('user_home')
                                    .select('home_id')
                                    .eq('user_id', currentUserId)
                                    .execute();

                                final home_id = currentHome.data[0]['home_id'];

                                await supabase
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
                      color: const Color(0xFF103465),
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                        child: Text(
                          'Address:',
                          style: GoogleFonts.arvo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.arvo(
                              fontSize: 16,
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
                            onTap: () {
                              _homeAddressController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    _homeAddressController.value.text.length,
                              );
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            (_homeAddressFocusNode.hasFocus) ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF103465),
                            ),
                            child: const Text('Save'),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();

                                final currentHome = await supabase
                                    .from('user_home')
                                    .select('home_id')
                                    .eq('user_id', currentUserId)
                                    .execute();

                                final home_id = currentHome.data[0]['home_id'];

                                await supabase
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
                const SizedBox(height: 10.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF103465),
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 230,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 5.0, top: 5.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Members:',
                            style: GoogleFonts.arvo(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Expanded(
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                        height: usernames.length * 55.0,
                                        child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: usernames.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final username = usernames[index];

                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage: username[
                                                            'avatar_url'] !=
                                                        null
                                                    ? NetworkImage(
                                                        username['avatar_url']!)
                                                    : null,
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                child: username['avatar_url'] ==
                                                        null
                                                    ? Text(
                                                        username['username'][0]
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              title: Text(username['username']),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0.0,
                                                      horizontal: 5.0),
                                            );
                                          },
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
                const SizedBox(height: 30.0),

                //Logout button
                Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                        width: 130,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.redAccent,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.exit_to_app,
                                color: Colors.black),
                            horizontalTitleGap: 1,
                            title: Text(
                              'Logout',
                              style: GoogleFonts.arvo(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            onTap: () async {
                              //clear shared preferences from mobile device upon logout
                              final sharedPreferences =
                                  await SharedPreferences.getInstance();
                              sharedPreferences.clear();

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Confirm Logout"),
                                    content: Text(
                                        "Are you sure you want to logout?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginPage()),
                                          );
                                        },
                                        child: Text("Logout"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
