import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/main.dart';

class ChoresPoints {
  final String username;
  final int? effortPoints;

  ChoresPoints({
    required this.username,
    required this.effortPoints,
  });
}

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<ChoresPoints> _choresPoints = [];

  void initState() {
    super.initState();
    fetchAndSetPoints();
  }

  Future<void> fetchAndSetPoints() async {
    final choresPoints = await fetchPoints();
    if (mounted) {
      setState(() {
        _choresPoints = choresPoints;
        _choresPoints
            .sort((a, b) => b.effortPoints!.compareTo(a.effortPoints!));
      });
    }
  }

  Future<List<ChoresPoints>> fetchPoints() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;

    final response = await supabase.rpc('get_points_leaderboard',
        params: {'current_user_id': userId}).execute();

    final pointsList = (response.data as List<dynamic>)
        .map((item) => ChoresPoints(
              username: item['username'] as String,
              effortPoints: item['points'] as int,
            ))
        .toList();

    return pointsList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _choresPoints.length,
        itemBuilder: (BuildContext context, int index) {
          ChoresPoints chorePoints = _choresPoints[index];
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Color(0xFF103465), width: 1),
              ),
              child: ListTile(
                leading: Text(
                  '${index + 1}',
                  style: GoogleFonts.pacifico(
                    fontSize: 24,
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(_choresPoints[index].username,
                    style: GoogleFonts.arvo(
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                trailing: SizedBox(
                  width: 35,
                  child: Row(
                    children: [
                      Text(
                        '${_choresPoints[index].effortPoints}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.star,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}
