import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/main.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isLoading = false;
 Widget ifImageNull() {
  final currentUser = Supabase.instance.client.auth.currentUser;
  final userId = currentUser?.id;

  return FutureBuilder(
    future: supabase
        .from('profiles')
        .select('username')
        .eq('id', userId)
        .execute(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Show a loading spinner if the data is still loading
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Show an error message if something went wrong
        return Text('Error: ${snapshot.error}');
      } else {
        // Show the first letter of the username
        final data = snapshot.data!.data as List<dynamic>;
        final username = data.first['username'] as String;

        return Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              username[0].toUpperCase(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: SizedBox(
            width: 150,
            height: 150,
            child: widget.imageUrl == null || widget.imageUrl!.isEmpty
                ? ifImageNull()
                : Image.network(
                    widget.imageUrl!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _upload,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF103465),
          ),
          child: const Text('Upload'),
        ),
      ],
    );
  }

  Future<void> _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;
      await supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: imageFile.mimeType),
          );
      final imageUrlResponse = await supabase.storage
          .from('avatars')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      widget.onUpload(imageUrlResponse);
    } on StorageException catch (error) {
      if (mounted) {
        //context.showErrorSnackBar(message: error.message);
      }
    } catch (error) {
      if (mounted) {
        //context.showErrorSnackBar(message: 'Unexpected error occurred');
      }
    }

    setState(() => _isLoading = false);
  }
}
