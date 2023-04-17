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
  List<dynamic> _accounts = [];
  List<dynamic> accountsBefore = [];
  List<dynamic> accountsAfter = [];
  late final userId;
  dynamic curProfile = null;
  int selectedIndex = 0;
  int rowIndex = 0;
  String? _scheduleUrl = null;

  Future<void> _getMySchedule() async {
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OtherUserSchedule(account: account),
                          ),
                        );
                      });
                    },
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
                  );
                }).toList(),
              ),
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
