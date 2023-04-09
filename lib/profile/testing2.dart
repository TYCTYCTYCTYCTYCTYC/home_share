import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/main.dart';
import 'package:home_share/profile/avatar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SupabaseImagePage extends StatefulWidget {
  @override
  _SupabaseImagePageState createState() => _SupabaseImagePageState();
}

class _SupabaseImagePageState extends State<SupabaseImagePage> {
  late Uint8List _imageData;
  late final String _userId;
  String? _avatarUrl;
  var _loading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadImage();
  // }

  // void _loadImage() async {
  //   // Replace "objects" with your table name
  //   final response = await supabase.storage
  //       .from('objects')
  //       .download('$_userId.jpg');

  //     setState(() {
  //       _imageData = response.data;
  //     });
  //   }

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single() as Map;

      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      //context.showErrorSnackBar(message: error.message);
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected exception occurred');
    }

    setState(() {
      _loading = false;
    });
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });

    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Successfully update profile',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.amber,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    } on PostgrestException catch (error) {
      Fluttertoast.showToast(
        msg: 'error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpeted error occurred');
    }
    setState(() {
      _loading = false;
    });
  }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'profile image updated',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.amber,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    } on PostgrestException catch (error) {
      Fluttertoast.showToast(
        msg: 'error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          Avatar(
            imageUrl: _avatarUrl,
            onUpload: _onUpload,
          ),
          const SizedBox(height: 18),
          TextFormField(
            //controller: _usernameController,
            decoration: const InputDecoration(labelText: 'User Name'),
          ),
          const SizedBox(height: 18),
          TextFormField(
            //controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _updateProfile,
            child: Text(_loading ? 'Saving...' : 'Update'),
          ),
          const SizedBox(height: 18),
          //TextButton(onPressed: _signOut, child: const Text('Sign Out')),
        ],
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = Supabase.instance.client.auth.currentUser;
//     final _currentUserId = currentUser?.id;

//     if (_imageData == null) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return Scaffold(
//       body: Center(
//         child: Image.memory(_imageData),
//       ),
//     );
//   }
// }
