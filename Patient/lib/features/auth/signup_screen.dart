import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/section_header.dart';
import 'providers/auth_provider.dart';
import '../onboarding/providers/onboarding_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final email = _emailCtrl.text.trim();
      final name = _nameCtrl.text.trim();
      
      final metadata = {
        'full_name': name,
        // The rest of the metadata will be collected by the onboarding wizard
      };

      final success = await ref.read(authProvider.notifier).signUp(
        email,
        _passCtrl.text,
        metadata,
      );

      if (mounted && success) {
         // Pre-fill the wizard's name field
         ref.read(onboardingProvider.notifier).updateBasicInfo(fullName: name);
         // Redirect to the new Medical Onboarding Wizard
         context.go('/onboarding-wizard');
      } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed. Profile may already exist.')));
      }
    } catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Account Credentials'),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailCtrl,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (val) => val != null && val.contains('@') ? null : 'Valid email required',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passCtrl,
                hintText: 'Secure Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (val) => val != null && val.length > 5 ? null : 'Min 6 characters required',
              ),
              
              const SizedBox(height: 32),
              const SectionHeader(title: 'Basic Identity'),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameCtrl,
                hintText: 'Full Legal Name',
                prefixIcon: const Icon(Icons.person),
                validator: (val) => val != null && val.isNotEmpty ? null : 'Name required',
              ),
              
              const SizedBox(height: 64),
              SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Continue to Patient Profile',
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

