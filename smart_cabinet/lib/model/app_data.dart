import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class BoxCategory {
  String id;
  String name;
  String description;
  Color color;
  IconData icon;
  List<BoxItem> items;

  BoxCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.items,
  });
}

class BoxItem {
  String id;
  String name;
  int quantity;
  String categoryId;
  String storageBox;
  DateTime? expirationDate;
  String description;
  DateTime dateCreated;
  DateTime dateEdit;
  String? brand;
  String? size;
  String? locationDetail;
  bool isMedicine;
  String? dosage;
  bool prescriptionRequired;
  DateTime? manufacturedDate;
  String? batchNumber;

  BoxItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.categoryId,
    required this.storageBox,
    this.expirationDate,
    required this.description,
    required this.dateCreated,
    required this.dateEdit,
    this.brand,
    this.size,
    this.locationDetail,
    this.isMedicine = false,
    this.dosage,
    this.prescriptionRequired = false,
    this.manufacturedDate,
    this.batchNumber,
  });

  factory BoxItem.fromFirestore(Map<String, dynamic> data, String docId) {
    return BoxItem(
      id: data['id'] ?? docId,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      categoryId: data['categoryId'] ?? '',
      storageBox: data['storageBox'] ?? '',
      expirationDate: data['expirationDate'] != null
          ? DateTime.parse(data['expirationDate'])
          : null,
      description: data['description'] ?? '',
      dateCreated: DateTime.parse(data['dateCreated']),
      dateEdit: DateTime.parse(data['dateEdit']),
      brand: data['brand'] as String?,
      size: data['size'] as String?,
      locationDetail: data['locationDetail'] as String?,
      isMedicine: data['isMedicine'] as bool? ?? false,
      dosage: data['dosage'] as String?,
      prescriptionRequired: data['prescriptionRequired'] as bool? ?? false,
      manufacturedDate: data['manufacturedDate'] != null
          ? DateTime.parse(data['manufacturedDate'] as String)
          : null,
      batchNumber: data['batchNumber'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'categoryId': categoryId,
      'storageBox': storageBox,
      'expirationDate': expirationDate?.toIso8601String(),
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'dateEdit': dateEdit.toIso8601String(),
      'brand': brand,
      'size': size,
      'locationDetail': locationDetail,
      'isMedicine': isMedicine,
      'dosage': dosage,
      'prescriptionRequired': prescriptionRequired,
      'manufacturedDate': manufacturedDate?.toIso8601String(),
      'batchNumber': batchNumber,
    };
  }
}

class AppData {
  static List<BoxCategory> _categories = [];
  static final List<VoidCallback> _listeners = [];

