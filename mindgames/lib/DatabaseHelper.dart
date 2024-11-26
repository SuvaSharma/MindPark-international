import 'dart:developer';

import 'package:mindgames/CPTDataModel.dart';
import 'package:mindgames/DSTDataModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mindgames/game.dart';
import 'package:mindgames/word_model.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'game_database.db');
    log('Database path: $path'); // Debugging: Print database path
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS game_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          session_id INTEGER,
          block_id INTEGER,
          trial_id INTEGER,
          result INTEGER,
          response_time INTEGER,
          symbol_display_time INTEGER 
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS Words (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          session_id TEXT,
          trial_id INTEGER,
          word TEXT,
          color INTEGER,
          type TEXT,
          result TEXT,
          response_time INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS CPTData (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          session_id TEXT,
          trial_id INTEGER,
          letter TEXT,
          result TEXT,
          response_time INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS DSTData (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          session_id TEXT,
          trial_id INTEGER,
          sequence_given TEXT,
          sequence_entered TEXT,
          result TEXT,
          response_time INTEGER
        )
      ''');
      log('Tables created successfully'); // Debugging: Print success message
    } catch (e) {
      log('Error creating tables: $e'); // Debugging: Print error message
      throw Exception('Error creating tables');
    }
  }

  Future<void> insertGameData(List<GameData> gameData) async {
    try {
      final db = await database;
      var batch = db.batch();
      gameData.forEach((data) {
        batch.insert('game_data', data.toMap());
        log('Inserting ${data.toString()}');
      });

      await batch.commit();
    } catch (e) {
      log('Error inserting game data: $e');
      throw Exception('Error inserting game data');
    }
  }

  Future<void> insertWords(List<Word> words) async {
    try {
      final db = await database;
      var batch = db.batch();
      words.forEach((word) {
        batch.insert('Words', word.toMap());
        log('Inserting ${word.toString()}');
      });
      await batch.commit();
    } catch (e) {
      log('Error inserting words: $e');
      throw Exception('Error inserting words');
    }
  }

  Future<void> viewAllWords() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> words = await db.query('Words');
      words.forEach((word) {
        log('UserID: ${word['user_id']} ${word['word']}, Color: ${word['color']}, Type: ${word['type']}, Result: ${word['result']}, Response: ${word['response_time']}');
      });
    } catch (e) {
      log('Error viewing words: $e');
    }
  }

  Future<void> insertCPTData(List<CPTData> cptData) async {
    try {
      final db = await database;
      var batch = db.batch();
      cptData.forEach((data) {
        batch.insert('CPTData', data.toMap());
        log('Inserting ${data.toString()}');
      });
      await batch.commit();
    } catch (e) {
      log('Error inserting cpt data: $e');
      throw Exception('Error inserting cpt data');
    }
  }

  Future<void> viewCPTData() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> cptData = await db.query('CPTData');
      cptData.forEach((data) {
        log('UserID: ${data['user_id']}, ${data['letter']}, Result: ${data['result']}, Response: ${data['response_time']}');
      });
    } catch (e) {
      log('Error viewing data: $e');
    }
  }

  Future<void> insertDSTData(List<DSTData> dstData) async {
    try {
      final db = await database;
      var batch = db.batch();
      dstData.forEach((data) {
        batch.insert('DSTData', data.toMap());
        log('Inserting ${data.toString()}');
      });
      await batch.commit();
    } catch (e) {
      log('Error inserting dst data');
      throw Exception('Error inserting dst data');
    }
  }

  Future<void> viewDSTData() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> dstData = await db.query('DSTData');
      dstData.forEach((data) {
        log('UserID: ${data['user_id']}, SequenceGiven: ${data['sequence_given']}, SequenceEntered: ${data['sequence_entered']}, Result: ${data['result']}, Response: ${data['response_time']}');
      });
    } catch (e) {
      log('Error viewing data: $e');
    }
  }

  Future<void> getAllGameData() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('game_data');
      maps.forEach((data) {
        log('UserId: ${data['user_id']}, Result: ${data['result']}, ResponseTime: ${data['response_time']}, SymbolDisplayTime: ${data['symbol_display_time']}');
      });
    } catch (e) {
      log('Error getting game data: $e');
      throw Exception('Error getting game data');
    }
  }
}
