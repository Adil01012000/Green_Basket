import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/Cart.dart';
import '../user/user_placeorder_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                      child: Form(
                        key: _formKey,
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
                                  onPressed: () => Navigator.pop(context),
                                ),
                                SizedBox(width: padding * 0.5),
                                Text(
                                  'Checkout',
                                  style: TextStyle(
                                    fontSize: isTablet ? 28 : 22 * fontScale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: isTablet ? 30 : screenHeight * 0.03,
                            ),

                            // Delivery Information Section
                            Text(
                              'Delivery Information',
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 16 * fontScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isTablet ? 16 : padding * 0.5),

                            // Input Fields
                            _buildInputField(
                              controller: _nameController,
                              label: 'Full Name',
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                  ? 'Please enter your name'
                                  : null,
                              fontScale: fontScale,
                              padding: padding,
                              isTablet: isTablet,
                            ),
                            _buildInputField(
                              controller: _addressController,
                              label: 'Address',
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                  ? 'Please enter your address'
                                  : null,
                              fontScale: fontScale,
                              padding: padding,
                              isTablet: isTablet,
                            ),
                            _buildInputField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter phone number';
                                }
                                if (!RegExp(r'^\d{10,15}$').hasMatch(val)) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                              fontScale: fontScale,
                              padding: padding,
                              isTablet: isTablet,
                            ),
                            SizedBox(
                              height: isTablet ? 30 : screenHeight * 0.03,
                            ),

                            // Order Summary Section
                            Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 16 * fontScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isTablet ? 16 : padding * 0.5),

                            // Order Items List
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.cartItems.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: isTablet ? 20 : 12),
                              itemBuilder: (_, index) {
                                final item = widget.cartItems[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 8 : 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.name} (${item.weight}) x${item.quantity}',
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? 20
                                                : 14 * fontScale,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: isTablet
                                              ? 20
                                              : 14 * fontScale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            Divider(
                              thickness: 1,
                              height: isTablet ? 40 : screenHeight * 0.04,
                            ),

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
                            SizedBox(
                              height: isTablet ? 30 : screenHeight * 0.02,
                            ),

                            // Place Order Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet
                                        ? 20
                                        : screenHeight * 0.02,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      padding * 0.3,
                                    ),
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => _isLoading = true);

                                          final orderId =
                                              'KH-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9000) + 1000}';
                                          final orderData = {
                                            'orderId': orderId,
                                            'name': _nameController.text.trim(),
                                            'address': _addressController.text
                                                .trim(),
                                            'phone': _phoneController.text
                                                .trim(),
                                            'total': 'Rs $total',
                                            'createdAt':
                                                FieldValue.serverTimestamp(),
                                            'status': 'pending',
                                            'items': widget.cartItems
                                                .map(
                                                  (item) => {
                                                    'name': item.name,
                                                    'price': item.price,
                                                    'quantity': item.quantity,
                                                    'weight': item.weight,
                                                    'imageUrl': item.imageUrl,
                                                  },
                                                )
                                                .toList(),
                                          };

                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('orders')
                                                .doc(orderId)
                                                .set(orderData);

                                            if (!mounted) return;

                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PlaceOrderScreen(
                                                      orderId: orderId,
                                                      fullName: _nameController
                                                          .text
                                                          .trim(),
                                                      address:
                                                          _addressController
                                                              .text
                                                              .trim(),
                                                      phone: _phoneController
                                                          .text
                                                          .trim(),
                                                      total: total,
                                                      cartItems: List.from(
                                                        widget.cartItems,
                                                      ),
                                                      onClearCart: () {
                                                        setState(
                                                          () => widget.cartItems
                                                              .clear(),
                                                        );
                                                      },
                                                    ),
                                              ),
                                            );

                                            if (!mounted) return;
                                            Navigator.pop(context, 'updated');
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to place order: ${e.toString()}',
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 16
                                                        : 14,
                                                  ),
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin: EdgeInsets.all(20),
                                              ),
                                            );
                                            setState(() => _isLoading = false);
                                          }
                                        }
                                      },
                                child: _isLoading
                                    ? SizedBox(
                                        height: isTablet ? 28 : 20,
                                        width: isTablet ? 28 : 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Place Order',
                                        style: TextStyle(
                                          fontSize: isTablet
                                              ? 22
                                              : 16 * fontScale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required double fontScale,
    required double padding,
    required bool isTablet,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20 : padding * 0.5),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: isTablet ? 20 : 16 * fontScale),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: isTablet ? 18 : 14 * fontScale,
            color: Colors.grey[700],
          ),
          filled: true,
          fillColor: const Color(0xFFE8F5E8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(padding * 0.3),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 18 : 14,
          ),
        ),
      ),
    );
  }
}
