import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/app_color.dart';
import '../../main/screen/main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  // Demo Credentials
  static const _adminEmail = 'admin@gmail.com';
  static const _adminPass = 'admin@123';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email == _adminEmail && pass == _adminPass) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);

      if (!mounted) return;

      setState(() => _loading = false);

      Fluttertoast.showToast(
        msg: 'Login successful. Welcome to Suwidhaa!',
        backgroundColor: AppColor.primary,
        textColor: AppColor.white,
        gravity: ToastGravity.BOTTOM,
      );

      Get.offAll(() => const MainScreen());
    } else {
      if (!mounted) return;

      setState(() => _loading = false);

      Fluttertoast.showToast(
        msg: 'Invalid email or password.',
        backgroundColor: AppColor.red,
        textColor: AppColor.white,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColor.bg,
      body: isWeb ? _webLayout() : _mobileLayout(),
    );
  }

  // =========================================================
  // LAYOUTS
  // =========================================================

  Widget _webLayout() {
    return Row(
      children: [
        Expanded(flex: 5, child: _brandPanel()),
        Expanded(flex: 5, child: _formPanel(showCard: false)),
      ],
    );
  }

  Widget _mobileLayout() {
    return _formPanel(showCard: true);
  }

  // =========================================================
  // LEFT BRAND PANEL (WEB)
  // =========================================================

  Widget _brandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary,
            AppColor.deepPrimary,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: AppColor.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: AppColor.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 64,
              vertical: 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Logo & Name
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: AppColor.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),

                    const Text(
                      'SUWIDHAA',
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 64),

                // Main Heading
                const Text(
                  'Manage Your\nDigital Services',
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'A unified platform to manage digital services, '
                      'applications, education, payments and business operations.',
                  style: TextStyle(
                    color: AppColor.white.withOpacity(0.85),
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 48),

                _featureRow(
                  Icons.miscellaneous_services_rounded,
                  'Digital Services Management',
                ),

                const SizedBox(height: 18),

                _featureRow(
                  Icons.school_rounded,
                  'Education & Student Services',
                ),

                const SizedBox(height: 18),

                _featureRow(
                  Icons.assignment_rounded,
                  'Online Applications & Forms',
                ),

                const SizedBox(height: 18),

                _featureRow(
                  Icons.payments_rounded,
                  'Payments & Business Services',
                ),

                const SizedBox(height: 52),

                Text(
                  'ONE PLATFORM • MULTIPLE SERVICES',
                  style: TextStyle(
                    color: AppColor.white.withOpacity(0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FEATURE ROW
  // =========================================================

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColor.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: AppColor.white,
            size: 19,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColor.white.withOpacity(0.95),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // RIGHT FORM PANEL
  // =========================================================

  Widget _formPanel({required bool showCard}) {
    final content = _loginForm();

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: showCard ? 20 : 40,
          vertical: 40,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: showCard
              ? Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColor.border),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: content,
          )
              : content,
        ),
      ),
    );
  }

  // =========================================================
  // LOGIN FORM
  // =========================================================

  Widget _loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo for mobile
          if (MediaQuery.of(context).size.width < 900) ...[
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColor.primary, AppColor.deepPrimary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: AppColor.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'SUWIDHAA',
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],

          // Header
          const Text(
            'Welcome Back 👋',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Sign in to your Suwidhaa Admin Panel',
            style: TextStyle(
              fontSize: 14,
              color: AppColor.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          // Email
          _label('Email Address'),

          const SizedBox(height: 8),

          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Enter your email',
              Icons.mail_outline_rounded,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Email is required';
              }

              final ok = RegExp(
                r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$',
              ).hasMatch(v.trim());

              if (!ok) return 'Enter a valid email';

              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password
          _label('Password'),

          const SizedBox(height: 8),

          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            decoration: _inputDecoration(
              'Enter your password',
              Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColor.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscure = !_obscure);
                },
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Password is required';
              }

              if (v.length < 6) {
                return 'Minimum 6 characters required';
              }

              return null;
            },
          ),

          const SizedBox(height: 28),

          // Login Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: AppColor.white,
                disabledBackgroundColor: AppColor.primary.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColor.white,
                  ),
                ),
              )
                  : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Footer
          const Center(
            child: Text(
              'Secure access to your digital services',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.grey,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Center(
            child: Text(
              'POWERED BY SUWIDHAA',
              style: TextStyle(
                color: AppColor.primary.withOpacity(0.7),
                fontSize: 10,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColor.black,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColor.grey,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: AppColor.textSecondary,
      ),
      filled: true,
      fillColor: AppColor.bg,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColor.primary,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColor.red.withOpacity(0.7),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.red),
      ),
    );
  }
}