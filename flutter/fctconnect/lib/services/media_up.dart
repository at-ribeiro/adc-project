import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

enum MediaType { image, video }

class MediaUp {
  Future<Map<String, dynamic>> pickFile(MediaType mediaType) async {
    FileType fileType;

    switch (mediaType) {
      case MediaType.image:
        fileType = FileType.image;
        break;
      case MediaType.video:
        fileType = FileType.video;
        break;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      Uint8List fileData = file.bytes!;
      String fileName = file.name;
      String fileExtension = fileName.split('.').last;

      return {
        'fileData': fileData,
        'mediaType': fileExtension,
        'fileName': fileName,
        'type': mediaType == MediaType.image ? 'image' : 'video',
      };
    }

    return {};
  }

  Future<Map<String, dynamic>> takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final fileData = await File(pickedFile.path).readAsBytes();
      Uint8List imageData = Uint8List.fromList(fileData);
      String fileName = pickedFile.path.split('/').last;

      return {
        'fileData': imageData,
        'mediaType': 'jpeg',
        'fileName': fileName,
        'type': MediaType.image,
      };
    }

    return {};
  }
}
	