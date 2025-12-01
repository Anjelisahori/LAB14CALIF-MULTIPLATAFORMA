// lib/screens/product_form_screen.dart (ORDEN CORREGIDO)

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

// Constantes de color importadas para coherencia
const Color _kPrimaryColor = Color(0xFF9D79BC); // Purple Mountain Majesty
const Color _kAccentColor = Color(0xFFA14DA0); // Purpureus
const Color _kBackgroundColor = Color(0xFFF8F9FD);
const Color _kDarkTextColor = Color(0xFF2D3436);

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  String _selectedCategory = 'T-Shirts';
  String _selectedSize = 'M';
  String _selectedColor = 'Black';
  String _selectedIcon = '👕';

  final List<String> _categories = [
    'T-Shirts',
    'Dresses',
    'Pants',
    'Shoes',
    'Accessories',
  ];

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'Pink', 'color': const Color(0xFFFD79A8)},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Brown', 'color': Colors.brown},
    {'name': 'Grey', 'color': Colors.grey},
  ];

  final Map<String, List<String>> _categoryIcons = {
    'T-Shirts': ['👕', '🎽', '👔'],
    'Dresses': ['👗', '🥻', '👘'],
    'Pants': ['👖', '🩳', '🩱'],
    'Shoes': ['👟', '👠', '👞', '🥾', '🥿'],
    'Accessories': ['👜', '🎒', '👝', '🕶️', '🧢', '⌚'],
  };

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: product?.stock.toString() ?? '');

    if (product != null) {
      _selectedCategory = product.category;
      _selectedSize = product.size;
      _selectedColor = product.color;
      _selectedIcon = product.imageIcon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        imageIcon: _selectedIcon,
        size: _selectedSize,
        color: _selectedColor,
        isFavorite: widget.product?.isFavorite ?? false,
        createdTime: widget.product?.createdTime ?? DateTime.now(),
      );

      if (widget.product == null) {
        await _dbHelper.createProduct(product);
      } else {
        await _dbHelper.updateProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Product',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- INICIO DE SECCIONES (ORDEN CORREGIDO) ---

            // 1. Category Selection
            _buildSection(
              title: 'Category',
              icon: Icons.category,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        // Reset icon to first of new category
                        _selectedIcon = _categoryIcons[category]![0];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _kAccentColor : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? _kAccentColor : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? _kAccentColor.withOpacity(0.4)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _kDarkTextColor,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // 2. Product Icon Selection
            _buildSection(
              title: 'Product Icon',
              icon: Icons.image,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.grey[200]!, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _selectedIcon,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children: (_categoryIcons[_selectedCategory] ?? ['👕'])
                          .map((icon) {
                        final isSelected = icon == _selectedIcon;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = icon),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: isSelected ? _kPrimaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? _kPrimaryColor
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _kPrimaryColor.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 3. Basic Information (Description)
            _buildSection(
              title: 'Basic Information',
              icon: Icons.info,
              child: Column(
                children: [
                  _buildTextField(
                    context: context,
                    controller: _nameController,
                    label: 'Product Name',
                    hint: 'e.g. Classic White T-Shirt',
                    icon: Icons.label,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  // Mantenemos la descripción aquí
                  _buildTextField(
                    context: context,
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe the product...',
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter description'
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 4. Size Selection
            _buildSection(
              title: 'Size',
              icon: Icons.straighten,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _sizes.map((size) {
                  final isSelected = size == _selectedSize;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSize = size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: isSelected ? _kPrimaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              isSelected ? _kPrimaryColor : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? _kPrimaryColor.withOpacity(0.4)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _kDarkTextColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // 5. Color Selection
            _buildSection(
              title: 'Color',
              icon: Icons.palette,
              child: Wrap(
                spacing: 18,
                runSpacing: 18,
                children: _colors.map((colorData) {
                  final isSelected = colorData['name'] == _selectedColor;
                  final color = colorData['color'] as Color;
                  final isLight = color.computeLuminance() > 0.6;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColor = colorData['name']),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? _kAccentColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 3 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? _kAccentColor.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: isLight ? Colors.black : Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          colorData['name'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color:
                                isSelected ? _kAccentColor : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // 6. Price & Stock
            _buildSection(
              title: 'Pricing & Stock',
              icon: Icons.attach_money,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      controller: _priceController,
                      label: 'Price',
                      hint: '0.00',
                      icon: Icons.monetization_on,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Enter price';
                        if (double.tryParse(value!) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      controller: _stockController,
                      label: 'Stock',
                      hint: '0',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Enter stock';
                        if (int.tryParse(value!) == null)
                          return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Save Button
            ElevatedButton(
              onPressed: _saveProduct,
              child: Text(
                isEditing ? 'Update Product' : 'Add Product',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget _buildSection (se mantiene)
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: _kPrimaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: _kDarkTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    );
  }

  // Widget _buildTextField (se mantiene)
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _kPrimaryColor),
      ),
    );
  }
}
