  import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/session_storage_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SessionStorage{

    static final SessionStorage _instance = SessionStorage._init();

    static Database? _database;

    SessionStorage._init();


Future<Database> get database async{
  if(_database != null) return _database!;

  _database = await _initDB('fctconnect.db');
  return _database!;


  }
  
  Future<Database> _initDB(String s) async{

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, s);

    return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  
  FutureOr<void> _createDB(Database db, int version) async {

final idType = 'TEXT PRIMARY KEY';
final boolType = 'BOOLEAN NOT NULL';
final intType = 'INTEGER NOT NULL';
final textType = 'TEXT NOT NULL';


    await db.execute('''
      CREAT TABLE $tableSession(
        ${SessionStorageDataFields.username} $idType,
        ${SessionStorageDataFields.token} $textType,
        ${SessionStorageDataFields.creationd} $intType,
        ${SessionStorageDataFields.expirationd} $intType,
        ${SessionStorageDataFields.isLoggedIn} $boolType

      )

    ''');

  }

  Future close() async{
    final db = await _instance.database;

    db.close();
  }


}
   