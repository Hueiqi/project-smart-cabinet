import 'package:flutter/material.dart';
import 'package:smart_cabinet/model/app_data.dart';

class EditItemDialog extends StatefulWidget {
  final BoxItem item;
  final BoxCategory category;

  const EditItemDialog({super.key, required this.item, required this.category});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _sizeCtrl;
  late TextEditingController _locationDetailCtrl;
  late TextEditingController _dosageCtrl;
  late TextEditingController _batchCtrl;

  late DateTime? _expirationDate;
  late DateTime? _manufacturedDate;
  late bool _isMedicine;
  late bool _prescriptionRequired;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _qtyCtrl = TextEditingController(text: widget.item.quantity.toString());
    _descCtrl = TextEditingController(text: widget.item.description);
    _brandCtrl = TextEditingController(text: widget.item.brand ?? '');
    _sizeCtrl = TextEditingController(text: widget.item.size ?? '');
    _locationDetailCtrl = TextEditingController(
      text: widget.item.locationDetail ?? '',
    );
    _dosageCtrl = TextEditingController(text: widget.item.dosage ?? '');
    _batchCtrl = TextEditingController(text: widget.item.batchNumber ?? '');

    _expirationDate = widget.item.expirationDate;
    _manufacturedDate = widget.item.manufacturedDate;
    _isMedicine = widget.item.isMedicine;
    _prescriptionRequired = widget.item.prescriptionRequired;
  }

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
    if (qty == null || qty < 0) {
      _showSnack('Quantity must be a non-negative number');
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
      await AppData.updateItem(
        widget.item.id,
        name: name,
        quantity: qty,
        description: _descCtrl.text.trim(),
        expirationDate: _expirationDate,
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
      if (mounted) {
        _showSnack('Item updated!', isError: false);
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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
                        'Edit Item',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Update item details',
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
                            value: widget.item.categoryId,
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
                            onChanged: (newCatId) async {
                              if (newCatId != null &&
                                  newCatId != widget.item.categoryId) {
                                await AppData.moveItemToCategory(
                                  widget.item,
                                  newCatId,
                                );
                                if (mounted) Navigator.pop(context);
                              }
                            },
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
            _fieldLabel('Expiration Date'),
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
                            'Save Changes',
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
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
