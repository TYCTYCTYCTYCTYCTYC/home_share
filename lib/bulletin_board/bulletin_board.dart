import 'package:flutter/material.dart';
import 'package:home_share/bulletin_board/bulletin_form_page.dart';
import 'package:home_share/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

//connect to supabase can be easily done
import 'package:home_share/main.dart';

class Post {
  String userId;
  String username;
  String title;
  String message;
  DateTime timeStamp;
  Post(
      {required this.userId,
      required this.username,
      required this.title,
      required this.message,
      required this.timeStamp});

  static Future<Post> fromJson(Map<String, dynamic> json) async {
    final response = await supabase
        .from('profiles')
        .select('username')
        .eq('id', json['user_id'])
        .single()
        .execute();

    final username = response.data['username'] as String;
    return Post(
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      timeStamp: DateTime.parse(json['created_at']).toUtc(),
      username: username, // Pass the fetched username to the constructor
    );
  }
}

class BulletinBoard extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => BulletinBoard());
  }

  @override
  _BulletinBoardState createState() => _BulletinBoardState();
}

class _BulletinBoardState extends State<BulletinBoard>
    with WidgetsBindingObserver {
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    fetchAndSetBulletin();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchAndSetBulletin();
    }
  }

  Future<void> fetchAndSetBulletin() async {
    final bulletins = await fetchBulletin();
    if (mounted) {
      setState(() {
        _posts = bulletins;
        //   _posts
        //       .sort((a, b) => b.effortPoints!.compareTo(a.effortPoints!));
        //
      });
    }
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF103465),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home(initialIndex: 0)),
            );
          },
        ),
        title: Text('Bulletin Board',
            style: GoogleFonts.arvo(
                textStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to BulletinFormPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BulletinFormPage()),
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
      body: Container(
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: _posts.isEmpty
                  ? Visibility(
                      visible: true,
                      child: Center(
                        child: Text(
                          'No messages yet! Tap on the button below to post some information on the bulletin board!',
                          style: GoogleFonts.arvo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (BuildContext context, int index) {
                        Post post = _posts[index];
                        final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                        final formattedTimestamp =
                            dateFormat.format(post.timeStamp);

                        return Card(
                          child: ListTile(
                            title: Text(
                              post.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              post.message,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Text(
                              formattedTimestamp,
                              style: const TextStyle(
                                color: Colors.grey,
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
    );
  }
}
