import 'dart:io';
import 'dart:collection';
import 'package:image/image.dart';

void main() async {
  final file = File('assets/images/small_old_man.png');
  if (!await file.exists()) {
    print('File not found');
    return;
  }
  
  final bytes = await file.readAsBytes();
  final image = decodeImage(bytes);
  if (image == null) return;
  
  final newImage = Image(width: image.width, height: image.height, numChannels: 4);
  
  // copy image
  for (var y = 0; y < image.height; ++y) {
    for (var x = 0; x < image.width; ++x) {
      final p = image.getPixel(x, y);
      newImage.setPixelRgba(x, y, p.r, p.g, p.b, 255);
    }
  }

  // flood fill from (0,0)
  final startP = newImage.getPixel(0, 0);
  final targetR = startP.r;
  final targetG = startP.g;
  final targetB = startP.b;
  
  bool isTarget(Pixel p) {
    return (p.r - targetR).abs() < 50 && 
           (p.g - targetG).abs() < 50 && 
           (p.b - targetB).abs() < 50;
  }

  var queue = Queue<List<int>>();
  queue.add([0, 0]);
  
  var visited = List.generate(image.height, (i) => List.filled(image.width, false));
  visited[0][0] = true;

  while (queue.isNotEmpty) {
    var pos = queue.removeFirst();
    int x = pos[0];
    int y = pos[1];
    
    newImage.setPixelRgba(x, y, 0, 0, 0, 0);

    // check neighbors
    final dx = [0, 0, 1, -1];
    final dy = [1, -1, 0, 0];
    for(int i=0; i<4; i++) {
      int nx = x + dx[i];
      int ny = y + dy[i];
      if(nx >= 0 && nx < image.width && ny >= 0 && ny < image.height) {
        if(!visited[ny][nx]) {
          visited[ny][nx] = true;
          if(isTarget(newImage.getPixel(nx, ny))) {
            queue.add([nx, ny]);
          }
        }
      }
    }
  }

  final pngBytes = encodePng(newImage);
  await file.writeAsBytes(pngBytes);
  print('Background removed!');
}
