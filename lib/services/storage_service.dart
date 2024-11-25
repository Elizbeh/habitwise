import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';


// StorageService class handles file uploads to Firebase Storage
class StorageService {
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

  Future<String> uploadFile(File file, {String folder = 'images', int maxWidth = 500, int quality = 85}) async {
    try {
      // Read the original image and decode it
      img.Image? image = img.decodeImage(await file.readAsBytes());
      if (image == null) {
        throw Exception("Failed to decode image");
      }

      // Resize and compress the image
      img.Image resizedImage = img.copyResize(image, width: maxWidth);
      List<int> compressedImage = img.encodeJpg(resizedImage, quality: quality);

      // Create a temporary file for the compressed image
      var uuid = Uuid();
      String fileName = '${uuid.v4()}_${path.basename(file.path)}';
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$fileName.jpg');
      await tempFile.writeAsBytes(compressedImage);

      // Upload the compressed image
      firebase_storage.Reference ref = _storage.ref().child('$folder/$fileName');
      firebase_storage.UploadTask uploadTask = ref.putFile(tempFile);
      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Delete the temporary file after upload
      await tempFile.delete();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file to Firebase Storage: $e');
      throw e;
    }
  }

  Future<String> uploadGroupPhoto(File file) async {
  return await uploadFile(file, folder: 'group_images');
}

Future<File> getImageFileFromUrl(String imageUrl) async {
  try {
    final response = await HttpClient().getUrl(Uri.parse(imageUrl));
    final fileBytes = await response.close().then((res) => res.toList());
    final filePath = path.join(Directory.systemTemp.path, path.basename(imageUrl));
    final file = File(filePath);
    await file.writeAsBytes(fileBytes.expand((x) => x).toList());
    return file;
  } catch (e) {
    print('Error fetching image from URL: $e');
    throw e;
  }
}

}
