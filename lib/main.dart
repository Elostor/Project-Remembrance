import 'package:flutter/material.dart';
import 'package:project_remembrance/constants/routes.dart';
import 'package:project_remembrance/services/auth/auth_service.dart';
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
        home: const HomeView(),
        routes: {
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          notesRoute: (context) => const NotesView(),
          verifyEmailRoute: (context) => const VerifyEmailView(),
          createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
        },
      )
  );
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.done :
              final user = AuthService.firebase().currentUser;

              if (user != null) {
                if (user.isEmailVerified) {
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }

            default:
              return const CircularProgressIndicator(
                backgroundColor: Colors.black26,
                color: Colors.lightGreen,
              );
          }
        },
      ),
    );
  }
}


