import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fridge_item_appbar.dart';
import 'fridge.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class FridgeItemDetail extends StatefulWidget {
  final dynamic item;

  const FridgeItemDetail({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  _FridgeItemDetailState createState() => _FridgeItemDetailState();
}

class _FridgeItemDetailState extends State<FridgeItemDetail> {
  Color clr1 = const Color(0xFF103465);

  Future<void> deleteItemFromFridge(String itemId) async {
    final response = await Supabase.instance.client
        .from('fridge')
        .delete()
        .match({'id': itemId}).execute();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Fridge()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          FridgeItemAppBar(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Image.network(widget.item['item_image_url'], height: 300),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 50,
              bottom: 20,
            ),
            child: Row(
              children: [
                Text(
                  "Product Description",
                  style: GoogleFonts.arvo(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              widget.item['description'],
              textAlign: TextAlign.justify,
              style: GoogleFonts.arvo(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      floatingActionButton: null, // Remove the original FloatingActionButton
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to FridgeFormPage
            String itemIdString = widget.item['id'].toString();
            deleteItemFromFridge(itemIdString);
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.amber,
            onPrimary: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            'Delete',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
