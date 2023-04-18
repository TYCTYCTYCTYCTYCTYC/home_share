import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/chores/chores.dart';
import 'package:home_share/chores/chores_leaderboard.dart';
import 'package:home_share/chores/chores_statistics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainChoresPage extends StatefulWidget {
  @override
  _MainChoresPageState createState() => _MainChoresPageState();
}

class _MainChoresPageState extends State<MainChoresPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int index = 0;
  String? statsIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this); //set the length of the number of tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  'Chores',
                  style: GoogleFonts.arvo(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Leader\nBoard',
                  style: GoogleFonts.arvo(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Statistics',
                  style: GoogleFonts.arvo(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.amber, // Specify the color
                  width: 3, // Customize the width of the underline
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                // first tab view
                const Chores(),
                // second tab view
                LeaderboardPage(),
                // third tab view
                ChoresStatisticsPage(index: index),
              ],
            ),
          )
        ],
      ),
    );
  }
}
