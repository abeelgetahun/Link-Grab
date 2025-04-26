import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/providers.dart';
import '../utils/dialogs_riverpod.dart';
import 'link_item.dart';

class LinkList extends ConsumerWidget {
  const LinkList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(linksProvider);
    final categoryId = ref.watch(currentCategoryIdProvider);

    // Get filtered links using the filteredLinks provider
    final links = ref.watch(filteredLinksProvider);

    return linksAsync.when(
      data: (_) => _buildContent(context, ref, links, categoryId),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading links: ${error.toString()}')),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> links,
    int? categoryId,
  ) {
    // Get category name if filtering by category
    String headerText = 'All Links';
    if (categoryId != null) {
      final category = ref.watch(categoryByIdProvider(categoryId));
      if (category != null) {
        headerText = category.name;
      } else {
        headerText = 'Filtered Links';
      }
    }

    if (links.isEmpty) {
      return AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 400),
        child: FadeInAnimation(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.link_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No links yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                categoryId != null
                    ? ElevatedButton(
                      onPressed: () {
                        ref.read(currentCategoryIdProvider.notifier).state =
                            null;
                        ref.read(linksProvider.notifier).loadAllLinks();
                      },
                      child: const Text('Show All Links'),
                    )
                    : ElevatedButton(
                      onPressed: () {
                        DialogsRiverpod.showAddLinkDialog(context, '');
                      },
                      child: const Text('Add Link'),
                    ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Category header with animation
        AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 300),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Hero(
                      tag: 'categoryTitle${categoryId ?? 0}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          headerText,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    if (categoryId != null)
                      TextButton.icon(
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Filter'),
                        onPressed: () {
                          ref.read(currentCategoryIdProvider.notifier).state =
                              null;
                          ref.read(linksProvider.notifier).loadAllLinks();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Links list with staggered animations
        Expanded(
          child: AnimationLimiter(
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
          ),
        ),
      ],
    );
  }
}
