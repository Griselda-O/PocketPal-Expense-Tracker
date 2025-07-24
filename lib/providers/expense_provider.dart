import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  bool isDarkMode = false;
  bool isLoading = false;
  String? error;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  double _monthlyBudget = 500.0;
  double get monthlyBudget => _monthlyBudget;
  set monthlyBudget(double value) {
    _monthlyBudget = value;
    saveBudgetToFirestore(value);
    notifyListeners();
    _analytics.logEvent(name: 'update_budget', parameters: {'budget': value});
  }

  double get budgetProgress {
    if (_monthlyBudget == 0) return 0.0;
    return (totalMonthlyExpenses / _monthlyBudget).clamp(0.0, 1.0);
  }

  List<Expense> get expenses => _expenses;

  Future<void> loadExpensesFromFirestore() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();
      _expenses.clear();
      for (var doc in snap.docs) {
        final data = doc.data();
        _expenses.add(
          Expense(
            id: doc.id,
            category: data['category'],
            amount: (data['amount'] as num).toDouble(),
            note: data['note'] ?? '',
            date: (data['date'] as Timestamp).toDate(),
          ),
        );
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(
    String category,
    double amount,
    String note,
    DateTime date,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final newExpense = Expense(
      id: const Uuid().v4(),
      category: category,
      amount: amount,
      date: date,
      note: note,
    );
    _expenses.add(newExpense);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(newExpense.id)
        .set({
          'category': category,
          'amount': amount,
          'note': note,
          'date': Timestamp.fromDate(date),
        });
    await _analytics.logEvent(
      name: 'add_expense',
      parameters: {'category': category, 'amount': amount},
    );
  }

  Future<void> updateExpense(Expense expense) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      _expenses[idx] = expense;
      notifyListeners();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(expense.id)
          .set({
            'category': expense.category,
            'amount': expense.amount,
            'note': expense.note,
            'date': Timestamp.fromDate(expense.date),
          });
      await _analytics.logEvent(
        name: 'update_expense',
        parameters: {'category': expense.category, 'amount': expense.amount},
      );
    }
  }

  Future<void> deleteExpense(Expense expense) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _expenses.removeWhere((e) => e.id == expense.id);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expense.id)
        .delete();
    await _analytics.logEvent(
      name: 'delete_expense',
      parameters: {'category': expense.category, 'amount': expense.amount},
    );
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
    final progress = budgetProgress;
    if (progress < 0.5) return "Safe";
    if (progress < 0.8) return "Caution";
    if (progress < 1.0) return "Warning";
    return "Danger";
  }

  Future<void> loadBudgetFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await loadBudgetFromPrefs();
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final budget = doc.data()?['monthlyBudget'];
    if (budget != null) {
      _monthlyBudget = (budget as num).toDouble();
      notifyListeners();
    } else {
      await loadBudgetFromPrefs();
    }
  }

  Future<void> saveBudgetToFirestore(double value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'monthlyBudget': value,
    }, SetOptions(merge: true));
  }

  Future<void> loadBudgetFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetStr = prefs.getString('budget');
    if (budgetStr != null) {
      final parsed = double.tryParse(budgetStr);
      if (parsed != null && parsed > 0) {
        _monthlyBudget = parsed;
        notifyListeners();
      }
    }
  }
}
