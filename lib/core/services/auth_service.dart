import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/auth/user_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance =
      AuthService._();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount?
      googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final googleAuth =
          await googleUser.authentication;

      final credential =
          GoogleAuthProvider.credential(
            accessToken:
                googleAuth.accessToken,
            idToken:
                googleAuth.idToken,
          );

      final userCredential =
          await _auth.signInWithCredential(
            credential,
          );

      if (userCredential.user != null) {
        await UserService.createUserIfNeeded(
          userCredential.user!,
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      print(
        '=====================',
      );
      print('Before signout');

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }

      print('Google signout done');

      await _auth.signOut();

      print('Firebase signout done');
      print('After signout');
      print(
        '=====================',
      );
    } catch (e) {
      print(
        'SIGNOUT ERROR: $e',
      );
      rethrow;
    }
  }

  User? get currentUser =>
      _auth.currentUser;

  Stream<User?> get authChanges =>
      _auth.authStateChanges();
}