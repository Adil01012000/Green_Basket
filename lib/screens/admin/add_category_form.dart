import 'package:flutter/material.dart';
import '../../services/category_service.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  final CategoryService _categoryService = CategoryService();

  static const Color _primaryGreen = Color(0xFF388E3C);
  static const Color _accentGreen = Color(0xFF81C784);

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Responsive helper methods
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileBreakpoint;

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 32.0;
    if (_isDesktop(context)) return 48.0;
    return 24.0;
  }

  double _getVerticalPadding(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (height < 600) return 16.0;
    if (height < 800) return 24.0;
    return 32.0;
  }

  double _getMaxFormWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (_isMobile(context)) return width * 0.95;
    if (_isTablet(context)) return 600.0;
    if (_isDesktop(context)) return 700.0;
    return 500.0;
  }

  double _getContainerPadding(BuildContext context) {
    if (_isMobile(context)) return 20.0;
    if (_isTablet(context)) return 32.0;
    if (_isDesktop(context)) return 40.0;
    return 28.0;
  }

  double _getBorderRadius(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    if (_isDesktop(context)) return 24.0;
    return 20.0;
  }

  double _getButtonHeight(BuildContext context) {
    if (_isMobile(context)) return 48.0;
    if (_isTablet(context)) return 56.0;
    if (_isDesktop(context)) return 60.0;
    return 50.0;
  }

  double _getButtonBorderRadius(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    if (_isDesktop(context)) return 24.0;
    return 18.0;
  }

  double _getInputBorderRadius(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 16.0;
    if (_isDesktop(context)) return 18.0;
    return 14.0;
  }

  double _getSpacing(BuildContext context) {
    if (_isMobile(context)) return 24.0;
    if (_isTablet(context)) return 32.0;
    if (_isDesktop(context)) return 40.0;
    return 32.0;
  }

  TextStyle _getTitleStyle(BuildContext context) {
    final baseSize = _isMobile(context)
        ? 18.0
        : _isTablet(context)
        ? 20.0
        : 22.0;
    return TextStyle(fontWeight: FontWeight.w600, fontSize: baseSize);
  }

  TextStyle _getButtonTextStyle(BuildContext context) {
    final baseSize = _isMobile(context)
        ? 16.0
        : _isTablet(context)
        ? 18.0
        : 20.0;
    return TextStyle(fontWeight: FontWeight.bold, fontSize: baseSize);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = _getHorizontalPadding(context);
    final verticalPadding = _getVerticalPadding(context);
    final maxFormWidth = _getMaxFormWidth(context);
    final containerPadding = _getContainerPadding(context);
    final borderRadius = _getBorderRadius(context);
    final buttonHeight = _getButtonHeight(context);
    final buttonBorderRadius = _getButtonBorderRadius(context);
    final inputBorderRadius = _getInputBorderRadius(context);
    final spacing = _getSpacing(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 1,
        title: Text('Add Category', style: _getTitleStyle(context)),
        // Responsive app bar actions for larger screens
        actions: _isDesktop(context) || _isTablet(context)
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      // Add help functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a category name to organize your products',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    tooltip: 'Help',
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxFormWidth,
                minHeight: screenHeight * 0.3, // Ensure minimum height
              ),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.all(containerPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header section for larger screens
                          if (_isTablet(context) || _isDesktop(context)) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: _primaryGreen,
                                  size: _isDesktop(context) ? 32 : 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Create New Category',
                                    style: TextStyle(
                                      fontSize: _isDesktop(context) ? 24 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Add a new category to organize your products better',
                              style: TextStyle(
                                fontSize: _isDesktop(context) ? 16 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: spacing),
                          ],
                          TextFormField(
                            controller: _categoryController,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: _isMobile(context) ? 16 : 18,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Category Name',
                              labelStyle: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontSize: _isMobile(context) ? 14 : 16,
                              ),
                              hintText: 'e.g., Fruits, Vegetables, Dairy',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: _isMobile(context) ? 14 : 16,
                              ),
                              prefixIcon: Icon(
                                Icons.category,
                                color: _primaryGreen,
                                size: _isMobile(context) ? 20 : 24,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  inputBorderRadius,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: _isMobile(context) ? 1 : 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  inputBorderRadius,
                                ),
                                borderSide: BorderSide(
                                  color: _primaryGreen,
                                  width: _isMobile(context) ? 2 : 2.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  inputBorderRadius,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: _isMobile(context) ? 1 : 1.5,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  inputBorderRadius,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: _isMobile(context) ? 2 : 2.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(
                                vertical: _isMobile(context) ? 16 : 20,
                                horizontal: _isMobile(context) ? 16 : 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a category name';
                              }
                              if (value.trim().length < 2) {
                                return 'Category name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: spacing),
                          // Responsive button layout
                          if (_isDesktop(context)) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryGreen,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            buttonBorderRadius,
                                          ),
                                        ),
                                        elevation: 5,
                                        shadowColor: _primaryGreen.withOpacity(
                                          0.4,
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          _categoryService.createCategory(
                                            context,
                                            _categoryController.text.trim(),
                                          );
                                        }
                                      },
                                      child: Text(
                                        'Add Category',
                                        style: _getButtonTextStyle(context),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  height: buttonHeight,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _primaryGreen,
                                      side: BorderSide(color: _primaryGreen),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          buttonBorderRadius,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      _categoryController.clear();
                                      _formKey.currentState?.reset();
                                    },
                                    child: Text(
                                      'Clear',
                                      style: _getButtonTextStyle(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      buttonBorderRadius,
                                    ),
                                  ),
                                  elevation: 5,
                                  shadowColor: _primaryGreen.withOpacity(0.4),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _categoryService.createCategory(
                                      context,
                                      _categoryController.text.trim(),
                                    );
                                  }
                                },
                                child: Text(
                                  'Add Category',
                                  style: _getButtonTextStyle(context),
                                ),
                              ),
                            ),
                            if (_isTablet(context)) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _primaryGreen,
                                    side: BorderSide(color: _primaryGreen),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        buttonBorderRadius,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    _categoryController.clear();
                                    _formKey.currentState?.reset();
                                  },
                                  child: Text(
                                    'Clear Form',
                                    style: _getButtonTextStyle(context),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
