import 'package:flutter/material.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/marketplace_screen.dart';
import '../screens/user/cart_screen.dart';
import '../screens/user/profile_screen.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  const BottomNavbar({super.key, required this.currentIndex});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _navigateTo(const HomeScreen());
        break;
      case 1:
        _navigateTo(const MarketplaceScreen());
        break;
      case 2:
        _navigateTo(const CartScreen());
        break;
      case 3:
        _navigateTo(const ProfileScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrown = Color(0xFF5D4037);
    final Color unselected = const Color(0xFF8D6E63).withOpacity(0.7);
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFF5F2EC),
      selectedItemColor: primaryBrown,
      unselectedItemColor: unselected,
      selectedIconTheme: const IconThemeData(color: primaryBrown),
      unselectedIconTheme: IconThemeData(color: unselected),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'Keranjang',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
