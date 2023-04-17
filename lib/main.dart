import 'package:flutter/material.dart';
import 'package:home_share/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mcedvwisatrnerrojfbe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jZWR2d2lzYXRybmVycm9qZmJlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4MDU0MTEyOSwiZXhwIjoxOTk2MTE3MTI5fQ.UQ4UywVVts_8E5nMpG4_xDXQQE0kVBhhw4T5iYyC5Q8',
  );
  final supabaseClient = SupabaseClient(
    'https://mcedvwisatrnerrojfbe.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jZWR2d2lzYXRybmVycm9qZmJlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4MDU0MTEyOSwiZXhwIjoxOTk2MTE3MTI5fQ.UQ4UywVVts_8E5nMpG4_xDXQQE0kVBhhw4T5iYyC5Q8', // <- Copy and paste your public key
  );
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
        primaryColor: const Color(0xFF103465),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          color: Colors.white,
        ),
      ),
      home: const SplashPage(),
    );
  }
}
