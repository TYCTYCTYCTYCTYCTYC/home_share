import 'package:flutter/material.dart';
import 'package:home_share/home.dart';
import 'package:home_share/chores/chores.dart';
import 'package:home_share/fridge.dart';
import 'package:home_share/profile.dart';
import 'package:home_share/schedule.dart';
import 'package:home_share/chores/main_chores_page.dart';
import 'package:home_share/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//global variables

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mcedvwisatrnerrojfbe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jZWR2d2lzYXRybmVycm9qZmJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODA1NDExMjksImV4cCI6MTk5NjExNzEyOX0.zbYqEmU2OtBkl1B_qbQcaKOlPDMfD3UGP02I12ZE_a4',
  );
  final supabaseClient = SupabaseClient(
    'https://mcedvwisatrnerrojfbe.supabase.co', // <- Copy and paste your URL
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jZWR2d2lzYXRybmVycm9qZmJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODA1NDExMjksImV4cCI6MTk5NjExNzEyOX0.zbYqEmU2OtBkl1B_qbQcaKOlPDMfD3UGP02I12ZE_a4', // <- Copy and paste your public key
  );
  //await Firebase.initializeApp();/
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

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
      home: const SplashPage(),
    );
  }
}
