import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

// Model
class Payment {
  final String paymentId;
  final String tenantName;
  final String roomCode;
  final double rentAmount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidAt;

  Payment({
    required this.paymentId,
    required this.tenantName,
    required this.roomCode,
    required this.rentAmount,
    required this.dueDate,
    required this.isPaid,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'],
      tenantName: json['tenant_name'],
      roomCode: json['room_code'],
      rentAmount: double.tryParse(json['rent_amount'].toString()) ?? 0.0,
      dueDate: DateTime.parse(json['due_date']),
      isPaid: json['is_paid'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }
}

class RentPaymentScreen extends StatefulWidget {
  final String propertyId;
  const RentPaymentScreen({super.key, required this.propertyId});

  @override
  _RentPaymentScreenState createState() => _RentPaymentScreenState();
}

class _RentPaymentScreenState extends State<RentPaymentScreen> {
  late Future<List<Payment>> _paymentsFuture;
  DateTime _selectedMonth = DateTime.now();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    _paymentsFuture = _fetchPayments();
  }

  Future<List<Payment>> _fetchPayments() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    final monthFormat = DateFormat('yyyy-MM').format(_selectedMonth);

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/property/${widget.propertyId}/payments/?month=$monthFormat&status=$_selectedStatus'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> paymentsJson = data['payments'];
      return paymentsJson.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  Future<void> _markAsPaid(String paymentId) async {
     try {
      final apiBaseUrl = dotenv.env['API_BASE_URL'];
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/pg_tenant/payment/$paymentId/mark-done/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment marked as paid!'), backgroundColor: Colors.green),
        );
        setState(() {
          _loadPayments();
        });
      } else {
        throw Exception('Failed to mark as paid: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _sendReminder(String paymentId) async {
    try {
      final apiBaseUrl = dotenv.env['API_BASE_URL'];
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/pg_tenant/payment/$paymentId/send-reminder/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder sent successfully!'), backgroundColor: Colors.blue),
        );
      } else {
        throw Exception('Failed to send reminder: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: FutureBuilder<List<Payment>>(
              future: _paymentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No payments found for this period.'));
                }

                final payments = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    return _PaymentCard(payment: payments[index], onMarkAsPaid: _markAsPaid, onSendReminder: _sendReminder);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  _loadPayments();
                });
              }
            },
          ),
          // Status Picker
          DropdownButton<String>(
            value: _selectedStatus,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedStatus = newValue;
                  _loadPayments();
                });
              }
            },
            items: <String>['all', 'paid', 'due', 'overdue']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value[0].toUpperCase() + value.substring(1)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  final Future<void> Function(String) onMarkAsPaid;
  final Future<void> Function(String) onSendReminder;

  const _PaymentCard({required this.payment, required this.onMarkAsPaid, required this.onSendReminder});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !payment.isPaid && payment.dueDate.isBefore(DateTime.now());
    final statusText = payment.isPaid ? 'Paid' : (isOverdue ? 'Overdue' : 'Due');
    final statusColor = payment.isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(payment.tenantName, style: Theme.of(context).textTheme.titleLarge),
                Chip(
                  label: Text(statusText, style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            Text(payment.roomCode, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rent: ₹${payment.rentAmount.toStringAsFixed(0)}'),
                Text('Due: ${DateFormat('MMM dd, yyyy').format(payment.dueDate)}'),
              ],
            ),
            if (!payment.isPaid)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => onSendReminder(payment.paymentId),
                      child: const Text('Send Reminder'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => onMarkAsPaid(payment.paymentId),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFFE9B949)), // Yellow
                        foregroundColor: MaterialStateProperty.all(Colors.black), // Black text
                      ),
                      child: const Text('Mark as Paid'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}