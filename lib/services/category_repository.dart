import '../database/database.dart';
import '../models/category.dart';

class CategoryRepository {
  final AppDatabase _database;

  CategoryRepository(this._database);

  Future<List<Category>> getAllCategories() async {
    return await _database.categoryDao.findAllCategories();
  }

  Future<Category?> getCategoryById(int id) async {
    return await _database.categoryDao.findCategoryById(id);
  }

  Future<int> insertCategory(Category category) async {
    return await _database.categoryDao.insertCategory(category);
  }

  Future<int> updateCategory(Category category) async {
    return await _database.categoryDao.updateCategory(category);
  }

  Future<int> deleteCategory(Category category) async {
    return await _database.categoryDao.deleteCategory(category);
  }
}
