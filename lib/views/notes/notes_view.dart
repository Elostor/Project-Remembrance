import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;
import 'package:project_remembrance/constants/routes.dart';
import 'package:project_remembrance/services/auth/auth_service.dart';
import 'package:project_remembrance/services/auth/bloc/auth_event.dart';
import 'package:project_remembrance/services/cloud/cloud_note.dart';
import 'package:project_remembrance/services/cloud/firebase_cloud_storage.dart';
import 'package:project_remembrance/views/notes/notes_list_view.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String get userId => AuthService.firebase().currentUser!.userId;
  late final FirebaseCloudStorage _notesService;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            }, 
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch(value) {
                case MenuAction.logout: // Logs the user out.
                  final shouldLogout = await showLogOutDialog(context);
                  devtools.log(value.toString()); // Make a log.
                  if (shouldLogout && mounted) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                )
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Text('Waiting for notes...');
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;

                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId,
                      );
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              default:
                return const CircularProgressIndicator();
            }
          }
      )
    );
  }
}

/*Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Proceed')
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel')
        )
      ],
    )
  ).then((value) => value ?? false);
}*/ //ShowLogOutDialog Function

