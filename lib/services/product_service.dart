import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';

import '../screens/admin/product_list_screen.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  Future<void> submitForm({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController priceController,
    required TextEditingController quantityController,
    required String? selectedCategory,
    required String? selectedCategoryId,
    required File? imageFile,
    required String? selectedUnit,
    required VoidCallback onReset,
    String? existingProductId,
  }) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedUnit == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a unit')));
      return;
    }

    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    String imageUrl = '';

    if (imageFile != null) {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${basename(imageFile.path)}';

        // Upload to Supabase Storage
        await supabase.storage
            .from('greenbasket-products-images')
            .upload('products/$fileName', imageFile);

        // Get the public URL after successful upload
        imageUrl = supabase.storage
            .from('greenbasket-products-images')
            .getPublicUrl('products/$fileName');

        print("✅ Uploaded to Supabase: $imageUrl");
      } catch (e) {
        print("❌ Supabase upload error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image upload failed.")));
        return;
      }
    }

    final productData = <String, dynamic>{
      'name': nameController.text.trim(),
      'price': double.parse(priceController.text.trim()),
      'unit': selectedUnit,
      'quantity': int.parse(quantityController.text.trim()),
      'categoryId': selectedCategoryId,
      'categoryName': selectedCategory,
      if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (existingProductId != null) {
        // For updates, remove createdAt and add updatedAt
        productData.remove('createdAt');
        productData['updatedAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('products')
            .doc(existingProductId)
            .update(productData);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
        }
      } else {
        await FirebaseFirestore.instance
            .collection('products')
            .add(productData);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          onReset();
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("❌ Firestore error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save product. Please try again.'),
          ),
        );
      }
    }
  }
}
