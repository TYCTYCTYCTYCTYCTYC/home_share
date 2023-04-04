// import 'dart:html';

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

  Future<void> loadDB() async {
    final response = await supabase.from('profiles').select('username');
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
          appBar: AppBar(),
          backgroundColor: const Color.fromARGB(255, 180, 231, 255),
          body: Container(
              //code here
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Schedule Page',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _counter++;
                  });
                },
                child: Text('Click me!'),
              ),
              Container(
                height: 300,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 0.1,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    children: _accounts.map((account) {
                      return InkWell(
                        onTap: () {
                          // show drop down box loading image
                        },
                        child: Column(
                          children: [
                            Image.asset('assets/images/icon.png'),
                            Text(account['username']),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ))),
        ));
  }

  // @override
  // bool get wantKeepAlive => true;
}
