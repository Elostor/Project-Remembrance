import 'package:firebase_core/firebase_core.dart';
import 'package:project_remembrance/firebase_options.dart';

import 'auth_provider.dart';
import 'auth_user.dart';
import 'auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'dart:developer' as devtools show log;
import 'package:project_remembrance/firebase_options.dart';

class FirebaseAuthProvider implements AuthProvider {

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createAccount({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;

      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'weak-password':
          devtools.log('Weak password.');
          throw WeakPasswordAuthException();
        case 'email-already-in-use':
          devtools.log('E-mail is already in use');
          throw EmailAlreadyInUseAuthException();
        case 'invalid-email':
          devtools.log('E-mail is invalid.');
          throw InvalidEmailAuthException();
        default:
          devtools.log('Error: ${e.code}');
          throw GenericAuthException();
      }
    } catch (_) {
      devtools.log('Error: $_');
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;

      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          devtools.log('Please check your user credentials.');
          throw UserNotFoundAuthException();
        case 'wrong-password':
          devtools.log('Please check your user credentials.');
          throw WrongPasswordAuthException();
        default:
          devtools.log('Error: ${e.code}');
          throw GenericAuthException();
      }
    } catch (_) {
      devtools.log('Error: $_');
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
