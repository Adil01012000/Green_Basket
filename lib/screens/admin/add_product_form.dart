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

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final ProductService _productService = ProductService();

  String? _selectedCategoryId;
  String? _selectedCategoryName; // Added this missing variable
  File? _imageFile;

  List<Map<String, String>> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false; // Added loading state for form submission
  final List<String> _units = ['Kilogram', 'Bunch', 'Dozen'];
  String? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _loadCategories();

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
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.green),
              title: Text('Take a photo'),
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
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text('Choose from gallery'),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.green),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : Center(child: Text('Tap to upload image')),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Product Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter product name' : null,
              ),
              SizedBox(height: 16),
              _isLoadingCategories
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                  : _categories.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No categories available. Please add categories first.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value:
                          _categories.any(
                            (cat) => cat['id'] == _selectedCategoryId,
                          )
                          ? _selectedCategoryId
                          : null,
                      decoration: _inputDecoration('Category'),
                      hint: Text(
                        'Select a category',
                        style: TextStyle(color: Colors.green),
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
                          // Set the category name when ID is selected
                          _selectedCategoryName = _categories.firstWhere(
                            (cat) => cat['id'] == value,
                          )['name'];
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select category' : null,
                    ),

              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Price (PKR)'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter product price' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: _inputDecoration('Measuring Unit'),
                hint: Text(
                  'Select a unit',
                  style: TextStyle(color: Colors.green),
                ),
                items: _units
                    .map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select a measuring unit' : null,
              ),

              SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Quantity'),
                validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
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
                            selectedUnit: _selectedUnit, // Pass it here
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Adding Product...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : Text(
                        'Add Product',
                        style: TextStyle(color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
