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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.04;
    final fontScale = screenWidth < 400
        ? 0.9
        : screenWidth > 600
        ? 1.2
        : 1.0;

    double total = widget.cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

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
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, 'updated'),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                          size: screenWidth * 0.06,
                        ),
                      ),
                      SizedBox(width: padding * 0.5),
                      Text(
                        'Your Cart',
                        style: TextStyle(
                          fontSize: 22 * fontScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Expanded(
                    child: widget.cartItems.isEmpty
                        ? Center(
                            child: Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: widget.cartItems.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: padding * 0.5),
                            itemBuilder: (context, index) {
                              final item = widget.cartItems[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E8),
                                  borderRadius: BorderRadius.circular(
                                    padding * 0.3,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(padding * 0.5),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          padding * 0.2,
                                        ),
                                        child: Image.network(
                                          item.imageUrl,
                                          width: screenWidth * 0.15,
                                          height: screenWidth * 0.15,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.fastfood,
                                            size: screenWidth * 0.1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: padding * 0.5),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.name,
                                                    style: TextStyle(
                                                      fontSize: 16 * fontScale,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 4),
                                            Text(
                                              'Weight: ${item.weight}',
                                              style: TextStyle(
                                                fontSize: 14 * fontScale,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      decreaseQuantity(item),
                                                  child: CircleAvatar(
                                                    radius: screenWidth * 0.04,
                                                    backgroundColor:
                                                        Colors.green,
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: screenWidth * 0.04,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: padding * 0.5),
                                                Text(
                                                  '${item.quantity}',
                                                  style: TextStyle(
                                                    fontSize: 16 * fontScale,
                                                  ),
                                                ),
                                                SizedBox(width: padding * 0.5),
                                                GestureDetector(
                                                  onTap: () =>
                                                      increaseQuantity(item),
                                                  child: CircleAvatar(
                                                    radius: screenWidth * 0.04,
                                                    backgroundColor:
                                                        Colors.green,
                                                    child: Icon(
                                                      Icons.add,
                                                      size: screenWidth * 0.04,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16 * fontScale,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                              onTap: () => removeItem(item),
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: screenWidth * 0.06,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (widget.cartItems.isNotEmpty) ...[
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(padding * 0.3),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  CheckoutScreen(cartItems: widget.cartItems),
                            ),
                          );
                        },
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16 * fontScale,
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
    );
  }
}
