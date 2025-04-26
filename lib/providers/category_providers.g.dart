// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesNotifierHash() =>
    r'4e06420c7ba05f5b4e1a8486e7f10eb1baa675c4';

/// See also [categoriesNotifier].
@ProviderFor(categoriesNotifier)
final categoriesNotifierProvider =
    AutoDisposeProvider<CategoriesNotifier>.internal(
  categoriesNotifier,
  name: r'categoriesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesNotifierRef = AutoDisposeProviderRef<CategoriesNotifier>;
String _$getCategoryByIdHash() => r'783c549abe0ff54c6f7d1e66b62fa3c1eb008a9d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [getCategoryById].
@ProviderFor(getCategoryById)
const getCategoryByIdProvider = GetCategoryByIdFamily();

/// See also [getCategoryById].
class GetCategoryByIdFamily extends Family<Category?> {
  /// See also [getCategoryById].
  const GetCategoryByIdFamily();

  /// See also [getCategoryById].
  GetCategoryByIdProvider call(
    int id,
  ) {
    return GetCategoryByIdProvider(
      id,
    );
  }

  @override
  GetCategoryByIdProvider getProviderOverride(
    covariant GetCategoryByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getCategoryByIdProvider';
}

/// See also [getCategoryById].
class GetCategoryByIdProvider extends AutoDisposeProvider<Category?> {
  /// See also [getCategoryById].
  GetCategoryByIdProvider(
    int id,
  ) : this._internal(
          (ref) => getCategoryById(
            ref as GetCategoryByIdRef,
            id,
          ),
          from: getCategoryByIdProvider,
          name: r'getCategoryByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getCategoryByIdHash,
          dependencies: GetCategoryByIdFamily._dependencies,
          allTransitiveDependencies:
              GetCategoryByIdFamily._allTransitiveDependencies,
          id: id,
        );

  GetCategoryByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    Category? Function(GetCategoryByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetCategoryByIdProvider._internal(
        (ref) => create(ref as GetCategoryByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Category?> createElement() {
    return _GetCategoryByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetCategoryByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetCategoryByIdRef on AutoDisposeProviderRef<Category?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _GetCategoryByIdProviderElement
    extends AutoDisposeProviderElement<Category?> with GetCategoryByIdRef {
  _GetCategoryByIdProviderElement(super.provider);

  @override
  int get id => (origin as GetCategoryByIdProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
