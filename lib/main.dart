import 'package:flutter/material.dart';

import 'package:home_share/home.dart';

//global variables

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Home()));
}
