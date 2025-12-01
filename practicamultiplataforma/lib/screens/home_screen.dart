// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';
import 'cart_screen.dart';
import '../services/cart_service.dart';

// Constantes de color de main.dart para coherencia
const Color _kPrimaryColor = Color(0xFF9D79BC);
const Color _kAccentColor = Color(0xFFA14DA0);
const Color _kBackgroundColor = Color(0xFFF8F9FD);
const Color _kDarkTextColor = Color(0xFF2D3436);
const Color _kSecondaryAccent = Color(0xFFFD79A8); // Color de badge/resaltado

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CartService _cartService = CartService.instance;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': '🛍️', 'color': _kPrimaryColor},
    {'name': 'T-Shirts', 'icon': '👕', 'color': const Color(0xFFFD79A8)},
    {'name': 'Dresses', 'icon': '👗', 'color': const Color(0xFFA29BFE)},
    {'name': 'Pants', 'icon': '👖', 'color': const Color(0xFF00B894)},
    {'name': 'Shoes', 'icon': '👟', 'color': const Color(0xFFFDCB6E)},
    {'name': 'Accessories', 'icon': '👜', 'color': const Color(0xFFFF7675)},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _cartService.addListener(_updateState);
    _searchController
        .addListener(_filterProducts); // Escuchar cambios en el controlador
  }

  @override
  void dispose() {
    _cartService.removeListener(_updateState);
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProducts() async {
    final products = await _dbHelper.readAllProducts();
    setState(() {
      _allProducts = products;
      _filterProducts();
    });
  }

  void _filterProducts() {
    setState(() {
      // 1. Filtrar por categoría
      List<Product> productsByCategory;
      if (_selectedCategory == 'All') {
        productsByCategory = _allProducts;
      } else {
        productsByCategory =
            _allProducts.where((p) => p.category == _selectedCategory).toList();
      }

      // 2. Filtrar por búsqueda
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        _filteredProducts = productsByCategory
            .where((p) =>
                p.name.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query))
            .toList();
      } else {
        _filteredProducts = productsByCategory;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definimos un aspecto ligeramente más alto para las tarjetas para acomodar el precio y el botón.
    const double productCardAspectRatio = 0.72;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header: Saludo y Carrito - DISEÑO LIMPIO Y DE MARCA
            SliverAppBar(
              elevation: 0,
              backgroundColor: _kBackgroundColor,
              automaticallyImplyLeading: false,
              pinned: true,
              toolbarHeight: 70,
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    'Fashion Store',
                    style: TextStyle(
                      color: _kDarkTextColor,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w800, // Fuente más pesada para impacto
                    ),
                  ),
                ],
              ),
              actions: [
                _buildCartButton(context),
                const SizedBox(width: 15), // Más espacio a la derecha
              ],
            ),

            // Search Bar - DISEÑO ELEGANTE CON SHADOW
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(15), // Ligeramente menos redondo
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar ropa y accesorios...',
                      hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontStyle: FontStyle
                              .italic), // Cursiva para un toque elegante
                      prefixIcon: const Icon(Icons.search,
                          color: _kAccentColor), // Usamos el color de acento
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Categories - DISEÑO MÁS CLARO Y DISTRIBUIDO
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.symmetric(vertical: 15),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category['name'] == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['name'];
                          _filterProducts();
                        });
                      },
                      child: Container(
                        width: 75,
                        margin: const EdgeInsets.only(
                            right: 15), // Más espacio entre categorías
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 65, // Icono ligeramente más grande
                              height: 65,
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? _kAccentColor : Colors.white,
                                borderRadius: BorderRadius.circular(
                                    18), // Ligeramente más redondo
                                border: isSelected
                                    ? Border.all(
                                        color: _kAccentColor,
                                        width: 3) // Borde más grueso
                                    : Border.all(
                                        color: Colors.grey[200]!, width: 1.5),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: _kAccentColor.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: Text(
                                  category['icon'],
                                  style: const TextStyle(
                                      fontSize: 30), // Icono más grande
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              category['name'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? _kDarkTextColor
                                    : Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Section Header - TÍTULO CLARO
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Products', // Usamos un nombre más de marca
                      style: TextStyle(
                        fontSize: 22, // Ligeramente más grande
                        fontWeight: FontWeight.w700,
                        color: _kDarkTextColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All';
                          _filterProducts();
                        });
                      },
                      child: const Text(
                        'View All', // Usamos un nombre más de marca
                        style: TextStyle(
                          color: _kPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            _filteredProducts.isEmpty
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron productos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                            0.64, // Aspect ratio ajustado
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = _filteredProducts[index];
                          return _buildProductCard(product);
                        },
                        childCount: _filteredProducts.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      // FAB (Se mantiene limpio)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
          _loadProducts();
        },
        backgroundColor: _kPrimaryColor,
        tooltip: 'Agregar Producto',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget para el botón del carrito (Se mantiene, es funcional y claro)
  Widget _buildCartButton(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: _kDarkTextColor,
              size: 26,
            ),
          ),
        ),
        if (_cartService.itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: BoxDecoration(
                color: _kSecondaryAccent, // Usar un color de acento fuerte
                shape: BoxShape.circle,
                border: Border.all(color: _kBackgroundColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '${_cartService.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Tarjeta de Producto (Ajuste de espaciado y tamaño de fuente para un look más premium)
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        ).then((_) => _loadProducts());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container
                Stack(
                  children: [
                    Container(
                      height: 160, // Ligeramente más alta la imagen
                      decoration: BoxDecoration(
                        color: _kPrimaryColor.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          product.imageIcon,
                          style: const TextStyle(fontSize: 70),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _buildFavoriteButton(product),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: product.stock > 10
                              ? const Color(0xFF00B894)
                              : const Color(0xFFFDCB6E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.stock > 0
                              ? '${product.stock} en stock'
                              : 'Agotado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        12, 12, 12, 8), // Ajustamos a 12, 12, 12, 8
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre del Producto
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700, // Más peso
                            color: _kDarkTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6), // Más espacio

                        // Detalles (Talla y Color)
                        Row(
                          children: [
                            _buildDetailChip(product.size),
                            const SizedBox(width: 8), // Más espacio
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getColorFromName(product.color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1.5),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Precio
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 19, // Ligeramente más grande
                            fontWeight: FontWeight.w900, // Precio muy destacado
                            color: _kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Botón de Carrito POSICIONADO ABSOLUTAMENTE en la esquina inferior derecha.
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildAddToCartButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(Product product) {
    return GestureDetector(
      onTap: () async {
        final updated = product.copy(isFavorite: !product.isFavorite);
        await _dbHelper.updateProduct(updated);
        _loadProducts();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          product.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: product.isFavorite ? _kSecondaryAccent : Colors.grey[400],
          size: 18,
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _kAccentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: _kAccentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimaryColor, Color(0xFFA29BFE)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: _kPrimaryColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.add_shopping_cart,
        color: Colors.white,
        size: 18,
      ),
    );
  }

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
}
