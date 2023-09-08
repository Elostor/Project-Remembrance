import 'package:flutter/material.dart';
import 'package:project_remembrance/services/auth/auth_service.dart';
import 'package:project_remembrance/services/cloud/cloud_note.dart';
import 'package:project_remembrance/services/cloud/firebase_cloud_storage.dart';
import 'package:project_remembrance/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

import '../../utilities/dialogs/cannot_share_empty_note_dialog.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  final currentUser = AuthService.firebase().currentUser!;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _titleController = TextEditingController();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfEmptyText();
    _autoSaveNoteIfNotEmpty();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (_note != null) ? const Text('Edit Note') : const Text('New Note'),
        actions: [
          IconButton(
              onPressed: () async {
                final text = _textController.text;

                if (_note != null || text.isEmpty) {
                  await showCannotShareEmptyNoteDialog(context);
                } else {
                  Share.share(text);
                }
              }, 
              icon: const Icon(Icons.share)
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setUpTextControllerListener();
              return Row(
                children: [
                  TextField(
                    controller: _titleController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Start typing a title...'
                    ),
                  ),
                  TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Start typing your note...'
                    ),
                  ),
                ],
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      )
    );
  }

  void _textControllerListener() async {
    final note = _note;
    final title = _titleController.text;
    final text = _textController.text;

    if (note == null) {
      return;
    } else {
      await _notesService.updateNote(
          documentId: note.documentId,
          title: title,
          text: text
      );
    }
  }

  void _setUpTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    } else {
      final existingNote = _note;

      if (existingNote != null) {
        return existingNote;
      } else {
        final newNote = await _notesService.createNewNote(ownerUserId: currentUser.userId);
        _note = newNote;
        return newNote;
      }
    }
  }

  void _deleteNoteIfEmptyText() async {
    final note = _note;

    if (_textController.text.isEmpty && note != null) {
      await _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _autoSaveNoteIfNotEmpty() async {
    final note = _note;
    final title = _titleController.text;
    final text = _textController.text;

    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
          documentId: note.documentId,
          title: title,
          text: text
      );
    }
  }
}
