import 'package:link_grab/models/link.dart';
import 'package:link_grab/models/group.dart';
import 'package:link_grab/models/settings.dart';
import 'package:link_grab/services/hive_service.dart';

class MockLinkService implements LinkService {
  List<Link> links = [];

  @override
  Future<void> addLink(Link link) async {
    links.removeWhere((l) => l.id == link.id); // Remove if exists, then add
    links.add(link);
  }

  @override
  Future<List<Link>> getAllLinks() async {
    return List.from(links);
  }

  @override
  Future<Link?> getLinkById(String id) async {
    try {
      return links.firstWhere((link) => link.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Link>> getLinksByGroup(String groupName) async {
    return links.where((link) => link.group == groupName).toList();
  }

  @override
  Future<List<Link>> getFavoriteLinks() async {
    return links.where((link) => link.isFavorite).toList();
  }

  @override
  Future<List<Link>> getRecentLinks({int count = 20}) async {
    var sortedLinks = List<Link>.from(links);
    sortedLinks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedLinks.take(count).toList();
  }

  @override
  Future<void> updateLink(Link link) async {
    final index = links.indexWhere((l) => l.id == link.id);
    if (index != -1) {
      links[index] = link;
    } else {
      // Or throw not found? For mock, maybe just add if not found.
      links.add(link);
    }
  }

  @override
  Future<void> deleteLink(String linkId) async {
    links.removeWhere((link) => link.id == linkId);
  }
}

class MockGroupService implements GroupService {
  List<Group> groups = [];
  // To simulate link updates on group deletion
  MockLinkService? mockLinkService;

  MockGroupService({this.mockLinkService});

  @override
  Future<void> addGroup(Group group) async {
    if (groups.any((g) => g.name == group.name)) {
      throw Exception('MockGroupService: Group with name "${group.name}" already exists.');
    }
    groups.add(group);
  }

  @override
  Future<List<Group>> getAllGroups() async {
    return List.from(groups);
  }

  @override
  Future<Group?> getGroupByName(String name) async {
    try {
      return groups.firstWhere((g) => g.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteGroup(String groupName) async {
    groups.removeWhere((group) => group.name == groupName);
    if (mockLinkService != null) {
      final linksToUpdate = mockLinkService!.links.where((link) => link.group == groupName).toList();
      for (var link in linksToUpdate) {
        final updatedLink = Link(
            id: link.id,
            url: link.url,
            title: link.title,
            description: link.description,
            isFavorite: link.isFavorite,
            createdAt: link.createdAt,
            group: null);
        mockLinkService!.updateLink(updatedLink);
      }
    }
  }
}

class MockSettingsService implements SettingsService {
  Settings currentSettings = Settings(darkMode: false); // Default

  @override
  Future<Settings> getSettings() async {
    return currentSettings;
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    currentSettings = settings;
  }
}
