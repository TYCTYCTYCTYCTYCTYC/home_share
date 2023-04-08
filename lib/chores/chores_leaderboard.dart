import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:home_share/main.dart';

class ChoresPoints {
  final String userId;
  final String username;
  final int? effortPoints;

  ChoresPoints({
    required this.userId,
    required this.username,
    required this.effortPoints,
  });

  static Future<List<ChoresPoints>> fromJson() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;

    final homeIdResponse = await supabase
        .from('user_home')
        .select('home_id')
        .eq('user_id', userId)
        .single()
        .execute();

    final homeId = homeIdResponse.data['home_id'] as int;

    final usersAndPoints = await supabase
        .from('user_home')
        .select('user_id, chores_points')
        .eq('home_id', homeId)
        .execute();

    final userIds = (usersAndPoints.data as List<dynamic>)
        .map((item) => item['user_id'].toString())
        .toList();

    final response = await supabase
        .from('profiles')
        .select('id, username')
        .in_('id', userIds)
        .execute();

    final usernameMap = Map<String, String>.fromIterable(
      response.data,
      key: (item) => item['id'].toString(),
      value: (item) => item['username'].toString(),
    );

    final choresPoints = List<ChoresPoints>.generate(
      usersAndPoints.data.length,
      (index) {
        final userId = usersAndPoints.data[index]['user_id'].toString();
        final username = usernameMap[userId] ?? "Unknown";
        final points = usersAndPoints.data[index]['chores_points'] as int;
        return ChoresPoints(
          userId: userId,
          username: username,
          effortPoints: points,
        );
      },
    );

    return choresPoints;
  }
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
    return ChoresPoints.fromJson();
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
                trailing: Text(
                  '${_choresPoints[index].effortPoints}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ));
        },
      ),
    );
  }
}
