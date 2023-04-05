import 'package:flutter/material.dart';
import 'package:home_share/fridge.dart';
import 'package:home_share/chores.dart';
import 'package:home_share/schedule.dart';
import 'package:home_share/profile.dart';
import 'package:home_share/fridge.dart';
import 'package:home_share/dashboard.dart';
import 'package:home_share/main.dart';
import 'package:home_share/pages/create_or_join.dart';
import 'package:home_share/create_new_home.dart';
import 'package:home_share/join_existing_home.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const Home());
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final screen = [
    const DashBoard(),
    const Fridge(),
    const Chores(),
    const Schedule(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('HomeShare', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF103465),
      ),
      body: screen[_selectedIndex],
      backgroundColor: Color(0xFF103465),
      bottomNavigationBar: GNav(
          backgroundColor: Color(0xFF103465),
          color: Colors.white,
          activeColor: Colors.black,
          tabBackgroundColor: Colors.amber,
          iconSize: 24,
          tabMargin: EdgeInsets.symmetric(vertical: 8),
          gap: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          tabs: const [
            GButton(
              icon: Icons.home_outlined,
              text: 'Home',
            ),
            GButton(
              icon: Icons.kitchen_outlined,
              text: 'Fridge',
            ),
            GButton(
              icon: Icons.cleaning_services_outlined,
              text: 'chores',
            ),
            GButton(
              icon: Icons.date_range,
              text: 'Schedule',
            ),
            GButton(
              icon: Icons.account_circle_outlined,
              text: 'Profile',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
    );
  }
}
