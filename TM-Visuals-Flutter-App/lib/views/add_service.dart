import 'package:flutter/material.dart';
import 'package:photography_flutter_application/viewmodels/service_list_viewmodel.dart';
import 'package:provider/provider.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<ServiceViewModel>();
    try {
      await vm.addService(
        serviceName: _serviceNameController.text,
        description: _descriptionController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Could not add service: $error')));
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ServiceViewModel>().isSaving;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Add Service', style: TextStyle(color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _serviceNameController,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Service name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a service name.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLength: 1000,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add service'),
            ),
          ],
        ),
      ),
    );
  }
}
