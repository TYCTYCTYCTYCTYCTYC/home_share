import 'package:flutter/material.dart';
import 'package:home_share/fridge/fridge_item_detail.dart';

import 'package:home_share/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'fridge_form.dart';

Color clr = const Color.fromARGB(255, 165, 198, 255);
Color bgclr = Colors.white;
Color clr3 = const Color(0xFF103465);

class Fridge extends StatefulWidget {
  const Fridge({Key? key}) : super(key: key);

  @override
  _FridgeState createState() => _FridgeState();
}

class _FridgeState extends State<Fridge> {
  String dropdownValue = "Expiry (Earliest)";
  DateTime selectedDate = DateTime.now();
  late final userId;
  late final String categoryImage;
  List<dynamic> _rowItems = [];
  List<String> categories = [
    'Meat',
    'Vegetable',
    'Beverage',
    'Food',
    'Fruit',
    'Others'
  ];

  String getExpiryStatus(String dateStr) {
    DateTime expiryDate = DateTime.parse(dateStr);
    DateTime now = DateTime.now();

    final diff = expiryDate.difference(now).inDays;

    if (diff == 0) {
      return 'Will Expire Today';
    } else if (diff < 0) {
      return 'Expired ${-diff} days ago';
    } else {
      return 'Will Expire in $diff days';
    }
  }

  Color getColorBasedOnExpiry(String dateStr) {
    String expiryStatus = getExpiryStatus(dateStr);

    if (expiryStatus.contains('Will Expire Today')) {
      return Colors.black;
    } else if (expiryStatus.contains('days ago')) {
      return Colors.white;
    } else if (expiryStatus.contains('Will Expire in')) {
      return Colors.white;
    } else {
      // Return a default color if no matching pattern is found
      return Colors.black;
    }
  }

  Color getBackgroundColor(String dateStr) {
    String expiryStatus = getExpiryStatus(dateStr);
    if (expiryStatus.contains('Will Expire Today')) {
      return Colors.yellow;
    } else if (expiryStatus.contains('days ago')) {
      return Colors.red;
    } else if (expiryStatus.contains('Will Expire in')) {
      return Color.fromARGB(255, 17, 169, 27);
    } else {
      return Colors.transparent; // or any other default color
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HomeShare",
      home: Scaffold(
        backgroundColor: bgclr,
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            categories.length,
            (index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: Container(
                    height: 60,
                    color: Color.fromARGB(255, 255, 241, 201),
                    child: Center(
                      child: Text(
                        categories[index],
                        style: GoogleFonts.arvo(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0, left: 3.0),
                  child: SizedBox(
                    height: 280,
                    child: _rowItems == null
                        ? const CircularProgressIndicator()
                        : _rowItems
                                    .where((item) =>
                                        item['category'] == categories[index])
                                    .toList()
                                    .length ==
                                0
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "No items",
                                      style: GoogleFonts.amaticSc(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Tap on the '+' button below to add new item!",
                                      style: GoogleFonts.amaticSc(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: _rowItems
                                    .where((item) =>
                                        item['category'] == categories[index])
                                    .toList()
                                    .length,
                                itemBuilder:
                                    (BuildContext context, int index1) {
                                  List<dynamic> sortItems = _rowItems
                                      .where((item) =>
                                          item['category'] == categories[index])
                                      .toList();
                                  sortItems.sort((a, b) => a['date_expiring']
                                      .compareTo(b['date_expiring']));
                                  final item = sortItems[index1];
                                  return Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigate to subpage and pass item description as arguments
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FridgeItemDetail(item: item),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFF103465),
                                              width: 4.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Image.network(
                                                    item['item_image_url'],
                                                    width: 150,
                                                    height: 150,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 15.0),
                                                    child: Container(
                                                      child: Text(
                                                        item['item_name'],
                                                        style: GoogleFonts.arvo(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.0),
                                                    child: Container(
                                                      child: Text(
                                                        getExpiryStatus(item[
                                                            'date_expiring']),
                                                        style: GoogleFonts.arvo(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: getColorBasedOnExpiry(
                                                              item[
                                                                  'date_expiring']),
                                                          backgroundColor:
                                                              getBackgroundColor(
                                                                  item[
                                                                      'date_expiring']),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
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
    loadDB();
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
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur'));
  }
  // void _deleteItem(int index) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     items.removeAt(index);
  //   });
  //   prefs.setString('items_key', FridgeItem.encode(items));
  // }
}
