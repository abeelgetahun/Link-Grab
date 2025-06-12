import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:link_grab/models/group.dart'; // Adjust path
import 'package:link_grab/models/link.dart'; // Needed for deleteGroup's link update logic
import 'package:link_grab/services/hive_service.dart'; // Adjust path
// import 'hive_service_mocks.dart'; // Manual mocks - already created

void main() {
  // Similar disclaimers as in link_service_test.dart apply here regarding
  // Hive initialization and the nature of these tests (more integration-like).
  // Adapters for Group and Link are needed for real execution.

  setUpAll(() async {
    // Placeholder for Hive test initialization
    // Hive.initFlutter("test_hive_data_groups"); // Example
    // Need to register GroupAdapter and LinkAdapter
  });

  tearDownAll(() async {
    // await Hive.deleteFromDisk();
  });

  group('Group Model', () {
    test('Group object can be created', () {
      final group = Group(name: 'Test Group', color: 0xFFFF0000);
      expect(group.name, 'Test Group');
      expect(group.color, 0xFFFF0000);
    });
  });

  group('GroupService', () {
    late GroupService groupService;
    // late MockGroupBox mockGroupBox; // If we could inject
    // late MockLinkBox mockLinkBox; // For testing deleteGroup's impact on links

    setUp(() async {
      groupService = GroupService();
      // mockGroupBox = MockGroupBox();
      // mockLinkBox = MockLinkBox();
      // groupService = GroupService(groupBox: mockGroupBox, linkBox: mockLinkBox); // Ideal refactor

      // Clear boxes for test isolation (CONCEPTUAL)
      try {
        if (!Hive.isBoxOpen('groupsBox')) {
          await Hive.openBox<Group>('groupsBox');
        }
        final groupBox = Hive.box<Group>('groupsBox');
        await groupBox.clear();

        if (!Hive.isBoxOpen('linksBox')) {
          await Hive.openBox<Link>('linksBox');
        }
        final linkBox = Hive.box<Link>('linksBox');
        await linkBox.clear();
      } catch (e) {
        // print("Test setup warning: Could not clear boxes for GroupService tests. Error: $e");
      }
    });

    test('addGroup should add a group if name is unique', () async {
      final group = Group(name: 'New Group', color: 0xFF00FF00);
      await groupService.addGroup(group);

      final box = Hive.box<Group>('groupsBox');
      final retrievedGroup = box.get('New Group');
      expect(retrievedGroup, isNotNull);
      expect(retrievedGroup?.name, 'New Group');
      expect(retrievedGroup?.color, 0xFF00FF00);
    });

    test('addGroup should throw an exception for duplicate group name', () async {
      final group1 = Group(name: 'Duplicate Group', color: 0xFF0000FF);
      await groupService.addGroup(group1);

      final group2 = Group(name: 'Duplicate Group', color: 0xFFFFFF00);
      // Expect an exception because GroupService checks for key existence.
      // The service throws Exception('Group with name "${group.name}" already exists.');
      expect(() async => await groupService.addGroup(group2),
             throwsA(predicate((e) => e is Exception && e.toString().contains('already exists'))));
    });

    test('getAllGroups should return all groups from the box', () async {
      final group1 = Group(name: 'Group A', color: 1);
      final group2 = Group(name: 'Group B', color: 2);

      final box = Hive.box<Group>('groupsBox');
      await box.put(group1.name, group1);
      await box.put(group2.name, group2);

      final groups = await groupService.getAllGroups();

      expect(groups.length, 2);
      expect(groups.any((g) => g.name == 'Group A'), isTrue);
      expect(groups.any((g) => g.name == 'Group B'), isTrue);
    });

    test('deleteGroup should remove the group and update associated links', () async {
      final groupToDelete = Group(name: 'ToDelete', color: 3);
      final link1 = Link(id: 'l1', url: 'u1', group: 'ToDelete', createdAt: DateTime.now());
      final link2 = Link(id: 'l2', url: 'u2', group: 'AnotherGroup', createdAt: DateTime.now());
      final link3 = Link(id: 'l3', url: 'u3', group: 'ToDelete', createdAt: DateTime.now());

      final groupBox = Hive.box<Group>('groupsBox');
      await groupBox.put(groupToDelete.name, groupToDelete);

      final linkBox = Hive.box<Link>('linksBox');
      await linkBox.put(link1.id, link1);
      await linkBox.put(link2.id, link2);
      await linkBox.put(link3.id, link3);

      // Ensure group and links are there
      expect(groupBox.get('ToDelete'), isNotNull);
      expect(linkBox.get('l1')?.group, 'ToDelete');
      expect(linkBox.get('l3')?.group, 'ToDelete');

      await groupService.deleteGroup('ToDelete');

      // Verify group is deleted
      expect(groupBox.get('ToDelete'), isNull);

      // Verify associated links have their group field set to null
      final updatedLink1 = linkBox.get('l1');
      final updatedLink3 = linkBox.get('l3');
      expect(updatedLink1?.group, isNull);
      expect(updatedLink3?.group, isNull);

      // Verify other links are unaffected
      expect(linkBox.get('l2')?.group, 'AnotherGroup');
    });

    test('getGroupByName should retrieve a group by its name', () async {
      final group = Group(name: 'FindMe', color: 0xFF123456);
      final box = Hive.box<Group>('groupsBox');
      await box.put(group.name, group);

      final foundGroup = await groupService.getGroupByName('FindMe');
      expect(foundGroup, isNotNull);
      expect(foundGroup?.name, 'FindMe');
      expect(foundGroup?.color, 0xFF123456);

      final notFoundGroup = await groupService.getGroupByName('NonExistent');
      expect(notFoundGroup, isNull);
    });
  });
}

// Note: These tests, like LinkService tests, depend on a proper Hive test setup
// and registered TypeAdapters (GroupAdapter, LinkAdapter) which cannot be generated
// in the current environment. They illustrate the testing logic.
