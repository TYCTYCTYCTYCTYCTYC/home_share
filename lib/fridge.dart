import 'package:flutter/material.dart';

import 'package:home_share/main.dart';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs();
    _loadLocalTimeZone();
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

  /*
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "HomeShare",
        home: Scaffold(
          appBar: AppBar(),
          backgroundColor: bgclr,
          body: Container(
              //code here
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Fridge Page',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _counter++;
                  });
                },
                child: Text('Click me!'),
              ),
            ],
          ))),
        ));
  }
  */

  @override
  Widget build(BuildContext context) {
    var topHeight = MediaQuery.of(context).size.height * 4 / 10;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "HomeShare",
        home: Scaffold(
          backgroundColor: bgclr,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  height: topHeight,
                  width: MediaQuery.of(context).size.width,
                  // alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Hi Sidak",
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Your Fridge Items",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          // color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _infoColumn("Total", items.length.toString(),
                                  Colors.blue),
                              _infoColumn(
                                  "Valid",
                                  (items.length - _getExpiredItemCount())
                                      .toString(),
                                  Colors.green),
                              _infoColumn(
                                  "Expired",
                                  _getExpiredItemCount().toString(),
                                  Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: topHeight - 10),
                  height: MediaQuery.of(context).size.height - topHeight,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                    ),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Item List",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                      icon: Icon(Icons.sort),
                                      value: dropdownValue,
                                      items: <String>[
                                        'Expiry (Earliest)',
                                        'Expiry (Latest)',
                                        'Name (Ascending)',
                                        'Name (Descending)'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue = newValue ??
                                              ""; // Use a default value if null
                                          _sortItems();
                                        });
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: ListView.separated(
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            FridgeItem item = items[index];
                            return ListTile(
                              leading: ShapeOfView(
                                shape: CircleShape(),
                                elevation: 0,
                                child: item.imageUrl != null
                                    ? Image.network(
                                        item.imageUrl!,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.fitHeight,
                                      )
                                    : Image.asset(
                                        "images/food.png",
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.fitHeight,
                                      ),
                              ),
                              title: Text(item.name!),
                              subtitle: Text(DateFormat('dd MMM yyyy')
                                  .format(item.dateExpiring!)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteItem(index);
                                },
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigate to ChoreFormPage
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
        ));
  }
}
  // @override
  // bool get wantKeepAlive => true;
