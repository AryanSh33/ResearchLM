import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill with test credentials for easier testing
    _emailController.text = 'test@example.com';
    _passwordController.text = 'testpassword123';
    _userNameController.text = 'Test User';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  Icon(
                    Icons.psychology,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ResearchLM',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI-Powered Literature Survey Generator',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Form Card
                  Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Form Title
                            Text(
                              _isLogin ? 'Sign In' : 'Create Account',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Debug Info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Debug Info:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Test Email: test@example.com',
                                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                                  ),
                                  Text(
                                    'Test Password: testpassword123',
                                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Username Field (only for registration)
                            if (!_isLogin) ...[
                              CustomTextField(
                                controller: _userNameController,
                                label: 'Username',
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Username must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email Field
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!EmailValidator.validate(value.trim())) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (!_isLogin && value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Error Message
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                if (authProvider.error != null) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Theme.of(context).colorScheme.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            authProvider.error!,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Submit Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return CustomButton(
                                  text: _isLogin ? 'Sign In' : 'Create Account',
                                  onPressed: authProvider.isLoading ? null : () => _handleSubmit(context),
                                  isLoading: authProvider.isLoading,
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Toggle between login/register
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                                context.read<AuthProvider>().clearError();
                              },
                              child: Text(
                                _isLogin
                                    ? "Don't have an account? Sign up"
                                    : "Already have an account? Sign in",
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Google Sign In Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return CustomButton(
                                  text: 'Continue with Google',
                                  onPressed: authProvider.isLoading ? null : () => _handleGoogleSignIn(context),
                                  isLoading: authProvider.isLoading,
                                  icon: Icons.g_mobiledata,
                                  isOutlined: true,
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Debug Buttons
                            if (!_isLogin) ...[
                              const Divider(),
                              const SizedBox(height: 16),
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return CustomButton(
                                    text: 'Create Dummy User',
                                    onPressed: authProvider.isLoading ? null : () => _createDummyUser(context),
                                    isLoading: authProvider.isLoading,
                                    isOutlined: true,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success;

    print('Attempting ${_isLogin ? 'sign in' : 'registration'} with email: ${_emailController.text.trim()}');

    if (_isLogin) {
      success = await authProvider.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authProvider.registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _userNameController.text.trim(),
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Signed in successfully!' : 'Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      print('${_isLogin ? 'Sign in' : 'Registration'} successful');
    } else if (mounted) {
      print('${_isLogin ? 'Sign in' : 'Registration'} failed: ${authProvider.error}');
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    print('Attempting Google sign in...');

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed in with Google successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      print('Google sign in successful');
    } else if (mounted && authProvider.error != null) {
      print('Google sign in failed: ${authProvider.error}');
    }
  }

  Future<void> _createDummyUser(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    print('Creating dummy user...');

    await authProvider.createDummyUser();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dummy user created! Try signing in now.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}