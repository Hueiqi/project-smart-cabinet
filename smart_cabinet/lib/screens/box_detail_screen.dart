import 'package:flutter/material.dart';
import 'package:smart_cabinet/model/app_data.dart';
import '../widgets/add_item_dialog.dart';
import 'item_detail_screen.dart';

class BoxDetailScreen extends StatefulWidget {
  final BoxCategory category;

  const BoxDetailScreen({super.key, required this.category});

  @override
  State<BoxDetailScreen> createState() => _BoxDetailScreenState();
}

class _BoxDetailScreenState extends State<BoxDetailScreen> {
  int get _totalStock =>
      widget.category.items.fold(0, (sum, i) => sum + i.quantity);

  String _fmt(DateTime d) => '${d.month}/${d.day}/${d.year}';

  String get _creationDate {
    if (widget.category.items.isEmpty) return '—';
    final earliest = widget.category.items
        .map((i) => i.dateCreated)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return _fmt(earliest);
  }

  String get _editDate {
    if (widget.category.items.isEmpty) return '—';
    final latest = widget.category.items
        .map((i) => i.dateEdit)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return _fmt(latest);
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

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Color(0xFF8EC5D6),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cat.color, cat.color.withValues(alpha: 0.65)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Icon(cat.icon, size: 64, color: Colors.white70),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _InfoBadge(label: 'Date Create', value: _creationDate),
                      const SizedBox(width: 20),
                      _InfoBadge(label: 'Stock Left', value: '$_totalStock'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date Edit: $_editDate',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      cat.description.isEmpty ? 'None' : cat.description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          cat.items.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 52,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No items yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final item = cat.items[i];
                    return _ItemTile(
                      item: item,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ItemDetailScreen(item: item, category: cat),
                        ),
                      ).then((_) => _refresh()),
                    );
                  }, childCount: cat.items.length),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddItemDialog(
            category: widget.category,
            onSave: (item) {
              AppData.addItemToCategory(widget.category, item);
            },
          ),
        ),
        backgroundColor: const Color(0xFF8EC5D6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final BoxItem item;
  final VoidCallback onTap;
  const _ItemTile({required this.item, required this.onTap});

  String _fmt(DateTime d) => '${d.month}/${d.day}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.image_outlined,
                color: Colors.grey[300],
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (item.expirationDate != null)
                    Text(
                      'Expiration Date: ${_fmt(item.expirationDate!)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    'Date Create: ${_fmt(item.dateCreated)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  Text(
                    'Date Edit: ${_fmt(item.dateEdit)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
          ],
        ),
      ),
    );
  }
}
