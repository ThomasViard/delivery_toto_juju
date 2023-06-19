import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthenticationService {
  final auth = FirebaseAuth.instance;

  AppUser? userFromFirebaseUser(User? user) {
    return user != null ? AppUser(uid: user.uid) : null;
  }

  Stream<AppUser?> get user {
    return auth.authStateChanges().map(userFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String? email, String? password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
        email: email!, password: password!);
      User? user = result.user;
      return userFromFirebaseUser(user);
    } catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }
      return null;
    }
  }

  Future registerWithEmailAndPassword(String? email, String? password) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      User? user = result.user;
      return userFromFirebaseUser(user);
    } catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }
      return null;
    }
  }

  Future checkIfEmailInUse(String? email) async {
    try {
      final list = await auth.fetchSignInMethodsForEmail(email!);

      if (list.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }
      return true;
    }
  }

  Future resetPasswordFromEmail(String? email) async {
    try {
      await auth.sendPasswordResetEmail(email: email!);
    } catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }
    }
  }

  Future signOut() async {
    try {
      return await auth.signOut();
    } catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }
      return null;
    }
  }
}
