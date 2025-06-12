import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/link.dart';
import '../models/group.dart';
import '../providers/link_providers.dart';
import '../providers/group_providers.dart';
import 'add_group_dialog.dart'; // For "Add New Group" functionality

class EditLinkDialog extends ConsumerStatefulWidget {
  final Link linkToEdit;

  const EditLinkDialog({Key? key, required this.linkToEdit}) : super(key: key);

  @override
  ConsumerState<EditLinkDialog> createState() => _EditLinkDialogState();
}

class _EditLinkDialogState extends ConsumerState<EditLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedGroupId;
  bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.linkToEdit.url);
    _titleController = TextEditingController(text: widget.linkToEdit.title ?? '');
    _descriptionController = TextEditingController(text: widget.linkToEdit.description ?? '');
    _selectedGroupId = widget.linkToEdit.group;
    _isFavorite = widget.linkToEdit.isFavorite;
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
      final updatedLink = Link(
        id: widget.linkToEdit.id, // Keep original ID
        url: _urlController.text,
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        group: _selectedGroupId,
        isFavorite: _isFavorite,
        createdAt: widget.linkToEdit.createdAt, // Keep original creation date
      );

      try {
        await ref.read(linksNotifierProvider.notifier).updateLink(updatedLink);
        Navigator.of(context).pop(true); // Indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update link: $e')),
        );
      }
    }
  }

  void _showAddGroupDialogAndHandleResult() async {
    final newGroup = await showAddGroupDialog(context);
    if (newGroup != null) {
      setState(() {
        _selectedGroupId = newGroup.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "${newGroup.name}" added and selected.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsyncValue = ref.watch(groupsProvider);

    return AlertDialog(
      title: const Text('Edit Link'),
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
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No Group'),
                      ),
                      ...groups.map<DropdownMenuItem<String>>((Group group) {
                        return DropdownMenuItem<String>(
                          value: group.name,
                          child: Text(group.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGroupId = newValue;
                      });
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
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Favorite'),
                value: _isFavorite,
                onChanged: (bool value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
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
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

// Helper to show the dialog
Future<bool?> showEditLinkDialog(BuildContext context, {required Link linkToEdit}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return EditLinkDialog(linkToEdit: linkToEdit);
    },
  );
}
