import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import '../providers/providers.dart';
import '../widgets/link_list.dart';
import '../widgets/category_list.dart';
import 'search_screen.dart';
import '../utils/dialogs_riverpod.dart';
import '../services/sharing_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialSharedUrl;

  const HomeScreen({Key? key, this.initialSharedUrl}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final SharingService _sharingService = SharingService();

  // Animation controller for tab switching
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialize sharing service
    _sharingService.setLinkReceivedCallback(_handleReceivedLink);
    _sharingService.init();

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();

      // Handle any shared URL that might have been received when app was opened
      if (widget.initialSharedUrl != null &&
          widget.initialSharedUrl!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleReceivedLink(widget.initialSharedUrl!);
        });
      }
    });
  }

  @override
  void dispose() {
    _sharingService.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load data using Riverpod providers
    ref.read(categoriesProvider.notifier).loadCategories();
    ref.read(linksProvider.notifier).loadAllLinks();
  }

  void _handleReceivedLink(String url) {
    if (!mounted) return;

    DialogsRiverpod.showAddLinkDialog(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Grab'),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const SearchScreen(),
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 250),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Link List (index 0)
          Opacity(
            opacity: _selectedIndex == 0 ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: _selectedIndex != 0,
              child: const LinkList(),
            ),
          ),

          // Category List (index 1)
          Opacity(
            opacity: _selectedIndex == 1 ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: _selectedIndex != 1,
              child: const CategoryList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.link), label: 'Links'),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            DialogsRiverpod.showAddLinkDialog(context, '');
          } else {
            DialogsRiverpod.showAddCategoryDialog(context);
          }
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            _selectedIndex == 0 ? Icons.add_link : Icons.create_new_folder,
            key: ValueKey<int>(_selectedIndex),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    // Run animation when tab changes
    if (index == 1) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
