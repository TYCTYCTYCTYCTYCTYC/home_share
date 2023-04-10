import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/main.dart';
import 'package:home_share/chores/chores_form_page.dart';

class Chore {
  final int choreId;
  final String startDate;
  final String category;
  final String assignedUserId;
  final String username;
  final String description;
  final int effortPoints;
  bool isCompleted;

  Chore({
    required this.choreId,
    required this.startDate,
    required this.category,
    required this.assignedUserId,
    required this.username,
    required this.description,
    required this.effortPoints,
    this.isCompleted = false,
  });

  static Future<Chore> fromJson(Map<String, dynamic> json) async {
    final response = await supabase
        .from('profiles')
        .select('username')
        .eq('id', json['assigned_user_id'])
        .single()
        .execute();

    final username = response.data['username'] as String;
    return Chore(
      choreId: json['chores_id'],
      startDate: json['start_date'],
      category: json['category'],
      assignedUserId: json['assigned_user_id'],
      description: json['description'],
      effortPoints: json['effort_points'],
      isCompleted: json['status'],
      username: username, // Pass the fetched username to the constructor
    );
  }

  Future<void> updateIsCompleted(int choreId, bool isCompleted) async {
    await supabase
        .from('chores')
        .update({'status': isCompleted})
        .eq('chores_id', choreId)
        .execute();
  }
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
  List<Chore> _chores = [];

  @override
  void initState() {
    super.initState();
    fetchAndSetChores();
  }

  Future<void> fetchAndSetChores() async {
    final chores = await fetchChores();
    if (mounted) {
      setState(() {
        _chores = chores;
      });
    }
  }

//only fetch chores that are not completed yet
  Future<List<Chore>> fetchChores() async {
    final response = await supabase
        .from('chores')
        .select()
        .not('status', 'eq', true)
        .execute();
    final data = response.data as List<dynamic>;

    final chores = await Future.wait(data.map((item) async {
      final chore = await Chore.fromJson(item);
      return chore;
    }));

    return chores;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            color: Colors.white,
            child: _chores.isEmpty
                ? Visibility(
                    visible: true,
                    child: Center(
                      child: Text(
                        'No chores yet! Tap on the button below to boss your housemates around!',
                        style: GoogleFonts.arvo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _chores.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: const Color(0xFF103465),
                                width: 4.0,
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: ListTile(
                              tileColor: Colors.transparent,
                              leading: SizedBox(
                                width: 40,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Checkbox(
                                    value: _chores[index].isCompleted,
                                    onChanged: (bool? value) async {
                                      final isCompleted = value ?? false;
                                      if (mounted) {
                                        setState(() {
                                          _chores[index].isCompleted =
                                              isCompleted;
                                        });
                                      }

                                      await _chores[index].updateIsCompleted(
                                          _chores[index].choreId, isCompleted);
                                      if (isCompleted) {
                                        final userId =
                                            _chores[index].assignedUserId;
                                        final effortPoints =
                                            _chores[index].effortPoints;
                                        final now = DateTime.now();
                                        final obtainedDate = DateTime(
                                            now.year, now.month, now.day);

                                        await supabase
                                            .from('user_points')
                                            .insert({
                                          'user_id': userId,
                                          'effort_points': effortPoints,
                                          'obtained_date':
                                              obtainedDate.toIso8601String()
                                        }).execute();
                                        if (mounted) {
                                          setState(() {
                                            _chores.removeAt(index);
                                          });
                                        }

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Chore completed!',
                                                style: GoogleFonts.arvo(
                                                    textStyle: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            backgroundColor: Colors.amber,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
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
                                      const Icon(
                                        Icons.star,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        '${_chores[index].effortPoints}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  child: Column(children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.list,
                                            color: Colors.black),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${_chores[index].category}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        const VerticalDivider(
                                          thickness: 3,
                                          color: Colors.black,
                                          width: 10,
                                        ),
                                        const Icon(Icons.person,
                                            color: Colors.black),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${_chores[index].username}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            color: Colors.black),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${_chores[index].startDate}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ])),
                            ),
                          ));
                    },
                  )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to ChoreFormPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChoreFormPage()),
          );
        },
        backgroundColor: Colors.amber,
        child: const Text(
          '+',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
      ),
    );
  }
}
