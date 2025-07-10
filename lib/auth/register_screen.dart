// ignore_for_file: prefer_const_constructors

import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_basket/auth/signin_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart' show IntlPhoneField;

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fieldsFade;
  final authService = AuthService();
  final fullname = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String _completePhoneNumber = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fieldsFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4CAF50);
    const accentGreen = Color(0xFF81C784);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 600 ? 24.0 : 16.0;
          final verticalPadding = constraints.maxWidth > 600 ? 16.0 : 8.0;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.2,
                      colors: [
                        accentGreen.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      ScaleTransition(
                        scale: _logoScale,
                        child: Hero(
                          tag: 'gb-logo',
                          child: Image.asset(
                            'assets/green_basket_splash.png',
                            width: Math.min(constraints.maxWidth * 0.3, 120),
                            height: Math.min(constraints.maxWidth * 0.3, 120),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      FadeTransition(
                        opacity: _fieldsFade,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: fullname,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^[a-zA-Z\s]+$'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_rounded),
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) => v!.isEmpty
                                    ? 'Please enter your name'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_rounded),
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v!.isEmpty
                                    ? 'Please enter your email'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              IntlPhoneField(
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(),
                                  ),
                                  counterText: '',
                                ),
                                initialCountryCode: 'PK',
                                onChanged: (phone) {
                                  print(phone.completeNumber);
                                  setState(() {
                                    _completePhoneNumber = phone.completeNumber;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_rounded),
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: true,
                                validator: (v) => v!.length < 6
                                    ? 'Minimum 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: confirmPasswordController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_rounded),
                                  labelText: 'Confirm Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: true,
                                validator: (v) => v!.length < 6
                                    ? 'Minimum 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final authService =
                                        AuthService(); // Singleton instance

                                    try {
                                      final user = await authService.register(
                                        fullename: fullname.text,
                                        phone: _completePhoneNumber,
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );

                                      if (user != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Registration successful!",
                                            ),
                                          ),
                                        );

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SignInScreen(),
                                          ),
                                        );
                                      }
                                    } on AuthException catch (e) {
                                      // Show user-friendly error from AuthService
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.message)),
                                      );
                                    } catch (e) {
                                      // Optional: handle other unforeseen errors
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Something went wrong.",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Back to sign in
                                },
                                child: const Text(
                                  'Already have an account? Sign in',
                                  style: TextStyle(color: primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      SizedBox(
                        height: 60,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return ClipPath(
                              clipper: _WaveClipper(_controller.value),
                              child: Container(color: accentGreen),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double progress;
  _WaveClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 12.0;
    final waveLength = size.width;
    path.lineTo(0, 0);
    for (double i = 0; i <= waveLength; i++) {
      path.lineTo(
        i,
        Math.sin((i / waveLength * 2 * Math.pi) + progress * 2 * Math.pi) *
                waveHeight +
            waveHeight,
      );
    }
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) => true;
}
