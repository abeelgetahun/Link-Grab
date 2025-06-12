import 'package:hive_flutter/hive_flutter.dart';
import 'package:link_grab/models/link.dart'; // Adjust import path as necessary
import 'package:link_grab/models/group.dart';
import 'package:link_grab/models/settings.dart';

// Manual Mock for Box<T>
class MockBox<T> implements Box<T> {
  final Map<dynamic, T> _map = {};

  @override
  T? get(dynamic key, {T? defaultValue}) {
    return _map[key] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, T value) async {
    _map[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _map.remove(key);
  }

  @override
  Map<dynamic, T> toMap() => Map<dynamic, T>.from(_map);

  @override
  Iterable<T> get values => _map.values;

  @override
  bool containsKey(dynamic key) => _map.containsKey(key);

  @override
  int get length => _map.length;

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<dynamic> get keys => _map.keys;

  @override
  Future<int> add(T value) async {
    // For simplicity, using hash code as a key for add.
    // A more robust mock might use an incrementing counter.
    final key = value.hashCode;
    _map[key] = value;
    return key;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<T> values) async {
    final List<int> keys = [];
    for (var value in values) {
      keys.add(await add(value));
    }
    return keys;
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (var key in keys) {
      _map.remove(key);
    }
  }

  @override
  Future<void> clear() async {
    _map.clear();
  }

  // --- Unimplemented members ---
  @override
  Stream<BoxEvent> watch({dynamic key}) => throw UnimplementedError();

  @override
  bool get isOpen => true; // Assume open for mock

  @override
  String get name => 'mockBox';

  @override
  String? get path => null;

  @override
  LazyBox<T> get lazy => throw UnimplementedError();

  @override
  Future<void> close() async {}

  @override
  Future<void> compact() async {}

  @override
  T? getAt(int index) {
    if (index < 0 || index >= _map.length) return null;
    return _map.values.elementAt(index);
  }

  @override
  Future<void> putAt(int index, T value) async {
     // This is tricky for a simple map-based mock.
     // For now, not supporting robust putAt without ordered keys.
    if (index < 0 || index >= _map.length) return; // Or throw
    final key = _map.keys.elementAt(index);
    _map[key] = value;
  }

  @override
  Future<void> deleteAt(int index) async {
    if (index < 0 || index >= _map.length) return;
    final key = _map.keys.elementAt(index);
    _map.remove(key);
  }

  @override
  Future<void> flush() async {}

  @override
  bool isLazy = false; // Default to false
}

// Specific mock boxes (can extend MockBox or just be instances)
class MockLinkBox extends MockBox<Link> {}
class MockGroupBox extends MockBox<Group> {}
class MockSettingsBox extends MockBox<Settings> {}

// It would be ideal to use Mockito to generate these if `flutter pub get` worked.
// For now, these are placeholders for where Mockito would generate code.
// Example (conceptual):
// import 'package:mockito/mockito.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// class MockHiveInterface extends Mock implements HiveInterface {}
// class MockLinkBox extends Mock implements Box<Link> {}
// etc.

// Since Hive.isBoxOpen and Hive.openBox are static or global,
// testing services that use them directly is hard without a Hive setup.
// The services should ideally take Box<T> instances in their constructors
// or have a way to inject mock boxes for testing.
// The current HiveService uses static Hive calls directly.
// For these tests, we'll assume the boxes are passed or can be mocked.
// The HiveService provided has static const _boxName, and then uses Hive.box<T>(_boxName)
// This makes direct mocking hard without refactoring HiveService to accept Box instances.
// The tests below will proceed by instantiating the service and testing its methods,
// but they won't be true unit tests as they might interact with a real Hive instance if not careful,
// or fail if Hive isn't initialized.
// The ideal approach would be:
// 1. Refactor services to accept Box<T> in constructor.
// 2. In tests, pass MockBox<T> to the service.

// For now, the tests will be structured but might not run correctly without service refactoring or a test Hive setup.
