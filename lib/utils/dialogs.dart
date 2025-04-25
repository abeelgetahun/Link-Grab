import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/link_provider.dart';
import '../models/category.dart' as models;
import '../models/link.dart';

class Dialogs {
  // Show dialog to add a new category
  static Future<void> showAddCategoryDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Category'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).addCategory(controller.text);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  // Show dialog to edit a category
  static Future<void> showEditCategoryDialog(
    BuildContext context,
    models.Category category,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: category.name,
    );

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Category'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    final updatedCategory = models.Category(
                      id: category.id,
                      name: controller.text,
                      createdAt: category.createdAt,
                    );
                    Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).updateCategory(updatedCategory);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  // Show dialog to add a new link
  static Future<void> showAddLinkDialog(
    BuildContext context,
    String initialUrl,
  ) async {
    final TextEditingController urlController = TextEditingController(
      text: initialUrl,
    );
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    // Default to uncategorized
    int? selectedCategoryId;

    return showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add Link'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: urlController,
                        decoration: const InputDecoration(
                          labelText: 'URL',
                          hintText: 'Enter URL',
                        ),
                        autofocus: initialUrl.isEmpty,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title (Optional)',
                          hintText: 'Enter title',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter description',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, child) {
                          if (categoryProvider.categories.isEmpty) {
                            return Row(
                              children: [
                                const Text('No categories yet. '),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showAddCategoryDialog(context).then((_) {
                                      if (urlController.text.isNotEmpty) {
                                        showAddLinkDialog(
                                          context,
                                          urlController.text,
                                        );
                                      }
                                    });
                                  },
                                  child: const Text('Create One'),
                                ),
                              ],
                            );
                          }

                          List<DropdownMenuItem<int>> dropdownItems = [];
                          for (var category in categoryProvider.categories) {
                            if (category.id != null) {
                              dropdownItems.add(
                                DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              );
                            }
                          }

                          return DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            value: selectedCategoryId,
                            hint: const Text('Select a Category'),
                            items: dropdownItems,
                            onChanged: (value) {
                              setState(() {
                                selectedCategoryId = value;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (urlController.text.isNotEmpty &&
                          selectedCategoryId != null) {
                        Provider.of<LinkProvider>(
                          context,
                          listen: false,
                        ).addLink(
                          urlController.text,
                          selectedCategoryId!,
                          title:
                              titleController.text.isEmpty
                                  ? null
                                  : titleController.text,
                          description:
                              descController.text.isEmpty
                                  ? null
                                  : descController.text,
                        );
                        Navigator.of(context).pop();
                      } else if (urlController.text.isNotEmpty &&
                          selectedCategoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a category'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('URL is required')),
                        );
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Show dialog to confirm deletion
  static Future<bool> showDeleteConfirmDialog(
    BuildContext context,
    String itemType,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Delete $itemType'),
                content: Text(
                  'Are you sure you want to delete this $itemType?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
