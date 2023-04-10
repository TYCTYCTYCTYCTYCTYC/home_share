import 'package:flutter/material.dart';
import 'package:home_share/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const DashBoard());
  }

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String? homeName;
  String? username;

  @override
  void initState() {
    super.initState();
    myFunction();
  }

  Future<void> myFunction() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;

    final homeAndUser = await supabase
        .rpc('get_home_and_user_info', params: {'user_id': userId})
        .select()
        .execute();
    if (homeAndUser.data != null) {
      final List<dynamic> data = homeAndUser.data!;
      setState(() {
        homeName = data[0]['name'];
        username = data[0]['username'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: homeName != null && username != null
            ? Text(
                'Welcome to your home $homeName, $username!',
                textAlign: TextAlign.center,
                style: GoogleFonts.arvo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
