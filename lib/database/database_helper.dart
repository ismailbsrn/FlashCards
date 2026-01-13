import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE collections ADD COLUMN tags TEXT');
      await db.execute('ALTER TABLE collections ADD COLUMN color TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE study_settings ADD COLUMN show_interval_buttons INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE study_settings ADD COLUMN dark_mode INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE collections (
        id $idType,
        user_id $textType,
        name $textType,
        description TEXT,
        tags TEXT,
        color TEXT,
        created_at $textType,
        updated_at $textType,
        is_deleted $boolType DEFAULT 0,
        version $intType DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id $idType,
        collection_id $textType,
        front $textType,
        back $textType,
        ease_factor $realType DEFAULT 2.5,
        interval $intType DEFAULT 0,
        repetitions $intType DEFAULT 0,
        next_review_date TEXT,
        last_review_date TEXT,
        created_at $textType,
        updated_at $textType,
        is_deleted $boolType DEFAULT 0,
        version $intType DEFAULT 1,
        FOREIGN KEY (collection_id) REFERENCES collections (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE review_logs (
        id $idType,
        card_id $textType,
        user_id $textType,
        quality $intType,
        reviewed_at $textType,
        interval_before $intType,
        interval_after $intType,
        ease_factor_before $realType,
        ease_factor_after $realType,
        FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id $idType,
        entity_type $textType,
        entity_id $textType,
        operation $textType,
        data $textType,
        created_at $textType,
        retry_count $intType DEFAULT 0,
        error TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE study_settings (
        user_id $idType,
        max_reviews_per_day $intType DEFAULT 100,
        max_new_cards_per_day $intType DEFAULT 20,
        show_answer_timer $boolType DEFAULT 1,
        auto_play_audio $boolType DEFAULT 0,
        show_interval_buttons $boolType DEFAULT 0,
        dark_mode $boolType DEFAULT 0,
        updated_at $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType,
        display_name TEXT,
        created_at $textType,
        last_sync_at TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_cards_collection_id ON cards(collection_id)',
    );
    await db.execute(
      'CREATE INDEX idx_cards_next_review_date ON cards(next_review_date)',
    );
    await db.execute(
      'CREATE INDEX idx_review_logs_card_id ON review_logs(card_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id)',
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flashcards.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
