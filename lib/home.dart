import 'package:flutter/material.dart';
import 'package:home_share/fridge.dart';
import 'package:home_share/chores.dart';
import 'package:home_share/schedule.dart';
import 'package:home_share/profile.dart';
import 'package:home_share/main.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final screen = [
    HomePage(),
    Fridge(),
    Chores(),
    Schedule(),
    Profile(),
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
          tabs: [
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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Welcome to Home"),
      ),
    );
  }
}
