import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:uuid/uuid.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  bool isDarkMode = false;

  double _monthlyBudget = 500.0;
  double get monthlyBudget => _monthlyBudget;
  set monthlyBudget(double value) {
    _monthlyBudget = value;
    notifyListeners();
  }

  double get budgetProgress {
    if (_monthlyBudget == 0) return 0.0;
    return (totalMonthlyExpenses / _monthlyBudget).clamp(0.0, 1.0);
  }

  List<Expense> get expenses => _expenses;

  void addExpense(String category, double amount, String note, DateTime date) {
    final newExpense = Expense(
      id: const Uuid().v4(),
      category: category,
      amount: amount,
      date: date,
      note: note,
    );
    _expenses.add(newExpense);
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  double get totalMonthlyExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get dailyExpensesThisWeek {
    final Map<String, double> data = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final key = "${day.month}/${day.day}";
      data[key] = _expenses
          .where(
            (e) =>
                e.date.day == day.day &&
                e.date.month == day.month &&
                e.date.year == day.year,
          )
          .fold(0.0, (sum, e) => sum + e.amount);
    }

    return data;
  }

  double get predictedMonthlyExpense {
    final now = DateTime.now();
    final totalSoFar = totalMonthlyExpenses;
    final currentDay = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    if (currentDay == 0) return 0.0;

    return (totalSoFar / currentDay) * daysInMonth;
  }

  String get spendingStatus {
    final total = totalMonthlyExpenses;
    if (total < 100) return "Safe";
    if (total < 300) return "Caution";
    return "Danger";
  }
}
