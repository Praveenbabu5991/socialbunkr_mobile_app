import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SendMessageDialog extends StatefulWidget {
  final String propertyId;
  final VoidCallback onMessageSent;

  const SendMessageDialog({
    super.key,
    required this.propertyId,
    required this.onMessageSent,
  });

  @override
  _SendMessageDialogState createState() => _SendMessageDialogState();
}

class _SendMessageDialogState extends State<SendMessageDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() {
        _errorMessage = 'Message cannot be empty.';
        _isLoading = false;
      });
      return;
    }

    final apiBaseUrl = kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    final hostId = await secureStorage.read(key: 'user_id'); // Retrieve user_id (which is host_id) from secure storage

    if (hostId == null) {
      setState(() {
        _errorMessage = 'User ID (Host ID) is not available. Please log in again.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/communications/send/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
        body: json.encode({
          'host_id': hostId, // Use the retrieved hostId
          'property_id': widget.propertyId,
          'channel': 'whatsapp', // Hardcoded to WhatsApp as per requirement
          'message': message,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _successMessage = 'Message sent successfully!';
        });
        widget.onMessageSent(); // Callback to refresh or notify parent
        Navigator.of(context).pop(); // Close dialog on success
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage = errorData['error'] ?? 'Failed to send message.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Message to All Tenants'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 16),
            // Channel selection is removed as per requirement, hardcoded to WhatsApp
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Channel: WhatsApp (to all active tenants)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendMessage,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Send'),
        ),
      ],
    );
  }
}
