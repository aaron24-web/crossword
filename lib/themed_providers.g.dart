// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'themed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themedWordListHash() => r'b681ec8750ca7aa45ba4d0fc91497f96e9acb623';

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

/// Provider para cargar palabras de un tema específico
/// Solo incluye palabras que tienen pista en el diccionario
///
/// Copied from [themedWordList].
@ProviderFor(themedWordList)
const themedWordListProvider = ThemedWordListFamily();

/// Provider para cargar palabras de un tema específico
/// Solo incluye palabras que tienen pista en el diccionario
///
/// Copied from [themedWordList].
class ThemedWordListFamily extends Family<AsyncValue<BuiltSet<String>>> {
  /// Provider para cargar palabras de un tema específico
  /// Solo incluye palabras que tienen pista en el diccionario
  ///
  /// Copied from [themedWordList].
  const ThemedWordListFamily();

  /// Provider para cargar palabras de un tema específico
  /// Solo incluye palabras que tienen pista en el diccionario
  ///
  /// Copied from [themedWordList].
  ThemedWordListProvider call(String themeId) {
    return ThemedWordListProvider(themeId);
  }

  @override
  ThemedWordListProvider getProviderOverride(
    covariant ThemedWordListProvider provider,
  ) {
    return call(provider.themeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'themedWordListProvider';
}

/// Provider para cargar palabras de un tema específico
/// Solo incluye palabras que tienen pista en el diccionario
///
/// Copied from [themedWordList].
class ThemedWordListProvider
    extends AutoDisposeFutureProvider<BuiltSet<String>> {
  /// Provider para cargar palabras de un tema específico
  /// Solo incluye palabras que tienen pista en el diccionario
  ///
  /// Copied from [themedWordList].
  ThemedWordListProvider(String themeId)
    : this._internal(
        (ref) => themedWordList(ref as ThemedWordListRef, themeId),
        from: themedWordListProvider,
        name: r'themedWordListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$themedWordListHash,
        dependencies: ThemedWordListFamily._dependencies,
        allTransitiveDependencies:
            ThemedWordListFamily._allTransitiveDependencies,
        themeId: themeId,
      );

  ThemedWordListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.themeId,
  }) : super.internal();

  final String themeId;

