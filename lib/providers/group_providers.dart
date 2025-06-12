import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/group.dart';
import '../services/hive_service.dart';

part 'group_providers.g.dart';

// Service provider for GroupService
final groupServiceProvider = Provider<GroupService>((ref) {
  return GroupService();
});

@Riverpod(keepAlive: true)
class GroupNotifier extends _$GroupNotifier {
  @override
  Future<List<Group>> build() async {
    return _service.getAllGroups();
  }

  GroupService get _service => ref.read(groupServiceProvider);

  Future<void> addGroup(Group group) async {
    state = const AsyncValue.loading();
    try {
      // Ensure group name uniqueness is handled by the service or here before adding
      // For now, assuming service handles it or an error will propagate
      await _service.addGroup(group);
      await refreshGroups();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Optionally rethrow or handle: e.g., display a user-friendly message
      // if (e.toString().contains("already exists")) { ... }
    }
  }

  Future<void> deleteGroup(String groupName) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteGroup(groupName);
      await refreshGroups();
      // After deleting a group, we might need to update the links view
      // if links were associated with this group.
      // This can be done by invalidating or refreshing the link provider.
      // ref.invalidate(linksNotifierProvider); // Example if using linksNotifierProvider
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Group?> getGroupByName(String name) async {
    // This is a read operation, doesn't change state directly
    // but useful for checking existence or details.
    try {
      return await _service.getGroupByName(name);
    } catch (e) {
      print("Error getting group by name $name: $e");
      return null;
    }
  }

  Future<void> refreshGroups() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _service.getAllGroups());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// The @riverpod annotation creates groupNotifierProvider
// Provider to get the current list of groups
@riverpod
List<Group> groups(GroupsRef ref) {
  return ref.watch(groupNotifierProvider).when(
        data: (data) => data,
        loading: () => [], // Or return previous state: ref.watch(groupNotifierProvider).value ?? []
        error: (_, __) => [],
      );
}
