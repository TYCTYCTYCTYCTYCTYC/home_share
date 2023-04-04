import 'package:flutter/material.dart';

import 'package:home_share/main.dart';

class Fridge extends StatefulWidget {
  const Fridge({Key? key}) : super(key: key);

  @override
  _FridgeState createState() => _FridgeState();
}

class _FridgeState extends State<Fridge> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "HomeShare",
        home: Scaffold(
          appBar: AppBar(),
          backgroundColor: const Color.fromARGB(255, 180, 231, 255),
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

  // @override
  // bool get wantKeepAlive => true;
}
