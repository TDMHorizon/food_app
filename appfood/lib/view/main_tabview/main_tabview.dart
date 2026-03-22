// ========== PHẦN PUSH: THANH ĐIỀU HƯỚNG DƯỚI + TAB HỒ SƠ / KHÁC ==========
// IndexedStack: giữ state từng tab. Mỗi tab có Navigator riêng (push màn con trong tab).
// Tab index 3 = Hồ sơ (ProfileView), 4 = Khác (MoreView).

import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/view/home/home_view.dart';
import 'package:appfood/view/menu/menu_view.dart'; // Màn hình Menu mới
import 'package:appfood/view/order/order_view.dart'; // 'Offers'
import 'package:appfood/view/profile/profile_view.dart'; // 'Profile'
import 'package:appfood/view/more/more_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 2; // Default to Home (Center)

  // Mỗi tab một key để pop về root khi bấm lại cùng tab đang chọn
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Navigator lồng: root của tab = rootWidget (Menu / Order / Home / Profile / More)
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
          _buildNavigator(3, const ProfileView()), // tab Hồ sơ — phần push báo cáo
          _buildNavigator(4, const MoreView()), // tab Khác — phần push báo cáo
        ],
      ),
      backgroundColor: const Color(0xfff5f5f5),
      bottomNavigationBar: BottomAppBar(
        color: TColor.white,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTabItem(0, Icons.grid_view_rounded, "Thực đơn"),
              _buildTabItem(1, Icons.shopping_bag_outlined, "Ưu đãi"),
              _buildTabItem(2, Icons.home_rounded, "Trang chủ"),
              _buildTabItem(3, Icons.person_outline_rounded, "Hồ sơ"),
              _buildTabItem(4, Icons.more_horiz_rounded, "Khác"),
            ],
          ),
        ),
      ),
    );
  }

  // Đổi tab hoặc pop stack tab về màn đầu nếu bấm lại tab đang mở
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
