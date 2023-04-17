import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_share/main.dart';
import 'package:photo_view/photo_view.dart';

class MySchedule extends StatefulWidget {
  const MySchedule({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  _MyScheduleState createState() => _MyScheduleState();
}

class _MyScheduleState extends State<MySchedule> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.width / 5;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: widget.imageUrl == null || widget.imageUrl!.isEmpty
              ? const Text('You have not uploaded your schedule yet')
              : GestureDetector(
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
                                  width:
                                      MediaQuery.of(dialogContext).size.width,
                                  height:
                                      MediaQuery.of(dialogContext).size.height,
                                  child: PhotoView(
                                    enableRotation: true,
                                    backgroundDecoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    imageProvider: NetworkImage(
                                      widget.imageUrl!,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
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
                    widget.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        widget.imageUrl == null || widget.imageUrl!.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF103465),
                  ),
                  child: const Text('Upload Schedule'),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF103465),
                  ),
                  child: const Text('Update Schedule'),
                ),
              ),
      ],
    );
  }

  Future<void> _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
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
      await supabase.storage.from('schedule').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: imageFile.mimeType),
          );
      final imageUrlResponse = await supabase.storage
          .from('schedule')
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
