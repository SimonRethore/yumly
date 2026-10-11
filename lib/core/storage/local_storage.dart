import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instance de [SharedPreferences], initialisée dans `main` puis injectée.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider non injecté'),
);

final localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorage(ref.watch(sharedPreferencesProvider)),
);

/// Dernier problème de persistance à signaler à l'utilisateur.
final storageIssueProvider = NotifierProvider<StorageIssueNotifier, String?>(
  StorageIssueNotifier.new,
);

class StorageIssueNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void report(String message) => state = message;

  void clear() => state = null;
}

/// Résultat d'une lecture : la valeur décodée, ou l'indication que les
/// données étaient corrompues (et ont été réinitialisées).
class StorageRead<T> {
  const StorageRead(this.value, {this.wasCorrupted = false});

  final T? value;
  final bool wasCorrupted;
}

/// Stockage local léger. Chaque état est enregistré sous sa propre clé dans
/// une enveloppe versionnée `{"version": n, "data": ...}` afin qu'une
/// donnée corrompue ou d'une version inconnue n'affecte que cet état.
class LocalStorage {
  const LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  StorageRead<T> read<T>(
    String key, {
    required int version,
    required T? Function(Object? data) decode,
  }) {
    final String? raw;
    try {
      raw = _prefs.getString(key);
    } catch (e) {
      return _corrupted(key, e);
    }
    if (raw == null) return const StorageRead(null);
    try {
      final envelope = jsonDecode(raw);
      if (envelope is! Map<String, Object?> || envelope['version'] != version) {
        return _corrupted(key, 'version inconnue');
      }
      final value = decode(envelope['data']);
      if (value == null) return _corrupted(key, 'contenu invalide');
      return StorageRead(value);
    } catch (e) {
      return _corrupted(key, e);
    }
  }

  StorageRead<T> _corrupted<T>(String key, Object reason) {
    debugPrint('[Yumly] Données locales « $key » réinitialisées : $reason');
    try {
      _prefs.remove(key);
    } catch (_) {
      // Rien de plus à faire : l'état sera simplement vide.
    }
    return const StorageRead(null, wasCorrupted: true);
  }

  /// Retourne `false` si l'écriture a échoué.
  Future<bool> write(
    String key, {
    required int version,
    required Object? data,
  }) async {
    try {
      return await _prefs.setString(
        key,
        jsonEncode({'version': version, 'data': data}),
      );
    } catch (e) {
      debugPrint('[Yumly] Échec d’écriture « $key » : $e');
      return false;
    }
  }
}

/// Base des états persistés : lecture au démarrage, écriture après chaque
/// modification, signalement des erreurs sans bloquer l'interface.
abstract class PersistedNotifier<T> extends Notifier<T> {
  String get storageKey;
  int get storageVersion => 1;
  String get stateLabel;

  T get emptyState;
  T? decode(Object? data);
  Object? encode(T value);

  LocalStorage get _storage => ref.read(localStorageProvider);

  /// À appeler depuis `build`.
  T restore() {
    final result = _storage.read(
      storageKey,
      version: storageVersion,
      decode: decode,
    );
    if (result.wasCorrupted) {
      // Un provider ne peut pas en modifier un autre pendant sa construction.
      Future.microtask(
        () => ref
            .read(storageIssueProvider.notifier)
            .report(
              'Vos $stateLabel enregistrés étaient illisibles et ont été réinitialisés.',
            ),
      );
    }
    return result.value ?? emptyState;
  }

  /// Met à jour l'état puis le persiste.
  void save(T value) {
    state = value;
    _storage
        .write(storageKey, version: storageVersion, data: encode(value))
        .then((ok) {
          if (!ok && ref.mounted) {
            ref
                .read(storageIssueProvider.notifier)
                .report(
                  'Impossible d’enregistrer vos $stateLabel sur l’appareil.',
                );
          }
        });
  }
}
