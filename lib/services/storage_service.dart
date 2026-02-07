import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads raw image bytes (works on web & mobile) and returns the download URL.
  static Future<String> uploadChatImageBytes(Uint8List bytes, String expertId,
      {String contentType = 'image/jpeg'}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'chats/$expertId/$timestamp.jpg';
    final ref = _storage.ref().child(path);

    final uploadTask = ref.putData(bytes, SettableMetadata(contentType: contentType));
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
