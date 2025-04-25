import 'package:flutter/foundation.dart';
import '../models/link.dart';
import '../services/link_repository.dart';

class LinkProvider with ChangeNotifier {
  final LinkRepository _repository;
  List<Link> _links = [];
  List<Link> _filteredLinks = [];
  bool _isLoading = false;
  int? _currentCategoryId;
  String _searchQuery = '';

  LinkProvider(this._repository);

  List<Link> get links =>
      _searchQuery.isEmpty
          ? _filteredLinks
          : _filteredLinks
              .where(
                (link) =>
                    link.url.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (link.title?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false) ||
                    (link.description?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();

  bool get isLoading => _isLoading;
  int? get currentCategoryId => _currentCategoryId;
  String get searchQuery => _searchQuery;

  Future<void> loadAllLinks() async {
    _isLoading = true;
    _currentCategoryId = null;
    notifyListeners();

    try {
      _links = await _repository.getAllLinks();
      _filteredLinks = _links;
    } catch (e) {
      print('Error loading links: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLinksByCategory(int categoryId) async {
    _isLoading = true;
    _currentCategoryId = categoryId;
    notifyListeners();

    try {
      _filteredLinks = await _repository.getLinksByCategoryId(categoryId);
    } catch (e) {
      print('Error loading links by category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Link?> getLinkById(int id) async {
    return await _repository.getLinkById(id);
  }

  Future<void> searchLinks(String query) async {
    _searchQuery = query;
    notifyListeners();
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

    if (_currentCategoryId == null) {
      await loadAllLinks();
    } else {
      await loadLinksByCategory(_currentCategoryId!);
    }

    return id;
  }

  Future<void> updateLink(Link link) async {
    await _repository.updateLink(link);

    if (_currentCategoryId == null) {
      await loadAllLinks();
    } else {
      await loadLinksByCategory(_currentCategoryId!);
    }
  }

  Future<void> deleteLink(Link link) async {
    await _repository.deleteLink(link);

    if (_currentCategoryId == null) {
      await loadAllLinks();
    } else {
      await loadLinksByCategory(_currentCategoryId!);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
