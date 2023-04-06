import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/main.dart';

class Chores extends StatefulWidget {
  const Chores({Key? key}) : super(key: key);

  @override
  _ChoresState createState() => _ChoresState();
}

class _ChoresState extends State<Chores> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 180, 231, 255),
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
            // TODO: navigate to the page with the chore form
          },
          backgroundColor: Colors.amber,
          child: Text(
            '+',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 24,
            ),
          )),
    );
  }

  // @override
  // bool get wantKeepAlive => true;
}
