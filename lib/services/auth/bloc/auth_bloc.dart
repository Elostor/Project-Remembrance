import 'package:bloc/bloc.dart';
import 'package:project_remembrance/services/auth/auth_provider.dart';
import 'package:project_remembrance/services/auth/bloc/auth_event.dart';
import 'package:project_remembrance/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    // Initialize Event
    on<AuthEventInitialize>((event, emit) async {
      provider.initialize();
      final user = provider.currentUser;

      if (user == null) {
        emit(const AuthStateLoggedOut(null, false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateVerifyEmail());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    },);

    // LogIn Event
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(null, true));
      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);

        if (!user.isEmailVerified){
          emit(const AuthStateLoggedOut(null, false));
          emit(const AuthStateVerifyEmail());
        } else {
          emit(const AuthStateLoggedOut(null, false));
          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e, false));
      }
    },);

    // LogOut Event
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(null, false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e, false));
      }
    },);

    // Register Event
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createAccount(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateVerifyEmail());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    },);

    // Send Email Verification Event
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    },);
  }

}