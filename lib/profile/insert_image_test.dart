// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:home_share/main.dart'; 


// class ImageListPage extends StatefulWidget {
//   const ImageListPage({Key? key}) : super(key: key);

//   @override
//   _ImageListPageState createState() => _ImageListPageState();
// }

// class _ImageListPageState extends State<ImageListPage> {
//   late List<Uri> _imageUrls;

//   @override
//   void initState() {
//     super.initState();
//     _getImageUrls();
//   }

//   Future<void> _getImageUrls() async {
//     final storage = supabase.storage.from('image');
//     final response = await storage.list();
//     final data = response.data;
//     final urls = <Uri>[];
//     for (var item in data!) {
//       final downloadResponse = await storage.from('$item').download();
//       final bytes = downloadResponse.data!;
//       final blob = Uint8List.fromList(bytes);
//       final url = Uri.dataFromBytes(blob, mimeType: 'image/jpeg');
//       urls.add(url);
//     }
//     setState(() {
//       _imageUrls = urls;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image List'),
//       ),
//       body: _imageUrls == null
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//               gridDelegate:
//                   SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//               itemCount: _imageUrls.length,
//               itemBuilder: (context, index) {
//                 final url = _imageUrls[index];
//                 return Image.network(url.toString());
//               },
//             ),
//     );
//   }
// }
