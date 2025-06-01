import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'zerotier.db';
  static const _databaseVersion = 1;
  
  static const table = 'devices';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnLastOnline = 'lastOnline';
  static const columnIpAddress = 'ipAddress';
  static const columnOnline = 'online';
  
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final appDir = await path_provider.getApplicationDocumentsDirectory();
    final path = join(appDir.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT,
        $columnLastOnline INTEGER,
        $columnIpAddress TEXT,
        $columnOnline INTEGER
      )
    ''');
    
    // 创建索引
    await db.execute('''
      CREATE INDEX idx_last_online 
      ON $table ($columnLastOnline)
    ''');
  }
  
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $table 
        ADD COLUMN last_seen INTEGER DEFAULT 0
      ''');
    }
  }
  
  Future<void> initialize() async {
    await database;
  }
  
  // 插入或更新设备
  Future<void> upsertDevice(Device device) async {
    final db = await database;
    await db.insert(
      table,
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // 批量插入设备
  Future<void> batchInsertDevices(List<Device> devices) async {
    final db = await database;
    final batch = db.batch();
    
    for (var device in devices) {
      batch.insert(
        table,
        device.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
  
  // 获取所有设备
  Future<List<Device>> getAllDevices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      orderBy: '$columnLastOnline DESC'
    );
    return List.generate(maps.length, (i) => Device.fromMap(maps[i]));
  }
  
  // 获取最后更新时间
  Future<DateTime> getLastUpdateTime() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX($columnLastOnline) as last_update FROM $table'
    );
    
    if (result.isNotEmpty && result.first['last_update'] != null) {
      final timestamp = result.first['last_update'] as int;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    return DateTime(1970);
  }
  
  // 清空设备表
  Future<void> clearDevices() async {
    final db = await database;
    await db.delete(table);
  }
}