import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:csv/csv.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ClassicBaram.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, fileName);

    //데이터베이스가 로컬에 없으면 asset에서 복사
    if(!await databaseExists(fullPath)) {
      print('Database not found');
      await _copyDBFromAssets(fileName, fullPath);
    } else {
      print('Database already exist at $fullPath');
    }
    final db = await openDatabase(fullPath);
    await _validateDatabaseSchema(db);
    return openDatabase(
        fullPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE PLAYER ( 
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          JOB TEXT NOT NULL,
          CURRENT_HP INTEGER NOT NULL,
          CURRENT_MP INTEGER NOT NULL
          )
          ''');
          await _createMonsterTable(db);
        },
    );
  }
  Future<void> _validateDatabaseSchema(Database db) async {
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'PLAYER'"
    );
    if (result.isEmpty) {
      print('PLAYER table does not exist in the database.');
      throw Exception('Invalid database schema: PLAYER table is missing');
    }
    else {
      print('PLAYER table exists.');
    }

    final monsterTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'MONSTER'"
    );
    if (monsterTable.isEmpty) {
      print('MONSTER table does not exist in database.');
      await _createMonsterTable(db);
      await _insertMonstersFromCSV(db, 'assets/db/monster.csv');
    } else {
      print('MONSTER table exist');
      await _updateMonstersFromCSV(db, 'assets/db/monster.csv');
    }
  }
  //몹 테이블 생성
  Future<void> _createMonsterTable(Database db) async {
    await db.execute('''
      CREATE TABLE MONSTER (
        ID INTEGER PRIMARY KEY,
        NAME TEXT NOT NULL,
        LOCATION TEXT NOT NULL,
        HP INTEGER NOT NULL,
        AC INTEGER NOT NULL,
        EXP INTEGER NOT NULL
       )
    ''');
    print('MONSTER table created');
  }
  //몹 테이블 데이터 insert
  Future<void> _insertMonstersFromCSV (Database db, String csvPath) async {
    try {
      final csvData = await rootBundle.loadString(csvPath);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      Batch batch = db.batch();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        batch.insert(
            'MONSTER',
            {
              'ID':row[0],
              'NAME':row[1],
              'LOCATION':row[2],
              'HP':row[3],
              'AC':row[4],
              'EXP':row[5],
            },
          conflictAlgorithm: ConflictAlgorithm.replace, //중복시 덮어쓰기
        );
      }
      await batch.commit(noResult: true);
      print('MONSTER data inserted from CSV');
    } catch (e) {
      print('ERROR inserting MONSTER data from CSV: $e');
    }
  }

  //몹 테이블 데이터 update
  Future<void> _updateMonstersFromCSV (Database db, String csvPath) async {
    try {
      //초기화
      await db.delete('MONSTER');

      final csvData = await rootBundle.loadString(csvPath);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      Batch batch = db.batch();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        batch.insert(
          'MONSTER',
          {
            'ID':row[0],
            'NAME':row[1],
            'LOCATION':row[2],
            'HP':row[3],
            'AC':row[4],
            'EXP':row[5],
          },
          conflictAlgorithm: ConflictAlgorithm.replace, //중복시 덮어쓰기
        );
      }
      await batch.commit(noResult: true);
      print('MONSTER data updated from CSV');
    } catch (e) {
      print('ERROR inserting MONSTER data from CSV: $e');
    }
  }
  Future<void> checkPlayerTable() async {
    final db = await DBHelper().database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'PLAYER'"
    );
    if (result.isNotEmpty) {
      print('PLAYER table exists');
    } else {
      print('PLAYER table does not exists');
    }
  }
  Future<void> _copyDBFromAssets(String fileName, String destinationPath) async{
    try {
      final data = await rootBundle.load('assets/db/$fileName');
      final bytes = data.buffer.asUint8List();
      await File (destinationPath).writeAsBytes(bytes);
      print('Database copied to $destinationPath');
    } catch (e) {
      print('Error copying database $e');
    }
  }
  Future<List<Map<String,dynamic>>> getMonsterInfo() async {
    final db = await database;
    final result = await db.query(
      'MONSTER',
      where: 'HP > ?',
      whereArgs: [0],
    );
    return result;
  }
  //사용자 정보 읽기
  Future<Map<String, dynamic>?> getPlayerInfo() async {
    final db = await database;
    final result = await db.query('PLAYER', limit: 1);

    if (result.isNotEmpty) {
      //데이터가 있으면 반환
      return result.first;
    }
    else {
      //데이터가 없으면 기본 값 삽입
      await db.insert(
          'PLAYER',
          {
            'JOB': '전사',
            'CURRENT_HP':100,
            'CURRENT_MP':50,
          }
      );
      final newResult = await db.query('PLAYER', limit: 1);
      return newResult.isNotEmpty ? newResult.first : null;
    }
  }
  //사용자 정보 저장
  Future<void> savePlayerInfo(String job, int currentHp, int currentMp) async {
    final db = await database;

    //PLAYER테이블 데이터 확인
    final exstingData = await db.query('PLAYER', limit: 1);
    if (exstingData.isNotEmpty) {
      await db.update(
        'PLAYER',
        {'JOB': job, 'CURRENT_HP': currentHp, 'CURRENT_MP': currentMp},
        where: 'id = ?',
        whereArgs: [1],
      );
    } else {
      await  db.insert(
          'PLAYER',
          {'JOB':job, 'CURRENT_HP': currentHp, 'CURRENT_MP': currentMp},
      );
    }
  }
}