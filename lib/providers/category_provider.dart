import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../services/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _repository;
  List<models.Category> _categories = [];
  bool _isLoading = false;

  CategoryProvider(this._repository);

  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<models.Category?> getCategoryById(int id) async {
    return await _repository.getCategoryById(id);
  }

  Future<int> addCategory(String name) async {
    final category = models.Category(name: name);
    final id = await _repository.insertCategory(category);
    await loadCategories();
    return id;
  }

  Future<void> updateCategory(models.Category category) async {
    await _repository.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(models.Category category) async {
    await _repository.deleteCategory(category);
    await loadCategories();
  }
}
