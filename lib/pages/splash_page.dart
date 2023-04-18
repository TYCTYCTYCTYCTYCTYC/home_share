import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/utils/constants.dart';
import 'package:home_share/home.dart';
import 'package:home_share/pages/create_or_join.dart';
import 'package:home_share/pages/login_page.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = Supabase.instance.client.auth.currentSession;

    //if not logged in, go to login page
    if (session == null) {
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else {
      final homeQuery = await Supabase.instance.client
          .from('user_home')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .execute();

      //if user don't have home, go to createOrJoin.dart
      if (homeQuery.data.length == 0) {
        Navigator.of(context)
            .pushAndRemoveUntil(CreateOrJoin.route(), (route) => false);
      }

      //if user logged in and has home, go to Home
      else {
        Navigator.of(context)
            .pushAndRemoveUntil(Home.route(), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
