import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageService {
  Future<List<File>> pickImages({required int maxImages}) async {
    final pickedImages = await ImagePicker().pickMultiImage(
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 75,
    );

    return pickedImages?.map((image) => File(image.path)).toList() ?? [];
  }

  Future<File?> takePhoto() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 75,
    );

    return pickedImage != null ? File(pickedImage.path) : null;
  }
}
