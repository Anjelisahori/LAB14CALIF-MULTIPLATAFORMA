// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../models/product.dart';

// Constantes de color (para mantener la consistencia con main.dart)
const Color _kPrimaryColor = Color(0xFF9D79BC); // Purple Mountain Majesty
const Color _kAccentColor = Color(0xFFA14DA0); // Purpureus
const Color _kBackgroundColor = Color(0xFFF8F9FD);
const Color _kDarkTextColor = Color(0xFF2D3436);
const Color _kDeleteColor = Color(0xFFFF7675); // Rojo/Rosa (para eliminar)
const Color _kSuccessColor =
    Color(0xFF00B894); // Verde (para éxito/envío gratis)

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService.instance;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_updateState);
  }

  @override
  void dispose() {
    _cartService.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.items;
    final isEmpty = cartItems.isEmpty;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        // Hereda el estilo de AppBarTheme de main.dart
        title: const Text('Shopping Bag'),
        actions: [
          if (!isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: _kDeleteColor),
              onPressed: _confirmClearCart,
            ),
        ],
      ),
      body: isEmpty
          ? _buildEmptyCartState(context)
          : Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),

                // Summary Card (Bottom Fixed)
                _buildSummaryCard(context),
              ],
            ),
    );
  }

  // --- Funciones de utilidad ---

  // Muestra el diálogo para confirmar la limpieza del carrito
  Future<void> _confirmClearCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
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
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _cartService.clearCart();
    }
  }

  // Muestra el diálogo de checkout
  void _checkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kSuccessColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: _kSuccessColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Placed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _kDarkTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your order has been placed successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _cartService.clearCart();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                // Hereda el estilo global de ElevatedButton
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calcula el total con envío y tax
  double _calculateTotal() {
    final subtotal = _cartService.totalAmount;
    // Envío gratis si el subtotal es > $50
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final tax = subtotal * 0.1;
    return subtotal + shipping + tax;
  }

  // Obtiene el color
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

  // --- Widgets de construcción de UI ---

  // 1. Estado de carrito vacío
  Widget _buildEmptyCartState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: _kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: _kPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Shopping Bag is Empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _kDarkTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Looks like you haven\'t added anything to your bag yet. Go ahead and explore!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                // Hereda el estilo global de ElevatedButton
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Elemento individual del carrito
  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Dismissible(
        key: Key('${item.product.id}_${item.product.name}'),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _cartService.removeItem(item.product.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.product.name} removed from cart'),
              backgroundColor: _kDeleteColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: _kDeleteColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 28,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Padding más compacto
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 90, // Un poco más grande para destacar
                height: 90,
                decoration: BoxDecoration(
                  color: _kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.product.imageIcon,
                    style: const TextStyle(fontSize: 45),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Product Info & Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kDarkTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Detalles (Talla y Color)
                    Row(
                      children: [
                        _buildDetailChip(item.product.size, _kAccentColor),
                        const SizedBox(width: 8),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _getColorFromName(item.product.color),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Precio unitario
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Controls (diseño horizontal más limpio)
              _buildQuantityControl(item),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Chip de detalle (reutilizado de HomeScreen)
  Widget _buildDetailChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 4. Control de Cantidad (Horizontal, más compacto)
  Widget _buildQuantityControl(CartItem item) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón de Restar
          SizedBox(
            width: 35,
            child: IconButton(
              icon: const Icon(Icons.remove, size: 16),
              color: _kPrimaryColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                if (item.quantity > 1) {
                  _cartService.updateQuantity(
                      item.product.id!, item.quantity - 1);
                } else {
                  _cartService.removeItem(item.product.id!);
                }
              },
            ),
          ),

          // Cantidad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _kDarkTextColor,
              ),
            ),
          ),

          // Botón de Sumar
          SizedBox(
            width: 35,
            child: IconButton(
              icon: const Icon(Icons.add, size: 16),
              color: _kPrimaryColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                if (item.quantity < item.product.stock) {
                  _cartService.updateQuantity(
                      item.product.id!, item.quantity + 1);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Maximum stock reached'),
                      backgroundColor: const Color(0xFFFDCB6E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 5. Fila de resumen de costos
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    // Definimos el estilo base
    final labelStyle = TextStyle(
      fontSize: isTotal ? 18 : 14,
      color: isTotal ? _kDarkTextColor : Colors.grey[700],
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
    );

    // Definimos el estilo del valor
    final valueStyle = TextStyle(
      fontSize: isTotal ? 22 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
      color: isTotal ? _kPrimaryColor : _kDarkTextColor,
    );

    // Lógica para Envío Gratis
    bool isFreeShipping = label == 'Shipping' && value == 'FREE';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle,
          ),
          Row(
            children: [
              if (isFreeShipping)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kSuccessColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FREE SHIPPING',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                value,
                style: isFreeShipping
                    ? valueStyle.copyWith(color: _kSuccessColor)
                    : valueStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. Tarjeta de resumen fijo en la parte inferior
  Widget _buildSummaryCard(BuildContext context) {
    final subtotal = _cartService.totalAmount;
    final total = _calculateTotal();
    final shippingValue = subtotal > 50 ? 'FREE' : '\$5.99';
    final taxValue = (_cartService.totalAmount * 0.1);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen de costos
            _buildSummaryRow(
              'Subtotal (${_cartService.itemCount} items)',
              '\$${subtotal.toStringAsFixed(2)}',
            ),
            _buildSummaryRow(
              'Shipping',
              shippingValue,
            ),
            _buildSummaryRow(
              'Tax (10%)',
              '\$${taxValue.toStringAsFixed(2)}',
            ),

            const Divider(height: 24, thickness: 1.5),

            // Total
            _buildSummaryRow(
              'Total',
              '\$${total.toStringAsFixed(2)}',
              isTotal: true,
            ),

            const SizedBox(height: 20),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkout,
                // Hereda el estilo global de ElevatedButton
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
