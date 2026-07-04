import 'dart:io';
import 'package:image/image.dart';

void main() async {
  final files = ['assets/images/bear_boss.png'];
  
  for (var path in files) {
    final file = File(path);
    if (!await file.exists()) {
      print('File not found: $path');
      continue;
    }
    
    final bytes = await file.readAsBytes();
    final originalImage = decodeImage(bytes);
    if (originalImage == null) continue;
    
    final newImage = Image(width: originalImage.width, height: originalImage.height, numChannels: 4);
    
    for (var y = 0; y < originalImage.height; ++y) {
      for (var x = 0; x < originalImage.width; ++x) {
        final pixel = originalImage.getPixel(x, y);
        if (pixel.r >= 220 && pixel.g >= 220 && pixel.b >= 220) {
          newImage.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 0);
        } else {
          newImage.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 255);
        }
      }
    }
    
    final pngBytes = encodePng(newImage);
    await file.writeAsBytes(pngBytes);
    print('Processed and background removed: $path');
  }
}
