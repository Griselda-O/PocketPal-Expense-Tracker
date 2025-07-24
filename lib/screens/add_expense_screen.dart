import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    'Health',
    'Entertainment',
    'Utilities',
    'Shopping',
    'Education',
    'Savings',
    'Travel',
    'Airtime',
    'Printing',
    'Leisure',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadLastCategory();
  }

  Future<void> _loadLastCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCat = prefs.getString('last_expense_category');
    if (lastCat != null && _categories.contains(lastCat)) {
      setState(() => _category = lastCat);
    }
  }

  Future<void> _saveLastCategory(String cat) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_expense_category', cat);
  }

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
              Text('Category', style: Theme.of(context).textTheme.bodyMedium),
              Wrap(
                spacing: 8,
                children: _categories
                    .map(
                      (cat) => ChoiceChip(
                        label: Text(cat),
                        selected: _category == cat,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _category = cat);
                            _saveLastCategory(cat);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
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
                    provider.addExpense(_category, _amount, _note, _date);
                    Navigator.pop(context);
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
