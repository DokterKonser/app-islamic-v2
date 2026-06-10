import 'package:sqflite/sqflite.dart';

class MigrationV1 {
  static Future<void> runMigration(Database db) async {
    // ibadah_events
    await db.execute('''
      CREATE TABLE ibadah_events (
        id TEXT PRIMARY KEY,
        module_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        payload TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_ibadah_events_type ON ibadah_events(event_type)');
    await db.execute('CREATE INDEX idx_ibadah_events_timestamp ON ibadah_events(timestamp)');

    // salat_records
    await db.execute('''
      CREATE TABLE salat_records (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        prayer_name TEXT NOT NULL,
        scheduled_at TEXT NOT NULL,
        completed_at TEXT,
        was_on_time INTEGER,
        UNIQUE(date, prayer_name)
      )
    ''');
    await db.execute('CREATE INDEX idx_salat_records_date ON salat_records(date)');
    await db.execute('CREATE INDEX idx_salat_records_prayer ON salat_records(prayer_name)');

    // quran_bookmarks
    await db.execute('''
      CREATE TABLE quran_bookmarks (
        id TEXT PRIMARY KEY,
        surah_id INTEGER NOT NULL,
        ayah_id INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT
      )
    ''');

    // srs_cards
    await db.execute('''
      CREATE TABLE srs_cards (
        id TEXT PRIMARY KEY,
        surah_id INTEGER NOT NULL,
        ayah_id INTEGER NOT NULL,
        interval_days INTEGER NOT NULL,
        ease_factor REAL NOT NULL,
        repetitions INTEGER NOT NULL,
        next_review_date TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_srs_cards_next_review ON srs_cards(next_review_date)');

    // srs_review_log
    await db.execute('''
      CREATE TABLE srs_review_log (
        id TEXT PRIMARY KEY,
        card_id TEXT NOT NULL,
        quality INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (card_id) REFERENCES srs_cards (id) ON DELETE CASCADE
      )
    ''');

    // fasting_log
    await db.execute('''
      CREATE TABLE fasting_log (
        id TEXT PRIMARY KEY,
        fasting_type TEXT NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_fasting_log_date ON fasting_log(date)');

    // dzikir_sessions
    await db.execute('''
      CREATE TABLE dzikir_sessions (
        id TEXT PRIMARY KEY,
        dzikir_type TEXT NOT NULL,
        count INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL
      )
    ''');

    // tracker_streaks
    await db.execute('''
      CREATE TABLE tracker_streaks (
        id TEXT PRIMARY KEY,
        module_id TEXT NOT NULL,
        current_streak INTEGER NOT NULL,
        max_streak INTEGER NOT NULL,
        last_activity_date TEXT NOT NULL
      )
    ''');

    // markov_patterns
    await db.execute('''
      CREATE TABLE markov_patterns (
        id TEXT PRIMARY KEY,
        hour_slot INTEGER NOT NULL,
        miss_probability REAL NOT NULL,
        sample_size INTEGER NOT NULL,
        last_updated TEXT NOT NULL
      )
    ''');
    
    // badges
    await db.execute('''
      CREATE TABLE badges (
        id TEXT PRIMARY KEY,
        badge_type TEXT NOT NULL,
        unlocked_at TEXT NOT NULL
      )
    ''');

    // quest_log
    await db.execute('''
      CREATE TABLE quest_log (
        id TEXT PRIMARY KEY,
        quest_id TEXT NOT NULL,
        status TEXT NOT NULL,
        progress INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // energy_log
    await db.execute('''
      CREATE TABLE energy_log (
        id TEXT PRIMARY KEY,
        energy_delta INTEGER NOT NULL,
        current_energy INTEGER NOT NULL,
        reason TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // pause_for_mercy
    await db.execute('''
      CREATE TABLE pause_for_mercy (
        id TEXT PRIMARY KEY,
        is_active INTEGER NOT NULL,
        activated_at TEXT NOT NULL,
        resume_at TEXT NOT NULL
      )
    ''');

    // app_config_local
    await db.execute('''
      CREATE TABLE app_config_local (
        id TEXT PRIMARY KEY,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL
      )
    ''');
  }
}
