import 'package:flutter/material.dart';

class HomeTabsBar extends StatefulWidget {
  final List<String> tabTitles;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final TabController? tabController; // Optional: pass if managed externally

  const HomeTabsBar({
    Key? key,
    required this.tabTitles,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.tabController,
  }) : super(key: key);

  @override
  State<HomeTabsBar> createState() => _HomeTabsBarState();
}

class _HomeTabsBarState extends State<HomeTabsBar> with SingleTickerProviderStateMixin {
  TabController? _internalTabController;

  TabController get _effectiveTabController => widget.tabController ?? _internalTabController!;

  @override
  void initState() {
    super.initState();
    if (widget.tabController == null) {
      _internalTabController = TabController(
        length: widget.tabTitles.length,
        vsync: this,
        initialIndex: widget.selectedTabIndex,
      );
    }
    _effectiveTabController.addListener(_handleTabSelection);
  }

  @override
  void didUpdateWidget(HomeTabsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabTitles.length != oldWidget.tabTitles.length) {
      // If tab titles change length, we might need to recreate the internal controller
      _internalTabController?.dispose();
      if (widget.tabController == null) {
        _internalTabController = TabController(
          length: widget.tabTitles.length,
          vsync: this,
          initialIndex: widget.selectedTabIndex.clamp(0, widget.tabTitles.length - 1),
        );
      } else {
        _internalTabController = null; // Using external controller
      }
       _effectiveTabController.removeListener(_handleTabSelection); // remove old listener
      _effectiveTabController.addListener(_handleTabSelection); // add new listener
    }

    // Ensure index is updated if it changes externally or internally
    if (widget.selectedTabIndex != _effectiveTabController.index &&
        widget.selectedTabIndex < _effectiveTabController.length) {
      _effectiveTabController.animateTo(widget.selectedTabIndex);
    }
  }

  @override
  void dispose() {
    _effectiveTabController.removeListener(_handleTabSelection);
    // Only dispose the internal controller
    _internalTabController?.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_effectiveTabController.indexIsChanging || _effectiveTabController.index != widget.selectedTabIndex) {
      widget.onTabSelected(_effectiveTabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabTitles.isEmpty) {
      return const SizedBox.shrink(); // No tabs to display
    }

    return TabBar(
      controller: _effectiveTabController,
      isScrollable: true,
      tabs: widget.tabTitles.map((title) => Tab(text: title)).toList(),
      onTap: (index) {
        // The listener _handleTabSelection will call widget.onTabSelected
        // This onTap is more direct but TabController listener is more robust
        // widget.onTabSelected(index);
      },
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      indicatorColor: Theme.of(context).colorScheme.primary,
    );
  }
}
