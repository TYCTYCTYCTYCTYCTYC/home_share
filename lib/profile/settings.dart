import 'package:flutter/material.dart';
import 'package:home_share/pages/login_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF103465),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: Icon(Icons.home, color: Colors.black),
                title: Text(
                  'Home Settings',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF103465),
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text('Name:', style: TextStyle(color: Colors.black)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ),
              



              const Text(
                'Home Name(name)',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Home Code(code)',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Home Address(address)',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),


              
                            const SizedBox(height: 50.0),
              
              Text(
                'General Settings',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              SwitchListTile(
                title: Text('Dark Mode'),
                value: false,
                onChanged: (value) {},
              ),
              Divider(),
              Text(
                'Account Settings',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Change Password'),
                onTap: () {},
              ),

              //logout
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
