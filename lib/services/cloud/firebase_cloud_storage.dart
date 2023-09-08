import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_remembrance/constants/cloud_storage_constants.dart';
import 'package:project_remembrance/services/cloud/cloud_storage_exception.dart';
import 'cloud_note.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  // Create a singleton
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map(
              (event) => event.docs.map(
                      (doc) => CloudNote.fromSnapshot(doc)
              ).where((note) => note.ownerUserId == ownerUserId)
      );

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes.where(
          ownerUsedIdFieldName,
          isEqualTo: ownerUserId
      ).get()
          .then(
              (querySnapshot) => querySnapshot.docs.map(
                    (doc) => CloudNote.fromSnapshot(doc),
              ),
      );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUsedIdFieldName: ownerUserId,
      titleFieldName: '',
      textFieldName: '',
    });
    final fetchedNote = await document.get();

    return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerUserId,
        title: '',
        text: '',
    );
  }

  Future<void> updateNote({
    required String documentId,
    required String title,
    required String text
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        textFieldName: text
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
  /*
  Future<bool> syncAllNotes({required Iterable<CloudNote> dbNoteList, required String ownerUserId}) async {
    final userCloudNoteList = await getNotes(ownerUserId: ownerUserId);
    bool operationFinished;

    if (dbNoteList.isEmpty) {
      try {
        for(int i = 0; i < userCloudNoteList.length; i++) {
          await deleteNote(documentId: userCloudNoteList.elementAt(i).documentId);
        }
        operationFinished = true;
      } catch (e) {
        operationFinished = false;
        throw CouldNotDeleteNoteException();
      }
    } else if (dbNoteList.length < userCloudNoteList.length) {
      userCloudNoteList.toList().removeWhere(
              (note) => dbNoteList.toList().contains(note));

      try {
        for(int i = 0; i < userCloudNoteList.length; i++) {
          await deleteNote(documentId: userCloudNoteList.elementAt(i).documentId);
        }
        operationFinished = true;
      } catch (e) {
        operationFinished = false;
        throw CouldNotDeleteNoteException();
      }
    } else if (dbNoteList.length > userCloudNoteList.length) {
      dbNoteList.toList().removeWhere(
              (note) => userCloudNoteList.toList().contains(note));

      try {
        for(int i = 0; i < dbNoteList.length; i++) {
          await notes.add({
            ownerUsedIdFieldName: ownerUserId,
            titleFieldName: dbNoteList.elementAt(i).title,
            textFieldName: dbNoteList.elementAt(i).text
          });
        }
        operationFinished = true;
      } catch (e) {
        operationFinished = false;
        throw CouldNotCreateNoteException();
      }
    } else if (dbNoteList.length == userCloudNoteList.length) {
      try {
        for (int i = 0; i< dbNoteList.length; i++) {
          updateNote(
              documentId: dbNoteList.elementAt(i).documentId,
              title: dbNoteList.elementAt(i).title,
              text: dbNoteList.elementAt(i).text,
          );
        }
        operationFinished = true;
      } catch (e) {
        operationFinished = false;
        throw CouldNotUpdateNoteException();
      }
    } else {
      operationFinished = true;
      throw CouldNotSyncNoteException();
    }

    return operationFinished;
  }

  Future<Iterable<CloudNote>> convertDbToCloud({required Iterable<DatabaseNote> notes}) async {
    final result = notes.map((dbNote) => CloudNote.fromDbNote(dbNote));

    return result;
  }

  Future<Iterable<CloudNote>> convertDbToCloud({required Iterable<DatabaseNote> notes}) {
    final result = notes.map((note) => CloudNote.fromDb([note]));
  }
   */
}