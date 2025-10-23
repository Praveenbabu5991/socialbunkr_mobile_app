
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

// Model
class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.parse(json['date']),
    );
  }
}

class ExpenseTrackerScreen extends StatefulWidget {
  final String propertyId;
  const ExpenseTrackerScreen({super.key, required this.propertyId});

  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  late Future<Map<String, dynamic>> _expensesFuture;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    _expensesFuture = _fetchExpenses();
  }

  Future<Map<String, dynamic>> _fetchExpenses() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    final monthFormat = DateFormat('yyyy-MM').format(_selectedMonth);

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/property/${widget.propertyId}/expenses/?month=$monthFormat'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddExpenseDialog(propertyId: widget.propertyId, onExpenseAdded: () {
        setState(() {
          _loadExpenses();
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _expensesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No data found.'));
                }

                final List<Expense> expenses = (snapshot.data!['expenses'] as List).map((e) => Expense.fromJson(e)).toList();
                final double totalExpenses = double.tryParse(snapshot.data!['total_expenses'].toString()) ?? 0.0;

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _loadExpenses();
                    });
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      _buildTotalCard(totalExpenses),
                      const SizedBox(height: 16),
                      if (expenses.isEmpty)
                        const Center(child: Text('No expenses found for this month.'))
                      else
                        ...expenses.map((e) => _ExpenseCard(expense: e)).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: const Color(0xFFE9B949), // Yellow
        child: const Icon(Icons.add, color: Colors.black), // Black icon for contrast
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActionChip(
            avatar: const Icon(Icons.calendar_today),
            label: Text(DateFormat('MMM yyyy').format(_selectedMonth)),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null && (picked.year != _selectedMonth.year || picked.month != _selectedMonth.month)) {
                setState(() {
                  _selectedMonth = picked;
                  _loadExpenses();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Total Expenses for Month', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('₹${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(expense.description),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(expense.date)),
        trailing: Text('₹${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _AddExpenseDialog extends StatefulWidget {
  final String propertyId;
  final VoidCallback onExpenseAdded;

  const _AddExpenseDialog({required this.propertyId, required this.onExpenseAdded});

  @override
  __AddExpenseDialogState createState() => __AddExpenseDialogState();
}

class __AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  double _amount = 0.0;
  bool _isSaving = false;

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() { _isSaving = true; });

    try {
      final apiBaseUrl = dotenv.env['API_BASE_URL'];
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/pg_tenant/property/${widget.propertyId}/expenses/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
        body: json.encode({
          'description': _description,
          'amount': _amount,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        }),
      );

      if (response.statusCode == 201) {
        widget.onExpenseAdded();
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to add expense: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Invalid number' : null,
              onSaved: (value) => _amount = double.parse(value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _isSaving ? null : _saveExpense, child: _isSaving ? const CircularProgressIndicator() : const Text('Save')),
      ],
    );
  }
}
