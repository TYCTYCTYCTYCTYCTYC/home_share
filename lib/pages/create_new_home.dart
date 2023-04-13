import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/home.dart';
import 'package:home_share/pages/create_or_join.dart';

class NewHomeScreen extends StatelessWidget {
  NewHomeScreen({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => NewHomeScreen());
  }

  final _homeNameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a new home'),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF103465), // Change the color here
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const CreateOrJoin()));
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _homeNameController,
              decoration: const InputDecoration(
                labelText: 'Home Name',
                labelStyle: TextStyle(color: Colors.black),
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
            const SizedBox(height: 20.0),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(color: Colors.black),
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
                    onPressed: () async {
                      final homeName = _homeNameController.text;
                      final address = _addressController.text;
                      if (homeName.isEmpty || address.isEmpty) {
                        FocusScope.of(context).unfocus();
                        Fluttertoast.showToast(
                          msg: 'Please enter both home name and address.',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Colors.grey,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );
                        return;
                      }
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
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF103465)),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
