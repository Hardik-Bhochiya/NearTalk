import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _campusController = TextEditingController(text: 'Silicon Valley Campus');
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _campusController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final auth = context.read<AuthProvider>();
      final success = await auth.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        campus: _campusController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join Your Local Community',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connect with verified students, seniors, and locals in your area.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'e.g. Alex Morgan',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'College / Personal Email',
                  hintText: 'student@campus.edu',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campus
                CustomTextField(
                  controller: _campusController,
                  labelText: 'Campus / City Region',
                  hintText: 'e.g. Silicon Valley Campus',
                  prefixIcon: Icons.school_outlined,
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter your campus/region' : null,
                ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Minimum 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  text: 'Create Account',
                  isLoading: auth.status == AuthStatus.authenticating,
                  onPressed: _handleSignUp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
