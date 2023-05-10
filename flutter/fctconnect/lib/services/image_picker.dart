import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';


class ImagePicker (){

Future<void> pickImageFromGallery() async {
  final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    // Handle the image file
    print('Image picked: ${pickedFile.path}');
  } else {
    print('No image selected');
  }
}

Future<void> pickImageFromFilePicker() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

  if(result != null) {
    // Handle the image file
    print('Image picked: ${result.files.single.path}');
  } else {
    print('No image selected');
  }

}