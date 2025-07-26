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

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

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
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 28.0;
    return 22.0;
  }

  int _getGridCount(BuildContext context) {
    if (_isMobile(context)) return 2;
    if (_isTablet(context)) return 4;
    if (_isDesktop(context)) return 6;
    return 3;
  }

  double _getGridSpacing(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 32.0;
    return 16.0;
  }

  double _getCardPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 32.0;
    return 20.0;
  }

  double _getCardRadius(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    if (_isDesktop(context)) return 24.0;
    return 18.0;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = _getMaxContentWidth(context);
    final padding = _getPadding(context);
    final headerFontSize = _getHeaderFontSize(context);
    final gridCount = _getGridCount(context);
    final gridSpacing = _getGridSpacing(context);

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
            fontSize: headerFontSize,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: headerFontSize),
            tooltip: 'Add Category',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isTablet(context) ? 80 : 64),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              padding,
              0,
              padding,
              _isTablet(context) ? 16 : 12,
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, size: headerFontSize),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear, size: headerFontSize),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: _isTablet(context) ? 24 : 16,
                  vertical: _isTablet(context) ? 16 : 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_getCardRadius(context)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_getCardRadius(context)),
                  borderSide: BorderSide(color: _accentGreen.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_getCardRadius(context)),
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
                return _buildErrorState(snapshot.error.toString(), context);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState(context);
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
                return _buildEmptyState(context, _query.isNotEmpty);
              }

              return GridView.builder(
                padding: EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: _isMobile(context) ? 0.85 : 0.9,
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

                  return _buildCategoryCard(doc, data, context);
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
    BuildContext context,
  ) {
    final name = data['name']?.toString() ?? 'Unnamed';
    final enabled = data['enabled'] as bool? ?? true;
    final isTablet = _isTablet(context);
    final cardPadding = _getCardPadding(context);
    final cardRadius = _getCardRadius(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: () => _showUpdateDialog(doc, context),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
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

  void _showUpdateDialog(DocumentSnapshot doc, BuildContext context) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return;

    final editCtrl = TextEditingController(
      text: data['name']?.toString() ?? '',
    );
    final isTablet = _isTablet(context);

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

  Widget _buildErrorState(String error, BuildContext context) {
    final isTablet = _isTablet(context);
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

  Widget _buildLoadingState(BuildContext context) {
    final isTablet = _isTablet(context);
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

  Widget _buildEmptyState(BuildContext context, bool isSearch) {
    final isTablet = _isTablet(context);
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
