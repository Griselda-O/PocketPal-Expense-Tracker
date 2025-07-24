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

  Expense copyWith({
    String? category,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
