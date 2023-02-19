import 'package:agistaofficial/screens/cart/cart_screen.dart';
import 'package:agistaofficial/screens/cod/cod_screen.dart';
import 'package:agistaofficial/screens/product/product_screen.dart';
import 'package:agistaofficial/screens/transaction/transalction_screen.dart';
import 'package:agistaofficial/util/common.dart';
import 'package:flutter/material.dart';

import '../util/themes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;

  final _bottomNavigationBarItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, color: Colors.grey),
      activeIcon: Icon(Icons.home_filled, color: AppCommon.green),
      label: 'Beranda',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey),
      activeIcon: Icon(Icons.shopping_cart_sharp, color: AppCommon.green),
      label: 'Keranjang',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.monetization_on_outlined, color: Colors.grey),
      activeIcon: Icon(Icons.monetization_on, color: AppCommon.green),
      label: 'Transaksi',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_alt_outlined, color: Colors.grey),
      activeIcon: Icon(Icons.people_alt, color: AppCommon.green),
      label: 'COD',
    ),
  ];

  final List<Widget> _screens = [
    ProductScreen(),
    CartScreen(),
    TransactionScreen(),
    CODScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: Themes(),
        child: Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: _bottomNavigationBarItems,
            currentIndex: _selectedIndex,
            selectedItemColor: AppCommon.green,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
          ),
        )
    );
  }
}