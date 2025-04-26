import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/category.dart';

class DialogsRiverpod {
  static Future<void> showAddLinkDialog(
    BuildContext context,
    String initialUrl,
  ) async {
    final formKey = GlobalKey<FormState>();
    final urlController = TextEditingController(text: initialUrl);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    int? selectedCategoryId;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Link Dialog',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // Dummy container, not used
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.5,
              end: 1.0,
            ).animate(curvedAnimation),
            child: Consumer(
              builder: (context, ref, _) {
                final categoriesAsync = ref.watch(categoriesProvider);

                return AlertDialog(
                  title: const Text('Add Link'),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: urlController,
                            decoration: const InputDecoration(
                              labelText: 'URL *',
                              hintText: 'https://example.com',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a URL';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description (optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          categoriesAsync.when(
                            data: (categories) {
                              if (categories.isEmpty) {
                                return const Text('No categories available');
                              }

                              return DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Category *',
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedCategoryId,
                                items:
                                    categories.map((category) {
                                      return DropdownMenuItem<int>(
                                        value: category.id,
                                        child: Text(category.name),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  selectedCategoryId = value;
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a category';
                                  }
                                  return null;
                                },
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error:
                                (_, __) =>
                                    const Text('Failed to load categories'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('CANCEL'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate() &&
                            selectedCategoryId != null) {
                          // Add the link
                          ref
                              .read(linksProvider.notifier)
                              .addLink(
                                urlController.text,
                                selectedCategoryId!,
                                title:
                                    titleController.text.isNotEmpty
                                        ? titleController.text
                                        : null,
                                description:
                                    descriptionController.text.isNotEmpty
                                        ? descriptionController.text
                                        : null,
                              );
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('SAVE'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Future<void> showAddCategoryDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Category Dialog',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // Dummy container, not used
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.5,
              end: 1.0,
            ).animate(curvedAnimation),
            child: Consumer(
              builder: (context, ref, _) {
                return AlertDialog(
                  title: const Text('Add Category'),
                  content: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('CANCEL'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Add the category
                          ref
                              .read(categoriesProvider.notifier)
                              .addCategory(nameController.text);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('SAVE'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Future<bool> showDeleteConfirmDialog(
    BuildContext context,
    String itemType,
  ) async {
    bool result = false;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete Confirmation Dialog',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // Dummy container, not used
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.5,
              end: 1.0,
            ).animate(curvedAnimation),
            child: AlertDialog(
              title: Text('Delete $itemType?'),
              content: Text(
                'Are you sure you want to delete this $itemType? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () {
                    result = true;
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ),
        );
      },
    );

    return result;
  }

  static Future<void> showEditCategoryDialog(
    BuildContext context,
    Category category,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category.name);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Category Dialog',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // Dummy container, not used
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.5,
              end: 1.0,
            ).animate(curvedAnimation),
            child: Consumer(
              builder: (context, ref, _) {
                return AlertDialog(
                  title: const Text('Edit Category'),
                  content: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('CANCEL'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Update the category
                          final updatedCategory = Category(
                            id: category.id,
                            name: nameController.text,
                            createdAt: category.createdAt,
                          );
                          ref
                              .read(categoriesProvider.notifier)
                              .updateCategory(updatedCategory);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('UPDATE'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
