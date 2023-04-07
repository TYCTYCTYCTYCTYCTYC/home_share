import 'package:flutter/material.dart';
import 'package:home_share/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter, // Align everything to top center
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50.0),
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF103465), //ring colour
                    width: 4.0, //width of the ring
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/anwar.jpg',
                    fit: BoxFit.cover,
                    width: 100.0,
                    height: 100.0,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                width: 350.0,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color(0xFF103465),
                          width: 4.0,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('Anwar Ibrahim'),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color(0xFF103465),
                          width: 4.0,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.email),
                        title: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('Anwar@gmail.com'),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color(0xFF103465),
                          width: 4.0,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.phone),
                        title: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('012-3456789'),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color(0xFF103465),
                          width: 4.0,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.calendar_month),
                        title: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('08-SEP-2002'),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color(0xFF103465),
                          width: 4.0,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.key),
                        title: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('4896'),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        child: Text('Logout',
                            style: GoogleFonts.arvo(
                              fontWeight: FontWeight.bold,
                            )),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFF103465)),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                        ),
                        onPressed: _showToast,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showToast() {
  Fluttertoast.showToast(
    msg: "pressed again to logout",
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
