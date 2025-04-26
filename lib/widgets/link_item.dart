import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/link.dart';
import '../providers/providers.dart';
import '../utils/dialogs_riverpod.dart';
import '../services/share_service.dart';

class LinkItem extends ConsumerWidget {
  final Link link;

  const LinkItem({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the category name for this link
    final category = ref.watch(categoryByIdProvider(link.categoryId));
    final linksNotifier = ref.watch(linksProvider.notifier);

    String categoryName = 'Uncategorized';
    if (link.categoryId != 0 && category != null) {
      categoryName = category.name;
    } else if (link.categoryId != 0) {
      categoryName = 'Unknown Category';
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _shareLink(context);
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
          SlidableAction(
            onPressed: (context) async {
              final shouldDelete =
                  await DialogsRiverpod.showDeleteConfirmDialog(
                    context,
                    'link',
                  );

              if (shouldDelete && context.mounted) {
                linksNotifier.deleteLink(link);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _launchUrl(context, link.url),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Hero(
                tag: 'link_icon_${link.id}',
                child: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.link,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              title: Hero(
                tag: 'link_title_${link.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    link.title ?? _formatUrl(link.url),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    link.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(link.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    String normalizedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      normalizedUrl = 'https://$url';
    }

    final Uri uri = Uri.parse(normalizedUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open: $url'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareLink(BuildContext context) async {
    await ShareService.shareLink(
      link.url,
      title: link.title ?? _formatUrl(link.url),
    );
  }

  String _formatUrl(String url) {
    // Remove http/https prefix for display
    String formatted = url.replaceAll(RegExp(r'https?://'), '');
    // Remove trailing slash
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today, ${DateFormat.jm().format(dateTime)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(dateTime)}';
    } else {
      return DateFormat.yMMMd().format(dateTime);
    }
  }
}
