import 'package:flutter/material.dart';
import '../../models/Cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final String name;
  final String price;
  final String imageUrl;
  final bool isFavorite;
  final String unit;
  final Function(String, String, String, String) onAddToCart;

  const ProductDetailScreen({
    Key? key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
    required this.unit,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedQuantity;
  double calculatedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize with the first available quantity based on unit
    if (widget.unit == 'kilogram') {
      selectedQuantity = '250g';
      calculatedPrice = (double.tryParse(widget.price) ?? 0.0) * 0.25;
    } else if (widget.unit == 'bunch') {
      selectedQuantity = '1 Bunch';
      calculatedPrice = double.tryParse(widget.price) ?? 0.0;
    } else if (widget.unit == 'dozen') {
      selectedQuantity = 'Half Dozen';
      calculatedPrice = (double.tryParse(widget.price) ?? 0.0) * 0.5;
    }
  }

  // Quantity options based on unit type
  List<String> getQuantityOptions() {
    if (widget.unit == 'kilogram') {
      return ['250g', '500g', '750g', '1kg'];
    } else if (widget.unit == 'bunch') {
      return ['1 Bunch', '2 Bunches', '3 Bunches'];
    } else if (widget.unit == 'dozen') {
      return ['Half Dozen', '1 Dozen'];
    }
    return ['250g', '500g', '750g', '1kg']; // Default to kilogram
  }

  // Calculate price based on selected quantity
  double getQuantityFactor(String quantity) {
    if (widget.unit == 'kilogram') {
      switch (quantity) {
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
    } else if (widget.unit == 'bunch') {
      switch (quantity) {
        case '1 Bunch':
          return 1.0;
        case '2 Bunches':
          return 2.0;
        case '3 Bunches':
          return 3.0;
        default:
          return 1.0;
      }
    } else if (widget.unit == 'dozen') {
      switch (quantity) {
        case 'Half Dozen':
          return 0.5;
        case '1 Dozen':
        default:
          return 1.0;
      }
    }
    return 1.0;
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

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20 * fontScale,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: screenHeight * 0.4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(padding * 0.5),
                    color: Colors.grey[200],
                  ),
                  child: widget.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(padding * 0.5),
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.fastfood,
                                size: screenWidth * 0.2,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.fastfood,
                            size: screenWidth * 0.2,
                            color: Colors.grey,
                          ),
                        ),
                ),
                SizedBox(height: padding * 0.5),
                // Product Name
                Text(
                  widget.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24 * fontScale,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: padding * 0.2),
                // Product Price
                Text(
                  'Rs: ${calculatedPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * fontScale,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: padding * 0.5),
                // Unit Type
                Text(
                  'Unit: ${widget.unit}',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: padding * 0.5),
                // Quantity Selector
                Text(
                  'Select Quantity',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * fontScale,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: padding * 0.3),
                DropdownButton<String>(
                  value: selectedQuantity,
                  isExpanded: true,
                  hint: Text('Select ${widget.unit}'),
                  items: getQuantityOptions().map((quantity) {
                    return DropdownMenuItem<String>(
                      value: quantity,
                      child: Text(quantity),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedQuantity = value;
                      calculatedPrice =
                          (double.tryParse(widget.price) ?? 0.0) *
                          getQuantityFactor(value!);
                    });
                  },
                ),
                SizedBox(height: padding * 0.5),
                // Description (Placeholder)
                Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * fontScale,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: padding * 0.2),
                Text(
                  'This is a fresh and high-quality ${widget.name}. Perfect for a healthy diet.',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: padding),
                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedQuantity != null
                        ? () {
                            widget.onAddToCart(
                              widget.name,
                              calculatedPrice.toStringAsFixed(2),
                              widget.imageUrl,
                              selectedQuantity!,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.name} ($selectedQuantity) added to cart',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(padding * 0.3),
                      ),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
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
    );
  }
}
