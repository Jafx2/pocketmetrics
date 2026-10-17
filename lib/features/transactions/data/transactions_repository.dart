// lib/features/transactions/data/transactions_repository.dart
import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class TransactionsRepository {
  final AppDatabase _db;

  const TransactionsRepository(this._db);

  /// Stream reactivo: emite una nueva lista cada vez que la tabla cambia.
  /// Ordenado por fecha descendente (mas reciente primero).
  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Inserta una transaccion. Devuelve el id generado.
  Future<int> addTransaction({
    required double amount,
    required String currency,
    required DateTime date,
    required int categoryId,
    required String type, // 'income' | 'expense'
    String? note,
  }) {
    return _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            amount: amount,
            currency: Value(currency),
            date: date,
            categoryId: categoryId,
            type: type,
            note: Value(note),
          ),
        );
  }

  /// Elimina la transaccion con el [id] dado. Devuelve el numero de filas borradas.
  Future<int> deleteTransaction(int id) {
    return (_db.delete(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Calcula el balance total: suma de ingresos - suma de gastos.
  /// Usa dos queries separadas con expresiones de Drift (sin traer todas las filas).
  Future<double> getBalance() async {
    final sumExpr = _db.transactions.amount.sum();

    final incomeQuery = _db.selectOnly(_db.transactions)
      ..addColumns([sumExpr])
      ..where(_db.transactions.type.equals('income'));
    final incomeRow = await incomeQuery.getSingle();
    final income = incomeRow.read(sumExpr) ?? 0.0;

    final expenseQuery = _db.selectOnly(_db.transactions)
      ..addColumns([sumExpr])
      ..where(_db.transactions.type.equals('expense'));
    final expenseRow = await expenseQuery.getSingle();
    final expense = expenseRow.read(sumExpr) ?? 0.0;

    return income - expense;
  }
}
