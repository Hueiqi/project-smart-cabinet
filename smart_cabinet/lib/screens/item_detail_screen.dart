import 'package:flutter/material.dart';
import 'package:smart_cabinet/model/app_data.dart';
import '../widgets/edit_item_dialog.dart';

class ItemDetailScreen extends StatefulWidget {
  final BoxItem item;
  final BoxCategory category;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.category,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late BoxItem _currentItem;
  late BoxCategory _currentCategory;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _currentCategory = widget.category;
    // Listen to global data changes
    AppData.addListener(_refreshFromGlobal);
  }

  @override
  void dispose() {
    AppData.removeListener(_refreshFromGlobal);
    super.dispose();
  }

  void _refreshFromGlobal() {
    // Find the updated item from AppData
    for (var cat in AppData.categories) {
      for (var item in cat.items) {
        if (item.id == widget.item.id) {
          if (mounted) {
            setState(() {
              _currentItem = item;
              _currentCategory = cat;
            });
          }
          return;
        }
      }
    }
    // If item no longer exists (deleted), pop screen
    if (mounted) Navigator.pop(context);
  }

  String _fmt(DateTime d) => '${d.month}/${d.day}/${d.year}';

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item'),
        content: Text('Delete "${_currentItem.name}" from this box?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AppData.removeItem(_currentItem, _currentCategory);
              if (mounted) Navigator.pop(context); // close dialog
              if (mounted) Navigator.pop(context); // close screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleTakeOut() async {
    if (_currentItem.quantity > 0) {
      await AppData.updateItemQuantity(_currentItem, _currentItem.quantity - 1);
      // No need to call setState here because the listener will trigger rebuild
      // But show a snackbar for feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_currentItem.name} taken out. ${_currentItem.quantity - 1} left.',
            ),
            backgroundColor: const Color(0xFF8EC5D6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No stock left!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleEdit() {
    showDialog(
      context: context,
      builder: (_) =>
          EditItemDialog(item: _currentItem, category: _currentCategory),
    ).then((_) => _refreshFromGlobal());
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final cat = _currentCategory;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF8EC5D6),
                    size: 20,
                  ),
                  onPressed: _handleEdit,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: 160,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    cat.icon,
                    size: 72,
                    color: cat.color.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF8EC5D6,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Qty Left: ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8EC5D6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Place: ${cat.name} > ${item.storageBox}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  if (item.expirationDate != null)
                    Text(
                      'Expiration Date: ${_fmt(item.expirationDate!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    'Date Create: ${_fmt(item.dateCreated)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    'Date Edit: ${_fmt(item.dateEdit)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      item.description.isEmpty ? 'None' : item.description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleDelete,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleTakeOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8EC5D6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Take Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}
