
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

Future<String?> registration({
  required String email,
  required String password,
  required String confirmPassword,
}) async {
  try {
    if (password != confirmPassword) {
      return 'Password and Confirm Password do not match.';
    }

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return 'Success';
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      return 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      return 'The account already exists for that email.';
    } else {
      if (e.code == 'network-request-failed') {
        return 'No internet connection.';
      }
      return e.message;
    }
  } catch (e) {
    return e.toString();
  }
}




  // Method for user login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in with the provided email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException cases
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        // Check for network-related issue
        if (e.code == 'network-request-failed') {
          return 'No internet connection.';
        }
        return e.message;
      }
    } catch (e) {
      // Return the general error message for any other exceptions
      return e.toString();
    }
  }
}