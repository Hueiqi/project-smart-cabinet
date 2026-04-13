import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/app_data.dart';

class AddItemDialog extends StatefulWidget {
  final void Function(BoxItem item) onSave;
  final BoxCategory category;

  const AddItemDialog({
    super.key,
    required this.onSave,
    required this.category,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _descCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _locationDetailCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();

  String? _selectedCategoryId;
  DateTime? _expirationDate;
  DateTime? _manufacturedDate;
  bool _isMedicine = false;
  bool _prescriptionRequired = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _descCtrl.dispose();
    _brandCtrl.dispose();
    _sizeCtrl.dispose();
    _locationDetailCtrl.dispose();
    _dosageCtrl.dispose();
    _batchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showSnack('Please enter an item name');
      return;
    }
    final qty = int.tryParse(_qtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      _showSnack('Quantity must be a positive number');
      return;
    }
    if (_expirationDate != null && _expirationDate!.isBefore(DateTime.now())) {
      _showSnack('Expiration date cannot be in the past');
      return;
    }
    if (_isMedicine && _expirationDate == null) {
      _showSnack('Medicine requires an expiration date');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final catId = _selectedCategoryId ?? widget.category.id;
      final cat = AppData.categories.firstWhere(
        (c) => c.id == catId,
        orElse: () => widget.category,
      );

      final item = BoxItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        quantity: qty,
        categoryId: cat.id,
        storageBox: cat.name,
        expirationDate: _expirationDate,
        description: _descCtrl.text.trim(),
        dateCreated: DateTime.now(),
        dateEdit: DateTime.now(),
        brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
        size: _sizeCtrl.text.trim().isEmpty ? null : _sizeCtrl.text.trim(),
        locationDetail: _locationDetailCtrl.text.trim().isEmpty
            ? null
            : _locationDetailCtrl.text.trim(),
        isMedicine: _isMedicine,
        dosage: _dosageCtrl.text.trim().isEmpty
            ? null
            : _dosageCtrl.text.trim(),
        prescriptionRequired: _prescriptionRequired,
        manufacturedDate: _manufacturedDate,
        batchNumber: _batchCtrl.text.trim().isEmpty
            ? null
            : _batchCtrl.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('items')
          .doc(item.id)
          .set(item.toFirestore());
      widget.onSave(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Item',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Add a new item to your smart cabinet',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.grey[400], size: 20),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _fieldLabel('Item Name'),
            _inputField(_nameCtrl, 'e.g. Coffee Beans'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _fieldLabel('Quantity'),
                      _inputField(
                        _qtyCtrl,
                        '1',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _fieldLabel('Category'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategoryId,
                            hint: const Text(
                              'Choose one',
                              style: TextStyle(fontSize: 12),
                            ),
                            isExpanded: true,
                            items: AppData.categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCategoryId = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _fieldLabel('Brand (optional)'),
            _inputField(_brandCtrl, 'Brand name'),
            const SizedBox(height: 12),
            _fieldLabel('Size / Volume (optional)'),
            _inputField(_sizeCtrl, 'e.g., M, 500ml, 2kg'),
            const SizedBox(height: 12),
            _fieldLabel('Specific Location (optional)'),
            _inputField(_locationDetailCtrl, 'e.g., Top shelf, left side'),
            const SizedBox(height: 12),
            _fieldLabel('Expiration Date (Optional)'),
            _buildDatePicker(
              label: 'Expiration Date',
              selectedDate: _expirationDate,
              onSelected: (d) => setState(() => _expirationDate = d),
              firstDate: DateTime.now(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isMedicine,
                  onChanged: (v) => setState(() => _isMedicine = v ?? false),
                ),
                const Text('This is a medicine / medical item'),
              ],
            ),
            if (_isMedicine) ...[
              const SizedBox(height: 12),
              _fieldLabel('Dosage'),
              _inputField(_dosageCtrl, 'e.g., 1 tablet daily'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _prescriptionRequired,
                    onChanged: (v) =>
                        setState(() => _prescriptionRequired = v ?? false),
                  ),
                  const Text('Prescription required'),
                ],
              ),
              const SizedBox(height: 12),
              _fieldLabel('Manufactured Date'),
              _buildDatePicker(
                label: 'Manufactured Date',
                selectedDate: _manufacturedDate,
                onSelected: (d) => setState(() => _manufacturedDate = d),
                firstDate: DateTime(1900),
              ),
              const SizedBox(height: 12),
              _fieldLabel('Batch Number'),
              _inputField(_batchCtrl, 'e.g., BATCH-123'),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8EC5D6),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Item',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF444444),
      ),
    ),
  );

  Widget _inputField(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required void Function(DateTime) onSelected,
    required DateTime firstDate,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? firstDate,
          firstDate: firstDate,
          lastDate: DateTime(2035),
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(
              selectedDate == null
                  ? label
                  : '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
              style: TextStyle(
                fontSize: 13,
                color: selectedDate == null
                    ? Colors.grey
                    : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
