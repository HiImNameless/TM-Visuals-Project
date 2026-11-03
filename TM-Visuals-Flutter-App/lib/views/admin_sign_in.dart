import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_auth_viewmodel.dart';
import '../widgets/admin_widgets.dart';

const _bg = Color(0xFF050505);
const _gold = Color(0xFFFFB300);
const _goldDark = Color(0xFFB07F00);

class AdminSignInScreen extends StatefulWidget {
  const AdminSignInScreen({super.key});
  @override
  State<AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String? hint, {Widget? suffixIcon}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminAuthViewModel>();
    void submit() {
      if (form.currentState!.validate()) vm.signIn(email.text, password.text);
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Decorative circles (top-left and bottom-right)
          Positioned(top: -90, left: -20, child: _circle(180, _goldDark)),
          Positioned(top: -70, left: -90, child: _circle(160, _gold)),
          Positioned(bottom: -70, right: 40, child: _circle(150, _goldDark)),
          Positioned(bottom: -60, right: -60, child: _circle(150, _gold)),

          SafeArea(
            child: Stack(
              children: [
                const Positioned(top: 8, right: 16, child: _BrandMark()),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Form(
                        key: form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'TM Visuals Booking Management System',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 48),
                            _label('Email'),
                            TextFormField(
                              controller: email,
                              enabled: !vm.busy,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              style: const TextStyle(color: Colors.black),
                              decoration:
                                  _fieldDecoration('youremail@example.com'),
                              validator: (v) => v == null || !v.contains('@')
                                  ? 'Enter your email address.'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _label('Password'),
                            TextFormField(
                              controller: password,
                              enabled: !vm.busy,
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.password],
                              style: const TextStyle(color: Colors.black),
                              decoration: _fieldDecoration(null, suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              )),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Enter your password.'
                                  : null,
                              onFieldSubmitted: (_) => submit(),
                            ),
                            if (vm.error != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  adminError(vm.error!),
                                  textAlign: TextAlign.center,
                                  style:
                                      const TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            const SizedBox(height: 28),
                            Center(
                              child: SizedBox(
                                width: 244,
                                height: 52,
                                child: FilledButton(
                                  onPressed: vm.busy ? null : submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _gold,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: _goldDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child:
                                      Text(vm.busy ? 'Signing in…' : 'Login'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('TM',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(width: 6),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 2),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  color: _gold, size: 16),
            ),
          ],
        ),
        const Text('Visuals',
            style: TextStyle(color: _gold, fontSize: 20, height: 1.1)),
      ],
    );
  }
}