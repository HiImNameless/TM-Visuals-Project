import 'package:flutter/material.dart';
import 'package:photography_flutter_application/models/service_list_model.dart';
import 'package:photography_flutter_application/viewmodels/service_list_viewmodel.dart';
import 'package:provider/provider.dart';

class EditServiceView extends StatefulWidget {
  final ServicesListModel service;
  const EditServiceView({super.key, required this.service});

  @override
  State<EditServiceView> createState() => _EditServiceViewState();
}

class _EditServiceViewState extends State<EditServiceView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serviceNameController;
  late final TextEditingController _descriptionController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _serviceNameController = TextEditingController(
      text: widget.service.serviceName,
    );
    _descriptionController = TextEditingController(
      text: widget.service.description,
    );
    _isActive = widget.service.availability == 'Available';
  }

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
      await vm.updateService(
        widget.service.copyWith(
          serviceName: _serviceNameController.text.trim(),
          description: _descriptionController.text.trim(),
          availability: _isActive ? 'Available' : 'Unavailable',
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save service: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ServiceViewModel>().isSaving;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Edit Service',
          style: TextStyle(color: Colors.white),
        ),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Available for booking'),
              value: _isActive,
              activeTrackColor: Colors.orange,
              onChanged: (value) => setState(() => _isActive = value),
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
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
