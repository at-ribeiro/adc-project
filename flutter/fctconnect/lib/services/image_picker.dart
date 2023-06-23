import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';


class ImageGetter{


Future<dynamic> pickImageFromGallery() async {

  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    print('Image picked: ${pickedFile.path}');
    return pickedFile;
  } else {

    print('No image selected');
    return;
  }
}

Future<dynamic> pickImageFromFilePicker() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

  if(result != null) {
    // Handle the image file
    print('Image picked: ${result.files.single.path}');
    return result;
  } else {
    print('No image selected');
    return;
  }

}
}