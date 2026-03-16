import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/model/category_model.dart';
import 'package:appfood/model/restaurant_model.dart';
import 'package:appfood/view/home/widget/banner_slider.dart';
import 'package:appfood/view/home/widget/category_cell.dart';
import 'package:appfood/view/home/widget/restaurant_cell.dart';
import 'package:appfood/view/restaurant/restaurant_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Dữ liệu
  final List<CategoryModel> _categories = CategoryModel.mockList();
  final List<RestaurantModel> _allRestaurants = RestaurantModel.mockList();
  List<RestaurantModel> _filtered = [];
  int _selectedCategoryIndex = -1; // -1 = "Tất cả"

  // Search
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _filtered = _allRestaurants;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchCtrl.text.toLowerCase();
      _applyFilter();
    });
  }

  void _onSelectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = (_selectedCategoryIndex == index) ? -1 : index;
      _applyFilter();
    });
  }

  void _applyFilter() {
    _filtered = _allRestaurants.where((r) {
      // Filter theo category
      final matchCat = _selectedCategoryIndex == -1 ||
          r.category == _categories[_selectedCategoryIndex].name;
      // Filter theo search
      final matchSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery);
      return matchCat && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Search Bar ──
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── Banner ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const BannerSlider(),
              ),
            ),

            // ── Categories ──
            SliverToBoxAdapter(child: _buildCategorySection()),

            // ── Restaurant list ──
            SliverToBoxAdapter(child: _buildRestaurantSection()),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: TColor.primary, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "Vị trí của bạn",
                      style: TextStyle(
                          fontSize: 12, color: TColor.secondaryText),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16, color: TColor.secondaryText),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "TP. Hồ Chí Minh",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TColor.primaryText,
                  ),
                ),
              ],
            ),
          ),
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TColor.primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text("👤", style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: TColor.textfield,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded,
                      color: TColor.placeholder, size: 22),
                  hintText: "Tìm nhà hàng, món ăn...",
                  hintStyle: TextStyle(
                      color: TColor.placeholder,
                      fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.tune_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ── CATEGORY SECTION ──
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text(
            "Danh mục",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TColor.primaryText,
            ),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: _categories.length,
            itemBuilder: (context, index) => CategoryCell(
              category: _categories[index],
              isSelected: _selectedCategoryIndex == index,
              onTap: () => _onSelectCategory(index),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── RESTAURANT SECTION ──
  Widget _buildRestaurantSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategoryIndex == -1
                      ? "Nhà hàng gần bạn"
                      : _categories[_selectedCategoryIndex].name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TColor.primaryText,
                  ),
                ),
                Text(
                  "${_filtered.length} kết quả",
                  style: TextStyle(
                      fontSize: 13, color: TColor.secondaryText),
                ),
              ],
            ),
          ),

          // Danh sách hoặc empty state
          _filtered.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) => RestaurantCell(
                    restaurant: _filtered[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailView(
                            restaurant: _filtered[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Text("🔍", style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              "Không tìm thấy kết quả",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TColor.primaryText),
            ),
            const SizedBox(height: 6),
            Text(
              "Thử tìm kiếm với từ khóa khác",
              style:
                  TextStyle(fontSize: 13, color: TColor.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
