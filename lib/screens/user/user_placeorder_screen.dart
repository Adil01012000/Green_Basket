import 'package:flutter/material.dart';
import '../../models/Cart.dart';
import 'user_dashboard_scree.dart';

class PlaceOrderScreen extends StatelessWidget {
  final String orderId;
  final String fullName;
  final String address;
  final String phone;
  final double total;
  final List<CartItem> cartItems;
  final VoidCallback onClearCart;

  const PlaceOrderScreen({
    Key? key,
    required this.orderId,
    required this.fullName,
    required this.address,
    required this.phone,
    required this.total,
    required this.cartItems,
    required this.onClearCart,
  }) : super(key: key);

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

    WidgetsBinding.instance.addPostFrameCallback((_) => onClearCart());

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding * 1.2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(padding * 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: screenWidth * 0.2,
                        color: Colors.green,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Order Placed!',
                        style: TextStyle(
                          fontSize: 24 * fontScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Your order has been successfully placed.',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Order ID: $orderId',
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
                Divider(thickness: 1),
                _buildInfoRow('Name', fullName, fontScale),
                _buildInfoRow('Address', address, fontScale),
                _buildInfoRow('Phone', phone, fontScale),
                Divider(thickness: 1),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: padding * 0.5),
                ...cartItems.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: padding * 0.4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} x${item.quantity}',
                            style: TextStyle(fontSize: 14 * fontScale),
                          ),
                        ),
                        Text(
                          'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rs ${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                        horizontal: screenWidth * 0.1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(padding * 0.3),
                      ),
                    ),
                    onPressed: () {
                      onClearCart();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const UserDashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, double fontScale) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14 * fontScale, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
