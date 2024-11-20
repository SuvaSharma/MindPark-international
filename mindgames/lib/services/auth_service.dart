import 'package:cloud_firestore/cloud_firestore.dart';

import '../change_notifiers/registration_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;

  static User? get user => _auth.currentUser;

  static Stream<User?> get userStream => _auth.userChanges();

  static bool get isEmailVerified => user?.emailVerified ?? false;

  static final db = FirebaseFirestore.instance;

  static Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String gender,
    required String age,
  }) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((credential) {
        credential.user?.sendEmailVerification();
        credential.user?.updateDisplayName(fullName);
        db.collection('users').add({
          'userId': credential.user?.uid,
          'name': fullName,
          'email': email,
          // 'age': int.tryParse(age),
          // 'gender': gender,
          'agreedToTerms': false,
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw const NoGoogleAccountChosenException();
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    print('User logged in credential: ${credential}');

    // Once signed in, return the UserCredential
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print('User credential returned ${userCredential.user}');

    final newUser = userCredential.additionalUserInfo?.isNewUser;
    if (newUser!) {
      db.collection('users').add({
        'userId': userCredential.user?.uid,
        'name': userCredential.user?.displayName,
        'email': userCredential.user?.email,
        'age': '',
        'gender': '',
        'agreedToTerms': false,
      });
    }

    return userCredential;
  }

  static Future<void> resetPassword({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);

  static Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
