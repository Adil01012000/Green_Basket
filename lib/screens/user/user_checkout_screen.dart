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

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.grey,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          SizedBox(width: padding * 0.5),
                          Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 22 * fontScale,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Delivery Information',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: padding * 0.5),
                      _buildInputField(
                        controller: _nameController,
                        label: 'Full Name',
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Enter name'
                            : null,
                        fontScale: fontScale,
                        padding: padding,
                      ),
                      _buildInputField(
                        controller: _addressController,
                        label: 'Address',
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Enter address'
                            : null,
                        fontScale: fontScale,
                        padding: padding,
                      ),
                      _buildInputField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter phone number';
                          }
                          if (!RegExp(r'^\d{10,15}$').hasMatch(val)) {
                            return 'Enter valid number';
                          }
                          return null;
                        },
                        fontScale: fontScale,
                        padding: padding,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: padding * 0.5),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.cartItems.length,
                          itemBuilder: (_, index) {
                            final item = widget.cartItems[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: padding * 0.5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.name} (x${item.quantity})',
                                      style: TextStyle(
                                        fontSize: 14 * fontScale,
                                        color: Colors.black,
                                      ),
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
                            );
                          },
                        ),
                      ),
                      Divider(thickness: 1, height: screenHeight * 0.04),
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
                              borderRadius: BorderRadius.circular(
                                padding * 0.3,
                              ),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Generate order ID
                                    final orderId =
                                        'KH-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9000) + 1000}';

                                    // Create the order data
                                    final orderData = {
                                      'orderId': orderId,
                                      'name': _nameController.text.trim(),
                                      'address': _addressController.text.trim(),
                                      'phone': _phoneController.text.trim(),
                                      'total': 'Rs $total',
                                      'createdAt': FieldValue.serverTimestamp(),
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
                                    } catch (e, stack) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to place order:\n$e',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // Navigate to PlaceOrderScreen
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PlaceOrderScreen(
                                          orderId: orderId,
                                          fullName: _nameController.text.trim(),
                                          address: _addressController.text
                                              .trim(),
                                          phone: _phoneController.text.trim(),
                                          total: total,
                                          cartItems: List.from(
                                            widget.cartItems,
                                          ),
                                          onClearCart: () {
                                            setState(() {
                                              widget.cartItems.clear();
                                            });
                                          },
                                        ),
                                      ),
                                    );

                                    if (result == 'updated') {
                                      Navigator.pop(context, 'updated');
                                    }
                                  }
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Place Order',
                                  style: TextStyle(
                                    fontSize: 16 * fontScale,
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
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required double fontScale,
    required double padding,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding * 0.5),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14 * fontScale,
            color: Colors.grey[700],
          ),
          filled: true,
          fillColor: const Color(0xFFE8F5E8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(padding * 0.3),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
