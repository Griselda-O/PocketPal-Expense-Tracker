import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'package:uuid/uuid.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String? selectedCategory;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categories = provider.expenses
        .map((e) => e.category)
        .toSet()
        .toList();
    List<Expense> filtered = provider.expenses;
    if (selectedCategory != null) {
      filtered = filtered.where((e) => e.category == selectedCategory).toList();
    }
    if (selectedDate != null) {
      filtered = filtered
          .where(
            (e) =>
                e.date.year == selectedDate!.year &&
                e.date.month == selectedDate!.month &&
                e.date.day == selectedDate!.day,
          )
          .toList();
    }
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 0,
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                  onPressed: () async {
                    final provider = Provider.of<ExpenseProvider>(
                      context,
                      listen: false,
                    );
                    final csvData = [
                      ['Category', 'Amount', 'Note', 'Date'],
                      ...provider.expenses.map(
                        (e) => [
                          e.category,
                          e.amount.toStringAsFixed(2),
                          e.note,
                          "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
                        ],
                      ),
                    ];
                    final csv = const ListToCsvConverter().convert(csvData);
                    final dir = await getTemporaryDirectory();
                    final file = File('${dir.path}/expenses.csv');
                    await file.writeAsString(csv);
                    await Share.shareXFiles([
                      XFile(file.path),
                    ], text: 'My Expenses (CSV)');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CSV exported!')),
                    );
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  onPressed: () async {
                    final provider = Provider.of<ExpenseProvider>(
                      context,
                      listen: false,
                    );
                    final pdf = pw.Document();
                    pdf.addPage(
                      pw.Page(
                        pageFormat: PdfPageFormat.a4,
                        build: (pw.Context context) {
                          return pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'My Expenses',
                                style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 16),
                              pw.Table.fromTextArray(
                                headers: ['Category', 'Amount', 'Note', 'Date'],
                                data: provider.expenses
                                    .map(
                                      (e) => [
                                        e.category,
                                        e.amount.toStringAsFixed(2),
                                        e.note,
                                        "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
                                      ],
                                    )
                                    .toList(),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                    final dir = await getTemporaryDirectory();
                    final file = File('${dir.path}/expenses.pdf');
                    await file.writeAsBytes(await pdf.save());
                    await Share.shareXFiles([
                      XFile(file.path),
                    ], text: 'My Expenses (PDF)');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF exported!')),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          hint: const Text('Filter by Category'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            ...categories.map(
                              (cat) => DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat),
                              ),
                            ),
                          ],
                          onChanged: (val) =>
                              setState(() => selectedCategory = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        selectedDate == null
                            ? 'Filter by Date'
                            : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null)
                          setState(() => selectedDate = picked);
                      },
                    ),
                    if (selectedCategory != null || selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear Filters',
                        onPressed: () => setState(() {
                          selectedCategory = null;
                          selectedDate = null;
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No expenses found.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final e = filtered[i];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.15),
                            child: Icon(
                              Icons.category,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            e.category,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (e.note.isNotEmpty) Text(e.note),
                              Text(
                                "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Text(
                            "\$${e.amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Expense Details'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Category: ${e.category}'),
                                  Text(
                                    'Amount: \$${e.amount.toStringAsFixed(2)}',
                                  ),
                                  Text(
                                    'Date: ${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}',
                                  ),
                                  if (e.note.isNotEmpty)
                                    Text('Note: ${e.note}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          _EditExpenseDialog(expense: e),
                                    );
                                  },
                                  child: const Text('Edit'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final removed = e;
                                    await provider.deleteExpense(e);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Expense deleted'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () async {
                                            await provider.addExpense(
                                              removed.category,
                                              removed.amount,
                                              removed.note,
                                              removed.date,
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EditExpenseDialog extends StatefulWidget {
  final Expense expense;
  const _EditExpenseDialog({required this.expense});
  @override
  State<_EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<_EditExpenseDialog> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String category;
  late DateTime date;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: widget.expense.note);
    category = widget.expense.category;
    date = widget.expense.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final categories = provider.expenses
        .map((e) => e.category)
        .toSet()
        .toList();
    return AlertDialog(
      title: const Text('Edit Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: categories
                  .map(
                    (cat) =>
                        DropdownMenuItem<String>(value: cat, child: Text(cat)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => category = val ?? category),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => date = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final amount = double.tryParse(_amountController.text);
            if (amount == null || amount <= 0) return;
            // Update the expense using provider method
            final updatedExpense = widget.expense.copyWith(
              category: category,
              amount: amount,
              note: _noteController.text,
              date: date,
            );
            await provider.updateExpense(updatedExpense);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
