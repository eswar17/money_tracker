import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> createUserIfNeeded(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();

    if (doc.exists) {
      return;
    }

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> hasWorkspace(String uid) async {
    print('==============================');

    final doc = await _db.collection('users').doc(uid).get();

    print('DOC EXISTS: ${doc.exists}');
    print('DATA: ${doc.data()}');

    final data = doc.data();

    final result = data?['workspaceId'] != null;

    print('HAS WORKSPACE: $result');

    print('==============================');

    return result;
  }

  static Future<String?> getWorkspaceId(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    return doc.data()?['workspaceId'];
  }
}
