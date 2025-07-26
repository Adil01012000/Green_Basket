import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product_form.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
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
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 32.0;
    return 20.0;
  }

  double _getHeaderFontSize(BuildContext context) {
    if (_isMobile(context)) return 20.0;
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 28.0;
    return 22.0;
  }

  int _getGridCount(BuildContext context) {
    if (_isMobile(context)) return 1;
    if (_isTablet(context)) return 2;
    if (_isDesktop(context)) return 3;
    return 2;
  }

  double _getGridSpacing(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 32.0;
    return 20.0;
  }

  double _getCardPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    if (_isDesktop(context)) return 24.0;
    return 18.0;
  }

  double _getCardRadius(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 16.0;
    if (_isDesktop(context)) return 20.0;
    return 14.0;
  }

  double _getImageSize(BuildContext context) {
    if (_isMobile(context)) return 80.0;
    if (_isTablet(context)) return 120.0;
    if (_isDesktop(context)) return 140.0;
    return 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = _getMaxContentWidth(context);
    final padding = _getPadding(context);
    final headerFontSize = _getHeaderFontSize(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Product List',
          style: TextStyle(
            fontSize: headerFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: headerFontSize),
            tooltip: 'Add Product',
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(builder: (context) => AddProductForm()),
                  )
                  .then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString(), context);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState(context);
              }

              final products = snapshot.data?.docs ?? [];

              if (products.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                color: Color(0xFF4CAF50),
                onRefresh: () async => setState(() {}),
                child: _isMobile(context)
                    ? _buildMobileList(products, context)
                    : _buildTabletGrid(products, context),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabletGrid(
    List<QueryDocumentSnapshot> products,
    BuildContext context,
  ) {
    final padding = _getPadding(context);
    final gridCount = _getGridCount(context);
    final gridSpacing = _getGridSpacing(context);

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCount,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
        childAspectRatio: _isDesktop(context) ? 2.8 : 2.5,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          _buildProductCard(products[index], context),
    );
  }

  Widget _buildMobileList(
    List<QueryDocumentSnapshot> products,
    BuildContext context,
  ) {
    final padding = _getPadding(context);

    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: products.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: padding),
        child: _buildProductCard(products[index], context),
      ),
    );
  }

  Widget _buildProductCard(
    QueryDocumentSnapshot product,
    BuildContext context,
  ) {
    final data = product.data() as Map<String, dynamic>;
    final cardPadding = _getCardPadding(context);
    final cardRadius = _getCardRadius(context);
    final imageSize = _getImageSize(context);

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: () => _editProduct(product.id, data),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              _buildProductImage(data, context, imageSize),
              SizedBox(width: cardPadding),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductName(data, context),
                    if (data['categoryName'] != null)
                      _buildCategoryTag(data, context),
                    SizedBox(height: _isMobile(context) ? 8 : 12),
                    _buildPriceAndQuantity(data, context),
                    if (data['createdAt'] != null)
                      _buildDateAdded(data, context),
                  ],
                ),
              ),

              // Action Menu
              _buildActionMenu(product.id, data, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(
    Map<String, dynamic> data,
    BuildContext context,
    double size,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_getCardRadius(context) * 0.5),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey[200],
        child: data['imageUrl'] != null && data['imageUrl'].isNotEmpty
            ? Image.network(
                data['imageUrl'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: Color(0xFF4CAF50),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: size * 0.4,
                  );
                },
              )
            : Icon(Icons.image, color: Colors.grey[400], size: size * 0.4),
      ),
    );
  }

  Widget _buildProductName(Map<String, dynamic> data, BuildContext context) {
    final fontSize = _isMobile(context)
        ? 18.0
        : _isTablet(context)
        ? 22.0
        : 24.0;

    return Text(
      data['name'] ?? 'Unknown Product',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoryTag(Map<String, dynamic> data, BuildContext context) {
    final isTablet = _isTablet(context) || _isDesktop(context);

    return Padding(
      padding: EdgeInsets.only(top: isTablet ? 8 : 4),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 8,
          vertical: isTablet ? 4 : 2,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          data['categoryName'],
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceAndQuantity(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    final isTablet = _isTablet(context) || _isDesktop(context);
    final fontSize = isTablet ? 18.0 : 16.0;
    final iconSize = isTablet ? 20.0 : 16.0;

    return Row(
      children: [
        Icon(Icons.currency_rupee, size: iconSize, color: Colors.green[700]),
        Text(
          '${data['price']?.toStringAsFixed(0) ?? '0'}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(width: isTablet ? 24 : 16),
        Icon(Icons.inventory, size: iconSize, color: Colors.grey[600]),
        SizedBox(width: isTablet ? 8 : 4),
        Text(
          '${data['quantity']?.toString() ?? '0'} ${data['unit'] ?? ''}',
          style: TextStyle(fontSize: fontSize - 2, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDateAdded(Map<String, dynamic> data, BuildContext context) {
    final isTablet = _isTablet(context) || _isDesktop(context);

    return Padding(
      padding: EdgeInsets.only(top: isTablet ? 12 : 8),
      child: Text(
        'Added: ${_formatDate(data['createdAt'])}',
        style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildActionMenu(
    String productId,
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    final isTablet = _isTablet(context) || _isDesktop(context);
    final iconSize = isTablet ? 28.0 : 24.0;
    final fontSize = isTablet ? 18.0 : 14.0;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600], size: iconSize),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _editProduct(productId, data);
            break;
          case 'delete':
            _deleteProduct(productId, data['name'] ?? 'Product');
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: iconSize * 0.8, color: Colors.blue),
              SizedBox(width: 12),
              Text('Edit', style: TextStyle(fontSize: fontSize)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: iconSize * 0.8, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(fontSize: fontSize)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, BuildContext context) {
    final isTablet = _isTablet(context) || _isDesktop(context);
    final padding = _getPadding(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 80 : 64,
            color: Colors.red,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Error loading products',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 16 : 12,
              ),
            ),
            onPressed: () => setState(() {}),
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
    final isTablet = _isTablet(context) || _isDesktop(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Color(0xFF4CAF50), strokeWidth: 3),
        SizedBox(height: isTablet ? 24 : 16),
        Text(
          'Loading products...',
          style: TextStyle(
            fontSize: isTablet ? 20 : 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isTablet = _isTablet(context) || _isDesktop(context);
    final padding = _getPadding(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: isTablet ? 80 : 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Tap the + button to add your first product',
            style: TextStyle(
              fontSize: isTablet ? 18 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Unknown';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _editProduct(String productId, Map<String, dynamic> productData) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                AddProductForm(productId: productId, existingData: productData),
          ),
        )
        .then((_) => setState(() {}));
  }

  void _deleteProduct(String productId, String productName) {
    final isTablet = _isTablet(context) || _isDesktop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 20 : 18,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$productName"?',
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .delete();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete product: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
