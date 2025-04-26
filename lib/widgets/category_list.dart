import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/category.dart';
import '../providers/providers.dart';
import '../utils/dialogs_riverpod.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => _buildCategoryList(context, ref, categories),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Text('Error loading categories: ${error.toString()}'),
          ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) {
    if (categories.isEmpty) {
      return AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 400),
        child: FadeInAnimation(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text('No categories yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    DialogsRiverpod.showAddCategoryDialog(context);
                  },
                  child: const Text('Add Category'),
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
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildCategoryItem(context, ref, category),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    final categoriesNotifier = ref.watch(categoriesProvider.notifier);
    final linksNotifier = ref.watch(linksProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Set the current category ID filter
          ref.read(currentCategoryIdProvider.notifier).state = category.id;

          // Load links for this category
          linksNotifier.loadLinksByCategory(category.id!);

          // Switch to links tab (parent widget will handle this)
          ref.read(currentCategoryIdProvider.notifier).state = category.id;
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Hero(
              tag: 'category_icon_${category.id}',
              child: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                child: Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            title: Hero(
              tag: 'categoryTitle${category.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            subtitle: Text(
              'Created: ${_formatDateTime(category.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    DialogsRiverpod.showEditCategoryDialog(context, category);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.withOpacity(0.8),
                  onPressed: () async {
                    final shouldDelete =
                        await DialogsRiverpod.showDeleteConfirmDialog(
                          context,
                          'category',
                        );
                    if (shouldDelete && context.mounted) {
                      categoriesNotifier.deleteCategory(category);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
