import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/model/menu_item_model.dart';
import 'package:appfood/view/menu/item_detail_view.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SearchView extends StatefulWidget {
  final bool autofocus;
  const SearchView({super.key, this.autofocus = true});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _txtSearch = TextEditingController();
  List<MenuItemModel> _searchResults = [];
  Timer? _debounce;
  bool _isLoading = false;

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final q = query.trim();
      if (q.isEmpty) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final results = await MenuItemModel.search(q);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  @override

  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new, color: TColor.primaryText),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: TColor.textfield,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(Icons.search, color: TColor.placeholder),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _txtSearch,
                              autofocus: widget.autofocus,
                              onChanged: _onSearch,
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm món ăn, danh mục...",
                                hintStyle: TextStyle(color: TColor.placeholder, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_txtSearch.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _txtSearch.clear();
                                _onSearch("");
                              },
                              icon: Icon(Icons.close, color: TColor.primary),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Results List
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : _txtSearch.text.isEmpty
                  ? Center(
                      child: Text(
                        "Nhập tên món ăn để tìm kiếm",
                        style: TextStyle(color: TColor.placeholder, fontSize: 16),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            "Không tìm thấy món nào",
                            style: TextStyle(color: TColor.primaryText, fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                item.category,
                                style: TextStyle(color: TColor.secondaryText, fontSize: 13),
                              ),
                              trailing: Text(
                                currencyFormatter.format(item.price),
                                style: TextStyle(
                                  color: TColor.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailView(
                                      itemObj: {
                                        "name": item.name,
                                        "type": item.category,
                                        "food_type": item.category,
                                        "rate": "4.9",
                                        "rating": "124",
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
