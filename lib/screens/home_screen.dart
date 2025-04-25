import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/link_provider.dart';
import '../widgets/link_list.dart';
import '../widgets/category_list.dart';
import 'search_screen.dart';
import '../utils/dialogs.dart';
import '../services/sharing_service.dart';

class HomeScreen extends StatefulWidget {
  final String? initialSharedUrl;

  const HomeScreen({Key? key, this.initialSharedUrl}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final SharingService _sharingService = SharingService();

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  Future<void> _loadData() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final linkProvider = Provider.of<LinkProvider>(context, listen: false);

    await categoryProvider.loadCategories();
    await linkProvider.loadAllLinks();
  }

  void _handleReceivedLink(String url) {
    if (!mounted) return;

    Dialogs.showAddLinkDialog(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Grab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Links'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            Dialogs.showAddLinkDialog(context, '');
          } else {
            Dialogs.showAddCategoryDialog(context);
          }
        },
        child: Icon(
          _selectedIndex == 0 ? Icons.add_link : Icons.create_new_folder,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const LinkList();
      case 1:
        return const CategoryList();
      default:
        return const Center(child: Text('Something went wrong!'));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
