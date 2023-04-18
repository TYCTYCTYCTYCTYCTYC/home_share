import 'package:flutter/material.dart';
import 'package:home_share/home.dart';
import 'package:home_share/main.dart';
import 'package:photo_view/photo_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/bulletin_board/bulletin_board.dart';
import 'package:home_share/chores/chores.dart';

import 'fridge/fridge.dart';
import 'fridge/fridge_item_detail.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const DashBoard());
  }

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with WidgetsBindingObserver {
  String? homeName;
  String? username;
  List<Post> _bulletinBoardMessages = [];
  int notDone = 0;
  int done = 0;
  String choreStatistics = '';
  int highestChorePoints = 0;
  String highestChoreUsername = '';
  dynamic profileSchedule = null;
  List<dynamic>? _rowItems = null;

  @override
  void initState() {
    super.initState();
    myFunction();
    loadDB();
    fetchAndSetBulletin();
    getChoreStatistics();
    getLeaderboardStatics();
    retrieveMySchedule();
  }

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
      return const Color.fromARGB(255, 17, 169, 27);
    } else {
      return Colors.transparent; // or any other default color
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchAndSetBulletin();
      getChoreStatistics();
      getLeaderboardStatics();
    }
  }

  Future<void> myFunction() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;

    final homeAndUser = await supabase
        .rpc('get_home_and_user_info', params: {'user_id': userId})
        .select()
        .execute();
    if (homeAndUser.data != null) {
      final List<dynamic> data = homeAndUser.data!;
      if (mounted) {
        setState(() {
          homeName = data[0]['name'];
          username = data[0]['username'];
        });
      }
    }
  }

  Future<void> fetchAndSetBulletin() async {
    final bulletins = await fetchBulletin();
    if (mounted) {
      setState(() {
        _bulletinBoardMessages = bulletins;
      });
    }
  }

  Future<void> loadDB() async {
    int days = 7;
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userId = currentUser?.id;

      // Get home_id
      final response = await supabase
          .from('user_home')
          .select('home_id')
          .eq('user_id', userId)
          .single()
          .execute();

      final homeId = response.data['home_id'] as int;

      // Get fridge items with ascending date_expiring and filter by date that is today or after today
      final now = DateTime.now()
          .toIso8601String()
          .substring(0, 10); // Get today's date in ISO 8601 format
      final response2 = await supabase
          .from('fridge')
          .select('*')
          .eq('home_id', homeId)
          .gte('date_expiring',
              now) // Filter by date that is today or after today
          .lte(
              'date_expiring',
              DateTime.now()
                  .add(Duration(days: days))
                  .toIso8601String()) // Filter by date that is up to 'days' days from now
          .order('date_expiring',
              ascending: true) // Sort by date_expiring in ascending order
          .execute();

      setState(() {
        _rowItems = response2.data as List<dynamic>;
      });
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
  }

  Future<void> getChoreStatistics() async {
    String startDateToString(DateTime date) {
      return date.toIso8601String();
    }

    String endDateToString(DateTime date) {
      return date.add(const Duration(days: 1)).toIso8601String();
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;
    final now = DateTime.now().toUtc();
    String startDate =
        startDateToString(now.subtract(Duration(days: now.weekday - 1)));
    String endDate = endDateToString(
        now.add(Duration(days: DateTime.daysPerWeek - now.weekday)));

    final response = await supabase.rpc('count_user_chores', params: {
      'current_user_id': userId,
      'filter_start_date': startDate,
      'filter_end_date': endDate,
    }).execute();

    final data = response.data as List<dynamic>;
    notDone = data[0]['not_done'] as int;
    done = data[0]['done'] as int;

    final total = notDone + done;

    if (total == 0) {
      setState(() {
        choreStatistics = 'You do not have any chores for this week!';
      });
    } else {
      final percentDone = done / total * 100;
      final percentNotDone = 100 - percentDone;

      if (percentDone == 100) {
        setState(() {
          choreStatistics = 'Congrats! You did all your chores this week!';
        });
      } else {
        setState(() {
          choreStatistics =
              'You only did ${percentDone.toStringAsFixed(2)}% of your chores this week!';
        });
      }
    }
  }

  Future<void> getLeaderboardStatics() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;
    final response = await supabase.rpc('get_points_leaderboard',
        params: {'current_user_id': userId}).execute();
    final data = response.data as List<dynamic>;
    data.sort((a, b) => b['points'] - a['points']);
    highestChorePoints = data.isNotEmpty ? data.first['points'] ?? 0 : 0;
    highestChoreUsername = data.isNotEmpty ? data.first['username'] ?? '' : '';
  }

  Future<List<Post>> fetchBulletin() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;

    final response = await supabase
        .from('user_home')
        .select('home_id')
        .eq('user_id', userId)
        .single()
        .execute();

    final homeId = response.data['home_id'] as int;

    final response2 = await supabase
        .from('user_home')
        .select('user_id')
        .eq('home_id', homeId)
        .execute();

    final userIds = response2.data
        .map<String>((item) => item['user_id'] as String)
        .toList();

    final response3 = await supabase
        .from('bulletin_board')
        .select()
        .in_('user_id', userIds)
        .order('created_at', ascending: false)
        .limit(2)
        .execute();

    final data = response3.data as List<dynamic>;

    final bulletins = await Future.wait(data.map((item) async {
      final bulletin = await Post.fromJson(item);
      return bulletin;
    }));

    return bulletins;
  }

  Future<void> retrieveMySchedule() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userId = currentUser?.id;

      //get home_id
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single()
          .execute();

      setState(() {
        profileSchedule = response.data;
      });
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    //home name
                    homeName != null && username != null
                        ? Text(
                            'Welcome to $homeName, $username!',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.arvo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const CircularProgressIndicator(),
                    const SizedBox(height: 16),

                    //Bulletin board
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF103465), width: 4.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  size: 30,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Bulletin Board',
                                  style: GoogleFonts.arvo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ]),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => BulletinBoard()));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text(
                                      'See More',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_bulletinBoardMessages.isEmpty)
                            const Text('No messages available.')
                          else
                            Column(
                              children: _bulletinBoardMessages
                                  .map((message) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 34),
                                                child: Text(
                                                  message.title,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 34),
                                                child: Text(
                                                  message.message,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    //Fridge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF103465), width: 4.0),
                      ),
                      child: _rowItems == null
                          ? const CircularProgressIndicator()
                          : _rowItems!.length == 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.kitchen_outlined,
                                              size: 30,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Fridge',
                                              style: GoogleFonts.arvo(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) => const Home(
                                                        initialIndex: 1)));
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: const [
                                              Text(
                                                'See More',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.amber,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 34),
                                        child: Text(
                                          'No items in the fridge is expiring soon.',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height / 2.3,
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.kitchen_outlined,
                                                size: 30,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                'Fridge',
                                                style: GoogleFonts.arvo(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const Home(
                                                              initialIndex:
                                                                  1)));
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: const [
                                                Text(
                                                  'See More',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.amber,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 16,
                                                  color: Colors.amber,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: _rowItems!.length,
                                          itemBuilder: (BuildContext context,
                                              int index1) {
                                            final item = _rowItems![index1];
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Navigate to subpage and pass item description as arguments
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FridgeItemDetail(
                                                              item: item),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFF103465),
                                                      width: 4.0,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Stack(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Image.network(
                                                              item[
                                                                  'item_image_url'],
                                                              width: 150,
                                                              height: 150,
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          15.0),
                                                              child: Container(
                                                                child: Text(
                                                                  item[
                                                                      'item_name'],
                                                                  style:
                                                                      GoogleFonts
                                                                          .arvo(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10.0),
                                                              child: Container(
                                                                child: Text(
                                                                  getExpiryStatus(
                                                                      item[
                                                                          'date_expiring']),
                                                                  style:
                                                                      GoogleFonts
                                                                          .arvo(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: getColorBasedOnExpiry(
                                                                        item[
                                                                            'date_expiring']),
                                                                    backgroundColor:
                                                                        getBackgroundColor(
                                                                            item['date_expiring']),
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
                                    ],
                                  ),
                                ),
                    ),
                    const SizedBox(height: 30),

                    //Chores
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF103465), width: 4.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.cleaning_services_outlined,
                                    size: 30,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Chores',
                                    style: GoogleFonts.arvo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          const Home(initialIndex: 2)));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text(
                                      'See More',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                child: SfRadialGauge(
                                    enableLoadingAnimation: true,
                                    animationDuration: 1500,
                                    axes: [
                                      RadialAxis(
                                        minimum: 0,
                                        maximum: 100,
                                        showLabels: false,
                                        showTicks: false,
                                        axisLineStyle: AxisLineStyle(
                                          thickness: 0.2,
                                          cornerStyle: CornerStyle.bothCurve,
                                          color: Colors.grey[700],
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        pointers: [
                                          RangePointer(
                                            value: notDone + done == 0
                                                ? 0
                                                : (done / (notDone + done)) *
                                                    100,
                                            width: 0.2,
                                            sizeUnit: GaugeSizeUnit.factor,
                                            cornerStyle: CornerStyle.bothCurve,
                                            color: const Color.fromARGB(
                                                255, 237, 69, 57),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                  width: 230,
                                  child: choreStatistics.isEmpty
                                      ? Visibility(
                                          visible: choreStatistics.isEmpty,
                                          child: const Text(
                                              'No messages available.'))
                                      : Text(choreStatistics)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.leaderboard_outlined,
                                size: 30,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 34),
                              Flexible(
                                child: highestChorePoints == 0
                                    ? Text(
                                        "No one is leading, score some points to have your name on the dashboard!")
                                    : Text(
                                        "${highestChoreUsername} is the kakak of the week!"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    //Schedule
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF103465), width: 4.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.date_range,
                                    size: 30,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Schedule',
                                    style: GoogleFonts.arvo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          const Home(initialIndex: 3)));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text(
                                      'See More',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Row(
                          //   children: [
                          //     Container(
                          //       width: 45,
                          //       height: 45,
                          //       child: SfRadialGauge(
                          //           enableLoadingAnimation: true,
                          //           animationDuration: 1500,
                          //           axes: [
                          //             RadialAxis(
                          //               minimum: 0,
                          //               maximum: 100,
                          //               showLabels: false,
                          //               showTicks: false,
                          //               axisLineStyle: AxisLineStyle(
                          //                 thickness: 0.2,
                          //                 cornerStyle: CornerStyle.bothCurve,
                          //                 color: Colors.grey[700],
                          //                 thicknessUnit: GaugeSizeUnit.factor,
                          //               ),
                          //               pointers: [
                          //                 RangePointer(
                          //                   value: notDone + done == 0
                          //                       ? 0
                          //                       : (done / (notDone + done)) *
                          //                           100,
                          //                   width: 0.2,
                          //                   sizeUnit: GaugeSizeUnit.factor,
                          //                   cornerStyle: CornerStyle.bothCurve,
                          //                   color: const Color.fromARGB(
                          //                       255, 237, 69, 57),
                          //                 ),
                          //               ],
                          //             ),
                          //           ]),
                          //     ),
                          //     const SizedBox(width: 20),
                          //     Container(
                          //         width: 230,
                          //         child: choreStatistics.isEmpty
                          //             ? Visibility(
                          //                 visible: choreStatistics.isEmpty,
                          //                 child: const Text(
                          //                     'No messages available.'))
                          //             : Text(choreStatistics)),
                          //   ],
                          // ),
                          (profileSchedule == null ||
                                  profileSchedule['schedule_url'] == null)
                              ? const Text(
                                  'You have not uploaded your schedule yet')
                              : GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext dialogContext) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  width: MediaQuery.of(
                                                          dialogContext)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(
                                                          dialogContext)
                                                      .size
                                                      .height,
                                                  child: PhotoView(
                                                    enableRotation: true,
                                                    backgroundDecoration:
                                                        BoxDecoration(
                                                      color: Colors.transparent,
                                                    ),
                                                    imageProvider: NetworkImage(
                                                      profileSchedule[
                                                          'schedule_url'],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        dialogContext);
                                                  },
                                                  child: Text('Close'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.network(
                                    profileSchedule['schedule_url'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ))));
  }
}
