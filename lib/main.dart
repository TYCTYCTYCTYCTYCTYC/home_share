import 'package:flutter/material.dart';
import 'package:home_share/home.dart';
import 'package:home_share/chores.dart';
import 'package:home_share/fridge.dart';
import 'package:home_share/profile.dart';
import 'package:home_share/schedule.dart';

//global variables

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.blue,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.black),
            color: Colors.white,
          )),
      home: const Home(),
    );
  }
}
