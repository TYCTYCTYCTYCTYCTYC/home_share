import 'package:flutter/material.dart';
import 'package:home_share/fridge.dart';
import 'package:home_share/schedule.dart';
import 'package:home_share/profile/profile.dart';
import 'package:home_share/chores/main_chores_page.dart';
import 'package:home_share/dashboard.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/profile/settings.dart';

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
    Profile(),

  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('HomeShare',
              style: GoogleFonts.arvo(
                  textStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          backgroundColor: const Color(0xFF103465),
          actions: [
            GestureDetector(
              child: IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: IconButton(
                  icon: const Icon(Icons.settings),
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
        backgroundColor: const Color(0xFF103465),
        bottomNavigationBar: Container(
          width: width,
          child: GNav(
              backgroundColor: const Color(0xFF103465),
              color: Colors.white,
              activeColor: Colors.black,
              tabBackgroundColor: Colors.amber,
              iconSize: 20,
              tabMargin: const EdgeInsets.symmetric(vertical: 8),
              gap: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
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
                if (mounted) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              }),
        ));
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
