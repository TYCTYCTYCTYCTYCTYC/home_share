import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/chores/chores_form_page.dart';
import 'package:home_share/chores/chores.dart';
import 'package:home_share/chores/chores_leaderboard.dart';

class MainChoresPage extends StatefulWidget {
  @override
  _MainChoresPageState createState() => _MainChoresPageState();
}

class _MainChoresPageState extends State<MainChoresPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2,
        vsync: this); //set the length to the number of tabs you want to have
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
                  'Leaderboard',
                  style: GoogleFonts.arvo(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.amber, // Specify the color you want here
                  width: 3, // Customize the width of the underline here
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                // The first tab view, here you can display the chores
                Chores(),
                // The second tab view, here you can display the leaderboard
                LeaderboardPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
