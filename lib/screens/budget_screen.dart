import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../services/tips_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    final budget = context.read<ExpenseProvider>().monthlyBudget;
    _controller = TextEditingController(text: budget.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Monthly Budget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter your monthly budget',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed > 0) {
                  provider.monthlyBudget = parsed;
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Getting your financial tip...'),
                      ],
                    ),
                  ),
                );

                try {
                  final tip = await TipsService().getFinancialTip();
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber[700],
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Financial Tip',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip,
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tap "New Tip" to get another piece of advice!',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              // Get another tip
                              final newTip = await TipsService()
                                  .getFinancialTip();
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline,
                                          color: Colors.amber[700],
                                          size: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Financial Tip',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      newTip,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('New Tip'),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: Text('Failed to load financial tip: $e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Get Financial Tip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _CategoryPieChart(),
            const SizedBox(height: 24),
            _BudgetSummaryCards(),
            const SizedBox(height: 24),
            _BudgetTipsAlerts(),
            const SizedBox(height: 24),
            Text(
              'Monthly Budget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      prefixText: '\$', // Dollar sign
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final value = double.tryParse(_controller.text);
                    if (value != null && value > 0) {
                      provider.monthlyBudget = value;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget updated!')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Budget Usage',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: provider.budgetProgress,
              minHeight: 16,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                provider.budgetProgress < 0.7
                    ? Colors.green
                    : provider.budgetProgress < 1.0
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${provider.totalMonthlyExpenses.toStringAsFixed(2)} spent of \$${provider.monthlyBudget.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              "Predicted this month: \$${provider.predictedMonthlyExpense.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 16),
            Text('Status: ${provider.spendingStatus}'),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final colors = [
      Colors.indigo,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.blue,
      Colors.teal,
      Colors.brown,
      Colors.pink,
      Colors.cyan,
    ];
    int colorIdx = 0;
    return total == 0
        ? const Text('No expenses to show.')
        : Column(
            children: [
              SizedBox(
                height: 120,
                child: PieChart(
                  PieChartData(
                    sections: categoryTotals.entries.map((entry) {
                      final color = colors[colorIdx % colors.length];
                      colorIdx++;
                      return PieChartSectionData(
                        value: entry.value,
                        color: color,
                        title: '',
                        radius: 48,
                        showTitle: false,
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: categoryTotals.entries.map((entry) {
                  final idx = categoryTotals.keys.toList().indexOf(entry.key);
                  final color = colors[idx % colors.length];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
  }
}

class _BudgetSummaryCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day;
    final dailyLimit =
        (provider.monthlyBudget - provider.totalMonthlyExpenses) /
        (daysLeft > 0 ? daysLeft : 1);
    final cards = [
      _SummaryCard(title: 'Days Left', value: daysLeft.toString()),
      _SummaryCard(
        title: 'Daily Limit',
        value:
            '\$${dailyLimit.isFinite ? dailyLimit.toStringAsFixed(2) : '0.00'}',
      ),
      _SummaryCard(
        title: 'Predicted',
        value: '\$${provider.predictedMonthlyExpense.toStringAsFixed(2)}',
      ),
      _SummaryCard(title: 'Status', value: provider.spendingStatus),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i != 0) const SizedBox(width: 12),
              cards[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetTipsAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final percent = provider.budgetProgress;
    String message;
    Color color;
    IconData icon;
    if (percent < 0.7) {
      message = "You're on track! Keep it up!";
      color = Colors.green;
      icon = Icons.thumb_up;
    } else if (percent < 1.0) {
      message = "Caution: You're nearing your budget limit.";
      color = Colors.orange;
      icon = Icons.warning;
    } else {
      message = "Over budget! Review your spending.";
      color = Colors.red;
      icon = Icons.error;
    }
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetTipCard extends StatefulWidget {
  @override
  State<_BudgetTipCard> createState() => _BudgetTipCardState();
}

class _BudgetTipCardState extends State<_BudgetTipCard> {
  String? tip;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchTip();
  }

  Future<void> _fetchTip() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      tip = await TipsService().getRandomTip();
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.indigo[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Text(
                'Error loading tip: $error',
                style: const TextStyle(color: Colors.red),
              )
            : Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.indigo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip ?? 'No tip available.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'New Tip',
                    onPressed: _fetchTip,
                  ),
                ],
              ),
      ),
    );
  }
}
