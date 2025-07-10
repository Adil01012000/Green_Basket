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
  String? selectedCategory; // Keep null initially to show all products
  String searchQuery = '';
  List<CartItem> cartItems = [];

  void addToCart(String name, String price, String imageUrl, String weight) {
    final id = '$name-$weight'; // make id unique per weight
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final padding = screenWidth * 0.04;
    final fontScale = screenWidth < 400
        ? 0.9
        : screenWidth > 600
        ? 1.2
        : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: screenWidth * 0.02,
                            height: screenWidth * 0.02,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.015),
                          Text(
                            'Green Basket',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16 * fontScale,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person, color: Colors.grey),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInScreen(),
                                ),
                              );
                              if (result != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Welcome back, ${result}!'),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
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
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${cartItems.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
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
                                setState(() {}); // Refresh cart badge
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'Welcome User',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Find your health',
                    style: TextStyle(
                      fontSize: 28 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    height: screenHeight * 0.07,
                    padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(padding * 0.3),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: screenWidth * 0.06,
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
                                fontSize: 16 * fontScale,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('categories')
                        .where('enabled', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text(
                          "No categories found",
                          style: TextStyle(fontSize: 14 * fontScale),
                        );
                      }

                      final categoryDocs = snapshot.data!.docs;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Add "All" category as the first option
                            Padding(
                              padding: EdgeInsets.only(right: padding * 0.5),
                              child: _buildCategoryTab('All', fontScale),
                            ),
                            // Then show all other categories
                            ...categoryDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final name = data['name'] ?? 'Unnamed';
                              return Padding(
                                padding: EdgeInsets.only(right: padding * 0.5),
                                child: _buildCategoryTab(name, fontScale),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('products')
                          .snapshots(), // Get all products
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
                              style: TextStyle(fontSize: 14 * fontScale),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No products found',
                              style: TextStyle(fontSize: 14 * fontScale),
                            ),
                          );
                        }

                        // Filter products based on selected category and search query
                        final products = snapshot.data!.docs.where((doc) {
                          final product = doc.data() as Map<String, dynamic>;
                          final productName = (product['name'] ?? '')
                              .toLowerCase();
                          final productCategory = product['categoryName'] ?? '';

                          // Check search query match
                          bool matchesSearch = productName.contains(
                            searchQuery,
                          );

                          // Check category match (if no category selected, show all)
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
                              style: TextStyle(fontSize: 14 * fontScale),
                            ),
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: padding * 0.5,
                                mainAxisSpacing: padding * 0.5,
                                childAspectRatio: screenWidth < 400
                                    ? 0.7
                                    : 0.75,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product =
                                products[index].data() as Map<String, dynamic>;
                            return _buildFoodItem(
                              product['name'] ?? 'Product Name',
                              product['price']?.toString() ?? '0.00',
                              product['imageUrl'] ?? '',
                              product['isFavorite'] ?? false,
                              product['unit'] ?? 'kilogram', // New unit field
                              fontScale,
                              screenWidth,
                              padding,
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
    );
  }

  Widget _buildCategoryTab(String title, double fontScale) {
    bool isSelected =
        selectedCategory == title ||
        (selectedCategory == null && title == 'All');

    return GestureDetector(
      onTap: () {
        setState(() {
          if (title == 'All') {
            selectedCategory = null; // Set to null to show all products
          } else {
            selectedCategory = title;
          }
          searchQuery = ''; // Clear search when changing category
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
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
            fontSize: 14 * fontScale,
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
    String unit, // New parameter for unit type
    double fontScale,
    double screenWidth,
    double padding,
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
                                size: screenWidth * 0.1,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.fastfood,
                            size: screenWidth * 0.1,
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
                      padding: EdgeInsets.all(padding * 0.2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: screenWidth * 0.04,
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
                      fontSize: 14 * fontScale,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rs: $price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * fontScale,
                      color: Colors.green,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          // Decide which bottom sheet to show based on unit
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
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(padding * 0.2),
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
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "Add To Cart",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
    final weights = ['250g', '500g', '750g', '1kg'];

    double getWeightFactor(String weight) {
      switch (weight) {
        case '250g':
          return 0.25;
        case '500g':
          return 0.5;
        case '750g':
          return 0.75;
        case '1kg':
        default:
          return 1.0;
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: weights.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final weight = weights[index];
        final calculatedPrice = (basePrice * getWeightFactor(weight))
            .toStringAsFixed(2);
        return ListTile(
          title: Text('Add $weight - Rs $calculatedPrice'),
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

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: bunches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final bunch = bunches[index];
        final calculatedPrice = (basePrice * getBunchFactor(bunch))
            .toStringAsFixed(2);
        return ListTile(
          title: Text('Add $bunch - Rs $calculatedPrice'),
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

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: dozens.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final dozen = dozens[index];
        final calculatedPrice = (basePrice * getDozenFactor(dozen))
            .toStringAsFixed(2);
        return ListTile(
          title: Text('Add $dozen - Rs $calculatedPrice'),
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
    );
  }
}
