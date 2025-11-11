import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AssignTenantScreen extends StatefulWidget {
  final String bedId;
  final VoidCallback onTenantAssigned;

  const AssignTenantScreen({super.key, required this.bedId, required this.onTenantAssigned});

  @override
  _AssignTenantScreenState createState() => _AssignTenantScreenState();
}

class _AssignTenantScreenState extends State<AssignTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _upgradeLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _govtIdController = TextEditingController();
  final _rentController = TextEditingController();
  final _advanceController = TextEditingController();
  DateTime? _joinDate;

  late Razorpay _razorpay;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _govtIdController.dispose();
    _rentController.dispose();
    _advanceController.dispose();
    _razorpay.clear();
    _pollingTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startPollingForStatus() {
    int attempts = 0;
    const maxAttempts = 15; // 30 seconds timeout
    const pollInterval = Duration(seconds: 2);

    _pollingTimer = Timer.periodic(pollInterval, (timer) async {
      attempts++;
      debugPrint('[Mobile Polling] Attempt $attempts to check subscription status.');

      try {
        final apiBaseUrl = kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
        final secureStorage = FlutterSecureStorage();
        final token = await secureStorage.read(key: 'token');
        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/pg_tenant/subscriptions/status/'),
          headers: {
            if (token != null) 'Authorization': 'Token $token',
          },
        );

        if (response.statusCode == 200) {
          final statusData = json.decode(response.body);
          debugPrint('[Mobile Polling] Received status: ${statusData["plan"]}');
          if (statusData['plan'] == 'ACTIVE') {
            timer.cancel();
            debugPrint('[Mobile Polling] Status is ACTIVE. Stopping poll and refreshing UI.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subscription activated!'), backgroundColor: Colors.green),
            );
            widget.onTenantAssigned(); // Trigger UI refresh
          }
        }

        if (attempts >= maxAttempts) {
          timer.cancel();
          debugPrint('[Mobile Polling] Max attempts reached. Stopping poll.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status update taking longer than expected. Please refresh manually.'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        debugPrint('[Mobile Polling] Error checking status: $e');
        if (attempts >= maxAttempts) {
          timer.cancel();
        }
      }
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Activating subscription...'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(); // Close the upgrade dialog
    _startPollingForStatus(); // Start polling for the status update
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  Future<void> _handleUpgrade() async {
    setState(() {
      _upgradeLoading = true;
    });

    try {
      final apiBaseUrl = kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/pg_tenant/subscriptions/initiate/'),
        headers: {
          if (token != null) 'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 201) { // Status is 201 Created
        final subscriptionData = json.decode(response.body);
        final subscriptionId = subscriptionData['id']; // Corrected field name

        if (subscriptionId == null) {
          throw Exception('Subscription ID not found in response');
        }

        var options = {
          'key': dotenv.env['RAZORPAY_KEY_ID'],
          'subscription_id': subscriptionId,
          'name': 'AffordaNest Pro',
          'description': 'Unlimited access to all features.',
          'prefill': {
            'contact': '9999999999',
            'email': 'test@example.com'
          }
        };
        _razorpay.open(options);
      } else {
        throw Exception('Failed to initiate subscription. Status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _upgradeLoading = false;
      });
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upgrade to Pro'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You have reached the free tenant limit.'),
                Text('Upgrade to Pro to add unlimited tenants.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: _upgradeLoading ? null : _handleUpgrade,
              child: _upgradeLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Upgrade Now'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectJoinDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joinDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _joinDate) {
      setState(() {
        _joinDate = picked;
      });
    }
  }

  Future<void> _assignTenant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_joinDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a join date.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiBaseUrl = kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/beds/${widget.bedId}/assign-tenant/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'govt_id': _govtIdController.text,
          'join_date': DateFormat('yyyy-MM-dd').format(_joinDate!),
          'rent': _rentController.text,
          'advance_amount': _advanceController.text,
        }),
      );

      if (response.statusCode == 201) {
        widget.onTenantAssigned();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tenant assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 403) {
        _showUpgradeDialog();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to assign tenant: ${errorData.toString()}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign New Tenant'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _govtIdController,
              decoration: const InputDecoration(labelText: 'Government ID'),
              validator: (value) => value!.isEmpty ? 'Please enter a Government ID' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rentController,
              decoration: const InputDecoration(labelText: 'Monthly Rent'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter the rent amount' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _advanceController,
              decoration: const InputDecoration(labelText: 'Advance Amount'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter the advance amount' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Join Date'),
              subtitle: Text(_joinDate == null ? 'Not selected' : DateFormat('yyyy-MM-dd').format(_joinDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectJoinDate(context),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _assignTenant,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Assign Tenant'),
            ),
          ],
        ),
      ),
    );
  }
}
