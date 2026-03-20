import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/view/home/home_view.dart';
import 'package:appfood/view/menu/menu_view.dart'; // Màn hình Menu mới
import 'package:appfood/view/order/order_view.dart'; // 'Offers'
import 'package:appfood/view/profile/profile_view.dart'; // 'Profile'

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 2; // Default to Home (Center)

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Widget _buildNavigator(int index, Widget rootWidget) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => rootWidget);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildNavigator(0, const MenuView()),
          _buildNavigator(1, const OrderView()),
          _buildNavigator(2, const HomeView()),
          _buildNavigator(3, const ProfileView()),
          _buildNavigator(4, Container(color: Colors.white)), // Placeholder
        ],
      ),
      backgroundColor: const Color(0xfff5f5f5),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex != 2) {
            setState(() {
              _currentIndex = 2;
            });
          } else {
            _navigatorKeys[2].currentState?.popUntil((route) => route.isFirst);
          }
        },
        backgroundColor: _currentIndex == 2
            ? TColor.primary
            : TColor.placeholder,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        child: Icon(Icons.home_rounded, color: TColor.white, size: 35),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: TColor.white,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Tabs
              Row(
                children: [
                  _buildTabItem(0, Icons.grid_view_rounded, "Thực đơn"),
                  const SizedBox(width: 25),
                  _buildTabItem(1, Icons.shopping_bag_outlined, "Ưu đãi"),
                ],
              ),
              // Right Tabs
              Row(
                children: [
                  _buildTabItem(3, Icons.person_outline_rounded, "Hồ sơ"),
                  const SizedBox(width: 25),
                  _buildTabItem(4, Icons.more_horiz_rounded, "Khác"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        } else {
          _navigatorKeys[index].currentState?.popUntil(
            (route) => route.isFirst,
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? TColor.primary : TColor.placeholder,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? TColor.primary : TColor.placeholder,
            ),
          ),
        ],
      ),
    );
  }
}
