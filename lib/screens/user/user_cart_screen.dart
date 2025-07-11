import 'package:flutter/material.dart';
import '../../models/Cart.dart';
import '../user/user_checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void increaseQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void decreaseQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        widget.cartItems.remove(item);
      }
    });
  }

  void removeItem(CartItem item) {
    setState(() {
      widget.cartItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = isTablet ? screenWidth * 0.06 : screenWidth * 0.04;
    final maxContentWidth = isTablet ? 700.0 : double.infinity;
    final fontScale = isTablet
        ? 1.3
        : screenWidth < 400
        ? 0.9
        : 1.0;

    double total = widget.cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(padding * 0.5),
                    boxShadow: isTablet
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding * 0.8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with back button
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.grey,
                                size: isTablet ? 32 : 24,
                              ),
                              onPressed: () =>
                                  Navigator.pop(context, 'updated'),
                            ),
                            SizedBox(width: padding * 0.5),
                            Text(
                              'Your Cart',
                              style: TextStyle(
                                fontSize: isTablet ? 28 : 22 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 30 : screenHeight * 0.03),

                        // Cart Items List
                        Expanded(
                          child: widget.cartItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'Your cart is empty',
                                    style: TextStyle(
                                      fontSize: isTablet ? 22 : 16 * fontScale,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: widget.cartItems.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: isTablet ? 20 : 12),
                                  itemBuilder: (_, index) {
                                    final item = widget.cartItems[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E8),
                                        borderRadius: BorderRadius.circular(
                                          padding * 0.3,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(
                                        isTablet ? 20 : padding * 0.5,
                                      ),
                                      child: Row(
                                        children: [
                                          // Product Image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              padding * 0.2,
                                            ),
                                            child: Image.network(
                                              item.imageUrl,
                                              width: isTablet
                                                  ? 100
                                                  : screenWidth * 0.15,
                                              height: isTablet
                                                  ? 100
                                                  : screenWidth * 0.15,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                    Icons.fastfood,
                                                    size: isTablet
                                                        ? 50
                                                        : screenWidth * 0.1,
                                                    color: Colors.grey,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: isTablet
                                                ? 20
                                                : padding * 0.5,
                                          ),

                                          // Product Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 22
                                                        : 16 * fontScale,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: isTablet ? 8 : 4,
                                                ),
                                                Text(
                                                  'Weight: ${item.weight}',
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 18
                                                        : 14 * fontScale,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: isTablet ? 12 : 6,
                                                ),

                                                // Quantity Controls
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          decreaseQuantity(
                                                            item,
                                                          ),
                                                      child: CircleAvatar(
                                                        radius: isTablet
                                                            ? 20
                                                            : screenWidth *
                                                                  0.04,
                                                        backgroundColor:
                                                            Colors.green,
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: isTablet
                                                              ? 24
                                                              : screenWidth *
                                                                    0.04,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: isTablet
                                                          ? 16
                                                          : padding * 0.5,
                                                    ),
                                                    Text(
                                                      '${item.quantity}',
                                                      style: TextStyle(
                                                        fontSize: isTablet
                                                            ? 22
                                                            : 16 * fontScale,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: isTablet
                                                          ? 16
                                                          : padding * 0.5,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          increaseQuantity(
                                                            item,
                                                          ),
                                                      child: CircleAvatar(
                                                        radius: isTablet
                                                            ? 20
                                                            : screenWidth *
                                                                  0.04,
                                                        backgroundColor:
                                                            Colors.green,
                                                        child: Icon(
                                                          Icons.add,
                                                          size: isTablet
                                                              ? 24
                                                              : screenWidth *
                                                                    0.04,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Price and Delete
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: isTablet
                                                      ? 22
                                                      : 16 * fontScale,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              SizedBox(
                                                height: isTablet ? 10 : 6,
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: isTablet
                                                      ? 30
                                                      : screenWidth * 0.06,
                                                ),
                                                onPressed: () =>
                                                    removeItem(item),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Checkout Section (only shown if cart has items)
                        if (widget.cartItems.isNotEmpty) ...[
                          SizedBox(height: isTablet ? 30 : screenHeight * 0.02),
                          Divider(thickness: 1, height: 1),
                          SizedBox(height: isTablet ? 20 : screenHeight * 0.02),

                          // Total Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: isTablet ? 26 : 18 * fontScale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rs ${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: isTablet ? 26 : 18 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 30 : screenHeight * 0.02),

                          // Checkout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 20 : screenHeight * 0.02,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    padding * 0.3,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                      cartItems: widget.cartItems,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: isTablet ? 22 : 16 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
