import 'package:flutter/material.dart';
import '../../auth/signin_screen.dart';
import './../../services/auth_service.dart';
import './category_list_screen.dart';
import 'product_list_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _accentGreen = Color(0xFF81C784);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final maxContentWidth = isTablet ? 1200.0 : double.infinity;
    final padding = isTablet ? 32.0 : 20.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          title: Text(
            'Admin Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 28 : 20,
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.logout_rounded, size: isTablet ? 30 : 24),
              tooltip: 'Logout',
              onPressed: () async {
                await AuthService().signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 32 : 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primaryGreen, _accentGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryGreen.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTablet ? 16 : 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: isTablet ? 32 : 24,
                              ),
                            ),
                            SizedBox(width: isTablet ? 20 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, Admin!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 28 : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Manage your store efficiently',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: isTablet ? 18 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 30),

                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 16),

                    Expanded(
                      child: GridView.count(
                        padding: EdgeInsets.symmetric(vertical: padding / 2),
                        crossAxisCount: isTablet ? 4 : 2,
                        crossAxisSpacing: isTablet ? 24 : 16,
                        mainAxisSpacing: isTablet ? 24 : 16,
                        childAspectRatio: isTablet ? 1.0 : 1.1,
                        children: [
                          _ActionCard(
                            title: 'Categories',
                            icon: Icons.category_rounded,
                            color: _primaryGreen,
                            animationDelay: 200,
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CategoryListScreen(),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            title: 'Products',
                            icon: Icons.shopping_basket_rounded,
                            color: _accentGreen,
                            animationDelay: 400,
                            isTablet: isTablet,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProductListScreen(),
                              ),
                            ),
                          ),
                          if (isTablet) ...[
                            _ActionCard(
                              title: 'Orders',
                              icon: Icons.list_alt_rounded,
                              color: Colors.orange,
                              animationDelay: 600,
                              isTablet: isTablet,
                              onTap: () {},
                            ),
                            _ActionCard(
                              title: 'Analytics',
                              icon: Icons.analytics_rounded,
                              color: Colors.blue,
                              animationDelay: 800,
                              isTablet: isTablet,
                              onTap: () {},
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.animationDelay,
    required this.isTablet,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int animationDelay;
  final bool isTablet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + animationDelay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final safeOpacity = value.clamp(0.0, 1.0) as double;

        return Opacity(
          opacity: safeOpacity,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: color.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: isTablet ? 40 : 32, color: color),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
