import 'package:flutter/material.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/rider/rider_dashboard_screen.dart';

class NavigationService {
  void navigateBasedOnRole(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        // Or use: Navigator.pushReplacementNamed(context, '/admin-dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
        break;
      case 'rider':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RiderDashboardScreen()),
        );

        // Or use: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverDashboard()));
        break;
      case 'vendor':
        Navigator.pushReplacementNamed(context, '/vendor-dashboard');
        // Or use: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VendorDashboard()));
        break;
      case 'rider':
      default:
        Navigator.pushReplacementNamed(context, '/rider-dashboard');
        // Or use: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RiderDashboard()));
        break;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome back!'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
