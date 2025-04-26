import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/category.dart';
import '../services/category_repository.dart';

part 'category_providers.g.dart';

// Repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  throw UnimplementedError('Repository must be overridden in main.dart');
});

// Category state notifier
class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    return _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() async {
    final repository = ref.read(categoryRepositoryProvider);
    return repository.getAllCategories();
  }

  // CRUD operations
  Future<int> addCategory(String name) async {
    final repository = ref.read(categoryRepositoryProvider);
    final category = Category(name: name);
    final id = await repository.insertCategory(category);
    refreshData();
    return id;
  }

  Future<void> updateCategory(Category category) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.updateCategory(category);
    refreshData();
  }

  Future<void> deleteCategory(Category category) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.deleteCategory(category);
    refreshData();
  }

  Future<void> refreshData() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _fetchCategories());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Create the provider
@riverpod
CategoriesNotifier categoriesNotifier(CategoriesNotifierRef ref) {
  return CategoriesNotifier();
}

// Helper provider to get a category by ID
@riverpod
Category? getCategoryById(GetCategoryByIdRef ref, int id) {
  final categoriesState = ref.watch(categoriesNotifierProvider);

  return categoriesState.when(
    data: (categories) {
      try {
        return categories.firstWhere((cat) => cat.id == id);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
}
