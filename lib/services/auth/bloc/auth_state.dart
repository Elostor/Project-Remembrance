import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:project_remembrance/services/auth/auth_user.dart';

@immutable
sealed class AuthState {
  final bool isLoading;
  final String? loadingText;

  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment'
  });
}

final class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

final class AuthStateLoggedIn extends AuthState {
  final AuthUser user;

  const AuthStateLoggedIn({required this.user, required isLoading})
      : super(isLoading: isLoading);
}

final class AuthStateVerifyEmail extends AuthState {
  const AuthStateVerifyEmail({required isLoading})
      : super(isLoading: isLoading);
}

final class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;

  const AuthStateLoggedOut({
    required this.exception,
    required isLoading,
    String? loadingText})
      : super(isLoading: isLoading, loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}

final class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({required this.exception, required isLoading})
      : super(isLoading: isLoading);
}

final class AuthStateForgotPassword extends AuthState{
  final Exception? exception;
  final bool emailSent;

  const AuthStateForgotPassword({
    required this.exception,
    required this.emailSent,
    required bool isLoading
  }) : super(isLoading: isLoading);
}