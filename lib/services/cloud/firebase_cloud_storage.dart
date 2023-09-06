import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_remembrance/constants/cloud_storage_constants.dart';
import 'package:project_remembrance/services/cloud/cloud_storage_exception.dart';
import 'package:project_remembrance/services/crud/crud_exceptions.dart';
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
                      (doc) => CloudNote(
                          documentId: doc.id,
                          ownerUserId: doc.data()[ownerUsedIdFieldName] as String,
                          title: doc.data()[titleFieldName] as String,
                          text: doc.data()[textFieldName] as String
                      )
              ),
      );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUsedIdFieldName: ownerUserId,
      titleFieldName: '',
      textFieldName: '',
    });
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
      throw CouldNotDeleteNote();
    }
  }
}