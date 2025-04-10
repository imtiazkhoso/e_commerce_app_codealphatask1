import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../payments/presentation/pages/checkout_page.dart';
import '../widgets/cart_item.dart';
import '../../data/models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Sample cart items (in a real app, these would come from a cart provider)
  final List<CartItemModel> _cartItems = [
    CartItemModel(
      id: '1',
      productId: '1',
      name: 'Wireless Earbuds',
      price: 79.99,
      quantity: 1,
      imageUrl: 'https://source.unsplash.com/random/400x400/?earbuds',
    ),
    CartItemModel(
      id: '2',
      productId: '3',
      name: 'Running Shoes',
      price: 89.99,
      quantity: 2,
      imageUrl: 'https://source.unsplash.com/random/400x400/?running-shoes',
    ),
  ];

  double get _subtotal => _cartItems.fold(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );

  final double _shippingFee = 10.00;
  final double _taxRate = 0.08; // 8% tax

  double get _tax => _subtotal * _taxRate;
  double get _total => _subtotal + _shippingFee + _tax;

  void _updateQuantity(String id, int quantity) {
    setState(() {
      final itemIndex = _cartItems.indexWhere((item) => item.id == id);
      if (itemIndex != -1) {
        if (quantity == 0) {
          _cartItems.removeAt(itemIndex);
        } else {
          _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(quantity: quantity);
        }
      }
    });
  }

  void _removeItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return CartItem(
                        item: item,
                        onUpdateQuantity: _updateQuantity,
                        onRemove: _removeItem,
                      );
                    },
                  ),
                ),
                
                // Order summary
                _buildOrderSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Looks like you haven\'t added anything to your cart yet.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Shipping Fee', '\$${_shippingFee.toStringAsFixed(2)}'),
          _buildSummaryRow('Tax (8%)', '\$${_tax.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total',
            '\$${_total.toStringAsFixed(2)}',
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cartItems.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            cartItems: _cartItems,
                            subtotal: _subtotal,
                            shippingFee: _shippingFee,
                            tax: _tax,
                            total: _total,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textStyle ?? TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: textStyle ?? const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
} 