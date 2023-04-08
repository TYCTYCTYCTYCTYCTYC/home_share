import 'package:flutter/material.dart';
import 'package:home_share/fridge.dart';
import 'package:home_share/chores/chores.dart';
import 'package:home_share/insert_image_test.dart';
import 'package:home_share/schedule.dart';
import 'package:home_share/profile.dart';
import 'package:home_share/fridge.dart';
import 'package:home_share/chores/main_chores_page.dart';
import 'package:home_share/dashboard.dart';
import 'package:home_share/main.dart';
import 'package:home_share/pages/create_or_join.dart';
import 'package:home_share/create_new_home.dart';
import 'package:home_share/join_existing_home.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/setting.dart';

class Home extends StatefulWidget {
  final int initialIndex;

  const Home({Key? key, this.initialIndex = 0}) : super(key: key);

  static Route<void> route({int initialIndex = 0}) {
    return MaterialPageRoute(
        builder: (context) => Home(initialIndex: initialIndex));
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final screen = [
    const DashBoard(),
    const Fridge(),
    MainChoresPage(),
    const Schedule(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('HomeShare',
            style: GoogleFonts.arvo(
                textStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        backgroundColor: Color(0xFF103465),
        actions: [
          GestureDetector(
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ),
          ),
        ],
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
              textStyle: GoogleFonts.arvo(fontWeight: FontWeight.bold),
            ),
            GButton(
              icon: Icons.kitchen_outlined,
              text: 'Fridge',
              textStyle: GoogleFonts.arvo(fontWeight: FontWeight.bold),
            ),
            GButton(
              icon: Icons.cleaning_services_outlined,
              text: 'Chores',
              textStyle: GoogleFonts.arvo(fontWeight: FontWeight.bold),
            ),
            GButton(
              icon: Icons.date_range,
              text: 'Schedule',
              textStyle: GoogleFonts.arvo(fontWeight: FontWeight.bold),
            ),
            GButton(
              icon: Icons.account_circle_outlined,
              text: 'Profile',
              textStyle: GoogleFonts.arvo(fontWeight: FontWeight.bold),
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
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome to Home page',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

void _showToast() {
  Fluttertoast.showToast(
    msg: "pressed again to logout",
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
