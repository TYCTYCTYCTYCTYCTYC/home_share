// import 'dart:html';

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:home_share/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  int _counter = 0;
  List<dynamic> _accounts = [];
  // double height = MediaQuery.of(context).size.height;
  // double width = MediaQuery.of(context).size.width;

  Future<void> loadDB() async {
    final response = await supabase.from('profiles').select();
    setState(() {
      _accounts = response;
    });
  }

  @override
  void initState() {
    super.initState();
    loadDB();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "HomeShare",
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 180, 231, 255),
          body: Column(
            children: <Widget>[
              SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.25,
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children: _accounts.map((account) {
                        return InkWell(
                          onTap: () {
                            // show drop down box loading image
                          },
                          child: Column(
                            children: [
                              // account['avatar_url'] != null
                              //     ? Image.network(
                              //         account['avatar_url']!,
                              //         fit: BoxFit.cover,
                              //       )
                              //     : Image.asset(
                              //         'assets/images/icon.png',
                              //         fit: BoxFit.cover,
                              //       ),
                              cropCircleImage(account['avatar_url'], context),
                              Text(account['username']),
                            ],
                          ),

                          // Column(
//   children: [
//     Image.network(
//       account['avatar_url'] != null ? account['avatar_url'] : 'assets/images/icon.png',
//       fit: BoxFit.cover,
//     ),
//     Text(account['username']),
//   ],
// ),
                        );
                      }).toList(),
                    ),
                  )),
            ],
          ),
        ));
  }

  // @override
  // bool get wantKeepAlive => true;
}

Widget cropCircleImage(String? imageUrl, BuildContext context) {
  return imageUrl != null
      ? ClipOval(
          child: Image.network(
          imageUrl,
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.width / 3,
          fit: BoxFit.cover,
        ))
      : ClipOval(
          child: Image.asset(
            'assets/images/icon.png',
            fit: BoxFit.cover,
          ),
        );
}
