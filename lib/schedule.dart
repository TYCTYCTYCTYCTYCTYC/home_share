// import 'dart:html';

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import 'mySchedule.dart';
import 'otherUserSchedule.dart';

Color clr = Color.fromARGB(255, 165, 198, 255);
Color clr2 = Colors.white;
Color clr3 = Colors.blueAccent;

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  int _counter = 0;
  String? expandedID = null;
  List<dynamic> _accounts = [];
  List<dynamic> accountsBefore = [];
  List<dynamic> accountsAfter = [];
  // double height = MediaQuery.of(context).size.height;
  // double width = MediaQuery.of(context).size.width;
  late final userId;
  dynamic curProfile = null;
  int selectedIndex = 0;
  int rowIndex = 0;
  String? _scheduleUrl = null;
  var _loading = false;

  Future<void> _getMySchedule() async {
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

      _scheduleUrl = (data['schedule_url'] ?? '') as String;
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
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> loadDB() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      userId = currentUser?.id;

      //get home_id
      final response = await supabase
          .from('user_home')
          .select('home_id')
          .eq('user_id', userId)
          .single()
          .execute();

      final homeId = response.data['home_id'] as int;

      final response2 = await supabase
          .from('profiles')
          .select('*, user_home!inner(*)')
          .eq('user_home.home_id', homeId)
          .execute();

      setState(() {
        curProfile = response2.data.firstWhere(
            (account) => account['id'] == userId,
            orElse: () => null);
        response2.data.removeWhere((account) => account['id'] == userId);

        _accounts = response2.data as List<dynamic>;
      });
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
  }

  Future<void> _onUpload(String scheduleUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'schedule_url': scheduleUrl,
      });
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'schedule image updated',
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
        msg: 'Error updating schedule image',
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

    if (mounted) {
      setState(() {
        _scheduleUrl = scheduleUrl;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadDB();
    _getMySchedule();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.width / 5;
    if (expandedID != null) {
      selectedIndex =
          _accounts.indexWhere((account) => account['id'] == expandedID);
      rowIndex = min((selectedIndex ~/ 3) * 3 + 2, _accounts.length - 1);
    }
    if (_accounts.length != 0) {
      if (rowIndex != 0) {
        accountsBefore = _accounts.sublist(0, rowIndex + 1);
        accountsAfter = _accounts.sublist(rowIndex + 1);
      } else {
        accountsBefore = _accounts;
      }
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "HomeShare",
        home: Scaffold(
          backgroundColor: clr2,
          body: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                height: height,
                color: clr,
              ),
              Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: height,
                        color: clr,
                      ),
                      Container(
                        height: height,
                        color: clr2,
                      ),
                    ],
                  ),
                  Center(child: cropCircleImage(context, curProfile, 2))
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                    child: Column(
                  children: [
                    const Text(
                      'Your current schedule',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    // if (curProfile != null)
                    //   Padding(
                    //     padding: EdgeInsets.symmetric(vertical: 20),
                    //     child: Container(
                    //       height: height * 2,
                    //       child: curProfile['schedule_url'] != null
                    //           ? Image.network(
                    //               curProfile['schedule_url'],
                    //               fit: BoxFit.cover,
                    //             )
                    //           : const Text(
                    //               'This user has not uploaded their schedule yet'),
                    //     ),
                    //   ),
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   // onPressed: () async {
                    //   //   await _onUpload('scheduleUrl');
                    //   // },
                    //   child: Text('Upload ' + 'your schedule'),
                    // ),
                    MySchedule(
                      imageUrl: _scheduleUrl,
                      onUpload: _onUpload,
                    ),
                  ],
                )),
              ),
              const Text(
                'Home member schedules',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),

              GridView.count(
                padding: EdgeInsets.zero,
                physics: ScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                // mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                children: _accounts.map((account) {
                  return InkWell(
                      onTap: () {
                        setState(() {
                          // if (expandedID == null) {
                          //   //if there isnt any expanded profile
                          //   expandedID = account['id'];
                          // } else if (expandedID == account['id']) {
                          //   //if clicking already expanded profile
                          //   expandedID = null;
                          // } else {
                          //   //else clicking on a profile when there is already an expanded profile
                          //   expandedID = account['id'];
                          // }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtherUserSchedule(account: account),
                            ),
                          );
                        });
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: expandedID == account['id'] ? clr3 : null,
                          // border: expandedID == account['id']
                          //     ? Border(
                          //         top: BorderSide(
                          //             width: 3.0, color: clr3),
                          //         left: BorderSide(
                          //             width: 3.0, color: clr3),
                          //         right: BorderSide(
                          //             width: 3.0, color: clr3),
                          //       )
                          //     : null,
                        ),
                        child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                child: cropCircleImage(context, account, 3),
                              ),
                              Text(account['username']),
                            ],
                          ),
                        ),
                      ));
                }).toList(),
              ),
              // //insert container here
              // if (expandedID != null)
              //   Container(
              //       height: height * 2,
              //       padding: EdgeInsets.symmetric(vertical: 20.0),
              //       decoration: BoxDecoration(
              //         color: clr,
              //         border: Border(
              //             top: BorderSide(width: 3.0, color: clr3),
              //             bottom: BorderSide(width: 3.0, color: clr3)),
              //       ),
              //       child: Center(
              //         child: _accounts[selectedIndex]['schedule_url'] != null
              //             ? Image.network(
              //                 _accounts[selectedIndex]['schedule_url'],
              //                 fit: BoxFit.cover,
              //               )
              //             : const Text(
              //                 'This user has not uploaded their schedule yet'),
              //       )),

              // GridView.count(
              //   padding: EdgeInsets.zero,
              //   physics: ScrollPhysics(),
              //   shrinkWrap: true,
              //   crossAxisCount: 3,
              //   childAspectRatio: 0.75,
              //   // mainAxisSpacing: 10.0,
              //   crossAxisSpacing: 10.0,
              //   children: accountsAfter.map((account) {
              //     return InkWell(
              //       onTap: () {
              //         // setState(() {
              //         //   if (expandedID == null) {
              //         //     //if there isnt any expanded profile
              //         //     expandedID = account['id'];
              //         //   } else if (expandedID == account['id']) {
              //         //     //if clicking already expanded profile
              //         //     expandedID = null;
              //         //   } else {
              //         //     //else clicking on a profile when there is already an expanded profile
              //         //     expandedID = account['id'];
              //         //   }
              //         // });
              //       },
              //       child: Column(
              //         children: [
              //           Padding(
              //             padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              //             child: cropCircleImage(context, account, 3),
              //           ),
              //           Text(account['username']),
              //         ],
              //       ),
              //     );
              //   }).toList(),
              // ),
            ],
          )),
        ));
  }
}

Widget cropCircleImage(BuildContext context, final account, double val) {
  double size = MediaQuery.of(context).size.width / val;
  if (account == null) {
    return SizedBox(
        height: size,
        width: size,
        child: CircleAvatar(
          radius: size,
          backgroundImage: null,
          backgroundColor: Colors.blueGrey,
        ));
  }
  return account['avatar_url'] != null
      ? SizedBox(
          height: size,
          width: size,
          child: ClipOval(
              child: Image.network(
            account['avatar_url'],
            width: size,
            height: size,
            fit: BoxFit.cover,
          )),
        )
      : SizedBox(
          height: size,
          width: size,
          child: CircleAvatar(
            radius: size,
            backgroundImage: null,
            backgroundColor: Colors.blueGrey,
            child: Text(
              account['username'][0].toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: clr2, fontSize: 30),
            ),
          ));
}
