import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/model/restaurant_model.dart';
import 'package:appfood/model/menu_item_model.dart';
import 'package:appfood/model/cart_item_model.dart';
import 'package:appfood/view/cart/cart_view.dart';

class RestaurantDetailView extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailView({super.key, required this.restaurant});

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  final CartManager _cart = CartManager();
  late List<MenuItemModel> _menuItems;
  late List<String> _categories;
  int _selectedCatIndex = 0;

  @override
  void initState() {
    super.initState();
    _menuItems = MenuItemModel.mockForRestaurant(widget.restaurant.id);
    _categories = MenuItemModel.categoriesOf(_menuItems);
    // Rebuild khi cart thay đổi (cập nhật số lượng trên button)
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;

    return Scaffold(
      backgroundColor: TColor.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Ảnh + AppBar ──
              _buildSliverAppBar(r),

              // ── Thông tin nhà hàng ──
              SliverToBoxAdapter(child: _buildRestaurantInfo(r)),

              // ── Category tabs ──
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryTabDelegate(
                  categories: _categories,
                  selectedIndex: _selectedCatIndex,
                  onSelect: (i) => setState(() => _selectedCatIndex = i),
                  color: TColor.background,
                ),
              ),

              // ── Menu items ──
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final filtered = _menuItems
                        .where((m) => m.category == _categories[_selectedCatIndex])
                        .toList();
                    if (index >= filtered.length) return null;
                    return _buildMenuItem(filtered[index]);
                  },
                  childCount: _menuItems
                      .where((m) => m.category == _categories[_selectedCatIndex])
                      .length,
                ),
              ),

              // Bottom padding cho floating button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // ── Floating Cart Button ──
          if (!_cart.isEmpty) _buildCartButton(context),
        ],
      ),
    );
  }

  // ── SLIVER APP BAR ──
  Widget _buildSliverAppBar(RestaurantModel r) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: TColor.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: Colors.black87),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: TColor.textfield,
          child: Center(
            child: Text(
              _categoryEmoji(r.category),
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),
      ),
    );
  }

  // ── RESTAURANT INFO ──
  Widget _buildRestaurantInfo(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên + badge open/close
          Row(
            children: [
              Expanded(
                child: Text(
                  r.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: TColor.primaryText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: r.isOpen
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.isOpen ? "Đang mở" : "Đóng cửa",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: r.isOpen ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _statChip(Icons.star_rounded, TColor.primary,
                  "${r.rating} (${r.reviewCount})"),
              const SizedBox(width: 16),
              _statChip(Icons.access_time_rounded, TColor.secondaryText,
                  r.deliveryTime),
              const SizedBox(width: 16),
              _statChip(Icons.delivery_dining_rounded, TColor.secondaryText,
                  r.deliveryFee == 0
                      ? "Miễn phí ship"
                      : CartManager.formatPrice(r.deliveryFee)),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: TColor.textfield, thickness: 1),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 13, color: TColor.secondaryText)),
      ],
    );
  }

  // ── MENU ITEM CARD ──
  Widget _buildMenuItem(MenuItemModel item) {
    final qty = _cart.quantityOf(item.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColor.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColor.textfield, width: 1.5),
      ),
      child: Row(
        children: [
          // Emoji ảnh món
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: TColor.textfield,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 14),

          // Tên + mô tả + giá
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TColor.primaryText,
                        ),
                      ),
                    ),
                    if (item.isBestSeller)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: TColor.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "🔥 Best",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(fontSize: 12, color: TColor.secondaryText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CartManager.formatPrice(item.price),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: TColor.orangeDark,
                      ),
                    ),
                    // Nút thêm/bớt
                    qty == 0
                        ? _addButton(item)
                        : _quantityControl(item, qty),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Nút "+" khi chưa thêm
  Widget _addButton(MenuItemModel item) {
    return GestureDetector(
      onTap: () => _cart.addItem(item, widget.restaurant.id, widget.restaurant.name),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: TColor.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  // Nút tăng/giảm khi đã có trong giỏ
  Widget _quantityControl(MenuItemModel item, int qty) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _cart.decreaseItem(item.id),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: TColor.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove_rounded, color: TColor.primary, size: 16),
          ),
        ),
        SizedBox(
          width: 28,
          child: Center(
            child: Text(
              qty.toString(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: TColor.primaryText,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _cart.addItem(item, widget.restaurant.id, widget.restaurant.name),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  // ── FLOATING CART BUTTON ──
  Widget _buildCartButton(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartView()),
        ),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: TColor.primaryDark,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: TColor.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${_cart.totalQuantity}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Xem giỏ hàng",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                CartManager.formatPrice(_cart.total),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryEmoji(String cat) {
    const map = {"Cơm": "🍚", "Phở": "🍜", "Bánh mì": "🥖", "Pizza": "🍕", "Burger": "🍔"};
    return map[cat] ?? "🍱";
  }
}

// ── STICKY CATEGORY TAB ──
class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color color;

  _CategoryTabDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
    required this.color,
  });

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final selected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? TColor.primary : TColor.textfield,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                categories[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : TColor.secondaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryTabDelegate old) =>
      old.selectedIndex != selectedIndex;
}
