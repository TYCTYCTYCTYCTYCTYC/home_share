import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/chores_form_page.dart';

class Chores extends StatefulWidget {
  const Chores({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const Chores());
  }

  @override
  _ChoresState createState() => _ChoresState();
}

class _ChoresState extends State<Chores> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            "You have not created any chore yet! \nClick on the button below to create a new chore.",
            textAlign: TextAlign.center,
            style: GoogleFonts.arvo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(ChoreFormPage.route());
          },
          backgroundColor: Colors.amber,
          child: const Text(
            '+',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 24,
            ),
          )),
    );
  }
}
