import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/main.dart';
import 'package:photo_view/photo_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;

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
  late BuildContext _dialogContext;

  Future<void> downloadImage(String imageUrl) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        var response = await dio.Dio().get(imageUrl,
            options: dio.Options(responseType: dio.ResponseType.bytes));
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.data),
            quality: 60,
            name: "${widget.account['username']}Schedule.jpg");
        Fluttertoast.showToast(msg: 'Image downloaded successfully!');
      } else {
        Fluttertoast.showToast(msg: 'Failed to download image!');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error downloading image: $e');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _saveNetworkImage() async {
    try {
      String path = widget.account['schedule_url'];
      GallerySaver.saveImage(path, toDcim: true).then((success) {
        showToast('Schedule downloaded successfully');
      });
    } catch (error) {
      log(123);
    }
  }

  @override
  void initState() {
    super.initState();
    _otherUserScheduleKey = GlobalKey<ScaffoldState>();
    // loadDB();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dialogContext = context;
  }

  @override
  void dispose() {
    // Use the saved reference to the dialog context to dismiss the dialog
    Navigator.of(_dialogContext).pop();
    super.dispose();
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
                                                      widget.account[
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
                                    widget.account['schedule_url'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Text(
                                  'This user has not uploaded their schedule yet'),
                        ),
                      ),
                    if (widget.account != null &&
                        widget.account['schedule_url'] != null)
                      ElevatedButton(
                        onPressed: () async {
                          // _saveNetworkImage();
                          downloadImage(widget.account['schedule_url']);
                        },
                        child: Text('Download Image'),
                      )
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
