import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/admin/admin_dashboard_screen.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCategory(BuildContext context, String categoryName) async {
    try {
      final String trimmedName = categoryName.trim();

      final dupSnap = await _firestore
          .collection('categories')
          .where('nameLower', isEqualTo: trimmedName.toLowerCase())
          .limit(1)
          .get();

      if (dupSnap.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category "$trimmedName" already exists')),
        );
        return;
      }

      final docRef = _firestore.collection('categories').doc();
      await docRef.set({
        'id': docRef.id,
        'name': trimmedName,
        'enabled': true,
        'nameLower': trimmedName.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "$trimmedName" created successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminDashboard()),
      );
    } catch (e) {
      print('Error creating category: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating category: $e')));
      rethrow;
    }
  }
}
