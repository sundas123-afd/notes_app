import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  // Firebase Auth instance
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  // Google Sign In instance
  final GoogleSignIn googleSignIn = GoogleSignIn();

  
  User? getCurrentUser() {
    return auth.currentUser;
  }

  
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      
      if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.message ?? 'Sign up failed';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      
      if (e.code == 'user-not-found') {
        return 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  
  Future<String?> signInWithGoogle() async {
    try {
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      
      if (googleUser == null) {
        return 'Sign in cancelled';
      }

      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      
      await auth.signInWithCredential(credential);
      
      return null; 
    } catch (e) {
      return 'Google sign in failed: $e';
    }
  }

 
  Future<void> logout() async {
    await auth.signOut();
    await googleSignIn.signOut();
  }

  
  Future<String?> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.message ?? 'Failed to send reset email';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
}