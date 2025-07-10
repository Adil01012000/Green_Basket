class CartItem {
  final String id; // should be unique per name + weight
  final String name;
  final double price;
  final String imageUrl;
  final String weight;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.weight,
    this.quantity = 1,
  });
}
