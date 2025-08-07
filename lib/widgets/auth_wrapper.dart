// lib/widgets/auth_wrapper.dart
// Widget pembungkus yang mengelola status autentikasi dan peran pengguna.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Flag untuk memastikan hanya satu navigasi awal yang terjadi
  bool _isInitialCheckComplete = false;

  @override
  void initState() {
    super.initState();
    // PENTING: Lakukan pemeriksaan status awal saat widget pertama kali dibuat.
    _initialAuthCheck();

    // Dengarkan perubahan status autentikasi untuk penyesuaian dinamis.
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      print('AuthWrapper: Menerima event autentikasi: $event');
      if (mounted) {
        if (event == AuthChangeEvent.signedIn) {
          // Hanya panggil _checkUserRole jika bukan dari pemeriksaan awal
          if (!_isInitialCheckComplete) {
            _checkUserRole();
          }
        } else if (event == AuthChangeEvent.signedOut) {
          context.go('/login');
        }
      }
    });
  }

  Future<void> _initialAuthCheck() async {
    print('AuthWrapper: Memulai pemeriksaan status otentikasi awal...');
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      print('AuthWrapper: Pengguna ditemukan, memeriksa peran...');
      await _checkUserRole();
    } else {
      print('AuthWrapper: Tidak ada pengguna yang ditemukan, menavigasi ke login...');
      context.go('/login');
    }
    _isInitialCheckComplete = true;
  }

  Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      
      final String role = response['role'];
      if (mounted) {
        if (role == 'customer') {
          print('AuthWrapper: Peran adalah pelanggan, menavigasi ke dashboard...');
          context.go('/dashboard');
        } else {
          print('AuthWrapper: Peran bukan pelanggan, menavigasi ke login...');
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        print('AuthWrapper: Gagal mendapatkan peran, menavigasi ke login. Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan peran pengguna: $e')),
        );
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen sampai status autentikasi diketahui.
    // Kode di sini hanya akan berjalan sebentar karena _initialAuthCheck akan menavigasi.
    print('AuthWrapper: Menampilkan CircularProgressIndicator...');
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
