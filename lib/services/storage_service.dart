import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';


// StorageService class handles file uploads to Firebase Storage
class StorageService {
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

// Method to upload a file to Firebase Storage and return the download URL
  /*Future<String> uploadFile(File file) async {
    try {
      var uuid = Uuid();
      String fileName = '${uuid.v4()}_${path.basename(file.path)}';
      firebase_storage.Reference ref = _storage.ref().child('images/$fileName');
      firebase_storage.UploadTask uploadTask = ref.putFile(file);

      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file to Firebase Storage: $e');
      throw e;
    }
  }

  // Method to upload a file to Firebase Storage and return the download URL
  Future<String> uploadGroupPhoto(File file) async {
    try {
      var uuid = Uuid();
      String fileName = '${uuid.v4()}_${path.basename(file.path)}';
      firebase_storage.Reference ref = _storage.ref().child('group_images/$fileName');
      firebase_storage.UploadTask uploadTask = ref.putFile(file);

      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading group photo to Firebase Storage: $e');
      throw e;
    }
  }*/
  Future<String> uploadFile(File file, {String folder = 'images'}) async {
  try {
    var uuid = Uuid();
    String fileName = '${uuid.v4()}_${path.basename(file.path)}';
    firebase_storage.Reference ref = _storage.ref().child('$folder/$fileName');
    firebase_storage.UploadTask uploadTask = ref.putFile(file);
    firebase_storage.TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print('Error uploading file to Firebase Storage: $e');
    throw e;
  }
}

  Future<String> uploadGroupPhoto(File file) async {
  return await uploadFile(file, folder: 'group_images');
}

}
