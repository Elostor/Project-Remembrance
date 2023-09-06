import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String email;
  final String userId;

  const AuthUser({required this.userId, required this.isEmailVerified, required this.email});
  factory AuthUser.fromFirebase(User user) => AuthUser(
    userId: user.uid,
    isEmailVerified: user.emailVerified,
    email: user.email!,
  );
}