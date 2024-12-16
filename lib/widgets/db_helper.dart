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

    // MONSTER 테이블 확인 및 생성
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

    // ITEM_WEAPONS 테이블 확인 및 생성
    final weaponsTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'ITEM_WEAPONS'"
    );
    if (weaponsTable.isEmpty) {
      print('ITEM_WEAPONS table does not exist in database.');
      await _createItemWeaponsTable(db);
      await _insertWeaponsFromCSV(db, 'assets/db/ITEM_WEAPONS.csv');
    } else {
      print('ITEM_WEAPONS table exists.');
      await _updateWeaponsFromCSV(db, 'assets/db/ITEM_WEAPONS.csv');
    }
    // ITEM_ARMORS 테이블 확인 및 생성
    final armorsTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'ITEM_ARMORS'"
    );
    if (armorsTable.isEmpty) {
      print('ITEM_ARMORS table does not exist in database.');
      await _createItemArmorsTable(db);
      await _insertArmorsFromCSV(db, 'assets/db/ITEM_ARMORS.csv');
    } else {
      print('ITEM_WEAPONS table exists.');
      await _updateArmorsFromCSV(db, 'assets/db/ITEM_ARMORS.csv');
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
  //무기 테이블 생성
  Future<void> _createItemWeaponsTable(Database db) async {
    await db.execute('''
    CREATE TABLE ITEM_WEAPONS (
      WEAPON_ID INTEGER PRIMARY KEY,
      WEAPON_NAME TEXT NOT NULL,
      DURABILITY INTEGER NOT NULL,
      WEAPON_HP INTEGER NOT NULL,
      WEAPON_MP INTEGER NOT NULL,
      WEAPON_JOB TEXT NOT NULL,
      WEAPON_STR INTEGER NOT NULL,
      WEAPON_INT INTEGER NOT NULL,
      WEAPON_DEX INTEGER NOT NULL,
      WEAPON_STR_LIMIT INTEGER NOT NULL,
      WEAPON_INT_LIMIT INTEGER NOT NULL,
      WEAPON_DEX_LIMIT INTEGER NOT NULL,
      WEAPON_HIT INTEGER NOT NULL,
      WEAPON_DAM INTEGER NOT NULL,
      DAMAGE_S INTEGER NOT NULL,
      DAMAGE_L INTEGER NOT NULL,
      WEAPON_REPAIR TEXT NOT NULL,
      WEAPON_EXCHANGE TEXT NOT NULL,
      ITEM_RES TEXT NOT NULL,
      LEVEL INTEGER NOT NULL,
      ITEM_PRICE INTEGER NOT NULL,
      DESCRIPTION TEXT NOT NULL
    )
  ''');
    print('ITEM_WEAPONS table created');
  }
  //갑옷 테이블 생성
  Future<void> _createItemArmorsTable(Database db) async {
    await db.execute('''
    CREATE TABLE ITEM_ARMORS (
      ARMOR_ID INTEGER PRIMARY KEY,
      ARMOR_NAME TEXT NOT NULL,
      ARMOR_SEX TEXT NOT NULL,
      DURABILITY INTEGER NOT NULL,
      ARMOR_AC INTEGER NOT NULL,
      ARMOR_HP INTEGER NOT NULL,
      ARMOR_MP INTEGER NOT NULL,
      ARMOR_JOB TEXT NOT NULL,
      ARMOR_STR INTEGER NOT NULL,
      ARMOR_INT INTEGER NOT NULL,
      ARMOR_DEX INTEGER NOT NULL,
      ARMOR_STR_LIMIT INTEGER NOT NULL,
      ARMOR_INT_LIMIT INTEGER NOT NULL,
      ARMOR_DEX_LIMIT INTEGER NOT NULL,
      ARMOR_REPAIR TEXT NOT NULL,
      ARMOR_EXCHANGE TEXT NOT NULL,
      ARMOR_RES TEXT NOT NULL,
      ARMOR_MD INTEGER NOT NULL,
      LEVEL INTEGER NOT NULL,
      ITEM_PRICE INTEGER NOT NULL,
      DESCRIPTION TEXT NOT NULL
    )
  ''');
    print('ITEM_ARMORS table created');
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
  //무기 테이블 데이터 insert
  Future<void> _insertWeaponsFromCSV(Database db, String csvPath) async {
    try {
      final csvData = await rootBundle.loadString(csvPath);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      Batch batch = db.batch();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        batch.insert(
          'ITEM_WEAPONS',
          {
            'WEAPON_ID': row[0],
            'WEAPON_NAME': row[1],
            'DURABILITY': row[2],
            'WEAPON_HP': row[3],
            'WEAPON_MP': row[4],
            'WEAPON_JOB': row[5],
            'WEAPON_STR': row[6],
            'WEAPON_INT': row[7],
            'WEAPON_DEX': row[8],
            'WEAPON_STR_LIMIT': row[9],
            'WEAPON_INT_LIMIT': row[10],
            'WEAPON_DEX_LIMIT': row[11],
            'WEAPON_HIT': row[12],
            'WEAPON_DAM': row[13],
            'DAMAGE_S': row[14],
            'DAMAGE_L': row[15],
            'WEAPON_REPAIR': row[16],
            'WEAPON_EXCHANGE': row[17],
            'ITEM_RES': row[18],
            'LEVEL': row[19],
            'ITEM_PRICE': row[20],
            'DESCRIPTION': row[21],
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // 중복 시 업데이트
        );
      }
      await batch.commit(noResult: true);
      print('ITEM_WEAPONS data inserted from CSV');
    } catch (e) {
      print('ERROR inserting ITEM_WEAPONS data from CSV: $e');
    }
  }
  //무기 테이블 update
  Future<void> _updateWeaponsFromCSV(Database db, String csvPath) async {
    try {
      // 테이블 초기화
      await db.delete('ITEM_WEAPONS');

      final csvData = await rootBundle.loadString(csvPath);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      Batch batch = db.batch();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        batch.insert(
          'ITEM_WEAPONS',
          {
            'WEAPON_ID': row[0],
            'WEAPON_NAME': row[1],
            'DURABILITY': row[2],
            'WEAPON_HP': row[3],
            'WEAPON_MP': row[4],
            'WEAPON_JOB': row[5],
            'WEAPON_STR': row[6],
            'WEAPON_INT': row[7],
            'WEAPON_DEX': row[8],
            'WEAPON_STR_LIMIT': row[9],
            'WEAPON_INT_LIMIT': row[10],
            'WEAPON_DEX_LIMIT': row[11],
            'WEAPON_HIT': row[12],
            'WEAPON_DAM': row[13],
            'DAMAGE_S': row[14],
            'DAMAGE_L': row[15],
            'WEAPON_REPAIR': row[16],
            'WEAPON_EXCHANGE': row[17],
            'ITEM_RES': row[18],
            'LEVEL': row[19],
            'ITEM_PRICE': row[20],
            'DESCRIPTION': row[21],
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // 중복 시 업데이트
        );
      }
      await batch.commit(noResult: true);
      print('ITEM_WEAPONS data updated from CSV');
    } catch (e) {
      print('ERROR updating ITEM_WEAPONS data from CSV: $e');
    }
  }

  //갑옷 테이블 데이터 insert
  Future<void> _insertArmorsFromCSV(Database db, String csvPath) async {
    try {
      final csvData = await rootBundle.loadString(csvPath);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      Batch batch = db.batch();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        batch.insert(
          'ITEM_ARMORS',
          {
            'ARMOR_ID': row[0],
            'ARMOR_NAME': row[1],
            'ARMOR_SEX': row[2],
            'DURABILITY': row[3],
            'ARMOR_AC': row[4],
            'ARMOR_HP': row[5],
            'ARMOR_MP': row[6],
            'ARMOR_JOB': row[7],
            'ARMOR_STR': row[8],
            'ARMOR_INT': row[9],
            'ARMOR_DEX': row[10],
            'ARMOR_STR_LIMIT': row[11],
            'ARMOR_INT_LIMIT': row[12],
            'ARMOR_DEX_LIMIT': row[13],
            'ARMOR_REPAIR': row[14],
            'ARMOR_EXCHANGE': row[15],
            'ARMOR_RES': row[16],
            'ARMOR_MD': row[17],
            'LEVEL': row[18],
            'ITEM_PRICE': row[19],
            'DESCRIPTION': row[20],
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // 중복 시 업데이트
        );
      }
      await batch.commit(noResult: true);
      print('ITEM_ARMORS data inserted from CSV');
    } catch (e) {
      print('ERROR inserting ITEM_ARMORS data from CSV: $e');
    }
  }
  //갑옷 테이블 update
  Future<void> _updateArmorsFromCSV(Database db, String csvPath) async {
    try {
      // 테이블 초기화
      await db.delete('ITEM_ARMORS');

      final csvData = await rootBundle.loadString(csvPath);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      Batch batch = db.batch();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        batch.insert(
          'ITEM_ARMORS',
          {
            'ARMOR_ID': row[0],
            'ARMOR_NAME': row[1],
            'ARMOR_SEX': row[2],
            'DURABILITY': row[3],
            'ARMOR_AC': row[4],
            'ARMOR_HP': row[5],
            'ARMOR_MP': row[6],
            'ARMOR_JOB': row[7],
            'ARMOR_STR': row[8],
            'ARMOR_INT': row[9],
            'ARMOR_DEX': row[10],
            'ARMOR_STR_LIMIT': row[11],
            'ARMOR_INT_LIMIT': row[12],
            'ARMOR_DEX_LIMIT': row[13],
            'ARMOR_REPAIR': row[14],
            'ARMOR_EXCHANGE': row[15],
            'ARMOR_RES': row[16],
            'ARMOR_MD': row[17],
            'LEVEL': row[18],
            'ITEM_PRICE': row[19],
            'DESCRIPTION': row[20],
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // 중복 시 업데이트
        );
      }
      await batch.commit(noResult: true);
      print('ITEM_ARMORS data updated from CSV');
    } catch (e) {
      print('ERROR updating ITEM_ARMORS data from CSV: $e');
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

  //무기 테이블 정보 읽기
  Future<List<Map<String, dynamic>>> getWeaponInfo() async {
    final db = await database;
    final result = await db.query('ITEM_WEAPONS');
    return result;
  }

  //갑옷 테이블 정보 읽기
  Future<List<Map<String, dynamic>>> getArmorInfo() async {
    final db = await database;
    final result = await db.query('ITEM_ARMORS');
    return result;
  }

  //몬스터 정보 가져오기
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
  Future<List<Map<String, dynamic>>> searchItems (String query) async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'ClassicBaram.db');
    final db = await openDatabase(fullPath);
    final results = await db.rawQuery('''
      SELECT COALESCE(WEAPON_NAME, '') AS NAME, '무기' AS CATEGORY
      FROM ITEM_WEAPONS
      WHERE WEAPON_NAME LIKE ?
      
      UNION
      
      SELECT COALESCE(ARMOR_NAME, '') AS NAME, '갑옷' AS CATEGORY
      FROM ITEM_ARMORS
      WHERE ARMOR_NAME LIKE ?

    ''', ['%$query%', '%$query%']); // LIKE 조건


    return results.map((item) {
      return {
        'NAME': item['NAME'] ?? '',
        'CATEGORY': item['CATEGORY'] ?? '', // CATEGORY 포함
      };
    }).toList();
  }

  //검색한 아이템 상세정보 표기하기 위해
  Future<Map<String, dynamic>> getItemDetails (String name, String category) async  {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'ClassicBaram.db');
    final db = await openDatabase('ClassicBaram.db');

    //카테고리에 따라 다른 테이블에서 상세 정보 조회
    List<Map<String, dynamic>> result;

    if(category == '무기') {
      result = await db.rawQuery(
        'SELECT * FROM ITEM_WEAPONS WHERE WEAPON_NAME = ?',
        [name],
      );
    } else if (category == '갑옷') {
      result = await db.rawQuery(
        'SELECT * FROM ITEM_ARMORS WHERE ARMOR_NAME = ?',
        [name],
      );
    } else {
      result = [];
    }

    return result.isNotEmpty ? result.first : {};
  }
}