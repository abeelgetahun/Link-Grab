import 'package:floor/floor.dart';
import '../../models/category.dart';

@dao
abstract class CategoryDao {
  @Query('SELECT * FROM Category ORDER BY created_at DESC')
  Future<List<Category>> findAllCategories();

  @Query('SELECT * FROM Category WHERE id = :id')
  Future<Category?> findCategoryById(int id);

  @insert
  Future<int> insertCategory(Category category);

  @update
  Future<int> updateCategory(Category category);

  @delete
  Future<int> deleteCategory(Category category);
}
