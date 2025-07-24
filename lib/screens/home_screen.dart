import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import 'budget_screen.dart';
import 'reports_screen.dart';
import 'expenses_screen.dart';

class BudgetPlaceholderScreen extends StatelessWidget {
  const BudgetPlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Budget Management (Coming Soon)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class ReportsPlaceholderScreen extends StatelessWidget {
  const ReportsPlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Reports & Analysis (Coming Soon)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab =
      0; // 0: Home, 1: Profile, 2: Budget, 3: Reports, 4: Expenses
  int _selectedChartPeriod = 0; // 0: Week, 1: Month, 2: Year
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    await prefs.remove('email');
    await prefs.remove('name');
    await prefs.remove('phone');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _getTabPage() {
    switch (_selectedTab) {
      case 0:
        return _buildHomeDashboard();
      case 1:
        return const ProfileScreen();
      case 2:
        return const BudgetScreen();
      case 3:
        return const ReportsScreen();
      case 4:
        return const ExpensesScreen();
      default:
        return _buildHomeDashboard();
    }
  }

  Widget _buildHomeDashboard() {
    final provider = Provider.of<ExpenseProvider>(context);
    final double diff = provider.totalMonthlyExpenses - provider.monthlyBudget;
    Widget budgetStatus;
    if (diff > 0) {
      budgetStatus = Text(
        'You are over budget by GHS ${diff.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    } else {
      budgetStatus = Text(
        'You are under budget by GHS ${diff.abs().toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    double progress = provider.budgetProgress;
    Color progressColor;
    if (progress < 0.8) {
      progressColor = Colors.green;
    } else if (progress < 1.0) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: provider.expenses.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 80.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wallet,
                              size: 80,
                              color: Colors.indigo.withOpacity(0.3),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "No expenses yet!",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Start tracking your spending by adding your first expense.",
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/add-expense');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Add Expense"),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Budget Progress Bar Section
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Monthly Budget: GHS ${provider.monthlyBudget.toStringAsFixed(2)}",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            LinearProgressIndicator(
                                              value: progress > 1.0
                                                  ? 1.0
                                                  : progress,
                                              minHeight: 10,
                                              backgroundColor: Colors.grey[300],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    progressColor,
                                                  ),
                                            ),
                                            if (progress >= 1.0)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Text(
                                                  "Over Budget!",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            budgetStatus,
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Edit Budget',
                                    onPressed: () async {
                                      final controller = TextEditingController(
                                        text: provider.monthlyBudget
                                            .toStringAsFixed(2),
                                      );
                                      final result = await showDialog<double>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Set Monthly Budget',
                                          ),
                                          content: TextField(
                                            controller: controller,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            decoration: const InputDecoration(
                                              labelText: 'Budget (GHS)',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                final value = double.tryParse(
                                                  controller.text,
                                                );
                                                if (value != null &&
                                                    value > 0) {
                                                  Navigator.pop(context, value);
                                                }
                                              },
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (result != null) {
                                        provider.monthlyBudget = result;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.account_balance_wallet),
                                label: const Text('Open Budget Page'),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/budget');
                                },
                              ),
                            ),
                          ),
                          // Export Buttons Section
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _exportCSV(context, provider),
                                    icon: const Icon(Icons.download),
                                    label: const Text('Export CSV'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _exportPDF(context, provider),
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text('Export PDF'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Chart & Analytics Section
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: ToggleButtons(
                                      borderRadius: BorderRadius.circular(24),
                                      isSelected: [0, 1, 2]
                                          .map((i) => _selectedChartPeriod == i)
                                          .toList(),
                                      onPressed: (index) {
                                        setState(() {
                                          _selectedChartPeriod = index;
                                        });
                                      },
                                      selectedColor: Colors.white,
                                      fillColor: Colors.indigo,
                                      color: Colors.indigo,
                                      constraints: const BoxConstraints(
                                        minWidth: 80,
                                        minHeight: 36,
                                      ),
                                      children: const [
                                        Text('Week'),
                                        Text('Month'),
                                        Text('Year'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedChartPeriod == 0
                                        ? "This Week's Expenses"
                                        : _selectedChartPeriod == 1
                                        ? "This Month's Expenses"
                                        : "This Year's Expenses",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  SizedBox(
                                    height: 260,
                                    child: _buildDotChart(
                                      context,
                                      provider,
                                      _selectedChartPeriod,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildAnalytics(
                                    provider,
                                    _selectedChartPeriod,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Expenses List Section
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Expenses:",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  ...provider.expenses.map(
                                    (e) => Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        title: Text(e.category),
                                        subtitle: Text(e.note),
                                        trailing: Text(
                                          'GHS ${e.amount.toStringAsFixed(2)}',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/add-expense',
                                        );
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text("Add Expense"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("PocketPal Home"),
        actions: [
          if (_userName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  'Hi, $_userName!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => provider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _getTabPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings (Coming Soon)', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

Map<String, double> _monthlyExpenses(ExpenseProvider provider) {
  final now = DateTime.now();
  final Map<String, double> data = {};
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  for (int i = 0; i < daysInMonth; i++) {
    final day = DateTime(now.year, now.month, i + 1);
    final key = "${day.month}/${day.day}";
    data[key] = provider.expenses
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

Map<String, double> _yearlyExpenses(ExpenseProvider provider) {
  final now = DateTime.now();
  final Map<String, double> data = {};
  for (int i = 1; i <= 12; i++) {
    final key = "${now.year}/$i";
    data[key] = provider.expenses
        .where((e) => e.date.month == i && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
  return data;
}

Widget _buildAnalytics(ExpenseProvider provider, int period) {
  Map<String, double> data;
  String label;
  if (period == 0) {
    data = provider.dailyExpensesThisWeek;
    label = "day";
  } else if (period == 1) {
    data = _monthlyExpenses(provider);
    label = "day";
  } else {
    data = _yearlyExpenses(provider);
    label = "month";
  }
  final keys = data.keys.toList();
  final values = data.values.toList();
  if (values.isEmpty || values.every((v) => v == 0)) {
    return const SizedBox();
  }
  final avg = values.reduce((a, b) => a + b) / values.length;
  final maxVal = values.reduce((a, b) => a > b ? a : b);
  final minVal = values.reduce((a, b) => a < b ? a : b);
  final maxIdx = values.indexOf(maxVal);
  final minIdx = values.indexOf(minVal);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text("Average per $label: GHS ${avg.toStringAsFixed(2)}"),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Expanded(
            child: Text(
              "Highest $label: ${keys[maxIdx]} (GHS ${maxVal.toStringAsFixed(2)})",
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Expanded(
            child: Text(
              "Lowest $label: ${keys[minIdx]} (GHS ${minVal.toStringAsFixed(2)})",
            ),
          ),
        ],
      ),
    ],
  );
}

Future<void> _exportCSV(BuildContext context, ExpenseProvider provider) async {
  final List<List<dynamic>> rows = [
    ['ID', 'Category', 'Amount', 'Date', 'Note'],
    ...provider.expenses.map(
      (e) => [e.id, e.category, e.amount, e.date.toIso8601String(), e.note],
    ),
  ];
  final csvData = const ListToCsvConverter().convert(rows);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/expenses.csv');
  await file.writeAsString(csvData);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('CSV Exported'),
      content: Text('CSV exported to ${file.path}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Share.shareXFiles([
              XFile(file.path),
            ], text: 'PocketPal Expenses CSV');
            Navigator.pop(ctx);
          },
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ],
    ),
  );
}

Future<void> _exportPDF(BuildContext context, ExpenseProvider provider) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PocketPal Expenses',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['ID', 'Category', 'Amount', 'Date', 'Note'],
              data: provider.expenses
                  .map(
                    (e) => [
                      e.id,
                      e.category,
                      e.amount.toStringAsFixed(2),
                      e.date.toIso8601String(),
                      e.note,
                    ],
                  )
                  .toList(),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFEEEEEE),
              ),
            ),
          ],
        );
      },
    ),
  );
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/expenses.pdf');
  await file.writeAsBytes(await pdf.save());
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('PDF Exported'),
      content: Text('PDF exported to ${file.path}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Share.shareXFiles([
              XFile(file.path),
            ], text: 'PocketPal Expenses PDF');
            Navigator.pop(ctx);
          },
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ],
    ),
  );
}

