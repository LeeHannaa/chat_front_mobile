import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "chatService.db";
  static const _databaseVersion = 1;

  // DatabaseHelper를 싱글턴으로 하여 데이터베이스 인스턴스가
  // 한번만 초기화 되도록함
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // getDatabasesPath()로 가져온 데이터베이스 경로와
    // 데이터베이스의 이름을 합쳐서 경로로 설정
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      // 데이터베이스 생성시 실행할 SQL
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE chatRoom (
            roomId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            roomName TEXT NOT NULL,
            lastMsg TEXT NOT NULL,
            regDate TEXT NOT NULL
          );
        ''');
        db.execute('''
          CREATE TABLE chatMessage (
            msgId TEXT NOT NULL UNIQUE,
            writerName TEXT NOT NULL,
            writerId INTEGER NOT NULL,
            roomId INTEGER NOT NULL,
            regDate TEXT NOT NULL,
            PRIMARY KEY(msgId)
          )
        ''');
      },
    );
  }
}
