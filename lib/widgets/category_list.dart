import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/category_provider.dart';
import '../providers/link_provider.dart';
import '../models/category.dart';
import '../utils/dialogs.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryProvider.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No categories yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Dialogs.showAddCategoryDialog(context);
                  },
                  child: const Text('Create Category'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: categoryProvider.categories.length,
          itemBuilder: (context, index) {
            final category = categoryProvider.categories[index];
            return CategoryListItem(category: category);
          },
        );
      },
    );
  }
}

class CategoryListItem extends StatelessWidget {
  final Category category;

  const CategoryListItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Dialogs.showEditCategoryDialog(context, category);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) async {
              final shouldDelete = await Dialogs.showDeleteConfirmDialog(
                context,
                'category',
              );

              if (shouldDelete && context.mounted) {
                Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                ).deleteCategory(category);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.folder),
        title: Text(category.name),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to the links in this category
          final linkProvider = Provider.of<LinkProvider>(
            context,
            listen: false,
          );
          if (category.id != null) {
            linkProvider.loadLinksByCategory(category.id!);
          }

          // Go back to the Links tab
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing links in "${category.name}"'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
}
