import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/providers.dart';
import '../widgets/link_item.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
      // Clear any existing search
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    // Clear search query when leaving screen
    ref.read(searchQueryProvider.notifier).state = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get links filtered by search query
    final query = ref.watch(searchQueryProvider);
    final linksAsync = ref.watch(linksProvider);

    // Create the filtered list
    final links = ref.watch(filteredLinksProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: InputDecoration(
            hintText: 'Search links...',
            border: InputBorder.none,
            suffixIcon:
                query.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                    : null,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: linksAsync.when(
        data: (_) => _buildResults(links, query),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }

  Widget _buildResults(List<dynamic> links, String query) {
    if (query.isEmpty) {
      return AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 300),
        child: FadeInAnimation(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Enter text to search',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (links.isEmpty) {
      return AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 300),
        child: FadeInAnimation(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No results for "$query"',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: links.length,
        itemBuilder: (context, index) {
          final link = links[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: LinkItem(link: link)),
            ),
          );
        },
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    _searchFocus.requestFocus();
  }
}
