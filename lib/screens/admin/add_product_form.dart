import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../services/product_service.dart';
import 'package:http/http.dart' as http;

class AddProductForm extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? existingData;

  const AddProductForm({Key? key, this.productId, this.existingData})
    : super(key: key);
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final ProductService _productService = ProductService();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  File? _imageFile;

  List<Map<String, String>> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  final List<String> _units = ['Kilogram', 'Bunch', 'Dozen'];
  String? _selectedUnit;

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  // Animation controller for smooth transitions
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _priceController.text = widget.existingData!['price']?.toString() ?? '';
      _quantityController.text =
          widget.existingData!['quantity']?.toString() ?? '';
      _selectedCategoryId = widget.existingData!['categoryId'];
      _selectedCategoryName = widget.existingData!['categoryName'];
      _selectedUnit = widget.existingData!['unit'];
      if (widget.existingData!['imageUrl'] != null &&
          widget.existingData!['imageUrl'].toString().isNotEmpty) {
        // you can optionally preload the network image in UI if needed
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    if (_isMobile(context)) return width * 0.98;
    if (_isTablet(context)) return 700.0;
    if (_isDesktop(context)) return 900.0;
    return 600.0;
  }

  double _getImageHeight(BuildContext context) {
    if (_isMobile(context)) return 150.0;
    if (_isTablet(context)) return 200.0;
    if (_isDesktop(context)) return 250.0;
    return 180.0;
  }

  double _getBorderRadius(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 16.0;
    if (_isDesktop(context)) return 20.0;
    return 14.0;
  }

  double _getInputBorderRadius(BuildContext context) {
    if (_isMobile(context)) return 10.0;
    if (_isTablet(context)) return 12.0;
    if (_isDesktop(context)) return 14.0;
    return 11.0;
  }

  double _getButtonHeight(BuildContext context) {
    if (_isMobile(context)) return 48.0;
    if (_isTablet(context)) return 56.0;
    if (_isDesktop(context)) return 60.0;
    return 52.0;
  }

  double _getButtonBorderRadius(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 16.0;
    if (_isDesktop(context)) return 18.0;
    return 14.0;
  }

  double _getSpacing(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    if (_isDesktop(context)) return 24.0;
    return 18.0;
  }

  double _getLargeSpacing(BuildContext context) {
    if (_isMobile(context)) return 24.0;
    if (_isTablet(context)) return 32.0;
    if (_isDesktop(context)) return 40.0;
    return 28.0;
  }

  TextStyle _getTitleStyle(BuildContext context) {
    final baseSize = _isMobile(context)
        ? 18.0
        : _isTablet(context)
        ? 20.0
        : 22.0;
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: baseSize,
      color: Colors.white,
    );
  }

  TextStyle _getButtonTextStyle(BuildContext context) {
    final baseSize = _isMobile(context)
        ? 16.0
        : _isTablet(context)
        ? 18.0
        : 20.0;
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: baseSize,
      color: Colors.white,
    );
  }

  TextStyle _getLabelStyle(BuildContext context) {
    final baseSize = _isMobile(context)
        ? 14.0
        : _isTablet(context)
        ? 15.0
        : 16.0;
    return TextStyle(
      color: Colors.green,
      fontSize: baseSize,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle _getHintStyle(BuildContext context) {
    final baseSize = _isMobile(context)
        ? 14.0
        : _isTablet(context)
        ? 15.0
        : 16.0;
    return TextStyle(color: Colors.green, fontSize: baseSize);
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();
      setState(() {
        _categories = snapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
            .toList();
        _isLoadingCategories = false;

        // Reset selected category if it doesn't exist in the new list
        if (_selectedCategoryId != null &&
            !_categories.any((cat) => cat['id'] == _selectedCategoryId)) {
          _selectedCategoryId = null;
          _selectedCategoryName = null;
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_getBorderRadius(context)),
        ),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: Colors.green,
                size: _isMobile(context) ? 24 : 28,
              ),
              title: Text(
                'Take a photo',
                style: TextStyle(fontSize: _isMobile(context) ? 16 : 18),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (pickedFile != null) {
                  setState(() => _imageFile = File(pickedFile.path));
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Colors.green,
                size: _isMobile(context) ? 24 : 28,
              ),
              title: Text(
                'Choose from gallery',
                style: TextStyle(fontSize: _isMobile(context) ? 16 : 18),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  setState(() => _imageFile = File(pickedFile.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: _getLabelStyle(context),
      hintText: hintText,
      hintStyle: _getHintStyle(context),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.green,
          width: _isMobile(context) ? 2 : 2.5,
        ),
        borderRadius: BorderRadius.circular(_getInputBorderRadius(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: _isMobile(context) ? 1 : 1.5,
        ),
        borderRadius: BorderRadius.circular(_getInputBorderRadius(context)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: _isMobile(context) ? 1 : 1.5,
        ),
        borderRadius: BorderRadius.circular(_getInputBorderRadius(context)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: _isMobile(context) ? 2 : 2.5,
        ),
        borderRadius: BorderRadius.circular(_getInputBorderRadius(context)),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: EdgeInsets.symmetric(
        vertical: _isMobile(context) ? 16 : 20,
        horizontal: _isMobile(context) ? 16 : 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final verticalPadding = _getVerticalPadding(context);
    final maxFormWidth = _getMaxFormWidth(context);
    final imageHeight = _getImageHeight(context);
    final borderRadius = _getBorderRadius(context);
    final buttonHeight = _getButtonHeight(context);
    final buttonBorderRadius = _getButtonBorderRadius(context);
    final spacing = _getSpacing(context);
    final largeSpacing = _getLargeSpacing(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.productId != null ? 'Edit Product' : 'Add New Product',
          style: _getTitleStyle(context),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
        // Responsive app bar actions for larger screens
        actions: (_isDesktop(context) || _isTablet(context))
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fill in all required fields and upload a product image',
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header section for larger screens
                      if (_isTablet(context) || _isDesktop(context)) ...[
                        Container(
                          padding: EdgeInsets.all(largeSpacing),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(borderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.productId != null
                                    ? Icons.edit
                                    : Icons.add_circle_outline,
                                color: Colors.green,
                                size: _isDesktop(context) ? 32 : 28,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.productId != null
                                          ? 'Edit Product'
                                          : 'Create New Product',
                                      style: TextStyle(
                                        fontSize: _isDesktop(context) ? 24 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add product details and upload an image',
                                      style: TextStyle(
                                        fontSize: _isDesktop(context) ? 16 : 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: largeSpacing),
                      ],

                      // Image upload section
                      Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(borderRadius),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: _isMobile(context) ? 1 : 2,
                              ),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      borderRadius,
                                    ),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: _isMobile(context) ? 48 : 64,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(height: spacing),
                                      Text(
                                        'Tap to upload image',
                                        style: TextStyle(
                                          fontSize: _isMobile(context)
                                              ? 16
                                              : 18,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Recommended: 800x600 pixels',
                                        style: TextStyle(
                                          fontSize: _isMobile(context)
                                              ? 12
                                              : 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: largeSpacing),

                      // Form fields section
                      Container(
                        padding: EdgeInsets.all(largeSpacing),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Responsive form layout
                            if (_isDesktop(context)) ...[
                              // Two-column layout for desktop
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _nameController,
                                          style: TextStyle(
                                            fontSize: _isMobile(context)
                                                ? 16
                                                : 18,
                                          ),
                                          decoration: _inputDecoration(
                                            'Product Name',
                                            hintText: 'e.g., Fresh Apples',
                                          ),
                                          validator: (value) => value!.isEmpty
                                              ? 'Enter product name'
                                              : null,
                                        ),
                                        SizedBox(height: spacing),
                                        _isLoadingCategories
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.green,
                                                    ),
                                              )
                                            : _categories.isEmpty
                                            ? Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        _getInputBorderRadius(
                                                          context,
                                                        ),
                                                      ),
                                                ),
                                                child: Text(
                                                  'No categories available. Please add categories first.',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              )
                                            : DropdownButtonFormField<String>(
                                                value:
                                                    _categories.any(
                                                      (cat) =>
                                                          cat['id'] ==
                                                          _selectedCategoryId,
                                                    )
                                                    ? _selectedCategoryId
                                                    : null,
                                                decoration: _inputDecoration(
                                                  'Category',
                                                ),
                                                hint: Text(
                                                  'Select a category',
                                                  style: _getHintStyle(context),
                                                ),
                                                items: _categories
                                                    .map(
                                                      (category) =>
                                                          DropdownMenuItem(
                                                            value:
                                                                category['id']!,
                                                            child: Text(
                                                              category['name']!,
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedCategoryId = value;
                                                    _selectedCategoryName =
                                                        _categories.firstWhere(
                                                          (cat) =>
                                                              cat['id'] ==
                                                              value,
                                                        )['name'];
                                                  });
                                                },
                                                validator: (value) =>
                                                    value == null
                                                    ? 'Select category'
                                                    : null,
                                              ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: spacing),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _priceController,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            fontSize: _isMobile(context)
                                                ? 16
                                                : 18,
                                          ),
                                          decoration: _inputDecoration(
                                            'Price (PKR)',
                                            hintText: 'e.g., 150',
                                          ),
                                          validator: (value) => value!.isEmpty
                                              ? 'Enter product price'
                                              : null,
                                        ),
                                        SizedBox(height: spacing),
                                        DropdownButtonFormField<String>(
                                          value: _selectedUnit,
                                          decoration: _inputDecoration(
                                            'Measuring Unit',
                                          ),
                                          hint: Text(
                                            'Select a unit',
                                            style: _getHintStyle(context),
                                          ),
                                          items: _units
                                              .map(
                                                (unit) => DropdownMenuItem(
                                                  value: unit,
                                                  child: Text(unit),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedUnit = value;
                                            });
                                          },
                                          validator: (value) => value == null
                                              ? 'Select a measuring unit'
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing),
                              TextFormField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: _isMobile(context) ? 16 : 18,
                                ),
                                decoration: _inputDecoration(
                                  'Quantity',
                                  hintText: 'e.g., 50',
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter quantity' : null,
                              ),
                            ] else ...[
                              // Single column layout for mobile and tablet
                              TextFormField(
                                controller: _nameController,
                                style: TextStyle(
                                  fontSize: _isMobile(context) ? 16 : 18,
                                ),
                                decoration: _inputDecoration(
                                  'Product Name',
                                  hintText: 'e.g., Fresh Apples',
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Enter product name'
                                    : null,
                              ),
                              SizedBox(height: spacing),
                              _isLoadingCategories
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.green,
                                      ),
                                    )
                                  : _categories.isEmpty
                                  ? Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(
                                          _getInputBorderRadius(context),
                                        ),
                                      ),
                                      child: Text(
                                        'No categories available. Please add categories first.',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : DropdownButtonFormField<String>(
                                      value:
                                          _categories.any(
                                            (cat) =>
                                                cat['id'] ==
                                                _selectedCategoryId,
                                          )
                                          ? _selectedCategoryId
                                          : null,
                                      decoration: _inputDecoration('Category'),
                                      hint: Text(
                                        'Select a category',
                                        style: _getHintStyle(context),
                                      ),
                                      items: _categories
                                          .map(
                                            (category) => DropdownMenuItem(
                                              value: category['id']!,
                                              child: Text(category['name']!),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCategoryId = value;
                                          _selectedCategoryName = _categories
                                              .firstWhere(
                                                (cat) => cat['id'] == value,
                                              )['name'];
                                        });
                                      },
                                      validator: (value) => value == null
                                          ? 'Select category'
                                          : null,
                                    ),
                              SizedBox(height: spacing),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: _isMobile(context) ? 16 : 18,
                                ),
                                decoration: _inputDecoration(
                                  'Price (PKR)',
                                  hintText: 'e.g., 150',
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Enter product price'
                                    : null,
                              ),
                              SizedBox(height: spacing),
                              DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                decoration: _inputDecoration('Measuring Unit'),
                                hint: Text(
                                  'Select a unit',
                                  style: _getHintStyle(context),
                                ),
                                items: _units
                                    .map(
                                      (unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUnit = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Select a measuring unit'
                                    : null,
                              ),
                              SizedBox(height: spacing),
                              TextFormField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: _isMobile(context) ? 16 : 18,
                                ),
                                decoration: _inputDecoration(
                                  'Quantity',
                                  hintText: 'e.g., 50',
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter quantity' : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: largeSpacing),

                      // Button section
                      if (_isDesktop(context)) ...[
                        // Side-by-side buttons for desktop
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: buttonHeight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        buttonBorderRadius,
                                      ),
                                    ),
                                    elevation: 5,
                                    shadowColor: Colors.green.withOpacity(0.4),
                                  ),
                                  onPressed: _isSubmitting
                                      ? null
                                      : () async {
                                          setState(() {
                                            _isSubmitting = true;
                                          });

                                          try {
                                            await _productService.submitForm(
                                              context: context,
                                              formKey: _formKey,
                                              nameController: _nameController,
                                              priceController: _priceController,
                                              quantityController:
                                                  _quantityController,
                                              selectedCategory:
                                                  _selectedCategoryName,
                                              selectedCategoryId:
                                                  _selectedCategoryId,
                                              imageFile: _imageFile,
                                              existingProductId:
                                                  widget.productId,
                                              onReset: () {
                                                setState(() {
                                                  _imageFile = null;
                                                  _selectedCategoryId = null;
                                                  _selectedCategoryName = null;
                                                  _selectedUnit = null;
                                                });
                                                _formKey.currentState!.reset();
                                              },
                                              selectedUnit: _selectedUnit,
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _isSubmitting = false;
                                              });
                                            }
                                          }
                                        },
                                  child: _isSubmitting
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Adding Product...',
                                              style: _getButtonTextStyle(
                                                context,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          widget.productId != null
                                              ? 'Update Product'
                                              : 'Add Product',
                                          style: _getButtonTextStyle(context),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(width: spacing),
                            SizedBox(
                              height: buttonHeight,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: BorderSide(color: Colors.green),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      buttonBorderRadius,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _nameController.clear();
                                  _priceController.clear();
                                  _quantityController.clear();
                                  setState(() {
                                    _imageFile = null;
                                    _selectedCategoryId = null;
                                    _selectedCategoryName = null;
                                    _selectedUnit = null;
                                  });
                                  _formKey.currentState?.reset();
                                },
                                child: Text(
                                  'Clear Form',
                                  style: _getButtonTextStyle(
                                    context,
                                  ).copyWith(color: Colors.green),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Single button for mobile and tablet
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  buttonBorderRadius,
                                ),
                              ),
                              elevation: 5,
                              shadowColor: Colors.green.withOpacity(0.4),
                            ),
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    setState(() {
                                      _isSubmitting = true;
                                    });

                                    try {
                                      await _productService.submitForm(
                                        context: context,
                                        formKey: _formKey,
                                        nameController: _nameController,
                                        priceController: _priceController,
                                        quantityController: _quantityController,
                                        selectedCategory: _selectedCategoryName,
                                        selectedCategoryId: _selectedCategoryId,
                                        imageFile: _imageFile,
                                        existingProductId: widget.productId,
                                        onReset: () {
                                          setState(() {
                                            _imageFile = null;
                                            _selectedCategoryId = null;
                                            _selectedCategoryName = null;
                                            _selectedUnit = null;
                                          });
                                          _formKey.currentState!.reset();
                                        },
                                        selectedUnit: _selectedUnit,
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isSubmitting = false;
                                        });
                                      }
                                    }
                                  },
                            child: _isSubmitting
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Adding Product...',
                                        style: _getButtonTextStyle(context),
                                      ),
                                    ],
                                  )
                                : Text(
                                    widget.productId != null
                                        ? 'Update Product'
                                        : 'Add Product',
                                    style: _getButtonTextStyle(context),
                                  ),
                          ),
                        ),
                        if (_isTablet(context)) ...[
                          SizedBox(height: spacing),
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    buttonBorderRadius,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _nameController.clear();
                                _priceController.clear();
                                _quantityController.clear();
                                setState(() {
                                  _imageFile = null;
                                  _selectedCategoryId = null;
                                  _selectedCategoryName = null;
                                  _selectedUnit = null;
                                });
                                _formKey.currentState?.reset();
                              },
                              child: Text(
                                'Clear Form',
                                style: _getButtonTextStyle(
                                  context,
                                ).copyWith(color: Colors.green),
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
    );
  }
}
