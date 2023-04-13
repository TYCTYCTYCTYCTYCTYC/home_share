import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/home.dart';
import 'package:home_share/pages/create_or_join.dart';

class JoinHomeScreen extends StatelessWidget {
  JoinHomeScreen({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => JoinHomeScreen());
  }

  final _codeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join an existing home'),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF103465),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const CreateOrJoin()));
            }),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Home Code:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 350,
                      child: TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Home Code',
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () async {
                      final homeCode = _codeController.text;
                      if (_codeController.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Please enter a home code!',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Colors.grey,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );
                        return;
                      }
                      try {
                        final homeQuery = await Supabase.instance.client
                            .from('home')
                            .select()
                            .eq('home_code', homeCode)
                            .execute();
                      } catch (e) {
                        print('Error fetching home query: $e');
                        FocusScope.of(context).unfocus();
                        Fluttertoast.showToast(
                            msg:
                                'Home does not exist! Consider creating your own home.',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 2,
                            backgroundColor: Colors.grey,
                            textColor: Colors.black,
                            fontSize: 16.0);
                        return;
                      }

                      final currentUser =
                          Supabase.instance.client.auth.currentUser;
                      final userId = currentUser?.id;

                      await Supabase.instance.client
                          .rpc('join_home_with_user_id', params: {
                        'home_code': homeCode,
                        'user_id': userId,
                      });

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => Home(initialIndex: 0)),
                        (route) => false,
                      );
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(const Size(0, 40)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF103465)),
                    ),
                    child: const Text('Join Home'),
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
