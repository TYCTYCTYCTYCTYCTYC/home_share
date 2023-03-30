import 'package:flutter/material.dart';

import 'package:home_share/main.dart';

class Fridge extends StatefulWidget {
  const Fridge({super.key});

  @override
  _FridgeState createState() => _FridgeState();
}

class _FridgeState extends State<Fridge> {
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
