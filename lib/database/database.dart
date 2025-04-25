import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;

import '../models/category.dart';
import '../models/link.dart';
import 'daos/category_dao.dart';
import 'daos/link_dao.dart';

part 'database.g.dart';

@Database(version: 1, entities: [Category, Link])
abstract class AppDatabase extends FloorDatabase {
  CategoryDao get categoryDao;
  LinkDao get linkDao;

  static Future<AppDatabase> getInstance() async {
    // For web demo, we'll use a simpler initialization
    // In a real app, we'd properly configure sqflite_web or use appropriate web storage
    if (kIsWeb) {
      // Return a pre-built database for web demo
      return await $FloorAppDatabase.databaseBuilder('link_grab.db').build();
    } else {
      // Regular mobile initialization
      return await $FloorAppDatabase.databaseBuilder('link_grab.db').build();
    }
  }
}