Widget _buildDotChart(
  BuildContext context,
  ExpenseProvider provider,
  int period,
) {
  Map<String, double> data;
  if (period == 0) {
    data = provider.dailyExpensesThisWeek;
  } else if (period == 1) {
    data = _monthlyExpenses(provider);
  } else {
    data = _yearlyExpenses(provider);
  }
  final keys = data.keys.toList().reversed.toList();
  final values = data.values.toList().reversed.toList();

  // Limit number of dots for month/year to avoid overflow
  List<String> limitedKeys = keys;
  List<double> limitedValues = values;
  if (period != 0 && keys.length > 14) {
    limitedKeys = keys.sublist(keys.length - 14);
    limitedValues = values.sublist(values.length - 14);
  }

  final theme = Theme.of(context);
  final dotColor = theme.colorScheme.primary;

  int labelStep = 1;
  double labelAngle = 0;
  if (period == 1) {
    labelStep = 3;
    labelAngle = -0.7;
  } else if (period == 2) {
    labelStep = 1;
    labelAngle = -0.7;
  }

  if (limitedKeys.isEmpty || limitedValues.isEmpty) {
    return const SizedBox(height: 200);
  }

  return LineChart(
    LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            limitedValues.length,
            (i) => FlSpot(i.toDouble(), limitedValues[i]),
          ),
          isCurved: false,
          dotData: FlDotData(show: true),
          barWidth: 2,
          color: dotColor,
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index < 0 || index >= limitedKeys.length)
                return const Text('');
              if (period == 0 || index % (period == 1 ? 3 : 1) == 0) {
                return Transform.rotate(
                  angle: period == 0 ? 0 : -0.7,
                  child: Text(
                    limitedKeys[index],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 200,
            getTitlesWidget: (value, _) {
              if (value % 200 == 0) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: limitedValues.isNotEmpty
          ? (limitedValues.reduce((a, b) => a > b ? a : b) * 1.2)
          : 10,
    ),
  );
}
