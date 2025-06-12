import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/link.dart';
import '../services/hive_service.dart'; // Changed to HiveService

part 'link_providers.g.dart';

var _uuid = Uuid();

// Service provider
// It's often better to provide the actual service instance directly,
// especially with Hive where services might be simple classes.
// For now, maintaining the pattern but switching to LinkService.
final linkServiceProvider = Provider<LinkService>((ref) {
  // In a real app, you might initialize LinkService here if it has dependencies
  // or if it's not a simple class. For Hive, often it's new LinkService().
  // However, if build_runner isn't run, this provider might not be overridden correctly in main.
  // For safety, we can directly instantiate, or rely on override.
  // Let's assume it might be overridden or use a direct instance.
  return LinkService(); // Direct instantiation, can be overridden.
});

// Link state notifier
@Riverpod(keepAlive: true) // Added keepAlive if links should persist across UI changes
class LinksNotifier extends _$LinksNotifier { // Changed to _$LinksNotifier for generated file
  String? _currentGroupName;
  String _searchQuery = '';
  // No longer need _currentCategoryId

  @override
  Future<List<Link>> build() async {
    // Load initial data, LinkService instance will be from ref.read(linkServiceProvider)
    // The generated code will handle the service injection if done via constructor.
    // For now, assume service is accessed via ref.read inside methods.
    return _fetchAllLinks();
  }

  LinkService get _service => ref.read(linkServiceProvider);

  Future<List<Link>> _fetchAllLinks() async {
    return _service.getAllLinks();
  }

  Future<List<Link>> _fetchLinksByGroup(String groupName) async {
    return _service.getLinksByGroup(groupName);
  }

  Future<void> setGroupFilter(String? groupName) async {
    _currentGroupName = groupName;
    state = const AsyncValue.loading();
    try {
      if (groupName == null) {
        state = AsyncValue.data(await _fetchAllLinks());
      } else {
        state = AsyncValue.data(await _fetchLinksByGroup(groupName));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadFavorites() async {
    _currentGroupName = null; // Clear group filter
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _service.getFavoriteLinks());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    // We don't call notifyListeners here for AsyncNotifier.
    // The filteredLinksProvider will re-evaluate when _searchQuery changes if it watches this notifier.
    // To make filteredLinksProvider rebuild, we might need to refetch/filter data or make it watch _searchQuery.
    // A simple way is to just refresh the data which will apply the new search query via the filteredLinksProvider.
    // However, Riverpod's @riverpod pattern encourages immutable state updates to trigger rebuilds.
    // For now, let's assume filteredLinksProvider handles this by watching the notifier.
    // To explicitly trigger a re-filter, we can refetch data.
    refreshData();
  }

  void clearSearch() {
    _searchQuery = '';
    refreshData();
  }

  Future<void> addLink({
    required String url,
    String? title,
    String? group,
    String? description,
    bool isFavorite = false,
  }) async {
    state = const AsyncValue.loading(); // Optional: indicate loading state
    try {
      final newLink = Link(
        id: _uuid.v4(),
        url: url,
        title: title,
        group: group,
        description: description,
        isFavorite: isFavorite,
        createdAt: DateTime.now(),
      );
      await _service.addLink(newLink);
      await refreshData(); // Refresh data
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Set error state
      // Optionally, rethrow or handle error
    }
  }

  Future<void> updateLink(Link link) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateLink(link);
      await refreshData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String linkId) async {
    state = const AsyncValue.loading();
    try {
      final link = await _service.getLinkById(linkId);
      if (link != null) {
        final updatedLink = Link(
          id: link.id,
          url: link.url,
          title: link.title,
          group: link.group,
          description: link.description,
          isFavorite: !link.isFavorite,
          createdAt: link.createdAt,
        );
        await _service.updateLink(updatedLink);
        await refreshData();
      } else {
        // Handle case where link is not found, though getLinkById might throw
        throw Exception("Link with ID $linkId not found for toggling favorite.");
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLink(String linkId) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteLink(linkId);
      await refreshData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshData() async {
    state = const AsyncValue.loading();
    try {
      final List<Link> updatedLinks;
      if (_currentGroupName != null) {
        updatedLinks = await _fetchLinksByGroup(_currentGroupName!);
      } else {
        // Consider if we need a separate "favorites" mode or if it's part of general filtering.
        // For now, if no group, fetch all. loadFavorites() can be used for explicit favorites view.
        updatedLinks = await _fetchAllLinks();
      }
      state = AsyncValue.data(updatedLinks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String? get currentGroupName => _currentGroupName;
  String get searchQuery => _searchQuery;
}

// The @riverpod annotation handles the provider creation for LinksNotifier.
// It will be linksNotifierProvider.

// Filtered links (with search query applied)
@riverpod
List<Link> filteredLinks(FilteredLinksRef ref) {
  // Watch the Notifier itself for its properties like _searchQuery and _currentGroupName
  final notifier = ref.watch(linksNotifierProvider.notifier);
  // Watch the state of the Notifier for the actual list of links
  final linksAsyncValue = ref.watch(linksNotifierProvider);

  return linksAsyncValue.when(
    data: (links) {
      List<Link> potentiallyFilteredLinks = links;

      // Note: The LinksNotifier already filters by group internally before setting its state.
      // So, `links` here are already filtered by group if a group is set.
      // If _currentGroupName was handled here instead, the logic would be:
      // if (notifier.currentGroupName != null) {
      //   potentiallyFilteredLinks = potentiallyFilteredLinks.where((link) => link.group == notifier.currentGroupName).toList();
      // }

      if (notifier.searchQuery.isEmpty) {
        return potentiallyFilteredLinks;
      }
      final query = notifier.searchQuery.toLowerCase();
      return potentiallyFilteredLinks
          .where(
            (link) =>
                link.url.toLowerCase().contains(query) ||
                (link.title?.toLowerCase().contains(query) ?? false) ||
                (link.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    },
    loading: () => [], // Return empty list or previous data while loading
    error: (_, __) => [], // Return empty list or error indicator on error
  );
}
