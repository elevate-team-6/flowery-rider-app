import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<File?> pickFromGallery() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    return image != null ? File(image.path) : null;
  }

  static Future<File?> pickFromCamera() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    return image != null ? File(image.path) : null;
  }
}