// lib/main.dart
// Mengatur inisialisasi Supabase, GoRouter, dan navigasi utama.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async'; // Import ini dibutuhkan untuk StreamSubscription

import 'pages/customer_dashboard_page.dart';
import 'pages/product_list_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/order_history_page.dart';
import 'pages/profile_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/auth/forgot_password_page.dart';
// import 'widgets/auth_wrapper.dart'; // AuthWrapper tidak lagi digunakan

// Inisialisasi SupabaseClient
final supabase = Supabase.instance.client;

// --- Definisi Rute Aplikasi ---
final _router = GoRouter(
  // PENTING: Fungsi redirect untuk mengelola status otentikasi.
  redirect: (context, state) {
    final isAuthenticated = supabase.auth.currentUser != null;
    final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/register' || state.uri.path == '/forgot-password';

    // Jika pengguna belum login dan mencoba mengakses halaman selain login/register, arahkan ke login.
    if (!isAuthenticated && !isLoggingIn) {
      return '/login';
    }

    // Jika pengguna sudah login dan mencoba mengakses halaman login/register, arahkan ke dashboard.
    if (isAuthenticated && isLoggingIn) {
      return '/dashboard';
    }

    // Jika tidak ada kondisi di atas, biarkan navigasi berlanjut.
    return null;
  },
  // Tambahkan key untuk merefresh router saat status otentikasi berubah.
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
  ],
);

// --- Stream untuk mendengarkan perubahan otentikasi GoRouter ---
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  // PERBAIKAN: Mengubah tipe dari Stream<AuthState> menjadi StreamSubscription<AuthState>
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel(); // Gunakan .cancel() untuk menghentikan subscription
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

// --- Widget untuk Menangani Proses Loading Aplikasi (Inisialisasi) ---
class LoadingApp extends StatefulWidget {
  const LoadingApp({super.key});

  @override
  State<LoadingApp> createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> {
  // Gunakan FutureBuilder untuk menunggu inisialisasi selesai
  Future<void> _initializeSupabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Kunci Supabase tidak ditemukan di file .env.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeSupabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: ErrorScreen(message: snapshot.error.toString()),
            );
          } else {
            return const MyApp(); // Inisialisasi berhasil, tampilkan aplikasi utama
          }
        } else {
          return const MaterialApp(
            home: SplashScreen(), // Tampilkan splash screen saat loading
          );
        }
      },
    );
  }
}

// --- Halaman Splash Screen ---
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// --- Halaman Error ---
class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                'Terjadi Kesalahan:',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Fungsi main() ---
void main() {
  runApp(const LoadingApp());
}
