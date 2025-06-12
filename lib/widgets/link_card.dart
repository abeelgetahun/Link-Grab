import 'package:flutter/material.dart';
import '../models/link.dart'; // Assuming Link model is in lib/models/link.dart
// Import the new edit link dialog helper if actions are directly handled here
// For now, assume onMoreOptions callback will handle showing dialogs from the parent widget (e.g. HomeScreen)
// import '../dialogs/edit_link_dialog.dart';


class LinkCard extends StatelessWidget {
  final Link link;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onTap;
  // Specific callbacks for edit and delete
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;


  const LinkCard({
    Key? key,
    required this.link,
    this.onToggleFavorite,
    this.onTap,
    this.onEdit,
    this.onDelete,
    // Remove generic onMoreOptions if specific actions are preferred
    // this.onMoreOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Placeholder for Favicon
                  const Icon(Icons.link, size: 20.0, color: Colors.grey),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      link.title ?? 'No Title',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      link.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: link.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onToggleFavorite,
                    tooltip: 'Toggle Favorite',
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                      // Add other options if needed
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(leading: Icon(Icons.delete), title: Text('Delete')),
                      ),
                    ],
                    tooltip: 'More Options',
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                link.url,
                style: TextStyle(color: Colors.grey[700], fontSize: 12.0),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              if (link.description != null && link.description!.isNotEmpty) ...[
                Text(
                  link.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
              ],
              if (link.group != null && link.group!.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Chip(
                    label: Text(link.group!),
                    padding: EdgeInsets.zero,
                    labelStyle: const TextStyle(fontSize: 10.0),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
