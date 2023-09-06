const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const titleColum = 'title';
const textColumn = 'text';
const isSyncedColumn = 'is_synced_with_cloud';

// Create an user table and a note table. The three //
// quotation mark helps keeping codes that are written //
// in other programming languages. //
const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
      "id"	INTEGER NOT NULL,
      "email"	TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
      );
''';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "title"	TEXT,
      "text"	TEXT,
      "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY("user_id") REFERENCES "user"("id"),
      PRIMARY KEY("id" AUTOINCREMENT
      );
''';
