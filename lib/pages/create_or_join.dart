import 'package:flutter/material.dart';
import 'package:home_share/pages/create_new_home.dart';
import 'package:home_share/pages/join_existing_home.dart';
import 'package:home_share/pages/login_page.dart';

class CreateOrJoin extends StatelessWidget {
  const CreateOrJoin({Key? key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const CreateOrJoin());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Testing',
        home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Text('HomeShare',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFF103465),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        decoration: BoxDecoration(
                          //borderRadius: BorderRadius.circular(50.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ), // changes position of shadow
                          ],
                        ),
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                                color: Color(0xFF103465), width: 5),
                          ),
                          title: const Text('Confirm'),
                          content: const Text(
                              'Are you sure you want to go back? You will be required to log in again.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => const LoginPage()));
                                },
                                child: const Text('Yes'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              )),
          body: Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          NewHomeScreen.route(), (route) => false);
                    },
                    child: Container(
                        margin: EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Color(0xFF103465),
                            width: 3.0,
                          ),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 30.0,
                          child: Image.asset(
                            'assets/images/create_home.png',
                            fit: BoxFit.contain,
                          ),
                        )),
                  ),
                ),

//create the divider here
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Color(0xFF103465),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "or",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Color(0xFF103465),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          JoinHomeScreen.route(), (route) => false);
                    },
                    child: Container(
                        margin: EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Color(0xFF103465),
                            width: 3.0,
                          ),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 30.0,
                          child: Image.asset(
                            'assets/images/join_home.png',
                            fit: BoxFit.contain,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

//testing purpose
// //confirmation dialog box
// void _showConfirmationDialog(
//     BuildContext context, int type, Function onPressed) {
//   String message = '';
//   //1 - create home
//   //2 - join home
//   if (type == 1) {
//     message = 'You have selected create home';
//   } else if (type == 2) {
//     message = 'You have selected join home';
//   }

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Confirm'),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: ButtonStyle(
//               foregroundColor: MaterialStateProperty.all<Color>(Colors.amber),
//             ),
//             child: Text('CANCEL'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               onPressed();
//               Navigator.of(context).pop();
//               if (type == 1) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => NewHomeScreen()),
//                 );
//               } else if (type == 2) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => JoinHomeScreen()),
//                 );
//               }
//             },
//             style: ButtonStyle(
//               foregroundColor: MaterialStateProperty.all<Color>(Colors.amber),
//               backgroundColor:
//                   MaterialStateProperty.all<Color>(Color(0xFF103465)),
//             ),
//             child: Text('OK'),
//           ),
//         ],
//       );
//     },
//   );
// }
