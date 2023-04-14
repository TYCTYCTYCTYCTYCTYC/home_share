import 'package:flutter/material.dart';
import 'package:home_share/home.dart';
import 'package:home_share/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:home_share/bulletin_board/bulletin_board.dart';
import 'package:home_share/chores/chores.dart';

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

  @override
  void initState() {
    super.initState();
    myFunction();

    fetchAndSetBulletin();
    getChoreStatistics();
    getLeaderboardStatics();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
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
                                onTap: () {},
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
                          const Text('put your content here'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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
                  ],
                ))));
  }
}
