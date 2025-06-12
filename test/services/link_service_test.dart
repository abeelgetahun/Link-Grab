import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:link_grab/models/link.dart'; // Adjust path
import 'package:link_grab/services/hive_service.dart'; // Adjust path
import 'hive_service_mocks.dart'; // Manual mocks

// Helper to initialize Hive for testing if needed.
// This is tricky because it might use the real file system.
// For true unit tests, Hive itself should be abstracted or not used directly by services.
Future<void> _ensureHiveInitialized() async {
  // A proper test setup would use a temporary directory for Hive.
  // For now, this is a placeholder or relies on Hive being in-memory if possible for tests.
  // Hive.initFlutter("test_hive_data"); // Example, might need path_provider_ffi for tests
}

void main() {
  // Due to the static nature of Hive access in HiveService, these tests are more
  // like integration tests for the service layer or will require a test Hive setup.
  // We will use our manual MockBox for direct injection if we were to refactor service,
  // but since we are not, we are testing the actual service.

  // It's CRITICAL that for real test execution, Hive is initialized in a way
  // that does not interfere with development data (e.g., custom path, in-memory).
  // The following setup is conceptual for running these tests.

  setUpAll(() async {
    // This is a placeholder. A real test setup for Hive is complex.
    // Option 1: Use Hive Fakes or an in-memory implementation if available.
    // Option 2: Initialize Hive with a specific test path.
    // For now, we assume that either the service methods are robust enough
    // to be tested with mock boxes (if service was refactored) or that
    // a global Hive test setup is handled externally for these tests to run.
    // If LinkService directly calls Hive.openBox, we can't easily inject a MockBox
    // without refactoring LinkService.

    // The provided HiveService uses Hive.isBoxOpen and Hive.openBox internally.
    // To "mock" this for these tests without refactoring the service,
    // we would need to use a testing utility that can override static/global Hive behavior,
    // or ensure Hive is initialized in a test-safe way.
    // The current tests will instantiate the actual service.
  });

  tearDownAll(() async {
    // await Hive.deleteFromDisk(); // Clean up test Hive data
  });

  // Test Link class for basic functionality (not service, but good to have)
  group('Link Model', () {
    test('Link object can be created', () {
      final link = Link(
        id: '1',
        url: 'https://example.com',
        title: 'Example',
        createdAt: DateTime.now(),
      );
      expect(link.id, '1');
      expect(link.url, 'https://example.com');
    });
  });


  group('LinkService', () {
    late LinkService linkService;
    // This is where we'd ideally inject a MockLinkBox if LinkService was refactored.
    // Since it's not, these tests will use the actual Hive static methods called by LinkService.
    // This makes them more like integration tests for the service.
    // For a true unit test, you'd pass a MockBox<Link> to the LinkService constructor.

    // For a slightly better approach without full refactor, one could try to
    // "globally" replace Hive.openBox for the duration of tests, but this is hacky.
    // The most straightforward way given the current service structure is to
    // test it as is, understanding it's not a pure unit test.

    setUp(() async {
      // Before each test, we could try to ensure a clean state for the 'linksBox'.
      // This is complex with static Hive.
      // If we had a way to provide a box instance to the service:
      // mockLinkBox = MockLinkBox();
      // linkService = LinkService(box: mockLinkBox); // Assuming refactor

      linkService = LinkService(); // Uses static Hive calls

      // Clear the box before each test for isolation (CONCEPTUAL - needs real Hive setup)
      // This assumes 'linksBox' can be opened and cleared.
      try {
        if (!Hive.isBoxOpen('linksBox')) {
          await Hive.openBox<Link>('linksBox');
        }
        final box = Hive.box<Link>('linksBox');
        await box.clear(); // Clear content for test isolation
      } catch (e) {
        // print("Test setup warning: Could not clear linksBox. Tests might interfere. Error: $e");
        // This highlights the difficulty of testing Hive-dependent static calls.
      }
    });

    test('addLink should add a link to the box', () async {
      // This test requires Hive to be initialized and the box to be openable.
      // It's an integration test due to direct Hive dependency.
      final link = Link(id: 'id1', url: 'http://test.com', title: 'Test', createdAt: DateTime.now());

      await linkService.addLink(link);

      final box = Hive.box<Link>('linksBox'); // Re-fetch box to check content
      final retrievedLink = box.get('id1');
      expect(retrievedLink, isNotNull);
      expect(retrievedLink?.url, 'http://test.com');
      // Note: This test will fail if Hive is not properly initialized for the test environment.
    });

    test('getAllLinks should return all links from the box', () async {
      final link1 = Link(id: 'id1', url: 'http://test1.com', createdAt: DateTime.now());
      final link2 = Link(id: 'id2', url: 'http://test2.com', createdAt: DateTime.now());

      // Assuming 'linksBox' is cleared in setUp or this is the first test for it
      final box = Hive.box<Link>('linksBox');
      await box.put(link1.id, link1);
      await box.put(link2.id, link2);

      final links = await linkService.getAllLinks();

      expect(links.length, 2);
      expect(links.any((l) => l.id == 'id1'), isTrue);
      expect(links.any((l) => l.id == 'id2'), isTrue);
    });

    test('getFavoriteLinks should return only favorite links', () async {
      final link1 = Link(id: 'fav1', url: 'http://fav1.com', isFavorite: true, createdAt: DateTime.now());
      final link2 = Link(id: 'normal1', url: 'http://normal1.com', isFavorite: false, createdAt: DateTime.now());
      final link3 = Link(id: 'fav2', url: 'http://fav2.com', isFavorite: true, createdAt: DateTime.now());

      final box = Hive.box<Link>('linksBox');
      await box.put(link1.id, link1);
      await box.put(link2.id, link2);
      await box.put(link3.id, link3);

      final favoriteLinks = await linkService.getFavoriteLinks();

      expect(favoriteLinks.length, 2);
      expect(favoriteLinks.every((link) => link.isFavorite), isTrue);
      expect(favoriteLinks.any((l) => l.id == 'fav1'), isTrue);
      expect(favoriteLinks.any((l) => l.id == 'fav2'), isTrue);
    });

    test('updateLink should update an existing link in the box', () async {
      final originalLink = Link(id: 'upd1', url: 'http://original.com', title: 'Original', createdAt: DateTime.now());
      final box = Hive.box<Link>('linksBox');
      await box.put(originalLink.id, originalLink);

      final updatedLink = Link(
        id: 'upd1',
        url: 'http://updated.com',
        title: 'Updated',
        isFavorite: true,
        createdAt: originalLink.createdAt
      );
      await linkService.updateLink(updatedLink);

      final retrievedLink = box.get('upd1');
      expect(retrievedLink, isNotNull);
      expect(retrievedLink?.url, 'http://updated.com');
      expect(retrievedLink?.title, 'Updated');
      expect(retrievedLink?.isFavorite, true);
    });

    test('deleteLink should remove a link from the box', () async {
      final linkToDelete = Link(id: 'del1', url: 'http://delete.me', createdAt: DateTime.now());
      final box = Hive.box<Link>('linksBox');
      await box.put(linkToDelete.id, linkToDelete);

      // Ensure it's there
      expect(box.get('del1'), isNotNull);

      await linkService.deleteLink('del1');

      expect(box.get('del1'), isNull);
    });

    // Test for getLinksByGroup
    test('getLinksByGroup should return links matching the group name', () async {
      final link1 = Link(id: 'g1l1', url: 'url1', group: 'Tech', createdAt: DateTime.now());
      final link2 = Link(id: 'g2l1', url: 'url2', group: 'News', createdAt: DateTime.now());
      final link3 = Link(id: 'g1l2', url: 'url3', group: 'Tech', createdAt: DateTime.now());

      final box = Hive.box<Link>('linksBox');
      await box.put(link1.id, link1);
      await box.put(link2.id, link2);
      await box.put(link3.id, link3);

      final techLinks = await linkService.getLinksByGroup('Tech');
      expect(techLinks.length, 2);
      expect(techLinks.every((link) => link.group == 'Tech'), isTrue);

      final newsLinks = await linkService.getLinksByGroup('News');
      expect(newsLinks.length, 1);
      expect(newsLinks.first.id, 'g2l1');

      final otherLinks = await linkService.getLinksByGroup('Other');
      expect(otherLinks.isEmpty, isTrue);
    });

    // Test for getRecentLinks
    test('getRecentLinks should return links sorted by createdAt descending', () async {
      final now = DateTime.now();
      final link1 = Link(id: 'recent1', url: 'url1', createdAt: now.subtract(const Duration(days: 1)));
      final link2 = Link(id: 'recent2', url: 'url2', createdAt: now); // Most recent
      final link3 = Link(id: 'recent3', url: 'url3', createdAt: now.subtract(const Duration(hours: 1)));

      final box = Hive.box<Link>('linksBox');
      await box.put(link1.id, link1);
      await box.put(link2.id, link2);
      await box.put(link3.id, link3);

      // Test default count (20)
      var recentLinks = await linkService.getRecentLinks();
      expect(recentLinks.length, 3); // All links if less than count
      expect(recentLinks[0].id, 'recent2');
      expect(recentLinks[1].id, 'recent3');
      expect(recentLinks[2].id, 'recent1');

      // Test with specific count
      recentLinks = await linkService.getRecentLinks(count: 2);
      expect(recentLinks.length, 2);
      expect(recentLinks[0].id, 'recent2');
      expect(recentLinks[1].id, 'recent3');
    });

  });
}

// Note: For these tests to run reliably:
// 1. A proper Hive test initialization is needed (e.g., using a specific test path
//    or an in-memory adapter if Hive supports one for unit tests).
// 2. `Hive.initFlutter()` needs to be called, and TypeAdapters for Link, Group, Settings
//    would need to be registered. This is problematic because the `.g.dart` files
//    containing these adapters cannot be generated in the current environment.
//
// The tests are written to show intent but will likely fail to execute correctly
// without the generated adapters and a proper Hive test setup.
// The core issue remains the inability to run `build_runner` for Hive model adapters
// and the `flutter pub get` failures for test tools like Mockito.
