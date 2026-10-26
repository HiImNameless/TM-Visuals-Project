import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/route_manager.dart';
import '../services/admin_auth_service.dart';
import '../viewmodels/admin_auth_viewmodel.dart';
import '../viewmodels/add_invoice_view_model.dart';
import '../services/add_invoice_service.dart';
import '../widgets/admin_widgets.dart';
import 'admin_sign_in.dart';

class AdminEntryScreen extends StatelessWidget {
  const AdminEntryScreen({super.key, required this.client, this.service});
  final SupabaseClient client;
  final AdminAuthService? service;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AdminAuthViewModel(service ?? AdminAuthService(client)),
    child: _AdminGate(client: client),
  );
}

class _AdminGate extends StatelessWidget {
  const _AdminGate({required this.client});
  final SupabaseClient client;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminAuthViewModel>();
    if (vm.userId == null) return const AdminSignInScreen();
    if (vm.checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!vm.authorized) {
      return Scaffold(
        appBar: AppBar(title: const Text('TM Visuals')),
        body: AdminContent(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vm.error == null
                      ? 'This account does not have administrator access.'
                      : adminError(vm.error!),
                ),
                TextButton(
                  onPressed: vm.check,
                  child: const Text('Check again'),
                ),
                OutlinedButton(
                  onPressed: vm.busy ? null : vm.signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // Every protected route is removed with this Navigator on sign-out/revocation.
    return ChangeNotifierProvider(
      key: ValueKey('invoice-draft-${vm.userId}'),
      create: (_) =>
          AddInvoiceViewModel(service: AddInvoiceService(supabase: client)),
      child: Navigator(
        key: ValueKey(vm.userId),
        initialRoute: '/',
        onGenerateRoute: (settings) =>
            RouteManager.getRoute(settings, client: client),
      ),
    );
  }
}
