// ========== PHẦN PUSH: "INBOX" (từ tab Khác) ==========
// GET /api/user/inbox — tin nhắn/preview; icon star theo is_starred.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:appfood/common/api_config.dart';
import 'package:appfood/common/auth_token.dart';
import 'package:appfood/common/color_extension.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await AuthToken.get();
    if (token == null) {
      setState(() {
        _loading = false;
        _items = [];
      });
      return;
    }
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/inbox');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          _items = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
          color: TColor.primaryText,
        ),
        title: Text(
          'Inbox',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: TColor.primaryText),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: TColor.primaryText),
            onPressed: () {},
          ),
        ],
      ),
      // --- List inbox hoặc empty ---
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    'Hộp thư trống',
                    style: TextStyle(color: TColor.secondaryText),
                  ),
                )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: TColor.placeholder.withOpacity(0.5)),
                  itemBuilder: (context, i) {
                    final m = _items[i];
                    final read = m['is_read'] == true;
                    DateTime? dt;
                    try {
                      dt = DateTime.parse(m['created_at'].toString());
                    } catch (_) {}
                    return ListTile(
                      leading: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: read ? Colors.transparent : TColor.orangeDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              m['title']?.toString() ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: TColor.primaryText,
                              ),
                            ),
                          ),
                          if (dt != null)
                            Text(
                              DateFormat('d MMM').format(dt),
                              style: TextStyle(fontSize: 12, color: TColor.placeholder),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        m['preview']?.toString() ?? m['body']?.toString() ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: TColor.secondaryText),
                      ),
                      trailing: Icon(
                        m['is_starred'] == true ? Icons.star_rounded : Icons.star_border_rounded,
                        color: TColor.placeholder,
                      ),
                    );
                  },
                ),
    );
  }
}
