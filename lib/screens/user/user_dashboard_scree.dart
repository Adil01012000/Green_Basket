import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/signin_screen.dart';
import '../../models/Cart.dart';
import '../user/user_cart_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedCategory;
  String searchQuery = '';
  List<CartItem> cartItems = [];

  void addToCart(String name, String price, String imageUrl, String weight) {
    final id = '$name-$weight';
    final existingIndex = cartItems.indexWhere((item) => item.id == id);

    setState(() {
      if (existingIndex >= 0) {
        cartItems[existingIndex].quantity += 1;
      } else {
        cartItems.add(
          CartItem(
            id: id,
            name: name,
            price: double.tryParse(price) ?? 0.0,
            imageUrl: imageUrl,
            weight: weight,
          ),
        );
      }
    });
  }

  // Helper method to determine device type and get responsive values
  Map<String, dynamic> _getResponsiveValues(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;
    final isLargeTablet = screenWidth >= 1024;

    return {
      'isTablet': isTablet,
      'isLargeTablet': isLargeTablet,
      'crossAxisCount': isLargeTablet
          ? 5
          : isTablet
          ? 4
          : screenWidth > 600
          ? 3
          : 2,
      'padding': isTablet ? screenWidth * 0.03 : screenWidth * 0.04,
      'fontScale': isLargeTablet
          ? 1.4
          : isTablet
          ? 1.3
          : screenWidth < 400
          ? 0.9
          : screenWidth > 600
          ? 1.2
          : 1.0,
      'maxWidth': isTablet ? 1200.0 : double.infinity,
      'headerHeight': isTablet ? 80.0 : 60.0,
      'searchHeight': isTablet ? 60.0 : screenHeight * 0.07,
      'aspectRatio': isTablet
          ? 0.85
          : screenWidth < 400
          ? 0.7
          : 0.75,
    };
  }

  @override
  Widget build(BuildContext context) {
    final responsive = _getResponsiveValues(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = responsive['isTablet'];
    final maxWidth = responsive['maxWidth'];
    final padding = responsive['padding'];
    final fontScale = responsive['fontScale'];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Center(
          child: Container(
            width: maxWidth,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(padding * 0.5),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding * 0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with better tablet layout
                      Container(
                        height: responsive['headerHeight'],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: isTablet ? 24 : screenWidth * 0.02,
                                  height: isTablet ? 24 : screenWidth * 0.02,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(
                                  width: isTablet ? 12 : screenWidth * 0.015,
                                ),
                                Text(
                                  'Green Basket',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isTablet
                                        ? 24.0
                                        : 16.0 * fontScale,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  iconSize: isTablet ? 32 : 24,
                                  icon: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInScreen(),
                                      ),
                                    );
                                    if (result != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Welcome back, ${result}!',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  iconSize: isTablet ? 32 : 24,
                                  icon: Stack(
                                    children: [
                                      const Icon(
                                        Icons.shopping_cart,
                                        color: Colors.grey,
                                      ),
                                      if (cartItems.isNotEmpty)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              isTablet ? 4 : 2,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${cartItems.length}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isTablet ? 12 : 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CartScreen(cartItems: cartItems),
                                      ),
                                    );
                                    if (result == 'updated') {
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 32 : screenHeight * 0.04),

                      // Welcome text with better tablet sizing
                      Text(
                        'Welcome User',
                        style: TextStyle(
                          fontSize: isTablet ? 24.0 : (18.0 * fontScale),
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Find your health',
                        style: TextStyle(
                          fontSize: isTablet ? 36.0 : (28.0 * fontScale),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : screenHeight * 0.03),

                      // Search bar with better tablet layout
                      Container(
                        height: responsive['searchHeight'],
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 500 : double.infinity,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: padding * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(padding * 0.3),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: isTablet ? 28 : screenWidth * 0.06,
                            ),
                            SizedBox(width: padding * 0.3),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value.trim().toLowerCase();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search Food',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet
                                        ? 20.0
                                        : 16.0 * fontScale,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: isTablet ? 20.0 : 16.0 * fontScale,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : screenHeight * 0.03),

                      // Category tabs with better tablet layout
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('categories')
                            .where('enabled', isEqualTo: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Text(
                              "No categories found",
                              style: TextStyle(
                                fontSize: isTablet ? 18.0 : 14.0 * fontScale,
                              ),
                            );
                          }

                          final categoryDocs = snapshot.data!.docs;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: padding * 0.5,
                                  ),
                                  child: _buildCategoryTab(
                                    'All',
                                    fontScale,
                                    isTablet,
                                  ),
                                ),
                                ...categoryDocs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final name = data['name'] ?? 'Unnamed';
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: padding * 0.5,
                                    ),
                                    child: _buildCategoryTab(
                                      name,
                                      fontScale,
                                      isTablet,
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isTablet ? 24 : screenHeight * 0.03),

                      // Products grid with proper tablet layout
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('products').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading products',
                                  style: TextStyle(
                                    fontSize: isTablet
                                        ? 18.0
                                        : 14.0 * fontScale,
                                  ),
                                ),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No products found',
                                  style: TextStyle(
                                    fontSize: isTablet
                                        ? 18.0
                                        : 14.0 * fontScale,
                                  ),
                                ),
                              );
                            }

                            final products = snapshot.data!.docs.where((doc) {
                              final product =
                                  doc.data() as Map<String, dynamic>;
                              final productName = (product['name'] ?? '')
                                  .toLowerCase();
                              final productCategory =
                                  product['categoryName'] ?? '';

                              bool matchesSearch = productName.contains(
                                searchQuery,
                              );
                              bool matchesCategory =
                                  selectedCategory == null ||
                                  selectedCategory == 'All' ||
                                  productCategory == selectedCategory;

                              return matchesSearch && matchesCategory;
                            }).toList();

                            if (products.isEmpty) {
                              return Center(
                                child: Text(
                                  selectedCategory == null
                                      ? 'No products match your search'
                                      : 'No products found in this category',
                                  style: TextStyle(
                                    fontSize: isTablet
                                        ? 18.0
                                        : 14.0 * fontScale,
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        responsive['crossAxisCount'],
                                    crossAxisSpacing: padding * 0.5,
                                    mainAxisSpacing: padding * 0.5,
                                    childAspectRatio: responsive['aspectRatio'],
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product =
                                    products[index].data()
                                        as Map<String, dynamic>;
                                return _buildFoodItem(
                                  product['name'] ?? 'Product Name',
                                  product['price']?.toString() ?? '0.00',
                                  product['imageUrl'] ?? '',
                                  product['isFavorite'] ?? false,
                                  product['unit'] ?? 'kilogram',
                                  fontScale,
                                  screenWidth,
                                  padding,
                                  isTablet,
                                );
                              },
                            );
                          },
                        ),
                      ),
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

  Widget _buildCategoryTab(String title, double fontScale, bool isTablet) {
    bool isSelected =
        selectedCategory == title ||
        (selectedCategory == null && title == 'All');

    return GestureDetector(
      onTap: () {
        setState(() {
          if (title == 'All') {
            selectedCategory = null;
          } else {
            selectedCategory = title;
          }
          searchQuery = '';
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16,
          vertical: isTablet ? 14 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isTablet ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18.0 : 14.0 * fontScale,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItem(
    String name,
    String price,
    String imageUrl,
    bool isFavorite,
    String unit,
    double fontScale,
    double screenWidth,
    double padding,
    bool isTablet,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(padding * 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: padding * 0.5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(padding * 0.3),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(padding * 0.3),
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.fastfood,
                                size: isTablet ? 48 : screenWidth * 0.1,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.fastfood,
                            size: isTablet ? 48 : screenWidth * 0.1,
                            color: Colors.grey,
                          ),
                        ),
                ),
                Positioned(
                  top: padding * 0.3,
                  right: padding * 0.3,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 8 : padding * 0.2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: isTablet ? 24 : screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(padding * 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18.0 : 14.0 * fontScale,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rs: $price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 20.0 : 16.0 * fontScale,
                      color: Colors.green,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (unit == 'Kilogram') {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => _buildWeightSelector(
                            context: context,
                            basePrice: double.tryParse(price) ?? 0.0,
                            name: name,
                            imageUrl: imageUrl,
                          ),
                        );
                      } else if (unit == 'Bunch') {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => _buildBunchSelector(
                            context: context,
                            basePrice: double.tryParse(price) ?? 0.0,
                            name: name,
                            imageUrl: imageUrl,
                          ),
                        );
                      } else if (unit == 'Dozen') {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => _buildDozenSelector(
                            context: context,
                            basePrice: double.tryParse(price) ?? 0.0,
                            name: name,
                            imageUrl: imageUrl,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : padding * 0.2,
                        vertical: isTablet ? 12 : padding * 0.2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(padding * 0.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: isTablet ? 20 : 16,
                          ),
                          SizedBox(width: isTablet ? 8 : screenWidth * 0.02),
                          Text(
                            "Add To Cart",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 16.0 : 12.0 * fontScale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSelector({
    required BuildContext context,
    required double basePrice,
    required String name,
    required String imageUrl,
  }) {
    final weights = ['1kg', '750g', '500g', '250g'];

    double getWeightFactor(String weight) {
      switch (weight) {
        case '1kg':
          return 1.0;
        case '750g':
          return 0.75;
        case '500g':
          return 0.5;
        case '250g':
        default:
          return 0.25;
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: weights.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final weight = weights[index];
          final calculatedPrice = (basePrice * getWeightFactor(weight))
              .toStringAsFixed(2);
          return ListTile(
            title: Text(
              'Add $weight - Rs $calculatedPrice',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width >= 768
                    ? 18.0
                    : 16.0,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              addToCart(name, calculatedPrice, imageUrl, weight);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added to cart',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBunchSelector({
    required BuildContext context,
    required double basePrice,
    required String name,
    required String imageUrl,
  }) {
    final bunches = ['1 Bunch', '2 Bunches', '3 Bunches'];

    double getBunchFactor(String bunch) {
      switch (bunch) {
        case '1 Bunch':
          return 1.0;
        case '2 Bunches':
          return 2.0;
        case '3 Bunches':
          return 3.0;
        default:
          return 1.0;
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: bunches.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final bunch = bunches[index];
          final calculatedPrice = (basePrice * getBunchFactor(bunch))
              .toStringAsFixed(2);
          return ListTile(
            title: Text(
              'Add $bunch - Rs $calculatedPrice',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width >= 768
                    ? 18.0
                    : 16.0,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              addToCart(name, calculatedPrice, imageUrl, bunch);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added to cart',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDozenSelector({
    required BuildContext context,
    required double basePrice,
    required String name,
    required String imageUrl,
  }) {
    final dozens = ['Half Dozen', '1 Dozen'];

    double getDozenFactor(String dozen) {
      switch (dozen) {
        case 'Half Dozen':
          return 0.5;
        case '1 Dozen':
        default:
          return 1.0;
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: dozens.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dozen = dozens[index];
          final calculatedPrice = (basePrice * getDozenFactor(dozen))
              .toStringAsFixed(2);
          return ListTile(
            title: Text(
              'Add $dozen - Rs $calculatedPrice',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width >= 768
                    ? 18.0
                    : 16.0,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              addToCart(name, calculatedPrice, imageUrl, dozen);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added to cart',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
