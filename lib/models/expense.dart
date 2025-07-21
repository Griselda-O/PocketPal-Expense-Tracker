class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String note;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });
}