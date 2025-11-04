
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialbunkr_mobile_app/logic/blocs/host_verification/host_verification_bloc.dart';
import 'package:socialbunkr_mobile_app/data/providers/host_verification_api_provider.dart';
import 'package:socialbunkr_mobile_app/logic/blocs/authentication/authentication_bloc.dart';
import 'package:socialbunkr_mobile_app/routes/app_router.dart';

class HostVerificationPage extends StatelessWidget {
  const HostVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HostVerificationBloc(hostVerificationApiProvider: HostVerificationApiProvider()),
      child: const HostVerificationForm(),
    );
  }
}

class HostVerificationForm extends StatefulWidget {
  const HostVerificationForm({super.key});

  @override
  State<HostVerificationForm> createState() => _HostVerificationFormState();
}

class _HostVerificationFormState extends State<HostVerificationForm> {
  final _formKey = GlobalKey<FormState>();

  String _documentType = 'govt_id';
  XFile? _document;

  Future<void> _pickDocument() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _document = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0B3D2E);
    const String fontFamily = 'Poppins';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Verification', style: TextStyle(fontFamily: fontFamily, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: BlocListener<HostVerificationBloc, HostVerificationState>(
        listener: (context, state) {
          if (state is HostVerificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to submit host verification: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is HostVerificationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Host verification submitted successfully!', style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.grey[300],
              ),
            );
            // After successful submission, refresh authentication status
            BlocProvider.of<AuthenticationBloc>(context).add(AppStarted());
            Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDropdown(
                  value: _documentType,
                  onChanged: (value) => setState(() => _documentType = value!),
                  items: ['govt_id', 'utility_bill', 'other'],
                  labelText: 'Document Type',
                ),
                const SizedBox(height: 16),
                _buildDocumentPicker(),
                const SizedBox(height: 24),
                BlocBuilder<HostVerificationBloc, HostVerificationState>(
                  builder: (context, state) {
                    return state is HostVerificationLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_document == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select a document')),
                                  );
                                  return;
                                }
                                final authState = BlocProvider.of<AuthenticationBloc>(context).state;
                                String? userId;
                                if (authState is AuthenticationAuthenticated) {
                                  userId = authState.userId;
                                }
                                if (userId == null || userId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('User ID not found. Please log in again.')),
                                  );
                                  return;
                                }
                                BlocProvider.of<HostVerificationBloc>(context).add(
                                  HostVerificationSubmitted(
                                    documentType: _documentType,
                                    document: _document!,
                                    userId: userId,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Submit for Verification',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String value, required ValueChanged<String?> onChanged, required List<String> items, required String labelText}) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.replaceAll('_', ' ').toUpperCase()),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDocumentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDocument,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _document != null
                ? Image.network(_document!.path, fit: BoxFit.cover) // Use Image.network for web
                : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
