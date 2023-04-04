import 'package:flutter/material.dart';

import 'package:home_share/main.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  int _counter = 0;

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
            ],
          ))),
        ));
  }

  // @override
  // bool get wantKeepAlive => true;
}
