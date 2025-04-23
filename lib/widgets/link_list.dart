import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/link_provider.dart';
import '../providers/category_provider.dart';
import '../utils/dialogs.dart';
import 'link_item.dart';

class LinkList extends StatelessWidget {
  const LinkList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<LinkProvider, CategoryProvider>(
      builder: (context, linkProvider, categoryProvider, child) {
        if (linkProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Add a header for the current category if we're filtering by category
        String headerText = 'All Links';
        if (linkProvider.currentCategoryId != null) {
          try {
            final category = categoryProvider.categories.firstWhere(
              (cat) => cat.id == linkProvider.currentCategoryId,
            );
            headerText = category.name;
          } catch (e) {
            // If category not found, use default text
            headerText = 'Filtered Links';
          }
        }

        if (linkProvider.links.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.link_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No links yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                linkProvider.currentCategoryId != null
                    ? ElevatedButton(
                      onPressed: () {
                        linkProvider.loadAllLinks();
                      },
                      child: const Text('Show All Links'),
                    )
                    : ElevatedButton(
                      onPressed: () {
                        Dialogs.showAddLinkDialog(context, '');
                      },
                      child: const Text('Add Link'),
                    ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Category header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headerText,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (linkProvider.currentCategoryId != null)
                    TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filter'),
                      onPressed: () {
                        linkProvider.loadAllLinks();
                      },
                    ),
                ],
              ),
            ),

            // Links list
            Expanded(
              child: ListView.builder(
                itemCount: linkProvider.links.length,
                itemBuilder: (context, index) {
                  final link = linkProvider.links[index];
                  return LinkItem(link: link);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
