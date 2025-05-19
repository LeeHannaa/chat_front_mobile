import 'dart:developer';
import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/model/model_message.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "chatService.db";
  static const _databaseVersion = 10;

  // DatabaseHelper를 싱글턴으로 하여 데이터베이스 인스턴스가
  // 한번만 초기화 되도록함
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

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
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE chatRoom (
            id INTEGER NOT NULL PRIMARY KEY UNIQUE,
            name TEXT NOT NULL,
            lastmsg TEXT NOT NULL,
            num INTEGER NOT NULL,
            updateLastMsgTime TEXT NOT NULL
          );
        ''');
    await db.execute('''
          CREATE TABLE chatMessage (
            id TEXT NOT NULL PRIMARY KEY UNIQUE,
            name TEXT NOT NULL,
            writerId INTEGER NOT NULL,
            roomId INTEGER NOT NULL,
            message TEXT NOT NULL,
            createTime TEXT NOT NULL,
            type TEXT NOT NULL
          )
        ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS chatMessage');
    await db.execute('DROP TABLE IF EXISTS chatRoom');
    await _onCreate(db, newVersion);
  }

  Future<List<ChatRoom>> getChatRooms() async {
    final db = await database;
    var res = await db.query('chatRoom');
    List<ChatRoom> list = res.isNotEmpty
        ? res.map((c) => ChatRoom.fromJsonSqlite(c)).toList()
        : [];
    return list;
  }

  Future<int> insertChatRoom(ChatRoom chatRoom) async {
    final db = await database;
    return await db.insert('chatRoom', chatRoom.toMap());
  }

  Future<void> deleteChatRoomAndMessages(int roomId) async {
    final db = await database;

    // 1. chatMessage 테이블에서 해당 roomId에 해당하는 모든 메시지 삭제
    await db.delete(
      'chatMessage',
      where: 'roomId = ?',
      whereArgs: [roomId],
    );

    // 2. chatRoom 테이블에서 해당 roomId에 해당하는 레코드 삭제
    await db.delete(
      'chatRoom',
      where: 'id = ?',
      whereArgs: [roomId],
    );
    log("해당 채팅방 삭제 완료!");
  }

  Future<void> updateLastMessages() async {
    final db = await database;
    await db.rawUpdate('''
    UPDATE chatRoom
    SET lastmsg = (
        SELECT message 
        FROM chatMessage 
        WHERE chatMessage.roomId = chatRoom.id 
        ORDER BY createTime DESC 
        LIMIT 1
    )
    WHERE EXISTS (
        SELECT 1 
        FROM chatMessage 
        WHERE chatMessage.roomId = chatRoom.id
    );
  ''');
  }

  Future<List<Message>> getChatMessagesByRoomId(int roomId) async {
    final db = await database;
    var res = await db.query(
      'chatMessage',
      where: 'roomId = ?',
      whereArgs: [roomId], // roomId를 조건으로 사용
    );
    // print("Database Query Result: $res");
    List<Message> list = res.isNotEmpty
        ? res.map((c) => Message.fromJsonSqlite(c)).toList()
        : [];
    return list;
  }

  Future<int> insertChatMessage(Message message) async {
    final db = await database;
    return await db.insert('chatMessage', message.toMap());
  }

  Future<int> deleteChatMessage(String id) async {
    final db = await database;
    return await db.delete(
      'chatMessage',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
