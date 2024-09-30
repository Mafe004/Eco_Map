import 'dart:io';
import 'package:image/image.dart' as img;

class ImageHelper {
  static String getImageResolution(File imageFile) {
    final image = img.decodeImage(imageFile.readAsBytesSync());
    return '${image!.width}x${image.height}';
  }
}