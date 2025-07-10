import 'package:flutter/material.dart';
import 'package:green_basket/auth/signin_screen.dart';
import 'package:green_basket/screens/admin/admin_dashboard_screen.dart';
import 'package:green_basket/screens/rider/rider_dashboard_screen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/user/user_dashboard_scree.dart'; // Adjust path
import '../auth/signin_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role') ?? '';

    if (!mounted) return;

    if (isLoggedIn) {
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (role == 'rider') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RiderDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/green_basket_splash.png', width: 150),
      ),
    );
  }
}
