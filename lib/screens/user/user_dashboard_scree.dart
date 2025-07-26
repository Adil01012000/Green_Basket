import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              SizedBox(height: 24.h),

              // Welcome Section
              _buildWelcomeSection(),
              SizedBox(height: 24.h),

              // Search Bar
              _buildSearchBar(),
              SizedBox(height: 24.h),

              // Category Tabs
              _buildCategoryTabs(),
              SizedBox(height: 24.h),

              // Products Grid
              Expanded(child: _buildProductsGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Container(
            //   width: 40.w,
            //   height: 40.w,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     border: Border.all(color: Colors.green, width: 2.w),
            //   ),
            //   child: ClipOval(
            //     child: Image.asset(
            //       'assets/green_basket_splash.png',
            //       width: 28.w,
            //       height: 28.w,
            //       fit: BoxFit.contain,
            //     ),
            //   ),
            // ),
            SizedBox(width: 4.w),
            Text(
              'Green Basket',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.sp),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              iconSize: 24.w,
              icon: const Icon(Icons.person, color: Colors.grey),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Welcome back, $result!')),
                  );
                }
              },
            ),
            IconButton(
              iconSize: 24.w,
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.grey),
                  if (cartItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cartItems.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
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
                    builder: (_) => CartScreen(cartItems: cartItems),
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
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome User',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
        Text(
          'Find your health',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/green_basket_splash.png',
            width: 28.w,
            height: 28.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
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
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('categories')
          .where('enabled', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("No categories found", style: TextStyle(fontSize: 14.sp));
        }

        final categoryDocs = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryTab('All'),
              ...categoryDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Unnamed';
                return _buildCategoryTab(name);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTab(String title) {
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
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 1,
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading products',
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No products found', style: TextStyle(fontSize: 14.sp)),
          );
        }

        final products = snapshot.data!.docs.where((doc) {
          final product = doc.data() as Map<String, dynamic>;
          final productName = (product['name'] ?? '').toLowerCase();
          final productCategory = product['categoryName'] ?? '';

          bool matchesSearch = productName.contains(searchQuery);
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
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(),
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index].data() as Map<String, dynamic>;
            return _buildProductCard(
              product['name'] ?? 'Product Name',
              product['price']?.toString() ?? '0.00',
              product['imageUrl'] ?? '',
              product['isFavorite'] ?? false,
              product['unit'] ?? 'kilogram',
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    if (width > 400) return 2;
    return 1;
  }

  Widget _buildProductCard(
    String name,
    String price,
    String imageUrl,
    bool isFavorite,
    String unit,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.w),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12.w),
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 40.w,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 40.w,
                            color: Colors.grey,
                          ),
                        ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 16.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Price
                  Text(
                    'Rs: $price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 36.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                      onPressed: () {
                        if (unit == 'Kilogram') {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.w),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.w),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.w),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 14.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Add To Cart",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: weights.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final weight = weights[index];
          final calculatedPrice = (basePrice * getWeightFactor(weight))
              .toStringAsFixed(2);
          return ListTile(
            title: Text(
              'Add $weight - Rs $calculatedPrice',
              style: TextStyle(fontSize: 16.sp),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: bunches.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final bunch = bunches[index];
          final calculatedPrice = (basePrice * getBunchFactor(bunch))
              .toStringAsFixed(2);
          return ListTile(
            title: Text(
              'Add $bunch - Rs $calculatedPrice',
              style: TextStyle(fontSize: 16.sp),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: dozens.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dozen = dozens[index];
          final calculatedPrice = (basePrice * getDozenFactor(dozen))
              .toStringAsFixed(2);
          return ListTile(
            title: Text(
              'Add $dozen - Rs $calculatedPrice',
              style: TextStyle(fontSize: 16.sp),
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
