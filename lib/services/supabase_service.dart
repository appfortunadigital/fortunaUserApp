// lib/services/supabase_service.dart
// Layanan untuk interaksi dengan Supabase, khusus untuk pelanggan.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/product.dart';

class SupabaseService {
  final _supabaseClient = Supabase.instance.client;
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final List<Product> _cartItems = [];

  // Metode untuk mengelola keranjang
  void addToCart(Product product) {
    _cartItems.add(product);
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
  }

  void clearCart() {
    _cartItems.clear();
  }

  List<Product> getCartItems() {
    return _cartItems;
  }

  // Metode untuk interaksi dengan database
  Stream<List<Product>> getAllProductsStream() {
    return _supabaseClient
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Product.fromJson(json)).toList());
  }

  Future<Product?> getProductById(int productId) async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .eq('id', productId)
        .single();
    if (response.isNotEmpty) {
      return Product.fromJson(response);
    }
    return null;
  }

  Future<void> placeOrder({
    required String customerName,
    required String deliveryAddress,
    required List<Product> products,
  }) async {
    final userId = _supabaseClient.auth.currentUser!.id;
    // Asumsi setiap pesanan hanya berisi satu produk untuk penyederhanaan
    final firstProduct = products.first;

    await _supabaseClient.from('orders').insert({
      'user_id': userId,
      'product_id': firstProduct.id,
      'customer_name': customerName,
      'delivery_address': deliveryAddress,
      'status': 'pending',
    });
  }

  Stream<List<Order>> getCustomerOrders(String userId) {
    return _supabaseClient
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Order.fromJson(json)).toList());
  }
}
