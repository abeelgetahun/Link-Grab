import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import '../models/link.dart';
import '../services/hive_service.dart'; // Changed to HiveService

// Assuming Uuid is used for ID generation
var _uuid = Uuid();

class LinkProvider with ChangeNotifier {
  final LinkService _linkService; // Changed to LinkService
  List<Link> _links = [];
  List<Link> _filteredLinks = [];
  bool _isLoading = false;
  String? _currentGroupName; // Changed from categoryId to groupName
  String _searchQuery = '';

  LinkProvider(this._linkService) {
    // Initial load, can be more sophisticated
    loadAllLinks();
  }

  List<Link> get links {
    List<Link> linksToDisplay;
    if (_currentGroupName != null) {
      linksToDisplay = _links.where((link) => link.group == _currentGroupName).toList();
    } else {
      linksToDisplay = _links;
    }

    if (_searchQuery.isEmpty) {
      return linksToDisplay;
    } else {
      return linksToDisplay
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
    }
  }

  List<Link> get favoriteLinks => _links.where((link) => link.isFavorite).toList();

  bool get isLoading => _isLoading;
  String? get currentGroupName => _currentGroupName;
  String get searchQuery => _searchQuery;

  Future<void> loadAllLinks() async {
    _isLoading = true;
    _currentGroupName = null; // Reset group filter
    notifyListeners();

    try {
      _links = await _linkService.getAllLinks();
      _filteredLinks = _links; // _filteredLinks might be redundant if links getter handles filtering
    } catch (e) {
      print('Error loading all links: $e');
      _links = []; // Ensure links is empty on error
      _filteredLinks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLinksByGroup(String groupName) async {
    _isLoading = true;
    _currentGroupName = groupName;
    notifyListeners();

    try {
      // This now filters the already loaded _links list.
      // If direct fetching by group is preferred and efficient:
      // _links = await _linkService.getLinksByGroup(groupName);
      // For now, we filter the main list.
      // _filteredLinks = _links.where((link) => link.group == groupName).toList();
      // The main `links` getter will handle the filtering by _currentGroupName
    } catch (e) {
      print('Error loading links by group $groupName: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // To rebuild widgets using the new _currentGroupName
    }
  }

  Future<void> loadFavoriteLinks() async {
    _isLoading = true;
    notifyListeners();
    try {
      // This assumes favoriteLinks getter is sufficient and re-filters the main list.
      // If a dedicated service call is preferred:
      // _links = await _linkService.getFavoriteLinks();
      // For now, we rely on the getter.
      _currentGroupName = null; // Clear group filter when showing favorites
    } catch (e) {
      print('Error loading favorite links: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<Link?> getLinkById(String id) async {
    // This might require fetching from service if not all links are always loaded
    // or if a link might have been updated.
    try {
      return await _linkService.getLinkById(id);
    } catch (e) {
      print('Error getting link by ID $id: $e');
      return null;
    }
  }

  Future<void> searchLinks(String query) async {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addLink({
    required String url,
    String? title,
    String? group,
    String? description,
    bool isFavorite = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newLink = Link(
        id: _uuid.v4(), // Generate unique ID
        url: url,
        title: title,
        group: group,
        description: description,
        isFavorite: isFavorite,
        createdAt: DateTime.now(),
      );
      await _linkService.addLink(newLink);
      await loadAllLinks(); // Reload all links
    } catch (e) {
      print('Error adding link: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLink(Link link) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _linkService.updateLink(link);
      await loadAllLinks(); // Reload all links
    } catch (e)
    {
      print('Error updating link ${link.id}: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String linkId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final link = await _linkService.getLinkById(linkId);
      if (link != null) {
        final updatedLink = Link(
          id: link.id,
          url: link.url,
          title: link.title,
          group: link.group,
          description: link.description,
          isFavorite: !link.isFavorite, // Toggle favorite status
          createdAt: link.createdAt,
        );
        await _linkService.updateLink(updatedLink);
        await loadAllLinks(); // Reload all links
      }
    } catch (e) {
      print('Error toggling favorite for link $linkId: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLink(String linkId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _linkService.deleteLink(linkId);
      await loadAllLinks(); // Reload all links
    } catch (e) {
      print('Error deleting link $linkId: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentGroupName(String? groupName) {
    _currentGroupName = groupName;
    _searchQuery = ''; // Clear search when changing group
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
