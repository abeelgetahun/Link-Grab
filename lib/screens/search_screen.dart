import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/link_provider.dart';
import '../widgets/link_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear any existing search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LinkProvider>(context, listen: false).clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search links...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            Provider.of<LinkProvider>(
              context,
              listen: false,
            ).searchLinks(query);
          },
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              Provider.of<LinkProvider>(context, listen: false).clearSearch();
            },
          ),
        ],
      ),
      body: Consumer<LinkProvider>(
        builder: (context, linkProvider, child) {
          final links = linkProvider.links;

          if (linkProvider.searchQuery.isEmpty) {
            return const Center(child: Text('Type something to search'));
          }

          if (links.isEmpty) {
            return const Center(child: Text('No results found'));
          }

          return ListView.builder(
            itemCount: links.length,
            itemBuilder: (context, index) {
              return LinkItem(link: links[index]);
            },
          );
        },
      ),
    );
  }
}
