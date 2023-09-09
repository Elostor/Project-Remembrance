import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:project_remembrance/services/auth/auth_user.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

final class AuthStateLoggedIn extends AuthState {
  final AuthUser user;

  const AuthStateLoggedIn(this.user);
}

final class AuthStateVerifyEmail extends AuthState {
  const AuthStateVerifyEmail();
}

final class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;

  const AuthStateLoggedOut(this.exception, this.isLoading);

  @override
  List<Object?> get props => [exception, isLoading];
}

final class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering(this.exception);
}