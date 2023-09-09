import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_remembrance/constants/routes.dart';
import 'package:project_remembrance/services/auth/bloc/auth_bloc.dart';
import 'package:project_remembrance/services/auth/bloc/auth_event.dart';
import 'package:project_remembrance/services/auth/bloc/auth_state.dart';
import 'package:project_remembrance/services/auth/firebase_auth_provider.dart';
import 'package:project_remembrance/views/login_view.dart';
import 'package:project_remembrance/views/notes/create_update_note_view.dart';
import 'package:project_remembrance/views/notes/notes_view.dart';
import 'package:project_remembrance/views/register_view.dart';
import 'package:project_remembrance/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      MaterialApp(
        title: 'Remember What is Forgotten',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
          useMaterial3: true,
        ),
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const HomeView(),
        ),
        routes: {
          createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
        },
      )
  );
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder(
        builder: (context, state) {
          if (state is AuthStateLoggedIn) {
            return const NotesView();
          } else if (state is AuthStateVerifyEmail) {
            return const VerifyEmailView();
          } else if (state is AuthStateLoggedOut) {
            return const LoginView();
          } else if (state is AuthStateRegistering) {
            return const RegisterView();
          } else {
            return const Scaffold(
              body: CircularProgressIndicator(),
            );
          }
        },
    );
  }
}


