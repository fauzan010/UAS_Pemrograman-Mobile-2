import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
// import 'providers/user_provider.dart'; // Hapus baris ini
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/product/manage_product_screen.dart';
import 'screens/admin/user/manage_user_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rlvpagyvbhrnvcxeaear.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsdnBhZ3l2YmhybnZjeGVhZWFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4MTk4MjMsImV4cCI6MjA4NDM5NTgyM30.pJGru-44MVy26BuBaWWaZ88MAKVOcI7g2bXulNujuWs',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // Tambahkan ini
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'WorldBike',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        primaryColor: const Color(0xFF5D4037), // coklat gelap seperti tanah/batu
        scaffoldBackgroundColor: const Color(0xFFF5F2EC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5D4037),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5D4037),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (ctx) => const SplashScreen(),
        '/login': (ctx) => LoginScreen(),
        '/register': (ctx) => RegisterScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/admin_dashboard': (ctx) => const AdminDashboard(),
        '/manage_product': (ctx) => const ManageProductScreen(),
        '/manage_user': (ctx) => const ManageUserScreen(), // Tambahkan route untuk Kelola User
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (ctx) => LoginScreen()),
    );
  }
}