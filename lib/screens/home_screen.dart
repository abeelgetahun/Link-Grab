import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:page_transition/page_transition.dart'; // Keep if SearchScreen navigation is retained

// New Provider Imports
import '../providers/settings_providers.dart';
import '../providers/group_providers.dart';
import '../providers/link_providers.dart';

// New Widget Imports
import '../widgets/link_card.dart';
// import '../widgets/group_chip.dart'; // May not be directly used here but by HomeTabsBar or Group List
import '../widgets/search_bar.dart'; // Assuming AppSearchBar is defined here
import '../widgets/tabs_bar.dart';

// New Dialog Imports
import '../dialogs/add_link_dialog.dart' as AppDialogs; // Aliased to avoid conflict if any
import '../dialogs/edit_link_dialog.dart' as AppDialogs; // For Edit Link
import '../dialogs/add_group_dialog.dart' as AppDialogs;
import '../utils/dialogs_riverpod.dart' as UtilsDialogs; // For confirmation dialog


// Models (already imported by providers, but good for clarity if used directly)
import '../models/link.dart';
import '../models/group.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Added

// import 'search_screen.dart'; // Keep if SearchScreen is still used
import '../services/sharing_service.dart'; // Keep for now

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialSharedUrl;

  const HomeScreen({Key? key, this.initialSharedUrl}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin { // Changed to TickerProviderStateMixin for multiple TabControllers if needed
  final SharingService _sharingService = SharingService();
  TabController? _tabController;
  bool _isSearchVisible = false; // To toggle search bar visibility

  // Static tab titles
  final List<String> _staticTabs = ["All", "Groups", "Favorites", "Recent"];

  @override
  void initState() {
    super.initState();
    _sharingService.setLinkReceivedCallback(_handleReceivedLink);
    _sharingService.init();

    if (widget.initialSharedUrl != null && widget.initialSharedUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleReceivedLink(widget.initialSharedUrl!);
      });
    }

    // Initial load of links and groups is handled by the providers themselves (@Riverpod(keepAlive: true))
    // However, explicitly calling refresh here can ensure data is fresh if not already loaded.
    // ref.read(linksNotifierProvider.notifier).refreshData();
    // ref.read(groupNotifierProvider.notifier).refreshGroups();

    // Initialize TabController - will be updated when groups change
    _updateTabController();
  }

  void _updateTabController({List<Group>? currentGroups}) {
    final groups = currentGroups ?? ref.read(groupsProvider).value ?? [];
    final tabCount = _staticTabs.length + groups.length;

    // Preserve current index if possible
    int previousIndex = _tabController?.index ?? 0;
    if (previousIndex >= tabCount) {
      previousIndex = tabCount - 1;
    }
    if (previousIndex < 0 && tabCount > 0) {
      previousIndex = 0;
    }


    _tabController?.dispose(); // Dispose old controller if exists
    _tabController = TabController(
      length: tabCount > 0 ? tabCount : 1, // Must have at least 1 tab
      vsync: this,
      initialIndex: (tabCount > 0 && previousIndex < tabCount) ? previousIndex : 0,
    );
    // Add listener to handle tab changes for filtering if needed, though TabBarView handles content.
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        // Potentially call a provider method if direct action on tab change is needed
        // e.g., ref.read(linksNotifierProvider.notifier).setGroupFilter(selectedGroupName);
      }
      setState(() {}); // Rebuild to reflect tab change in UI if necessary (e.g. selected tab style)
    });
  }

  @override
  void dispose() {
    _sharingService.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _handleReceivedLink(String url) {
    if (!mounted) return;
    // Use the new aliased dialog
    AppDialogs.showAddLinkDialog(context, initialUrl: url);
  }

  List<String> _getTabTitles(List<Group> groups) {
    return _staticTabs + groups.map((g) => g.name).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final groups = ref.watch(groupsProvider).value ?? [];

    // This listener will update the TabController when groupProvider's state changes.
    ref.listen(groupsProvider, (previous, next) {
      if (previous?.value?.length != next.value?.length) {
         WidgetsBinding.instance.addPostFrameCallback((_) { // Ensure rebuild happens after current frame
          if (mounted) {
            _updateTabController(currentGroups: next.value);
            setState(() {}); // Trigger rebuild for TabBar and TabBarView
          }
        });
      }
    });

    if (_tabController == null || (_staticTabs.length + groups.length) != _tabController!.length) {
       // Fallback in case listen is not fast enough or controller is null initially
      _updateTabController(currentGroups: groups);
    }

    final allLinksAsync = ref.watch(linksNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? AppSearchBar(
                onQueryChanged: (query) {
                  ref.read(linksNotifierProvider.notifier).setSearchQuery(query);
                },
                onClear: () {
                  ref.read(linksNotifierProvider.notifier).clearSearch();
                },
              )
            : const Text('Link Grab'),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                   // Clear search when hiding search bar
                  ref.read(linksNotifierProvider.notifier).clearSearch();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).toggleDarkMode();
            },
          ),
          // Optional Menu IconButton
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu actions
              if (value == 'settings') {/* Navigate to settings */}
              if (value == 'add_group') {
                 AppDialogs.showAddGroupDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'add_group',
                child: Text('Add Group'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings (NYI)'),
              ),
            ],
          ),
        ],
        bottom: _tabController != null && _tabController!.length > 0
          ? HomeTabsBar(
              tabTitles: _getTabTitles(groups),
              selectedTabIndex: _tabController!.index,
              onTabSelected: (index) {
                _tabController!.animateTo(index);
              },
              tabController: _tabController,
            )
          : null, // Or a PreferredSize widget with zero height
      ),
      body: _tabController != null && _tabController!.length > 0
        ? TabBarView(
          controller: _tabController,
          children: [
            // "All" Tab
            _buildLinksList(allLinksAsync, filter: LinkFilterType.all),
            // "Groups" Tab - List of all groups
            _buildGroupsList(groups),
            // "Favorites" Tab
            _buildLinksList(allLinksAsync, filter: LinkFilterType.favorites),
            // "Recent" Tab
            _buildLinksList(allLinksAsync, filter: LinkFilterType.recent),
            // Dynamic Group Tabs
            ...groups.map((group) => _buildLinksList(allLinksAsync, filter: LinkFilterType.group, groupName: group.name)).toList(),
          ],
        )
        : const Center(child: Text("No tabs to display")), // Fallback for no tabs
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppDialogs.showAddLinkDialog(context); // Use new aliased dialog
        },
        child: const Icon(Icons.add_link),
      ),
    );
  }

  Widget _buildLinksList(AsyncValue<List<Link>> linksAsync, {required LinkFilterType filter, String? groupName}) {
    // This logic will be refined based on how LinksNotifier exposes filtered data.
    // For now, a simple client-side filter for demonstration.
    // Ideally, the provider itself should handle filtering efficiently.

    return linksAsync.when(
      data: (allLinks) {
        List<Link> linksToDisplay;
        switch (filter) {
          case LinkFilterType.all:
            linksToDisplay = allLinks;
            break;
          case LinkFilterType.favorites:
            linksToDisplay = allLinks.where((link) => link.isFavorite).toList();
            break;
          case LinkFilterType.recent:
            // Assuming LinkService.getRecentLinks in service, and LinksNotifier calls it
            // For now, sort by createdAt (descending)
            linksToDisplay = List<Link>.from(allLinks);
            linksToDisplay.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          case LinkFilterType.group:
            linksToDisplay = allLinks.where((link) => link.group == groupName).toList();
            break;
        }

        final currentSearchQuery = ref.watch(linksNotifierProvider.notifier).searchQuery;
        if (currentSearchQuery.isNotEmpty) {
          linksToDisplay = linksToDisplay.where((link) {
            final query = currentSearchQuery.toLowerCase();
            return (link.title?.toLowerCase().contains(query) ?? false) ||
                   link.url.toLowerCase().contains(query) ||
                   (link.description?.toLowerCase().contains(query) ?? false);
          }).toList();
        }


        if (linksToDisplay.isEmpty) {
          return Center(child: Text('No links found for "${_tabController!.index < _staticTabs.length ? _staticTabs[_tabController!.index] : groupName ?? "this group"}".'));
        }
        return AnimationLimiter(
          child: ListView.builder(
            itemCount: linksToDisplay.length,
            itemBuilder: (context, index) {
              final link = linksToDisplay[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: LinkCard(
                      link: link,
                      onTap: () { /* Handle link tap, e.g., open URL */ },
                      onToggleFavorite: () {
                        ref.read(linksNotifierProvider.notifier).toggleFavorite(link.id);
                      },
                      onEdit: () {
                        AppDialogs.showEditLinkDialog(context, linkToEdit: link);
                      },
                      onDelete: () async {
                        final confirm = await UtilsDialogs.DialogsRiverpod.showDeleteConfirmDialog(context, "Link");
                        if (confirm) {
                          ref.read(linksNotifierProvider.notifier).deleteLink(link.id);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading links: $err')),
    );
  }

  Widget _buildGroupsList(List<Group> groups) {
    if (groups.isEmpty) {
      return const Center(child: Text('No groups yet. Add one from the menu!'));
    }
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return ListTile(
          title: Text(group.name),
          leading: Icon(Icons.folder, color: Color(group.color)),
          onTap: () {
            // Find the tab index for this group and switch to it
            final tabIndex = _staticTabs.length + groups.indexOf(group);
            if (tabIndex < _tabController!.length) {
              _tabController!.animateTo(tabIndex);
            }
          },
          // Add more options like edit/delete group here if needed
        );
      },
    );
  }
}

enum LinkFilterType { all, favorites, recent, group }
