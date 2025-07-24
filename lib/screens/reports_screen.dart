import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;
    final months = List.generate(12, (i) => i + 1);
    final years = {
      ...expenses.map((e) => e.date.year),
      DateTime.now().year,
    }.toList()..sort();
    final monthlyTotals = _getMonthlyTotals(expenses);
    final categoryTotals = _getCategoryTotals(
      expenses,
      selectedMonth,
      selectedYear,
    );
    final totalForMonth = categoryTotals.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  items: months
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(_monthName(m)),
                        ),
                      )
                      .toList(),
                  onChanged: (m) {
                    if (m != null) setState(() => selectedMonth = m);
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selectedYear,
                  items: years
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (y) {
                    if (y != null) setState(() => selectedYear = y);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Monthly Spending Trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= months.length)
                            return const SizedBox();
                          return Text(_monthShortName(months[idx]));
                        },
                        reservedSize: 32,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (int i = 0; i < months.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: monthlyTotals[months[i]] ?? 0,
                            color: Colors.indigo,
                            width: 16,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Category Breakdown (${_monthName(selectedMonth)} $selectedYear)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _ReportsCategoryPieChart(categoryTotals: categoryTotals),
            const SizedBox(height: 24),
            Text(
              'Total Spent: \$${totalForMonth.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Map<int, double> _getMonthlyTotals(List<Expense> expenses) {
    final Map<int, double> totals = {for (var m = 1; m <= 12; m++) m: 0.0};
    for (var e in expenses) {
      if (e.date.year == selectedYear) {
        totals[e.date.month] = (totals[e.date.month] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  Map<String, double> _getCategoryTotals(
    List<Expense> expenses,
    int month,
    int year,
  ) {
    final Map<String, double> totals = {};
    for (var e in expenses) {
      if (e.date.month == month && e.date.year == year) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m - 1];
  }

  String _monthShortName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m - 1];
  }
}

class _ReportsCategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  const _ReportsCategoryPieChart({required this.categoryTotals});
  @override
  Widget build(BuildContext context) {
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
