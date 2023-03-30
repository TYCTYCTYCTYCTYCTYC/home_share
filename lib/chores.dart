import 'package:flutter/material.dart';

import 'package:home_share/main.dart';

class Chores extends StatefulWidget {
  const Chores({super.key});

  @override
  _ChoresState createState() => _ChoresState();
}

class _ChoresState extends State<Chores> {
  @override
  void initState() {
    super.initState();
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
              //DO YOUR CODE HERE
              ),
        ));
  }
}
