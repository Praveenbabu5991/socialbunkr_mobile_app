import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/host_bank_details/host_bank_details_bloc.dart';
import '../../data/repositories/user_repository.dart';

class HostBankDetailsPage extends StatelessWidget {
  const HostBankDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HostBankDetailsBloc(userRepository: UserRepository()),
      child: const _HostBankDetailsView(),
    );
  }
}

class _HostBankDetailsView extends StatefulWidget {
  const _HostBankDetailsView();

  @override
  _HostBankDetailsViewState createState() => _HostBankDetailsViewState();
}

class _HostBankDetailsViewState extends State<_HostBankDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  void _saveBankDetails() {
    if (_formKey.currentState!.validate()) {
      context.read<HostBankDetailsBloc>().add(
            SaveBankDetailsButtonPressed(
              accountNumber: _accountNumberController.text,
              ifscCode: _ifscCodeController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Details'),
      ),
      body: BlocListener<HostBankDetailsBloc, HostBankDetailsState>(
        listener: (context, state) {
          if (state is HostBankDetailsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bank Details Saved Successfully')),
            );
            Navigator.of(context).pop();
          }
          if (state is HostBankDetailsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ifscCodeController,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your IFSC code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<HostBankDetailsBloc, HostBankDetailsState>(
                builder: (context, state) {
                  if (state is HostBankDetailsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _saveBankDetails,
                    child: const Text('Save Details'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}