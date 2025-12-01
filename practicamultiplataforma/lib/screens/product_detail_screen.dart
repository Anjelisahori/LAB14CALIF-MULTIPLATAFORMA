// lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../database/database_helper.dart';
import '../services/cart_service.dart';
import 'product_form_screen.dart';

// Constantes de color (para mantener la consistencia con main.dart)
const Color _kPrimaryColor = Color(0xFF9D79BC); // Purple Mountain Majesty
const Color _kAccentColor = Color(0xFFA14DA0); // Purpureus
const Color _kBackgroundColor = Color(0xFFF8F9FD);
const Color _kDarkTextColor = Color(0xFF2D3436);
const Color _kRatingColor = Color(0xFFFDCB6E); // Amarillo
const Color _kDeleteColor = Color(0xFFFF7675); // Rojo/Rosa

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CartService _cartService = CartService.instance;

  late Product _product;
  String _selectedSize = '';
  String _selectedColor = '';
  int _quantity = 1;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'Pink', 'color': const Color(0xFFFD79A8)},
    {'name': 'Purple', 'color': const Color(0xFF6C5CE7)},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Brown', 'color': Colors.brown},
    {'name': 'Grey', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _selectedSize = _product.size;
    _selectedColor = _product.color;
  }

  // --- Funciones de utilidad ---
  Color _getColorFromName(String colorName) {
    final colors = {
      'Black': Colors.black,
      'White': Colors.white,
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Yellow': Colors.yellow,
      'Pink': const Color(0xFFFD79A8),
      'Purple': const Color(0xFF6C5CE7),
      'Orange': Colors.orange,
      'Brown': Colors.brown,
      'Grey': Colors.grey,
    };
    return colors[colorName] ?? Colors.grey;
  }

  // Muestra el diálogo de confirmación de eliminación
  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
          'Are you sure you want to delete this product?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: _kDeleteColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteProduct(_product.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  // Navega a la pantalla de edición y actualiza el producto
  Future<void> _editProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: _product),
      ),
    );
    final updated = await _dbHelper.readProduct(_product.id!);
    setState(() => _product = updated);
  }

  // Toggle de favorito
  Future<void> _toggleFavorite() async {
    final updated = _product.copy(isFavorite: !_product.isFavorite);
    await _dbHelper.updateProduct(updated);
    setState(() => _product = updated);
  }
  // --- Fin Funciones de utilidad ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar & Hero Image - Diseño Limpio
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            elevation: 0,
            // Usamos el color de fondo para una transición limpia
            backgroundColor: _kBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              // Eliminamos el gradiente pesado, usamos un fondo limpio
              background: Container(
                color: Colors.white,
                child: Center(
                  child: Hero(
                    tag: 'product_${_product.id}',
                    child: Text(
                      _product.imageIcon,
                      style: const TextStyle(fontSize: 150),
                    ),
                  ),
                ),
              ),
            ),
            // Actions (Botones flotantes sobre la imagen)
            leading: _buildCircularActionButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              _buildCircularActionButton(
                icon: _product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _product.isFavorite ? _kDeleteColor : _kDarkTextColor,
                onPressed: _toggleFavorite,
              ),
              _buildCircularActionButton(
                icon: Icons.edit,
                onPressed: _editProduct,
              ),
              const SizedBox(width: 10),
            ],
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de Nombre y Precio
                _buildProductHeader(),

                const SizedBox(height: 20),

                // Sección de Descripción
                _buildDescriptionSection(),

                const SizedBox(height: 30),

                // Sección de Talla
                _buildSizeSelection(),

                const SizedBox(height: 30),

                // Sección de Color
                _buildColorSelection(),

                const SizedBox(height: 30),

                // Sección de Cantidad
                _buildQuantitySelector(),

                // Espacio extra para que el contenido no quede oculto por el BottomBar
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),

      // Sticky Bottom Bar
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // --- Widgets de construcción de UI ---

  // 1. Botón de acción circular (Back, Favorite, Edit)
  Widget _buildCircularActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = _kDarkTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed,
        ),
      ),
    );
  }

  // 2. Encabezado del Producto (Nombre, Precio, Stock)
  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name & Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _product.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: _kDarkTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '\$${_product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _kPrimaryColor, // Usamos PrimaryColor para el precio
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rating & Stock
          Row(
            children: [
              // Rating (Simulado)
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: _kRatingColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '4.8',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _kDarkTextColor,
                    ),
                  ),
                  const Text(
                    ' (120 reviews)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),

              // Stock Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _product.stock > 10
                      ? const Color(0xFF00B894) // Verde
                      : const Color(0xFFFDCB6E), // Naranja (bajo stock)
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_product.stock} in stock',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Category Badge (Movido aquí para mejor jerarquía visual)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _kAccentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _product.category,
              style: TextStyle(
                color: _kAccentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Sección de Descripción (Separada para limpieza)
  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kDarkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _product.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Sección de Selección de Talla (Refactorizada con estilo de botón)
  Widget _buildSizeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Size',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kDarkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _sizes.map((size) {
              final isSelected = size == _selectedSize;
              return GestureDetector(
                onTap: () => setState(() => _selectedSize = size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? _kPrimaryColor : Colors.grey[300]!,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 5. Sección de Selección de Color (Refactorizada con estilo de círculo)
  Widget _buildColorSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Color',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kDarkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: _colors.map((colorData) {
              final isSelected = colorData['name'] == _selectedColor;
              final color = colorData['color'] as Color;
              final isLight = color.computeLuminance() > 0.6; // Para checkmark

              return GestureDetector(
                onTap: () => setState(() => _selectedColor = colorData['name']),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? _kAccentColor // Borde con color de acento
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 6. Selector de Cantidad
  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quantity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kDarkTextColor,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  color: _kPrimaryColor,
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                ),
                Container(
                  width: 40, // Ligeramente más compacto
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _kDarkTextColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: _kPrimaryColor,
                  onPressed: () {
                    if (_quantity < _product.stock) {
                      setState(() => _quantity++);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Bottom Bar (Sticky Footer)
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Delete Button (Manteniendo la función)
            Container(
              width: 55, // Más compacto
              height: 55,
              decoration: BoxDecoration(
                color: _kDeleteColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: _kDeleteColor),
                onPressed: _confirmDelete,
              ),
            ),
            const SizedBox(width: 16),

            // Add to Cart Button (Usando el tema global)
            Expanded(
              child: ElevatedButton(
                onPressed: _product.stock > 0
                    ? () {
                        _cartService.addItem(_product, _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '$_quantity x ${_product.name} added to cart'),
                            backgroundColor: const Color(0xFF00B894),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    : null, // Deshabilitado si no hay stock
                // Eliminamos styleFrom para usar el tema de main.dart
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _product.stock > 0
                          ? 'Add to Cart - \$${(_product.price * _quantity).toStringAsFixed(2)}'
                          : 'Out of Stock',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
