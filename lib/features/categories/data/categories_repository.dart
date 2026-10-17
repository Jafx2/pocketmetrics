// lib/features/categories/data/categories_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../transactions/presentation/transactions_provider.dart';

class CategoriesRepository {
  final AppDatabase _db;

  const CategoriesRepository(this._db);

  /// Stream reactivo de todas las categorias.
  Stream<List<Category>> watchAllCategories() {
    return _db.select(_db.categories).watch();
  }

  /// Devuelve todas las categorias de una sola vez (sin stream).
  Future<List<Category>> getAllCategories() {
    return _db.select(_db.categories).get();
  }

  /// Inserta una categoria. Devuelve el id generado.
  Future<int> addCategory({
    required String name,
    required String icon,
    required String type, // 'income' | 'expense'
  }) {
    return _db.into(_db.categories).insert(
          CategoriesCompanion.insert(name: name, icon: icon, type: type),
        );
  }

  /// Inserta las categorias predeterminadas SOLO si la tabla esta vacia.
  /// Seguro para llamar en cada inicio de la app (idempotente).
  Future<void> seedDefaultCategories() async {
    final existing = await _db.select(_db.categories).get();
    if (existing.isNotEmpty) return;

    const defaults = [
      (name: 'Comida',          icon: 'food',            type: 'expense'),
      (name: 'Transporte',      icon: 'transport',       type: 'expense'),
      (name: 'Entretenimiento', icon: 'entertainment',   type: 'expense'),
      (name: 'Salario',         icon: 'salary',          type: 'income'),
    ];

    await _db.batch((batch) {
      for (final c in defaults) {
        batch.insert(
          _db.categories,
          CategoriesCompanion.insert(name: c.name, icon: c.icon, type: c.type),
        );
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Providers de categorias
// ---------------------------------------------------------------------------
final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => CategoriesRepository(ref.watch(databaseProvider)),
);

final categoriesStreamProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoriesRepositoryProvider).watchAllCategories(),
);
