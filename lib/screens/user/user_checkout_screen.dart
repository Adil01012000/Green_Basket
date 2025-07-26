import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    double total = widget.cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F5E8),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Back button outside the card
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.grey,
                        size: 24.w,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // White card container
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 700.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 24.h),

                              // Delivery Information Section
                              Text(
                                'Delivery Information',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // Input Fields
                              _buildInputField(
                                controller: _nameController,
                                label: 'Full Name',
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                    ? 'Please enter your name'
                                    : null,
                              ),
                              _buildInputField(
                                controller: _addressController,
                                label: 'Address',
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                    ? 'Please enter your address'
                                    : null,
                              ),
                              _buildInputField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  if (!RegExp(r'^\d{10,15}\$').hasMatch(val)) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24.h),

                              // Order Summary Section
                              Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // Order Items List
                              ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.cartItems.length,
                                separatorBuilder: (_, __) =>
                                    Divider(height: 12.h),
                                itemBuilder: (_, index) {
                                  final item = widget.cartItems[index];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.name} (${item.weight}) x${item.quantity}',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              Divider(thickness: 1, height: 24.h),

                              // Total Price
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rs ${total.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),

                              // Place Order Button
                              SizedBox(
                                width: double.infinity,
                                height: 48.h,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() => _isLoading = true);

                                            final orderId =
                                                'KH- 2${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9000) + 1000}';
                                            final orderData = {
                                              'orderId': orderId,
                                              'name': _nameController.text
                                                  .trim(),
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
                                                        fullName:
                                                            _nameController.text
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
                                                            () => widget
                                                                .cartItems
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
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.all(20),
                                                ),
                                              );
                                              setState(
                                                () => _isLoading = false,
                                              );
                                            }
                                          }
                                        },
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 24.w,
                                          width: 24.w,
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
                                            fontSize: 16.sp,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: 16.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          filled: true,
          fillColor: const Color(0xFFE8F5E8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.w),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}
