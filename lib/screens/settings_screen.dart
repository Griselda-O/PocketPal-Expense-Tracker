import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pocketpal/screens/help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('isDarkMode') ?? false;
      _loading = false;
    });
  }

  Future<void> _setTheme(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', dark);
    setState(() => _isDark = dark);
    // Optionally notify provider if you want instant theme change
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    if (provider.isDarkMode != dark) provider.toggleTheme();
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'Are you sure you want to clear all your data? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/onboarding',
          (route) => false,
        );
      }
    }
  }

  Future<void> _exportCSV(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
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
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV exported to ${file.path}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(_isDark ? 'Dark' : 'Light'),
            trailing: Switch(
              value: _isDark,
              onChanged: (val) => _setTheme(val),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            onTap: () {
              final provider = Provider.of<ExpenseProvider>(
                context,
                listen: false,
              );
              _exportCSV(context, provider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            onTap: () {
              // TODO: Implement import logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Reset App Data'),
            onTap: _resetData,
          ),
        ],
      ),
    );
  }
}
