import 'package:flutter/material.dart';
import 'package:smart_cabinet/model/app_data.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/box_card.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/add_category_dialog.dart';
import 'box_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  List<BoxCategory> get _filtered {
    if (_searchQuery.isEmpty) return AppData.categories;
    final q = _searchQuery.toLowerCase();
    return AppData.categories
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q) ||
              c.items.any((i) => i.name.toLowerCase().contains(q)),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    AppData.addListener(_refresh);
  }

  @override
  void dispose() {
    AppData.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose one',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddItemDialog();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF8EC5D6)),
                ),
                child: const Text(
                  'Add Item',
                  style: TextStyle(color: Color(0xFF8EC5D6)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddCategoryDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8EC5D6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add categories',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddItemDialog(
        category: AppData.categories.first,
        onSave: (item) {
          final cat = AppData.categories.firstWhere(
            (c) => c.id == item.categoryId,
            orElse: () => AppData.categories.first,
          );
          AppData.addItemToCategory(cat, item);
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddCategoryDialog(
        onCreate: (category) {
          AppData.addCategory(category);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: SearchBarWidget(
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Box & Item',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '${AppData.categories.length} Box',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.filter_list, color: Colors.grey[600], size: 22),
                ],
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 52,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No results for "$_searchQuery"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.05,
                          ),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final cat = _filtered[i];
                        return BoxCard(
                          category: cat,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BoxDetailScreen(category: cat),
                            ),
                          ).then((_) => _refresh()),
                          onRemove: () => AppData.removeCategory(cat),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: const Color(0xFF8EC5D6),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
