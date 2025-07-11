import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product_form.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final maxContentWidth = isTablet ? 1000.0 : double.infinity;
    final padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product List',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: isTablet ? 30 : 24),
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
                return _buildErrorState(snapshot.error.toString(), isTablet);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState(isTablet);
              }

              final products = snapshot.data?.docs ?? [];

              if (products.isEmpty) {
                return _buildEmptyState(isTablet);
              }

              return RefreshIndicator(
                color: Color(0xFF4CAF50),
                onRefresh: () async => setState(() {}),
                child: isTablet
                    ? _buildTabletGrid(products, padding)
                    : _buildMobileList(products, padding),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabletGrid(
    List<QueryDocumentSnapshot> products,
    double padding,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: padding,
        mainAxisSpacing: padding,
        childAspectRatio: 2.5,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index], true),
    );
  }

  Widget _buildMobileList(
    List<QueryDocumentSnapshot> products,
    double padding,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: products.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: padding),
        child: _buildProductCard(products[index], false),
      ),
    );
  }

  Widget _buildProductCard(QueryDocumentSnapshot product, bool isTablet) {
    final data = product.data() as Map<String, dynamic>;
    final cardPadding = isTablet ? 20.0 : 16.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editProduct(product.id, data),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              _buildProductImage(data, isTablet),
              SizedBox(width: cardPadding),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductName(data, isTablet),
                    if (data['categoryName'] != null)
                      _buildCategoryTag(data, isTablet),
                    SizedBox(height: isTablet ? 12 : 8),
                    _buildPriceAndQuantity(data, isTablet),
                    if (data['createdAt'] != null)
                      _buildDateAdded(data, isTablet),
                  ],
                ),
              ),

              // Action Menu
              _buildActionMenu(product.id, data, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> data, bool isTablet) {
    final size = isTablet ? 120.0 : 80.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
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
                    size: isTablet ? 48 : 32,
                  );
                },
              )
            : Icon(
                Icons.image,
                color: Colors.grey[400],
                size: isTablet ? 48 : 32,
              ),
      ),
    );
  }

  Widget _buildProductName(Map<String, dynamic> data, bool isTablet) {
    return Text(
      data['name'] ?? 'Unknown Product',
      style: TextStyle(
        fontSize: isTablet ? 22 : 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoryTag(Map<String, dynamic> data, bool isTablet) {
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

  Widget _buildPriceAndQuantity(Map<String, dynamic> data, bool isTablet) {
    return Row(
      children: [
        Icon(
          Icons.currency_rupee,
          size: isTablet ? 20 : 16,
          color: Colors.green[700],
        ),
        Text(
          '${data['price']?.toStringAsFixed(0) ?? '0'}',
          style: TextStyle(
            fontSize: isTablet ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(width: isTablet ? 24 : 16),
        Icon(
          Icons.inventory,
          size: isTablet ? 20 : 16,
          color: Colors.grey[600],
        ),
        SizedBox(width: isTablet ? 8 : 4),
        Text(
          '${data['quantity']?.toString() ?? '0'} ${data['unit'] ?? ''}',
          style: TextStyle(
            fontSize: isTablet ? 18 : 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDateAdded(Map<String, dynamic> data, bool isTablet) {
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
    bool isTablet,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
        size: isTablet ? 28 : 24,
      ),
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
              Icon(Icons.edit, size: isTablet ? 24 : 18, color: Colors.blue),
              SizedBox(width: 12),
              Text('Edit', style: TextStyle(fontSize: isTablet ? 18 : 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: isTablet ? 24 : 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(fontSize: isTablet ? 18 : 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 80 : 64,
            color: Colors.red,
          ),
          SizedBox(height: 24),
          Text(
            'Error loading products',
            style: TextStyle(fontSize: isTablet ? 24 : 18, color: Colors.red),
          ),
          SizedBox(height: 12),
          Text(
            error,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(
                horizontal: 24,
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

  Widget _buildLoadingState(bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Color(0xFF4CAF50), strokeWidth: 3),
        SizedBox(height: 24),
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

  Widget _buildEmptyState(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: isTablet ? 80 : 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
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
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
