import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  DbHelper._internal();

  factory DbHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mobidic.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE words ADD COLUMN correct_count INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE words ADD COLUMN incorrect_count INTEGER DEFAULT 0',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 단어장 테이블
    await db.execute('''
      CREATE TABLE vocabularies (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        learning_rate REAL DEFAULT 0,
        accuracy REAL DEFAULT 0,
        word_count INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // 단어 테이블
    await db.execute('''
      CREATE TABLE words (
        id TEXT PRIMARY KEY,
        vocab_id TEXT NOT NULL,
        expression TEXT NOT NULL,
        difficulty REAL DEFAULT 0,
        accuracy REAL DEFAULT 0,
        is_learned INTEGER DEFAULT 0,
        correct_count INTEGER DEFAULT 0,
        incorrect_count INTEGER DEFAULT 0,
        created_at TEXT,
        FOREIGN KEY (vocab_id) REFERENCES vocabularies (id) ON DELETE CASCADE
      )
    ''');

    // 단어 뜻 테이블
    await db.execute('''
      CREATE TABLE definitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id TEXT NOT NULL,
        part_of_speech TEXT,
        meaning TEXT NOT NULL,
        example_expression TEXT,
        example_meaning TEXT,
        FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE
      )
    ''');
  }
}
