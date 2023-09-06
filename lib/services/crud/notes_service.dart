import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:project_remembrance/extensions/list/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../../constants/notes_service_constants.dart';
import 'crud_exceptions.dart';

class NotesService {
  Database? _db;
  List<DatabaseNote> _notesCache = [];
  DatabaseUser? _user;

  // Create a singleton of NotesService.
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notesCache);
      }
    );
  }
  static final NotesService _shared = NotesService._sharedInstance();
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;

        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      } );

  Database _checkDatabase() {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenedException {
      // Empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenedException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUser = true}) async {
    try {
      final user = await getUser(email: email);

      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);

      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _checkDatabase();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],);

    // This piece is to see if a factory and an initializer with a list works the same.
    // List<DatabaseUser>? checkerList = List<DatabaseUser>.empty();

    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);

      //checkerList.add(DatabaseUser.userFromRowTest(result.first));
      //return checkerList;
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _checkDatabase();
    final userCheck = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (userCheck.isNotEmpty) {
      throw UserAlreadyExists();
    } else {
      final userId = await db.insert(
          userTable,
          {emailColumn: email.toLowerCase()}
      );
      return DatabaseUser(id: userId, email: email);
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _checkDatabase();
    final deletedCount = db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount as int != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notesCache = allNotes.toList();
    _notesStreamController.add(_notesCache);
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    final db = _checkDatabase();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [noteId],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);

      _notesCache.removeWhere((note) => note.id == noteId);
      _notesCache.add(note);
      _notesStreamController.add(_notesCache);
      return note;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _checkDatabase();
    final notes = await db.query(noteTable);
    final result = notes.map((noteRow) => DatabaseNote.fromRow(noteRow));

    return result;
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _checkDatabase();
    final dbUser = await getUser(email: owner.email);
    const titleText = '';
    const contentText = '';

    // To check if the ID of the owner(?) is valid.
    if (dbUser != owner) {
      throw CouldNotFindUser();
    } else {
      final noteId = await db.insert(noteTable, {
        userIdColumn: owner.id,
        titleText: titleText,
        textColumn: contentText,
        isSyncedColumn: 1,
      });
      final note = DatabaseNote(id: noteId,
          userId: owner.id,
          title: titleText,
          text: contentText,
          isSyncedWithCloud: true,
      );
      
      _notesCache.add(note);
      _notesStreamController.add(_notesCache);
      return note;
    }
  }

  Future<void> deleteNote({required DatabaseUser owner,required int noteId}) async {
    await _ensureDbIsOpen();
    final db = _checkDatabase();
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    } else {
      final deletedCount = await db.delete(
          noteTable,
          where: 'id = ?',
          whereArgs: [noteId],
      );

      if (deletedCount == 0) {
        throw CouldNotDeleteNote();
      } else {
        _notesCache.removeWhere((note) => note.id == noteId);
        _notesStreamController.add(_notesCache);
      }
    }
  }

  Future<int> deleteAllNotes({required DatabaseUser owner,required int noteId}) async {
    await _ensureDbIsOpen();
    final db = _checkDatabase();
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    } else {
      final deletedCount = await db.delete(noteTable);

      if (deletedCount == 0) {
        throw CouldNotDeleteNote();
      } else {
        _notesCache = [];
        _notesStreamController.add(_notesCache);
        return deletedCount;
      }
    }
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String title, required String text}) async {
    await _ensureDbIsOpen();
    final db = _checkDatabase();
    await getNote(noteId: note.id);
    final updatesCount = await db.update(
      noteTable, {
        titleColum: title,
        textColumn: text,
        isSyncedColumn: 0,
    },
        where: 'id = ?',
        whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(noteId: note.id);

      _notesCache.removeWhere((note) => note.id == updatedNote.id);
      _notesCache.add(updatedNote);
      _notesStreamController.add(_notesCache);
      return updatedNote;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map) :
        id = map[idColumn] as int,
        email = map[emailColumn] as String;

  // The upper code is an initializer with an initializer list; this here is a factory.
  /* factory DatabaseUser.userFromRowTest(Map<String, Object?> map) =>
      DatabaseUser(
          id: map[idColumn] as int,
          email: map[emailColumn] as String
      ); */

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String title;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({required this.id, required this.userId, required this.title, required this.text, required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map) :
        id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColum] as String,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedColumn] as int) == 1 ? true : false;

  factory DatabaseNote.noteFromRowTest(Map<String, Object?> map) =>
      DatabaseNote(
          id: map[idColumn] as int,
          userId: map[userIdColumn] as int,
          title: map[titleColum] as String,
          text: map[textColumn] as String,
          isSyncedWithCloud: (map[isSyncedColumn] as int) == 1 ? true : false,
      );

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCLoud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
