import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/group.dart';
import '../providers/group_providers.dart'; // Assuming this exports groupNotifierProvider

class AddGroupDialog extends ConsumerStatefulWidget {
  const AddGroupDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends ConsumerState<AddGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Color _selectedColor = Colors.blue; // Default color

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _changeColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final groupName = _nameController.text;

      // Check for unique group name (optional, service might handle it)
      // final existingGroup = await ref.read(groupNotifierProvider.notifier).getGroupByName(groupName);
      // if (existingGroup != null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Group "$groupName" already exists.')),
      //   );
      //   return;
      // }

      final newGroup = Group(
        name: groupName,
        color: _selectedColor.value, // Store ARGB value
      );

      try {
        await ref.read(groupNotifierProvider.notifier).addGroup(newGroup);
        // Potentially return the new group or its name if the calling dialog needs it
        Navigator.of(context).pop(newGroup);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Group'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name *',
                  hintText: 'Enter group name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  // Potentially add check for existing group name here or rely on service
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Select Group Color:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              // Simple Block Color Picker
              BlockPicker(
                pickerColor: _selectedColor,
                onColorChanged: _changeColor,
                availableColors: const [
                  Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
                  Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
                  Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
                  Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
                  Colors.brown, Colors.grey, Colors.blueGrey,
                ],
              ),
              // For more options, one could use:
              // ColorPicker(
              //   pickerColor: _selectedColor,
              //   onColorChanged: _changeColor,
              //   showLabel: true,
              //   pickerAreaHeightPercent: 0.8,
              // ),
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
          child: const Text('Add Group'),
        ),
      ],
    );
  }
}

// Helper to show the dialog
Future<Group?> showAddGroupDialog(BuildContext context) {
  return showDialog<Group>(
    context: context,
    builder: (BuildContext context) {
      return const AddGroupDialog();
    },
  );
}
