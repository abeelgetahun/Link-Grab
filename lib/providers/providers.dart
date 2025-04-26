import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/link.dart';
import '../services/category_repository.dart';
import '../services/link_repository.dart';

// Repository providers
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  throw UnimplementedError('Repository must be overridden in main.dart');
});

final linkRepositoryProvider = Provider<LinkRepository>((ref) {
  throw UnimplementedError('Repository must be overridden in main.dart');
});

// Category providers
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((
      ref,
    ) {
      return CategoriesNotifier(ref.read(categoryRepositoryProvider));
    });

// Link providers
final linksProvider =
    StateNotifierProvider<LinksNotifier, AsyncValue<List<Link>>>((ref) {
      return LinksNotifier(ref.read(linkRepositoryProvider));
    });

// Current category ID provider
final currentCategoryIdProvider = StateProvider<int?>((ref) => null);

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered links provider
final filteredLinksProvider = Provider<List<Link>>((ref) {
  final linksAsync = ref.watch(linksProvider);
  final query = ref.watch(searchQueryProvider);

  return linksAsync.when(
    data: (links) {
      if (query.isEmpty) {
        return links;
      }

      final searchQuery = query.toLowerCase();
      return links
          .where(
            (link) =>
                link.url.toLowerCase().contains(searchQuery) ||
                (link.title?.toLowerCase().contains(searchQuery) ?? false) ||
                (link.description?.toLowerCase().contains(searchQuery) ??
                    false),
          )
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Category by ID provider
final categoryByIdProvider = Provider.family<Category?, int>((ref, id) {
  final categoriesAsync = ref.watch(categoriesProvider);

  return categoriesAsync.when(
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
});

// Link state notifier
class LinksNotifier extends StateNotifier<AsyncValue<List<Link>>> {
  final LinkRepository _repository;

  LinksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAllLinks();
  }

  Future<void> loadAllLinks() async {
    state = const AsyncValue.loading();
    try {
      final links = await _repository.getAllLinks();
      state = AsyncValue.data(links);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadLinksByCategory(int categoryId) async {
    state = const AsyncValue.loading();
    try {
      final links = await _repository.getLinksByCategoryId(categoryId);
      state = AsyncValue.data(links);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<int> addLink(
    String url,
    int categoryId, {
    String? title,
    String? description,
    String? imageUrl,
    String? sourceApp,
  }) async {
    final link = Link(
      url: url,
      categoryId: categoryId,
      title: title,
      description: description,
      imageUrl: imageUrl,
      sourceApp: sourceApp,
    );

    final id = await _repository.insertLink(link);
    loadAllLinks(); // Reload after adding
    return id;
  }

  Future<void> updateLink(Link link) async {
    await _repository.updateLink(link);
    loadAllLinks(); // Reload after updating
  }

  Future<void> deleteLink(Link link) async {
    await _repository.deleteLink(link);
    loadAllLinks(); // Reload after deleting
  }
}

// Categories state notifier
class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;

  CategoriesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<int> addCategory(String name) async {
    final category = Category(name: name);
    final id = await _repository.insertCategory(category);
    loadCategories(); // Reload after adding
    return id;
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    loadCategories(); // Reload after updating
  }

  Future<void> deleteCategory(Category category) async {
    await _repository.deleteCategory(category);
    loadCategories(); // Reload after deleting
  }
}
