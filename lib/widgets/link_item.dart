import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/link.dart';
import '../providers/link_provider.dart';
import '../providers/category_provider.dart';
import '../utils/dialogs.dart';
import '../services/share_service.dart';

class LinkItem extends StatelessWidget {
  final Link link;

  const LinkItem({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the category name for this link
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final linkProvider = Provider.of<LinkProvider>(context, listen: false);

    String categoryName = 'Uncategorized';
    if (link.categoryId != 0) {
      try {
        final category = categoryProvider.categories.firstWhere(
          (cat) => cat.id == link.categoryId,
        );
        categoryName = category.name;
      } catch (e) {
        // Category might have been deleted
        categoryName = 'Unknown Category';
      }
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
              final shouldDelete = await Dialogs.showDeleteConfirmDialog(
                context,
                'link',
              );

              if (shouldDelete && context.mounted) {
                linkProvider.deleteLink(link);
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
        leading: const CircleAvatar(child: Icon(Icons.link)),
        title: Text(
          link.title ?? _formatUrl(link.url),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              link.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    categoryName,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(link.createdAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _launchUrl(context, link.url),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open: $url')));
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
