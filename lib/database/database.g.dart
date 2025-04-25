// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CategoryDao? _categoryDaoInstance;

  LinkDao? _linkDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Category` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `created_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Link` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `url` TEXT NOT NULL, `title` TEXT, `description` TEXT, `imageUrl` TEXT, `sourceApp` TEXT, `categoryId` INTEGER NOT NULL, `created_at` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CategoryDao get categoryDao {
    return _categoryDaoInstance ??= _$CategoryDao(database, changeListener);
  }

  @override
  LinkDao get linkDao {
    return _linkDaoInstance ??= _$LinkDao(database, changeListener);
  }
}

class _$CategoryDao extends CategoryDao {
  _$CategoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _categoryInsertionAdapter = InsertionAdapter(
            database,
            'Category',
            (Category item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'created_at': item.createdAtMillis
                }),
        _categoryUpdateAdapter = UpdateAdapter(
            database,
            'Category',
            ['id'],
            (Category item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'created_at': item.createdAtMillis
                }),
        _categoryDeletionAdapter = DeletionAdapter(
            database,
            'Category',
            ['id'],
            (Category item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'created_at': item.createdAtMillis
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Category> _categoryInsertionAdapter;

  final UpdateAdapter<Category> _categoryUpdateAdapter;

  final DeletionAdapter<Category> _categoryDeletionAdapter;

  @override
  Future<List<Category>> findAllCategories() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Category ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) =>
            Category(id: row['id'] as int?, name: row['name'] as String));
  }

  @override
  Future<Category?> findCategoryById(int id) async {
    return _queryAdapter.query('SELECT * FROM Category WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            Category(id: row['id'] as int?, name: row['name'] as String),
        arguments: [id]);
  }

  @override
  Future<int> insertCategory(Category category) {
    return _categoryInsertionAdapter.insertAndReturnId(
        category, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateCategory(Category category) {
    return _categoryUpdateAdapter.updateAndReturnChangedRows(
        category, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteCategory(Category category) {
    return _categoryDeletionAdapter.deleteAndReturnChangedRows(category);
  }
}

class _$LinkDao extends LinkDao {
  _$LinkDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _linkInsertionAdapter = InsertionAdapter(
            database,
            'Link',
            (Link item) => <String, Object?>{
                  'id': item.id,
                  'url': item.url,
                  'title': item.title,
                  'description': item.description,
                  'imageUrl': item.imageUrl,
                  'sourceApp': item.sourceApp,
                  'categoryId': item.categoryId,
                  'created_at': item.createdAtMillis
                }),
        _linkUpdateAdapter = UpdateAdapter(
            database,
            'Link',
            ['id'],
            (Link item) => <String, Object?>{
                  'id': item.id,
                  'url': item.url,
                  'title': item.title,
                  'description': item.description,
                  'imageUrl': item.imageUrl,
                  'sourceApp': item.sourceApp,
                  'categoryId': item.categoryId,
                  'created_at': item.createdAtMillis
                }),
        _linkDeletionAdapter = DeletionAdapter(
            database,
            'Link',
            ['id'],
            (Link item) => <String, Object?>{
                  'id': item.id,
                  'url': item.url,
                  'title': item.title,
                  'description': item.description,
                  'imageUrl': item.imageUrl,
                  'sourceApp': item.sourceApp,
                  'categoryId': item.categoryId,
                  'created_at': item.createdAtMillis
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Link> _linkInsertionAdapter;

  final UpdateAdapter<Link> _linkUpdateAdapter;

  final DeletionAdapter<Link> _linkDeletionAdapter;

  @override
  Future<List<Link>> findAllLinks() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Link ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => Link(
            id: row['id'] as int?,
            url: row['url'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            imageUrl: row['imageUrl'] as String?,
            sourceApp: row['sourceApp'] as String?,
            categoryId: row['categoryId'] as int));
  }

  @override
  Future<List<Link>> findLinksByCategoryId(int categoryId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Link WHERE categoryId = ?1 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => Link(
            id: row['id'] as int?,
            url: row['url'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            imageUrl: row['imageUrl'] as String?,
            sourceApp: row['sourceApp'] as String?,
            categoryId: row['categoryId'] as int),
        arguments: [categoryId]);
  }

  @override
  Future<Link?> findLinkById(int id) async {
    return _queryAdapter.query('SELECT * FROM Link WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Link(
            id: row['id'] as int?,
            url: row['url'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            imageUrl: row['imageUrl'] as String?,
            sourceApp: row['sourceApp'] as String?,
            categoryId: row['categoryId'] as int),
        arguments: [id]);
  }

  @override
  Future<List<Link>> searchLinks(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Link WHERE url LIKE ?1 OR title LIKE ?1 OR description LIKE ?1 ORDER BY created_at DESC',
        mapper: (Map<String, Object?> row) => Link(id: row['id'] as int?, url: row['url'] as String, title: row['title'] as String?, description: row['description'] as String?, imageUrl: row['imageUrl'] as String?, sourceApp: row['sourceApp'] as String?, categoryId: row['categoryId'] as int),
        arguments: [query]);
  }

  @override
  Future<int> insertLink(Link link) {
    return _linkInsertionAdapter.insertAndReturnId(
        link, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateLink(Link link) {
    return _linkUpdateAdapter.updateAndReturnChangedRows(
        link, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteLink(Link link) {
    return _linkDeletionAdapter.deleteAndReturnChangedRows(link);
  }
}
