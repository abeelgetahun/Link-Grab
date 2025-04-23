import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/database.dart';
import 'models/category.dart';
import 'models/link.dart';
import 'providers/category_provider.dart';
import 'providers/link_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'services/category_repository.dart';
import 'services/link_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  AppDatabase? database;

  // Create mock repositories for web
  late CategoryRepository categoryRepository;
  late LinkRepository linkRepository;

  if (kIsWeb) {
    // For web, we'll use a simpler approach without actual database
    // since we're having issues with SQLite on web
    print('Running in web mode - using mock repositories');

    // Web storage or mock implementation would go here
    categoryRepository = MockCategoryRepository();
    linkRepository = MockLinkRepository();
  } else {
    // For mobile platforms, use the Floor database
    database = await AppDatabase.getInstance();
    categoryRepository = CategoryRepository(database!);
    linkRepository = LinkRepository(database!);
  }

  // Check if the user has seen the onboarding
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        Provider<CategoryRepository>(create: (_) => categoryRepository),
        Provider<LinkRepository>(create: (_) => linkRepository),
        ChangeNotifierProvider(
          create:
              (context) => CategoryProvider(
                Provider.of<CategoryRepository>(context, listen: false),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => LinkProvider(
                Provider.of<LinkRepository>(context, listen: false),
              ),
        ),
      ],
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Grab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: seenOnboarding ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}

// Mock implementation for web demo
class MockCategoryRepository implements CategoryRepository {
  final List<Category> _categories = [];
  int _nextId = 1;

  @override
  Future<List<Category>> getAllCategories() async {
    // Return demo categories if empty
    if (_categories.isEmpty) {
      _categories.add(Category(id: _nextId++, name: 'Work'));
      _categories.add(Category(id: _nextId++, name: 'Personal'));
      _categories.add(Category(id: _nextId++, name: 'Learning'));
    }
    return _categories;
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> insertCategory(Category category) async {
    final newCategory = Category(
      id: _nextId++,
      name: category.name,
      createdAt: category.createdAt,
    );
    _categories.add(newCategory);
    return newCategory.id!;
  }

  @override
  Future<int> updateCategory(Category category) async {
    final index = _categories.indexWhere((cat) => cat.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteCategory(Category category) async {
    final initialLength = _categories.length;
    _categories.removeWhere((cat) => cat.id == category.id);
    return initialLength - _categories.length;
  }
}

class MockLinkRepository implements LinkRepository {
  final List<Link> _links = [];
  int _nextId = 1;

  @override
  Future<List<Link>> getAllLinks() async {
    // Return demo links if empty
    if (_links.isEmpty) {
      _links.add(
        Link(
          id: _nextId++,
          url: 'https://flutter.dev',
          title: 'Flutter Website',
          description: 'Official Flutter website',
          categoryId: 3,
        ),
      );
      _links.add(
        Link(
          id: _nextId++,
          url: 'https://github.com',
          title: 'GitHub',
          description: 'Code hosting platform',
          categoryId: 1,
        ),
      );
    }
    return _links;
  }

  @override
  Future<List<Link>> getLinksByCategoryId(int categoryId) async {
    await getAllLinks(); // Ensure we have some demo links
    return _links.where((link) => link.categoryId == categoryId).toList();
  }

  @override
  Future<Link?> getLinkById(int id) async {
    try {
      return _links.firstWhere((link) => link.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Link>> searchLinks(String query) async {
    await getAllLinks(); // Ensure we have some demo links
    return _links
        .where(
          (link) =>
              link.url.toLowerCase().contains(query.toLowerCase()) ||
              (link.title?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (link.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  @override
  Future<int> insertLink(Link link) async {
    final newLink = Link(
      id: _nextId++,
      url: link.url,
      title: link.title,
      description: link.description,
      imageUrl: link.imageUrl,
      sourceApp: link.sourceApp,
      categoryId: link.categoryId,
      createdAt: link.createdAt,
    );
    _links.add(newLink);
    return newLink.id!;
  }

  @override
  Future<int> updateLink(Link link) async {
    final index = _links.indexWhere((l) => l.id == link.id);
    if (index != -1) {
      _links[index] = link;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteLink(Link link) async {
    final initialLength = _links.length;
    _links.removeWhere((l) => l.id == link.id);
    return initialLength - _links.length;
  }
}
