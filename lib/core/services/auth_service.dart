import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await signInAnonymously();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
