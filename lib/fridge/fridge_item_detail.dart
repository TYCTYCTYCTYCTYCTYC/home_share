import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fridge_item_appbar.dart';
import 'fridge.dart';
import 'package:google_fonts/google_fonts.dart';

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
    Navigator.push(context, MaterialPageRoute(builder: (context) => Fridge()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            FridgeItemAppBar(),
            Padding(
              padding: EdgeInsets.all(5),
              child: Image.network(widget.item['item_image_url'], height: 220),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 50,
                bottom: 20,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
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
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50.0),
              child: Text(
                widget.item['description'],
                textAlign: TextAlign.justify,
                style: GoogleFonts.quicksand(
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: null, // Remove the original FloatingActionButton
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ElevatedButton(
          onPressed: () {
            // Show confirmation dialog before deleting item
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirm Delete'),
                  content: Text('Are you sure you want to delete this item?'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                        onPrimary: Colors.white,
                      ),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Delete item and close the dialog
                        String itemIdString = widget.item['id'].toString();
                        deleteItemFromFridge(itemIdString);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                      ),
                      child: Text('Delete'),
                    ),
                  ],
                );
              },
            );
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
