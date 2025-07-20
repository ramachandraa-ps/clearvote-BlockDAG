import 'package:flutter/material.dart';
import 'package:clearvote/features/auth/screens/login_screen.dart';
import 'package:clearvote/features/home/screens/home_screen.dart';
import 'package:clearvote/core/utils/validators.dart';
import 'package:clearvote/features/auth/widgets/custom_text_field.dart';
import 'package:clearvote/features/auth/widgets/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would handle registration here
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111921),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App title
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ClearVote',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                              height: 1.28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Create account text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Create an account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Signup form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Name field
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CustomTextField(
                                controller: _nameController,
                                hintText: 'Full Name',
                                validator: Validators.validateName,
                              ),
                            ),
                            
                            // Email field
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CustomTextField(
                                controller: _emailController,
                                hintText: 'Email Address',
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
                              ),
                            ),
                            
                            // Password field
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CustomTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                obscureText: !_isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF93ADC6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                validator: Validators.validatePassword,
                              ),
                            ),
                            
                            // Confirm Password field
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CustomTextField(
                                controller: _confirmPasswordController,
                                hintText: 'Confirm Password',
                                obscureText: !_isConfirmPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF93ADC6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            
                            // Terms and conditions
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 12,
                              ),
                              child: const Text(
                                'By signing up, you agree to our Terms of Service and Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFF93ADC6),
                                  fontSize: 12,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            
                            // Sign up button
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CustomButton(
                                text: 'Sign Up',
                                onPressed: _handleSignup,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Login link
            Padding(
              padding: const EdgeInsets.only(
                bottom: 32,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Color(0xFF93ADC6),
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color(0xFF4296EA),
                        fontSize: 14,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}