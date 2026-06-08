import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/prompt.dart';

/// Contratto per lo storage dei prompt. Permette di sostituire l'archiviazione
/// reale (sqflite) con un fake in memoria nei test.
abstract class PromptRepository {
  /// Tutti i prompt, ordinati dal più recente.
  Future<List<Prompt>> getAll();

  Future<Prompt?> getById(String id);

  /// Inserisce o aggiorna un prompt.
  Future<void> upsert(Prompt prompt);

  Future<void> delete(String id);
}

/// Implementazione di [PromptRepository] basata su sqflite (storage locale).
class SqflitePromptRepository implements PromptRepository {
  SqflitePromptRepository._();

  static final SqflitePromptRepository instance = SqflitePromptRepository._();

  static const _dbName = 'autoprompter.db';
  static const _table = 'prompts';

  Database? _db;

  Future<Database> get _database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content_markdown TEXT NOT NULL,
            locale_id TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            tags TEXT NOT NULL DEFAULT ''
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE $_table ADD COLUMN tags TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
  }

  @override
  Future<List<Prompt>> getAll() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'updated_at DESC');
    return rows.map(Prompt.fromMap).toList();
  }

  @override
  Future<Prompt?> getById(String id) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Prompt.fromMap(rows.first);
  }

  @override
  Future<void> upsert(Prompt prompt) async {
    final db = await _database;
    await db.insert(
      _table,
      prompt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
