import 'package:bloc/bloc.dart';
import 'package:project_remembrance/services/auth/auth_provider.dart';
import 'package:project_remembrance/services/auth/bloc/auth_event.dart';
import 'package:project_remembrance/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // Initialize Event
    on<AuthEventInitialize>((event, emit) async {
      provider.initialize();
      final user = provider.currentUser;

      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateVerifyEmail(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    },);

    // LogIn Event
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
          exception: null,
          isLoading:  true,
          loadingText: 'Please wait while app is logging you in'
      ));
      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);

        if (!user.isEmailVerified){
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateVerifyEmail(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    },);

    // LogOut Event
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    },);

    // ShouldRegister Event
    on<AuthEventShouldRegister>((event, emit) async {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    },);

    // Register Event
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createAccount(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateVerifyEmail(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    },);

    // Send Email Verification Event
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    },);

    // Send Password Reset Email Event
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
          exception: null,
          emailSent: false,
          isLoading: false
      ));

      final email = event.email;
      bool emailSent;
      Exception? exception;

      if (email == null) {
        return;
      }
      emit(const AuthStateForgotPassword(
          exception: null,
          emailSent: false,
          isLoading: true
      ));

      try {
        await provider.sendPasswordResetEmail(email: email);
        emailSent = true;
        exception = null;
      } on Exception catch (e) {
        emailSent = false;
        exception = e;
      }
      emit(AuthStateForgotPassword(
          exception: exception,
          emailSent: emailSent,
          isLoading: false
      ));
    },);
  }

}