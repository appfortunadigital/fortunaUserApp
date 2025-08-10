// lib/main.dart
// Mengatur inisialisasi Supabase, GoRouter, dan navigasi utama.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mengimpor semua halaman menggunakan jalur paket yang benar
import 'package:AplikasiPelanggan/pages/customer_dashboard_page.dart';
import 'package:AplikasiPelanggan/pages/product_list_page.dart';
import 'package:AplikasiPelanggan/pages/product_detail_page.dart';
import 'package:AplikasiPelanggan/pages/cart_page.dart';
import 'package:AplikasiPelanggan/pages/checkout_page.dart';
import 'package:AplikasiPelanggan/pages/order_history_page.dart';
import 'package:AplikasiPelanggan/pages/profile_page.dart';
import 'package:AplikasiPelanggan/pages/auth/login_page.dart';
import 'package:AplikasiPelanggan/pages/auth/register_page.dart';
import 'package:AplikasiPelanggan/pages/auth/forgot_password_page.dart';

// Inisialisasi SupabaseClient
final supabase = Supabase.instance.client;

// --- Definisi Rute Aplikasi ---
final _router = GoRouter(
  // Fungsi redirect untuk mengelola status otentikasi.
  redirect: (context, state) {
    final isAuthenticated = supabase.auth.currentUser != null;
    final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/register' || state.uri.path == '/forgot-password';

    if (!isAuthenticated && !isLoggingIn) {
      return '/login';
    }

    if (isAuthenticated && isLoggingIn) {
      return '/dashboard';
    }
    return null;
  },
  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  initialLocation: '/login', // Atur halaman awal ke login
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const CustomerDashboardPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) {
        final productId = int.parse(state.pathParameters['id']!);
        return ProductDetailPage(productId: productId);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderHistoryPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/login-callback',
      builder: (context, state) => const Center(child: CircularProgressIndicator()),
    ),
    GoRoute(
      path: '/reset-password-callback',
      builder: (context, state) => const Center(child: CircularProgressIndicator()),
    ),
  ],
);

// --- Stream untuk mendengarkan perubahan otentikasi GoRouter ---
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// --- Widget Utama Aplikasi ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aplikasi Pelanggan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

// --- Fungsi main() ---
Future<void> main() async {
  // 1. Pastikan Flutter Widgets sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Load file .env
  await dotenv.load(fileName: ".env");

  // 3. Ambil URL dan Anon Key dari .env
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  // 4. Lakukan pengecekan untuk menghindari error
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Kunci Supabase tidak ditemukan di file .env.');
  }

  // 5. Inisialisasi Supabase SATU KALI DI SINI
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // 6. Jalankan aplikasi setelah Supabase siap
  runApp(const MyApp());
}
