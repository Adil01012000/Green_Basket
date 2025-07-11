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
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adaptive sizing based on device type
    final padding = isTablet ? screenWidth * 0.08 : screenWidth * 0.04;
    final maxContentWidth = isTablet ? 600.0 : double.infinity;
    final fontScale = isTablet
        ? 1.3
        : screenWidth < 400
        ? 0.9
        : 1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) => onClearCart());

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
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
                            size: isTablet ? 80 : screenWidth * 0.2,
                            color: Colors.green,
                          ),
                          SizedBox(height: isTablet ? 40 : screenHeight * 0.03),
                          Text(
                            'Order Placed!',
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 24 * fontScale,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: isTablet ? 16 : screenHeight * 0.01),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 400),
                            child: Text(
                              'Your order has been successfully placed.',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 16 * fontScale,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: isTablet ? 20 : screenHeight * 0.02),
                          Text(
                            'Order ID: $orderId',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 14 * fontScale,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: isTablet ? 30 : screenHeight * 0.03),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
                    _buildInfoRow('Name', fullName, fontScale, isTablet),
                    _buildInfoRow('Address', address, fontScale, isTablet),
                    _buildInfoRow('Phone', phone, fontScale, isTablet),
                    Divider(thickness: 1),
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 16 * fontScale,
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
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 14 * fontScale,
                                ),
                              ),
                            ),
                            Text(
                              'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 14 * fontScale,
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
                            fontSize: isTablet ? 22 : 16 * fontScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isTablet ? 22 : 16 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 40 : screenHeight * 0.04),
                    Center(
                      child: SizedBox(
                        width: isTablet ? 300 : double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 20 : screenHeight * 0.018,
                              horizontal: isTablet ? 40 : screenWidth * 0.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                padding * 0.3,
                              ),
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
                              fontSize: isTablet ? 20 : 16 * fontScale,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
    double fontScale,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: isTablet ? 12 : 8.0,
        bottom: isTablet ? 8 : 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: isTablet ? 18 : 14 * fontScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 18 : 14 * fontScale,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
