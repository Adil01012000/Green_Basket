import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './add_category_form.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _accentGreen = Color(0xFF81C784);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final maxContentWidth = isTablet ? 1200.0 : double.infinity;
    final padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        title: Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: isTablet ? 30 : 24),
            tooltip: 'Add Category',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isTablet ? 80 : 64),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 32 : 16,
              0,
              isTablet ? 32 : 16,
              isTablet ? 16 : 12,
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, size: isTablet ? 28 : 24),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear, size: isTablet ? 28 : 24),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 16 : 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _accentGreen.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primaryGreen, width: 2),
                ),
              ),
              onChanged: (val) =>
                  setState(() => _query = val.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('categories')
                .orderBy('nameLower')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString(), isTablet);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState(isTablet);
              }

              final docs = snapshot.data?.docs ?? [];
              final filtered = _query.isEmpty
                  ? docs
                  : docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      return data != null &&
                          data['name']?.toString().toLowerCase().contains(
                                _query,
                              ) ==
                              true;
                    }).toList();

              if (filtered.isEmpty) {
                return _buildEmptyState(isTablet, _query.isNotEmpty);
              }

              return GridView.builder(
                padding: EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 4 : 2,
                  crossAxisSpacing: padding,
                  mainAxisSpacing: padding,
                  childAspectRatio: isTablet ? 0.9 : 0.85,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final doc = filtered[i];
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data == null) {
                    return const Card(
                      child: Center(child: Text('Invalid data')),
                    );
                  }

                  return _buildCategoryCard(doc, data, isTablet);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    DocumentSnapshot doc,
    Map<String, dynamic> data,
    bool isTablet,
  ) {
    final name = data['name']?.toString() ?? 'Unnamed';
    final enabled = data['enabled'] as bool? ?? true;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showUpdateDialog(doc, isTablet),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                decoration: BoxDecoration(
                  color: enabled
                      ? _primaryGreen.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.category_outlined,
                  size: isTablet ? 48 : 32,
                  color: enabled ? _primaryGreen : Colors.grey,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),

              // Category Name
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 20 : 16,
                  color: enabled ? Colors.black87 : Colors.black38,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),

              // Toggle Switch
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    enabled ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: enabled ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: isTablet ? 16 : 12,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 8),
                  Switch(
                    value: enabled,
                    activeColor: _primaryGreen,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) async {
                      try {
                        await _firestore
                            .collection('categories')
                            .doc(doc.id)
                            .update({'enabled': val});
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update status: $e'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog(DocumentSnapshot doc, bool isTablet) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return;

    final editCtrl = TextEditingController(
      text: data['name']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Update Category',
            style: TextStyle(fontSize: isTablet ? 24 : 20),
          ),
          content: SizedBox(
            width: isTablet ? 400 : 300,
            child: TextField(
              controller: editCtrl,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
              ),
              style: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _primaryGreen,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = editCtrl.text.trim();
                if (newName.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category name cannot be empty'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  return;
                }

                try {
                  await _firestore.collection('categories').doc(doc.id).update({
                    'name': newName,
                    'nameLower': newName.toLowerCase(),
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category updated successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update category: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 16 : 12,
                ),
              ),
              child: Text(
                'Update',
                style: TextStyle(fontSize: isTablet ? 18 : 16),
              ),
            ),
          ],
        );
      },
    ).then((_) => editCtrl.dispose());
  }

  Widget _buildErrorState(String error, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 64 : 48,
            color: Colors.red,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Error loading categories',
            style: TextStyle(fontSize: isTablet ? 24 : 18, color: Colors.red),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            error,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 16 : 12,
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: _primaryGreen, strokeWidth: 3),
        SizedBox(height: isTablet ? 24 : 16),
        Text(
          'Loading categories...',
          style: TextStyle(
            fontSize: isTablet ? 20 : 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isTablet, bool isSearch) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: isTablet ? 80 : 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            isSearch ? 'No matching categories' : 'No categories found',
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            isSearch
                ? 'Try a different search term'
                : 'Tap the + button to add your first category',
            style: TextStyle(
              fontSize: isTablet ? 18 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
