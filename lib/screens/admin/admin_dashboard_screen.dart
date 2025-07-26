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

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

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

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileBreakpoint;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;
  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

  double _getMaxContentWidth(BuildContext context) {
    if (_isMobile(context)) return double.infinity;
    if (_isTablet(context)) return 900.0;
    if (_isDesktop(context)) return 1200.0;
    return 1000.0;
  }

  double _getPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 32.0;
    if (_isDesktop(context)) return 48.0;
    return 24.0;
  }

  double _getHeaderFontSize(BuildContext context) {
    if (_isMobile(context)) return 20.0;
    if (_isTablet(context)) return 28.0;
    if (_isDesktop(context)) return 32.0;
    return 24.0;
  }

  double _getWelcomeFontSize(BuildContext context) {
    if (_isMobile(context)) return 20.0;
    if (_isTablet(context)) return 28.0;
    if (_isDesktop(context)) return 32.0;
    return 24.0;
  }

  double _getQuickActionsFontSize(BuildContext context) {
    if (_isMobile(context)) return 22.0;
    if (_isTablet(context)) return 28.0;
    if (_isDesktop(context)) return 32.0;
    return 24.0;
  }

  int _getGridCount(BuildContext context) {
    if (_isMobile(context)) return 2;
    if (_isTablet(context)) return 4;
    if (_isDesktop(context)) return 6;
    return 3;
  }

  double _getGridSpacing(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 32.0;
    return 20.0;
  }

  double _getHeaderCardPadding(BuildContext context) {
    if (_isMobile(context)) return 20.0;
    if (_isTablet(context)) return 32.0;
    if (_isDesktop(context)) return 40.0;
    return 24.0;
  }

  double _getHeaderCardRadius(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    if (_isDesktop(context)) return 24.0;
    return 18.0;
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = _getMaxContentWidth(context);
    final padding = _getPadding(context);
    final headerFontSize = _getHeaderFontSize(context);
    final welcomeFontSize = _getWelcomeFontSize(context);
    final quickActionsFontSize = _getQuickActionsFontSize(context);
    final gridCount = _getGridCount(context);
    final gridSpacing = _getGridSpacing(context);
    final headerCardPadding = _getHeaderCardPadding(context);
    final headerCardRadius = _getHeaderCardRadius(context);

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
              fontSize: headerFontSize,
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.logout_rounded, size: headerFontSize),
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
                        padding: EdgeInsets.all(headerCardPadding),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primaryGreen, _accentGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(headerCardRadius),
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
                              padding: EdgeInsets.all(
                                _isTablet(context) ? 16 : 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: _isTablet(context)
                                    ? 32
                                    : _isDesktop(context)
                                    ? 40
                                    : 24,
                              ),
                            ),
                            SizedBox(width: _isTablet(context) ? 20 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, Admin!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: welcomeFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Manage your store efficiently',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: _isTablet(context)
                                          ? 18
                                          : _isDesktop(context)
                                          ? 20
                                          : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: _isTablet(context) ? 40 : 30),

                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: quickActionsFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: _isTablet(context) ? 24 : 16),

                    Expanded(
                      child: GridView.count(
                        padding: EdgeInsets.symmetric(vertical: padding / 2),
                        crossAxisCount: gridCount,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        childAspectRatio: _isMobile(context)
                            ? 1.1
                            : _isTablet(context)
                            ? 1.0
                            : 0.95,
                        children: [
                          _ActionCard(
                            title: 'Categories',
                            icon: Icons.category_rounded,
                            color: _primaryGreen,
                            animationDelay: 200,
                            isTablet: _isTablet(context) || _isDesktop(context),
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
                            isTablet: _isTablet(context) || _isDesktop(context),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProductListScreen(),
                              ),
                            ),
                          ),
                          if (!_isMobile(context)) ...[
                            _ActionCard(
                              title: 'Orders',
                              icon: Icons.list_alt_rounded,
                              color: Colors.orange,
                              animationDelay: 600,
                              isTablet:
                                  _isTablet(context) || _isDesktop(context),
                              onTap: () {},
                            ),
                            _ActionCard(
                              title: 'Analytics',
                              icon: Icons.analytics_rounded,
                              color: Colors.blue,
                              animationDelay: 800,
                              isTablet:
                                  _isTablet(context) || _isDesktop(context),
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
