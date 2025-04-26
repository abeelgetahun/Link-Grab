import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/link.dart';
import '../services/link_repository.dart';

part 'link_providers.g.dart';

// Repository provider
final linkRepositoryProvider = Provider<LinkRepository>((ref) {
  throw UnimplementedError('Repository must be overridden in main.dart');
});

// Link state notifier - manages all link state with better optimization
class LinksNotifier extends AsyncNotifier<List<Link>> {
  int? _currentCategoryId;
  String _searchQuery = '';

  @override
  Future<List<Link>> build() async {
    return _fetchAllLinks();
  }

  Future<List<Link>> _fetchAllLinks() async {
    final repository = ref.read(linkRepositoryProvider);
    return repository.getAllLinks();
  }

  Future<List<Link>> _fetchLinksByCategory(int categoryId) async {
    final repository = ref.read(linkRepositoryProvider);
    return repository.getLinksByCategoryId(categoryId);
  }

  // Sets the current category filter and refetches data
  Future<void> setCategoryFilter(int? categoryId) async {
    _currentCategoryId = categoryId;
    state = const AsyncValue.loading();

    try {
      if (categoryId == null) {
        state = AsyncValue.data(await _fetchAllLinks());
      } else {
        state = AsyncValue.data(await _fetchLinksByCategory(categoryId));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // For search functionality
  Future<void> searchLinks(String query) async {
    _searchQuery = query;
    ref.notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    ref.notifyListeners();
  }

  // CRUD operations
  Future<int> addLink(
    String url,
    int categoryId, {
    String? title,
    String? description,
    String? imageUrl,
    String? sourceApp,
  }) async {
    final repository = ref.read(linkRepositoryProvider);
    final link = Link(
      url: url,
      categoryId: categoryId,
      title: title,
      description: description,
      imageUrl: imageUrl,
      sourceApp: sourceApp,
    );

    final id = await repository.insertLink(link);
    // Refresh data after addition
    refreshData();
    return id;
  }

  Future<void> updateLink(Link link) async {
    final repository = ref.read(linkRepositoryProvider);
    await repository.updateLink(link);
    refreshData();
  }

  Future<void> deleteLink(Link link) async {
    final repository = ref.read(linkRepositoryProvider);
    await repository.deleteLink(link);
    refreshData();
  }

  // Refresh based on current category filter
  Future<void> refreshData() async {
    state = const AsyncValue.loading();
    try {
      if (_currentCategoryId == null) {
        state = AsyncValue.data(await _fetchAllLinks());
      } else {
        state = AsyncValue.data(
          await _fetchLinksByCategory(_currentCategoryId!),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Getters
  int? get currentCategoryId => _currentCategoryId;
  String get searchQuery => _searchQuery;
}

// Create the provider
@riverpod
LinksNotifier linksNotifier(LinksNotifierRef ref) {
  return LinksNotifier();
}

// Filtered links (with search query applied)
@riverpod
List<Link> filteredLinks(FilteredLinksRef ref) {
  final linksState = ref.watch(linksNotifierProvider);
  final notifier = ref.watch(linksNotifierProvider.notifier);

  return linksState.when(
    data: (links) {
      if (notifier.searchQuery.isEmpty) {
        return links;
      }
      final query = notifier.searchQuery.toLowerCase();
      return links
          .where(
            (link) =>
                link.url.toLowerCase().contains(query) ||
                (link.title?.toLowerCase().contains(query) ?? false) ||
                (link.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}
