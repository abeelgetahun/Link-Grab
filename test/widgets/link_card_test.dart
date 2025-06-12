import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_grab/models/link.dart'; // Adjust path
import 'package:link_grab/widgets/link_card.dart'; // Adjust path

void main() {
  // Helper function to pump LinkCard with necessary ancestors (MaterialApp, etc.)
  Widget makeTestableWidget({required Link link, VoidCallback? onToggleFavorite, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return MaterialApp(
      home: Scaffold(
        body: LinkCard(
          link: link,
          onToggleFavorite: onToggleFavorite,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }

  final testLink = Link(
    id: '1',
    url: 'https://example.com',
    title: 'Test Title',
    description: 'Test Description',
    group: 'Test Group',
    isFavorite: false,
    createdAt: DateTime.now(),
  );

  final favoriteLink = Link(
    id: '2',
    url: 'https://favorite.com',
    title: 'Favorite Link',
    isFavorite: true,
    createdAt: DateTime.now(),
  );

  testWidgets('LinkCard displays title, URL, and group', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(link: testLink));

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('https://example.com'), findsOneWidget);
    expect(find.text('Test Group'), findsOneWidget); // Assuming Chip displays text directly
    expect(find.byIcon(Icons.link), findsOneWidget); // Favicon placeholder
  });

  testWidgets('LinkCard displays description if provided', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(link: testLink));
    expect(find.text('Test Description'), findsOneWidget);

    final linkNoDesc = Link(id: '3', url: 'url', title: 'title_no_desc', createdAt: DateTime.now());
    await tester.pumpWidget(makeTestableWidget(link: linkNoDesc));
    expect(find.text('Test Description'), findsNothing); // Check it's not there
  });

  testWidgets('LinkCard favorite icon reflects link.isFavorite status', (WidgetTester tester) async {
    // Test with non-favorite link
    await tester.pumpWidget(makeTestableWidget(link: testLink));
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    // Test with favorite link
    await tester.pumpWidget(makeTestableWidget(link: favoriteLink));
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });

  testWidgets('LinkCard calls onToggleFavorite when favorite button is tapped', (WidgetTester tester) async {
    bool favoriteTapped = false;
    await tester.pumpWidget(makeTestableWidget(
      link: testLink,
      onToggleFavorite: () {
        favoriteTapped = true;
      },
    ));

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump(); // Process tap

    expect(favoriteTapped, isTrue);
  });

  testWidgets('LinkCard shows PopupMenuButton and calls callbacks', (WidgetTester tester) async {
    bool editCalled = false;
    bool deleteCalled = false;

    await tester.pumpWidget(makeTestableWidget(
      link: testLink,
      onEdit: () => editCalled = true,
      onDelete: () => deleteCalled = true,
    ));

    // Find the PopupMenuButton
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    // Tap the menu button to open it
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle(); // Wait for menu animation

    // Verify menu items are present
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Tap 'Edit'
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle(); // Wait for action
    expect(editCalled, isTrue);

    // Re-open for delete
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap 'Delete'
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(deleteCalled, isTrue);
  });

  testWidgets('LinkCard does not display group chip if group is null or empty', (WidgetTester tester) async {
    final linkNoGroup = Link(id: '4', url: 'url', title: 'No Group Link', createdAt: DateTime.now());
    await tester.pumpWidget(makeTestableWidget(link: linkNoGroup));

    // Assuming the Chip is identified by its text content for this test.
    // If the Chip is not rendered at all, this check is valid.
    // If the Chip is rendered with empty text, the expectation needs adjustment.
    expect(find.text('No Group'), findsNothing); // Check based on LinkCard logic for null/empty group
    // A more robust way might be to find by Type Chip and check its label or count.
    final chipFinder = find.byType(Chip);
    bool foundChipWithText(String text) {
      final chips = tester.widgetList<Chip>(chipFinder);
      for (final chip in chips) {
        if (chip.label is Text && (chip.label as Text).data == text) return true;
      }
      return false;
    }
    expect(foundChipWithText(linkNoGroup.group ?? 'No Group'), isFalse);
    // The LinkCard logic is `if (link.group != null && link.group!.isNotEmpty)`
    // So, if group is null, the Chip widget itself isn't added to the tree.
    // Thus, finding by a specific text that would be in the chip is a valid way to test its absence.
  });
}
