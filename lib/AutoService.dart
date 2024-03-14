import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with phone number
  Future<void> signInWithPhoneNumber(String smsCode, String verificationId) async {
    AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

    try {
      await _auth.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
    }
  }

  // Verify phone number and proceed to sign in or sign up
  Future<void> verifyPhoneNumber(String phoneNumber, Function(String) codeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Check if user is logged in
  User? get currentUser => _auth.currentUser;

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