  static List<BoxCategory> get categories => _categories;

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // Load categories metadata from Firestore
  static Future<void> loadCategoriesFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final existingIndex = _categories.indexWhere((c) => c.id == doc.id);
      final category = BoxCategory(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        color: Color(data['colorValue'] ?? 0xFF8EC5D6),
        icon: IconData(data['iconCodePoint'], fontFamily: 'MaterialIcons'),
        items: [],
      );
      if (existingIndex != -1) {
        _categories[existingIndex] = category;
      } else {
        _categories.add(category);
      }
    }
  }

  static Future<void> loadFromFirestore() async {
    await loadCategoriesFromFirestore();

    final itemsSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .get();
    final Map<String, BoxCategory> categoryMap = {};

    for (var doc in itemsSnapshot.docs) {
      final item = BoxItem.fromFirestore(doc.data(), doc.id);
      if (!categoryMap.containsKey(item.categoryId)) {
        final existingIndex = _categories.indexWhere(
          (c) => c.id == item.categoryId,
        );
        if (existingIndex != -1) {
          categoryMap[item.categoryId] = _categories[existingIndex];
        } else {
          categoryMap[item.categoryId] = BoxCategory(
            id: item.categoryId,
            name: item.storageBox,
            description: '',
            color: const Color(0xFF8EC5D6),
            icon: Icons.kitchen,
            items: [],
          );
        }
      }
      categoryMap[item.categoryId]!.items.add(item);
    }

    // If no categories at all, create default ones
    if (_categories.isEmpty && categoryMap.isEmpty) {
      _categories = [
        BoxCategory(
          id: '1',
          name: 'Pantry',
          description: 'Dry food, canned goods, and non-perishables',
          color: const Color(0xFFE8A87C),
          icon: Icons.kitchen,
          items: [],
        ),
        BoxCategory(
          id: '2',
          name: 'Fridge',
          description: 'Fresh produce, dairy, and meats',
          color: const Color(0xFF8EC5D6),
          icon: Icons.ac_unit,
          items: [],
        ),
        BoxCategory(
          id: '3',
          name: 'Freezer',
          description: 'Frozen vegetables, meats, and ice cream',
          color: const Color(0xFFB5EAD7),
          icon: Icons.snowing,
          items: [],
        ),
        BoxCategory(
          id: '4',
          name: 'Spices',
          description: 'Herbs, spices, and seasonings',
          color: const Color(0xFFFFDAC1),
          icon: Icons.restaurant,
          items: [],
        ),
        BoxCategory(
          id: '5',
          name: 'Beverages',
          description: 'Drinks, water, soda, and juice',
          color: const Color(0xFFE2F0CB),
          icon: Icons.local_drink,
          items: [],
        ),
        BoxCategory(
          id: '6',
          name: 'Snacks',
          description: 'Chips, cookies, and quick bites',
          color: const Color(0xFFF4A261),
          icon: Icons.cookie,
          items: [],
        ),
      ];
      // Save default categories to Firestore
      for (var cat in _categories) {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(cat.id)
            .set({
              'name': cat.name,
              'description': cat.description,
              'colorValue': cat.color.toARGB32(),
              'iconCodePoint': cat.icon.codePoint,
            });
      }
    } else {
      // Merge items into existing categories
      for (var entry in categoryMap.entries) {
        final existingIndex = _categories.indexWhere((c) => c.id == entry.key);
        if (existingIndex != -1) {
          _categories[existingIndex].items = entry.value.items;
        } else {
          _categories.add(entry.value);
        }
      }
    }
    _notifyListeners();
  }

  static Future<void> addCategory(BoxCategory category) async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(category.id)
        .set({
          'name': category.name,
          'description': category.description,
          'colorValue': category.color.toARGB32(),
          'iconCodePoint': category.icon.codePoint,
        });
    _categories.add(category);
    _notifyListeners();
  }

  static Future<void> updateCategory(
    String categoryId, {
    required String name,
    required String description,
    required Color color,
    required IconData icon,
  }) async {
    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .update({
          'name': name,
          'description': description,
          'colorValue': color.toARGB32(),
          'iconCodePoint': icon.codePoint,
        });

    // Update local data
    final updatedCategory = BoxCategory(
      id: categoryId,
      name: name,
      description: description,
      color: color,
      icon: icon,
      items: _categories[categoryIndex].items,
    );
    _categories[categoryIndex] = updatedCategory;
    _notifyListeners();
  }

  static Future<void> removeCategory(BoxCategory category) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var item in category.items) {
      final docRef = FirebaseFirestore.instance
          .collection('items')
          .doc(item.id);
      batch.delete(docRef);
    }
    batch.delete(
      FirebaseFirestore.instance.collection('categories').doc(category.id),
    );
    await batch.commit();
    _categories.remove(category);
    _notifyListeners();
    await NotificationService.checkAndNotifyExpiringItems();
  }

  static void addItemToCategory(BoxCategory category, BoxItem item) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index].items.add(item);
      _notifyListeners();
      NotificationService.checkAndNotifyExpiringItems();
    }
  }

  static Future<void> removeItem(BoxItem item, BoxCategory category) async {
    await FirebaseFirestore.instance.collection('items').doc(item.id).delete();
    final catIndex = _categories.indexWhere((c) => c.id == category.id);
    if (catIndex != -1) {
      _categories[catIndex].items.removeWhere((i) => i.id == item.id);
      _notifyListeners();
      await NotificationService.checkAndNotifyExpiringItems();
    }
  }

  // ✅ FIXED: updateItemQuantity with live lookup and error handling
  static Future<void> updateItemQuantity(BoxItem item, int newQuantity) async {
    try {
      // Find the actual live item reference in AppData
      BoxItem? liveItem;
      for (var cat in _categories) {
        for (var i in cat.items) {
          if (i.id == item.id) {
            liveItem = i;
            break;
          }
        }
        if (liveItem != null) break;
      }

      if (liveItem == null) {
        print('❌ updateItemQuantity: item not found in AppData');
        return;
      }

      // Update local object
      liveItem.quantity = newQuantity;
      liveItem.dateEdit = DateTime.now();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('items')
          .doc(liveItem.id)
          .update({
            'quantity': liveItem.quantity,
            'dateEdit': liveItem.dateEdit.toIso8601String(),
          });

      print('✅ Quantity updated to ${liveItem.quantity} for ${liveItem.name}');

      // Notify all listeners to rebuild UI
      _notifyListeners();

      // Re-check expiry notifications
      await NotificationService.checkAndNotifyExpiringItems();
    } catch (e) {
      print('❌ Firestore update failed: $e');
    }
  }

  // ✅ FIXED: updateItem – parentCategory is now correctly assigned
  static Future<void> updateItem(
    String itemId, {
    required String name,
    required int quantity,
    required String description,
    DateTime? expirationDate,
    String? brand,
    String? size,
    String? locationDetail,
    bool isMedicine = false,
    String? dosage,
    bool prescriptionRequired = false,
    DateTime? manufacturedDate,
    String? batchNumber,
  }) async {
    // Find the item and its category
    BoxItem? targetItem;
    BoxCategory? parentCategory;
    for (var cat in _categories) {
      for (var item in cat.items) {
        if (item.id == itemId) {
          targetItem = item;
          parentCategory = cat; // ✅ assign the category
          break;
        }
      }
      if (targetItem != null) break;
    }
    if (targetItem == null || parentCategory == null) return;

    // Update Firestore
    await FirebaseFirestore.instance.collection('items').doc(itemId).update({
      'name': name,
      'quantity': quantity,
      'description': description,
      'expirationDate': expirationDate?.toIso8601String(),
      'brand': brand,
      'size': size,
      'locationDetail': locationDetail,
      'isMedicine': isMedicine,
      'dosage': dosage,
      'prescriptionRequired': prescriptionRequired,
      'manufacturedDate': manufacturedDate?.toIso8601String(),
      'batchNumber': batchNumber,
      'dateEdit': DateTime.now().toIso8601String(),
    });

    // Update local object
    targetItem.name = name;
    targetItem.quantity = quantity;
    targetItem.description = description;
    targetItem.expirationDate = expirationDate;
    targetItem.brand = brand;
    targetItem.size = size;
    targetItem.locationDetail = locationDetail;
    targetItem.isMedicine = isMedicine;
    targetItem.dosage = dosage;
    targetItem.prescriptionRequired = prescriptionRequired;
    targetItem.manufacturedDate = manufacturedDate;
    targetItem.batchNumber = batchNumber;
    targetItem.dateEdit = DateTime.now();

    _notifyListeners();
    await NotificationService.checkAndNotifyExpiringItems();
  }

  static Future<void> moveItemToCategory(
    BoxItem item,
    String newCategoryId,
  ) async {
    // Find old category
    BoxCategory? oldCategory;
    for (var cat in _categories) {
      if (cat.items.any((i) => i.id == item.id)) {
        oldCategory = cat;
        break;
      }
    }
    if (oldCategory == null) return;

    // Remove from old list
    oldCategory.items.removeWhere((i) => i.id == item.id);

    // Find new category
    final newCategory = _categories.firstWhere((c) => c.id == newCategoryId);

    // Update item fields
    item.categoryId = newCategoryId;
    item.storageBox = newCategory.name;
    newCategory.items.add(item);

    // Update Firestore
    await FirebaseFirestore.instance.collection('items').doc(item.id).update({
      'categoryId': newCategoryId,
      'storageBox': newCategory.name,
    });

    _notifyListeners();
    await NotificationService.checkAndNotifyExpiringItems();
  }

  static final List<Color> boxColors = [
    const Color(0xFFE8A87C),
    const Color(0xFF8EC5D6),
    const Color(0xFFB5EAD7),
    const Color(0xFFFFDAC1),
    const Color(0xFFE2F0CB),
  ];

  static final List<IconData> boxIcons = [
    Icons.kitchen,
    Icons.ac_unit,
    Icons.lunch_dining,
    Icons.clean_hands,
    Icons.inventory,
  ];

  static void clearAll() {
    _categories.clear();
    _notifyListeners();
  }
}
