import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUp {
  
  Future<Map<String, dynamic>> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      Uint8List imageData = Uint8List.fromList(fileData);
      String fileName = pickedFile.path.split('/').last;
      
      return {'imageData': imageData, 'fileName': fileName};
    }
    
    return {};
  }

  Future<Map<String, dynamic>> takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      Uint8List imageData = Uint8List.fromList(fileData);
      String fileName = pickedFile.path.split('/').last;
      
      return {'imageData': imageData, 'fileName': fileName};
    }
    
    return {};
  }



}
