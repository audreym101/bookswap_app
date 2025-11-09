import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadBookImage(File imageFile, String bookId) async {
    try {
      final ref = _storage.ref().child('book_images').child('$bookId.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }
}