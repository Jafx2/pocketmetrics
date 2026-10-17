// lib/features/transactions/presentation/transactions_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../data/transactions_repository.dart';

// ---------------------------------------------------------------------------
// 1. Provider de la base de datos (singleton de la app)
// ---------------------------------------------------------------------------
/// Instancia unica de AppDatabase compartida en toda la app.
/// Se puede sobreescribir en tests con ProviderScope(overrides: [...]).
final databaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase(),
);

// ---------------------------------------------------------------------------
// 2. Provider del repositorio
// ---------------------------------------------------------------------------
final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(ref.watch(databaseProvider)),
);

// ---------------------------------------------------------------------------
// 3. StreamProvider para la lista de transacciones
// ---------------------------------------------------------------------------
/// Expone watchAllTransactions() como un AsyncValue<List<Transaction>>.
/// La UI se re-renderiza automaticamente cuando la base de datos cambia.
final transactionsStreamProvider = StreamProvider<List<Transaction>>(
  (ref) {
    final repo = ref.watch(transactionsRepositoryProvider);
    return repo.watchAllTransactions();
  },
);
