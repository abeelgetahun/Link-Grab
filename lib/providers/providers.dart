// This file is now primarily for re-exporting providers from other files
// and defining any simple, globally used providers that don't require their own file.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Export new Riverpod generated providers
export 'link_providers.dart';
export 'group_providers.dart';
export 'settings_providers.dart';

// Example of a simple global provider, if needed.
// For instance, if searchQueryProvider is still used globally and not managed within LinksNotifier directly.
// final searchQueryProvider = StateProvider<String>((ref) => '');
// However, it's often better to manage such state within the relevant notifier (e.g., LinksNotifier)
// and expose it via a getter or allow methods to set it (like setSearchQuery in LinksNotifier).
// For now, assuming LinksNotifier's setSearchQuery and searchQuery getter are sufficient.

// Old providers are removed as their functionality is replaced by the new Hive-based services
// and Riverpod generated notifiers in their respective files.

// Removed old categoryRepositoryProvider
// Removed old linkRepositoryProvider
// Removed old categoriesProvider
// Removed old linksProvider (manual StateNotifierProvider)
// Removed old currentCategoryIdProvider
// Removed old filteredLinksProvider (manual one)
// Removed old categoryByIdProvider
// Removed old LinksNotifier class (manual StateNotifier)
// Removed old CategoriesNotifier class (manual StateNotifier)
