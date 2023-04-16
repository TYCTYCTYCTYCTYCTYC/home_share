import 'package:flutter/material.dart';

import 'package:home_share/main.dart';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'fridge_form.dart';
import 'fridge_item.dart';

Color clr = const Color.fromARGB(255, 165, 198, 255);
Color bgclr = Colors.white;
Color clr3 = Colors.blueAccent;

class Fridge extends StatefulWidget {
  const Fridge({Key? key}) : super(key: key);

  @override
  _FridgeState createState() => _FridgeState();
}

class _FridgeState extends State<Fridge> {
  String dropdownValue = "Expiry (Earliest)";
  List<FridgeItem> items = [];
  DateTime selectedDate = DateTime.now();
  late final userId;
  List<dynamic> _rowItems = [];
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HomeShare",
      home: Scaffold(
        backgroundColor: bgclr,
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.width / 5,
              child: Center(
                child: Text("Type of Item"),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 15,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(width: 3),
                      ),
                      child: Column(
                        children: [
                          Text("This my photo"),
                          Text("This my expiry date")
                        ],
                      ));
                },
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Column(children: [
                  Container(
                    child: Center(
                      child: Text("Type of Item"),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 15,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(width: 3),
                            ),
                            child: Column(
                              children: [
                                Text("This my photo"),
                                Text("This my expiry date")
                              ],
                            ));
                      },
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(children: [
                        Container(
                          child: Center(
                            child: Text("Type of Item"),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 15,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    border: Border.all(width: 3),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("This my photo"),
                                      Text("This my expiry date")
                                    ],
                                  ));
                            },
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(children: [
                              Container(
                                child: Center(
                                  child: Text("Type of Item"),
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: 15,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          border: Border.all(width: 3),
                                        ),
                                        child: Column(
                                          children: [
                                            Text("This my photo"),
                                            Text("This my expiry date")
                                          ],
                                        ));
                                  },
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Column(children: [
                                    Container(
                                      child: Center(
                                        child: Text("Type of Item"),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: 15,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                border: Border.all(width: 3),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text("This my photo"),
                                                  Text("This my expiry date")
                                                ],
                                              ));
                                        },
                                      ),
                                    ),
                                  ]))
                            ]))
                      ]))
                ])),
          ],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to FridgeFormPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FridgeFormPage()),
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs();
    _loadLocalTimeZone();
  }

  Future<void> loadDB() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;

      userId = currentUser?.id;

      //get home_id
      final response = await supabase
          .from('user_home')
          .select('home_id')
          .eq('user_id', userId)
          .single()
          .execute();

      final homeId = response.data['home_id'] as int;

      final response2 = await supabase
          .from('fridge')
          .select('*')
          .eq('home_id', homeId)
          .execute();

      setState(() {
        _rowItems = response2.data as List<dynamic>;
      });
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
  }

  Future<void> _loadLocalTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
  }

  void _loadSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemsString = prefs.getString('items_key');
    if (itemsString == null) {
      setState(() {
        items = [];
      });
    } else {
      setState(() {
        items = FridgeItem.decode(itemsString);
        _sortItems();
      });
    }
  }

  void _addItem(FridgeItem fridgeItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      items.add(fridgeItem);
      _sortItems();
    });
    prefs.setString('items_key', FridgeItem.encode(items));
  }

  void _deleteItem(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      items.removeAt(index);
    });
    prefs.setString('items_key', FridgeItem.encode(items));
  }

  Widget _infoColumn(String title, String value, Color color) {
    var maxWidth = MediaQuery.of(context).size.width / 4;
    return Container(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: color,
                  ),
                ),
                SizedBox(
                  width: 7.5,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            title: Text("Fetching Item Information..."),
            titlePadding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        });
  }

  void _selectDate(StateSetter setter) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setter(() {
        selectedDate = picked;
      });
  }

  void _showItemSheet(FridgeItem fridgeItem) {
    selectedDate = DateTime.now();
    TextEditingController _controller =
        TextEditingController(text: fridgeItem.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setter) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 24,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                ),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShapeOfView(
                    shape: CircleShape(),
                    elevation: 0,
                    child: fridgeItem.imageUrl != null
                        ? Image.network(
                            fridgeItem.imageUrl!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.fitHeight,
                          )
                        : Image.asset(
                            "images/food.png",
                            height: 150,
                            width: 150,
                            fit: BoxFit.fitHeight,
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          child: TextField(
                            controller: _controller,
                            enabled: true,
                            onSubmitted: (String text) {
                              setter(() {
                                fridgeItem.name = text;
                              });
                            },
                          ),
                        ),
                        Icon(Icons.edit),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _selectDate(setter);
                    },
                    child: Text(
                      "Expiry Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                    ),
                  ),
                  ButtonBar(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          fridgeItem.dateExpiring = selectedDate;
                          _addItem(fridgeItem);
                          /*
                          _scheduleNotification(
                              fridgeItem.dateExpiring
                                  .subtract(Duration(hours: 12)),
                              "Expiring Tomorrow: " + fridgeItem.name,
                              "Use Soon!");
                          _scheduleNotification(
                              fridgeItem.dateExpiring
                                  .subtract(Duration(days: 1)),
                              "Expiring in Two Days: " + fridgeItem.name,
                              "Use Soon!");
                          Navigator.pop(context);
                          */
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  int _getExpiredItemCount() {
    DateTime expiryThreshold = DateTime.now();
    int count = 0;
    for (FridgeItem item in items) {
      if (item.dateExpiring!.isBefore(expiryThreshold)) {
        count++;
      }
    }
    return count;
  }

  void _sortItems() {
    if (dropdownValue == 'Expiry (Earliest)') {
      _sortByExpiry(true);
    } else if (dropdownValue == 'Expiry (Latest)') {
      _sortByExpiry(false);
    } else if (dropdownValue == 'Name (Ascending)') {
      _sortByName(true);
    } else {
      _sortByName(false);
    }
  }

  void _sortByExpiry(bool earliest) {
    items.sort((a, b) => a.dateExpiring!.isBefore(b.dateExpiring!) ? -1 : 1);
    if (!earliest) {
      items = items.reversed.toList();
    }
  }

  void _sortByName(bool asc) {
    items.sort((a, b) => a.name!.compareTo(b.name!));
    if (!asc) {
      items = items.reversed.toList();
    }
  }
}
  // @override
  // bool get wantKeepAlive => true;
