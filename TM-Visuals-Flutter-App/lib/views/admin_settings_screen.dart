import 'package:flutter/material.dart';
import '../widgets/admin_page_app_bar.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_settings_viewmodel.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load current email/phone, then prefill the fields
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<AdminSettingsViewModel>();
      await vm.load();
      if (!mounted) return;
      _emailCtrl.text = vm.settings.email;
      _phoneCtrl.text = vm.settings.phone;
    });
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final vm = context.read<AdminSettingsViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    vm.settings.password = _passwordCtrl.text;
    vm.settings.email = _emailCtrl.text;
    vm.settings.phone = _phoneCtrl.text;

    final ok = await vm.save();
    if (!mounted) return;

    if (ok) _passwordCtrl.clear();

    final text = ok
        ? (vm.successMessage ?? 'Settings saved')
        : (vm.errorMessage ?? 'Could not save settings');
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  InputDecoration _decoration(String label, String hint, {Widget? suffix}) {
    return InputDecoration(
      icon: SizedBox(
        width: 130,
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      suffixIcon: suffix,
      enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24)),
      focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.amber)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminSettingsViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const AdminPageAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: Colors.amber),
            ),
          Container(
            height: 300,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _passwordCtrl,
                  obscureText: vm.hidePassword,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _decoration(
                    'Change Password:',
                    'New password...',
                    suffix: IconButton(
                      icon: Icon(
                        vm.hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: vm.toggleHidePassword,
                    ),
                  ),
                ),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _decoration('Change Email:', 'Email...'),
                ),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _decoration('Change Phone:', 'Phone...'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: (vm.isSaving || vm.isLoading) ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: vm.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('SAVE',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}