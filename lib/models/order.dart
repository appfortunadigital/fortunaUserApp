// lib/models/order.dart
// Model data untuk objek pesanan.

class Order {
  final int id;
  final String customerName;
  final String deliveryAddress;
  final String status;
  final String? productName; // Informasi produk di level pesanan
  final double? productPrice;

  Order({
    required this.id,
    required this.customerName,
    required this.deliveryAddress,
    required this.status,
    this.productName,
    this.productPrice,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'] ?? 'Tidak diketahui',
      deliveryAddress: json['delivery_address'] ?? 'Tidak diketahui',
      status: json['status'],
      productName: json['product'] != null ? json['product']['name'] : null,
      productPrice: json['product'] != null ? (json['product']['price'] as num).toDouble() : null,
    );
  }
}
