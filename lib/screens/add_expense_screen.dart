import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Food';
  double _amount = 0.0;
  String _note = '';
  DateTime _date = DateTime.now();

  final List<String> _categories = [
    'Food',
    'Transport',
    'Airtime',
    'Printing',
    'Leisure',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField(
                value: _category,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter amount" : null,
                onSaved: (val) => _amount = double.tryParse(val!) ?? 0.0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Note (optional)"),
                onSaved: (val) => _note = val ?? '',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (_amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount.'),
                        ),
                      );
                      return;
                    }
                    try {
                      provider.addExpense(_category, _amount, _note, _date);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add expense: $e')),
                      );
                    }
                  }
                },
                child: const Text("Save Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
