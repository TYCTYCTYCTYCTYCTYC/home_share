import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/main.dart';
import 'package:photo_view/photo_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import 'mySchedule.dart';

Color clr = Color.fromARGB(255, 165, 198, 255);
Color clr2 = Colors.white;
Color clr3 = Colors.blueAccent;

class OtherUserSchedule extends StatefulWidget {
  final dynamic account;

  const OtherUserSchedule({Key? key, required this.account}) : super(key: key);

  @override
  _OtherUserScheduleState createState() => _OtherUserScheduleState();
}

class _OtherUserScheduleState extends State<OtherUserSchedule> {
  late GlobalKey<ScaffoldState> _otherUserScheduleKey;
  late BuildContext _ancestorContext;

  @override
  void initState() {
    super.initState();
    _otherUserScheduleKey = GlobalKey<ScaffoldState>();
    // loadDB();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ancestorContext = context;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.width / 5;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "HomeShare",
        home: Scaffold(
          key: _otherUserScheduleKey,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: const Color(0xFF103465),
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          backgroundColor: clr2,
          body: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                height: height,
                color: clr,
              ),
              Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: height,
                        color: clr,
                      ),
                      Container(
                        height: height,
                        color: clr2,
                      ),
                    ],
                  ),
                  Center(child: cropCircleImage(context, widget.account, 2))
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                    child: Column(
                  children: [
                    if (widget.account != null)
                      Text(
                        widget.account['username'] + '\'s Schedule',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    if (widget.account != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: SizedBox(
                          height: height * 2,
                          child: widget.account['schedule_url'] != null
                              ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: _ancestorContext,
                                      builder: (BuildContext dialogContext) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: SizedBox(
                                            width: MediaQuery.of(dialogContext)
                                                .size
                                                .width,
                                            height: MediaQuery.of(dialogContext)
                                                .size
                                                .height,
                                            child: PhotoView(
                                              imageProvider: NetworkImage(
                                                widget.account['schedule_url'],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.network(
                                    widget.account['schedule_url'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Text(
                                  'This user has not uploaded their schedule yet'),
                        ),
                      ),
//                     if (widget.account != null)

//                       ElevatedButton(
//   onPressed: () async {
//     var response = await http.get(Uri.parse('https://example.com/image.png'));
//     var filePath = await ImagePickerSaver.saveFile(fileData: response.bodyBytes);
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image saved to gallery')));
//   },
//   child: Text('Download Image'),
// );
                  ],
                )),
              ),
            ],
          )),
        ));
  }
}

Widget cropCircleImage(BuildContext context, final account, double val) {
  double size = MediaQuery.of(context).size.width / val;
  if (account == null) {
    return SizedBox(
        height: size,
        width: size,
        child: CircleAvatar(
          radius: size,
          backgroundImage: null,
          backgroundColor: Colors.blueGrey,
        ));
  }
  return account['avatar_url'] != null
      ? SizedBox(
          height: size,
          width: size,
          child: ClipOval(
              child: Image.network(
            account['avatar_url'],
            width: size,
            height: size,
            fit: BoxFit.cover,
          )),
        )
      : SizedBox(
          height: size,
          width: size,
          child: CircleAvatar(
            radius: size,
            backgroundImage: null,
            backgroundColor: Colors.blueGrey,
            child: Text(
              account['username'][0].toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: clr2, fontSize: 30),
            ),
          ));
}