  @override
  Override overrideWith(
    FutureOr<BuiltSet<String>> Function(ThemedWordListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ThemedWordListProvider._internal(
        (ref) => create(ref as ThemedWordListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        themeId: themeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<BuiltSet<String>> createElement() {
    return _ThemedWordListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ThemedWordListProvider && other.themeId == themeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, themeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ThemedWordListRef on AutoDisposeFutureProviderRef<BuiltSet<String>> {
  /// The parameter `themeId` of this provider.
  String get themeId;
}

class _ThemedWordListProviderElement
    extends AutoDisposeFutureProviderElement<BuiltSet<String>>
    with ThemedWordListRef {
  _ThemedWordListProviderElement(super.provider);

  @override
  String get themeId => (origin as ThemedWordListProvider).themeId;
}

String _$themedWorkQueueHash() => r'3c0502563d05f518a203a4944e915ef7523c38af';

/// Provider para generar crucigrama temático
///
/// Copied from [themedWorkQueue].
@ProviderFor(themedWorkQueue)
const themedWorkQueueProvider = ThemedWorkQueueFamily();

/// Provider para generar crucigrama temático
///
/// Copied from [themedWorkQueue].
class ThemedWorkQueueFamily extends Family<AsyncValue<model.WorkQueue>> {
  /// Provider para generar crucigrama temático
  ///
  /// Copied from [themedWorkQueue].
  const ThemedWorkQueueFamily();

  /// Provider para generar crucigrama temático
  ///
  /// Copied from [themedWorkQueue].
  ThemedWorkQueueProvider call(String themeId) {
    return ThemedWorkQueueProvider(themeId);
  }

  @override
  ThemedWorkQueueProvider getProviderOverride(
    covariant ThemedWorkQueueProvider provider,
  ) {
    return call(provider.themeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'themedWorkQueueProvider';
}

/// Provider para generar crucigrama temático
///
/// Copied from [themedWorkQueue].
class ThemedWorkQueueProvider
    extends AutoDisposeStreamProvider<model.WorkQueue> {
  /// Provider para generar crucigrama temático
  ///
  /// Copied from [themedWorkQueue].
  ThemedWorkQueueProvider(String themeId)
    : this._internal(
        (ref) => themedWorkQueue(ref as ThemedWorkQueueRef, themeId),
        from: themedWorkQueueProvider,
        name: r'themedWorkQueueProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$themedWorkQueueHash,
        dependencies: ThemedWorkQueueFamily._dependencies,
        allTransitiveDependencies:
            ThemedWorkQueueFamily._allTransitiveDependencies,
        themeId: themeId,
      );

  ThemedWorkQueueProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.themeId,
  }) : super.internal();

  final String themeId;

  @override
  Override overrideWith(
    Stream<model.WorkQueue> Function(ThemedWorkQueueRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ThemedWorkQueueProvider._internal(
        (ref) => create(ref as ThemedWorkQueueRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        themeId: themeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<model.WorkQueue> createElement() {
    return _ThemedWorkQueueProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ThemedWorkQueueProvider && other.themeId == themeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, themeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ThemedWorkQueueRef on AutoDisposeStreamProviderRef<model.WorkQueue> {
  /// The parameter `themeId` of this provider.
  String get themeId;
}

class _ThemedWorkQueueProviderElement
    extends AutoDisposeStreamProviderElement<model.WorkQueue>
    with ThemedWorkQueueRef {
  _ThemedWorkQueueProviderElement(super.provider);

  @override
  String get themeId => (origin as ThemedWorkQueueProvider).themeId;
}

String _$themedPuzzleHash() => r'260116475d26f8d1411fdd268bb075446c8294c8';

abstract class _$ThemedPuzzle
    extends BuildlessAutoDisposeAsyncNotifier<ThemedPuzzleState> {
  late final String themeId;

  FutureOr<ThemedPuzzleState> build(String themeId);
}

/// Provider para el crucigrama temático con pistas
///
/// Copied from [ThemedPuzzle].
@ProviderFor(ThemedPuzzle)
const themedPuzzleProvider = ThemedPuzzleFamily();

/// Provider para el crucigrama temático con pistas
///
/// Copied from [ThemedPuzzle].
class ThemedPuzzleFamily extends Family<AsyncValue<ThemedPuzzleState>> {
  /// Provider para el crucigrama temático con pistas
  ///
  /// Copied from [ThemedPuzzle].
  const ThemedPuzzleFamily();

  /// Provider para el crucigrama temático con pistas
  ///
  /// Copied from [ThemedPuzzle].
  ThemedPuzzleProvider call(String themeId) {
    return ThemedPuzzleProvider(themeId);
  }

  @override
  ThemedPuzzleProvider getProviderOverride(
    covariant ThemedPuzzleProvider provider,
  ) {
    return call(provider.themeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'themedPuzzleProvider';
}

/// Provider para el crucigrama temático con pistas
///
/// Copied from [ThemedPuzzle].
class ThemedPuzzleProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ThemedPuzzle, ThemedPuzzleState> {
  /// Provider para el crucigrama temático con pistas
  ///
  /// Copied from [ThemedPuzzle].
  ThemedPuzzleProvider(String themeId)
    : this._internal(
        () => ThemedPuzzle()..themeId = themeId,
        from: themedPuzzleProvider,
        name: r'themedPuzzleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$themedPuzzleHash,
        dependencies: ThemedPuzzleFamily._dependencies,
        allTransitiveDependencies:
            ThemedPuzzleFamily._allTransitiveDependencies,
        themeId: themeId,
      );

  ThemedPuzzleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.themeId,
  }) : super.internal();

  final String themeId;

  @override
  FutureOr<ThemedPuzzleState> runNotifierBuild(
    covariant ThemedPuzzle notifier,
  ) {
    return notifier.build(themeId);
  }

  @override
  Override overrideWith(ThemedPuzzle Function() create) {
    return ProviderOverride(
      origin: this,
      override: ThemedPuzzleProvider._internal(
        () => create()..themeId = themeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        themeId: themeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ThemedPuzzle, ThemedPuzzleState>
  createElement() {
    return _ThemedPuzzleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ThemedPuzzleProvider && other.themeId == themeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, themeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ThemedPuzzleRef
    on AutoDisposeAsyncNotifierProviderRef<ThemedPuzzleState> {
  /// The parameter `themeId` of this provider.
  String get themeId;
}

class _ThemedPuzzleProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ThemedPuzzle, ThemedPuzzleState>
    with ThemedPuzzleRef {
  _ThemedPuzzleProviderElement(super.provider);

  @override
  String get themeId => (origin as ThemedPuzzleProvider).themeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
