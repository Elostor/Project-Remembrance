import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_remembrance/constants/cloud_storage_constants.dart';
import 'package:project_remembrance/constants/notes_service_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String title;
  final String text;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.text
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUsedIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        text = snapshot.data()[textFieldName] as String;

  CloudNote.fromDb(Map<String, dynamic> dbMap)
      : documentId = dbMap[idColumn],
        ownerUserId = dbMap[userIdColumn],
        title = dbMap[titleColumn],
        text = dbMap[textColumn];

  /*
  CloudNote.fromDbNote(DatabaseNote dbNote)
      : documentId = dbNote.id as String,
        ownerUserId = dbNote.userId as String,
        title = dbNote.title,
        text = dbNote.text;
   */
}