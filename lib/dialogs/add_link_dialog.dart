import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart'; // UUID package not available
import '../models/link.dart';
import '../models/group.dart';
import '../providers/link_providers.dart'; // Assuming this exports linksNotifierProvider
import '../providers/group_providers.dart'; // Assuming this exports groupNotifierProvider and groupsProvider
import 'add_group_dialog.dart'; // Import the AddGroupDialog

// var _uuid = Uuid(); // UUID package not available

class AddLinkDialog extends ConsumerStatefulWidget {
  final String? initialUrl;

  const AddLinkDialog({Key? key, this.initialUrl}) : super(key: key);

  @override
  ConsumerState<AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends ConsumerState<AddLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedGroupId; // Store group NAME as ID for now, as per GroupService

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newLink = Link(
        // Fallback ID generation
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + (_urlController.text.hashCode % 10000).toString(),
        url: _urlController.text,
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        group: _selectedGroupId, // Name of the group
        isFavorite: false, // Default
        createdAt: DateTime.now(),
      );

      try {
        await ref.read(linksNotifierProvider.notifier).addLink(
          url: newLink.url,
          title: newLink.title,
          group: newLink.group,
          description: newLink.description,
          isFavorite: newLink.isFavorite,
          // createdAt is handled by addLink method in notifier
        );
        Navigator.of(context).pop(true); // Indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add link: $e')),
        );
      }
    }
  }

  void _showAddGroupDialogAndHandleResult() async {
    final newGroup = await showAddGroupDialog(context); // Uses the helper

    if (newGroup != null) {
      // GroupNotifier should automatically update the list of groups,
      // so the DropdownButtonFormField in this dialog should rebuild with the new group.
      // We might need to explicitly refresh if the provider setup doesn't auto-update consumers immediately
      // or if `groupsProvider` doesn't reflect the change fast enough.
      // For now, assume GroupNotifier updates and groupsProvider reflects it.
      // ref.read(groupNotifierProvider.notifier).refreshGroups(); // Potentially redundant

      setState(() {
        // Select the newly added group
        _selectedGroupId = newGroup.name;
      });
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "${newGroup.name}" added and selected.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsyncValue = ref.watch(groupsProvider); // Watching the simple list provider

    return AlertDialog(
      title: const Text('Add New Link'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL *',
                  hintText: 'https://example.com',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  if (!Uri.tryParse(value)?.hasAbsolutePath ?? true) {
                     return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              groupsAsyncValue.when(
                data: (groups) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Group (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedGroupId,
                    hint: const Text('Select a group'),
                    isExpanded: true,
                    items: [
                      // Option for no group
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No Group'),
                      ),
                      // Actual groups
                      ...groups.map<DropdownMenuItem<String>>((Group group) {
                        return DropdownMenuItem<String>(
                          value: group.name, // Using name as ID for selection
                          child: Text(group.name),
                        );
                      }).toList(),
                      // Option to add new group
                      // DropdownMenuItem<String>(
                      //   value: '_ADD_NEW_GROUP_', // Special value
                      //   child: Text('+ Add New Group'),
                      // ),
                    ],
                    onChanged: (String? newValue) {
                      // if (newValue == '_ADD_NEW_GROUP_') {
                      //   _showAddGroupDialog();
                      // } else {
                        setState(() {
                          _selectedGroupId = newValue;
                        });
                      // }
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading groups: $err'),
              ),
               TextButton(
                onPressed: _showAddGroupDialogAndHandleResult,
                child: const Text('Or Add New Group...'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitForm,
          child: const Text('Add Link'),
        ),
      ],
    );
  }
}

// Helper to show the dialog
Future<bool?> showAddLinkDialog(BuildContext context, {String? initialUrl}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AddLinkDialog(initialUrl: initialUrl);
    },
  );
}
