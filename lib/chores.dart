import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/chores_form_page.dart';

class Chore {
  final String startDate;
  final String category;
  final String assignedUserId;
  final String description;
  final int effortPoints;
  bool isCompleted;

  Chore({
    required this.startDate,
    required this.category,
    required this.assignedUserId,
    required this.description,
    required this.effortPoints,
    this.isCompleted = false,
  });
}

class Chores extends StatefulWidget {
  const Chores({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const Chores());
  }

  @override
  _ChoresState createState() => _ChoresState();
}

class _ChoresState extends State<Chores> {
  List<Chore> _chores = [
    Chore(
      startDate: '2022-04-01',
      category: 'Kitchen',
      assignedUserId: 'user1',
      description: 'Wash dishes',
      effortPoints: 5,
    ),
    Chore(
      startDate: '2022-04-02',
      category: 'Bathroom',
      assignedUserId: 'user2',
      description: 'Clean shower',
      effortPoints: 10,
    ),
  ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SizedBox(
//         width: MediaQuery.of(context).size.width,
//         child: Center(
//           child: Text(
//             "You have not created any chores yet! \nClick on the button below to create a new chore.",
//             textAlign: TextAlign.center,
//             style: GoogleFonts.arvo(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             Navigator.of(context).push(ChoreFormPage.route());
//           },
//           backgroundColor: Colors.amber,
//           child: const Text(
//             '+',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//               fontSize: 24,
//             ),
//           )),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: _chores.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Color(0xFF103465),
                      width: 4.0,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    tileColor: Colors.transparent,
                    leading: SizedBox(
                      width: 40,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Checkbox(
                          value: _chores[index].isCompleted,
                          onChanged: (bool? value) {
                            setState(() {
                              _chores[index].isCompleted = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Text(
                            _chores[index].description,
                            style: GoogleFonts.arvo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.black,
                            ),
                            Text(
                              '${_chores[index].effortPoints}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: Column(children: [
                          Row(
                            children: [
                              Icon(Icons.list, color: Colors.black),
                              SizedBox(width: 5),
                              Text(
                                '${_chores[index].category}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              VerticalDivider(
                                thickness: 3,
                                color: Colors.black,
                                width: 10,
                              ),
                              Icon(Icons.person, color: Colors.black),
                              SizedBox(width: 5),
                              Text(
                                '${_chores[index].assignedUserId}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.black),
                              SizedBox(width: 5),
                              Text(
                                '${_chores[index].startDate}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ])),
                  ),
                ));
          },
        ));
  }
}
