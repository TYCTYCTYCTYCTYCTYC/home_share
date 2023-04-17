import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class FridgeItemAppBar extends StatelessWidget {
  Color clr1 = const Color(0xFF103465);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(25),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, size: 30, color: clr1),
            ),
            Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Item Detail",
                  style: GoogleFonts.arvo(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ))
          ],
        ));
  }
}
