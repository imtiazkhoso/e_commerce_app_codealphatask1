import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/order_model.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In a real app, this would fetch the order details from a provider/API
    // For this example, we'll create a mock order
    final order = OrderModel(
      id: orderId,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.processing,
      items: 3,
      total: 219.97,
    );

    // Mock order items (in a real app, these would be part of the order model)
    final orderItems = [
      {
        'name': 'Wireless Earbuds',
        'quantity': 1,
        'price': 79.99,
        'image': 'https://source.unsplash.com/random/400x400/?earbuds',
      },
      {
        'name': 'Running Shoes',
        'quantity': 1,
        'price': 89.99,
        'image': 'https://source.unsplash.com/random/400x400/?running-shoes',
      },
      {
        'name': 'Water Bottle',
        'quantity': 1,
        'price': 24.99,
        'image': 'https://source.unsplash.com/random/400x400/?water-bottle',
      },
    ];

    // Mock shipping address
    final shippingAddress = {
      'name': 'John Doe',
      'address': '123 Main Street',
      'city': 'New York',
      'state': 'NY',
      'zipCode': '10001',
      'country': 'United States',
      'phone': '+1 (555) 123-4567',
    };

    // Calculate subtotal, shipping, and tax
    final subtotal = orderItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
    );
    final shippingFee = 10.0;
    final tax = subtotal * 0.08; // 8% tax

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildStatusCard(context, order),
            const SizedBox(height: 24),
            
            // Order Timeline
            _buildOrderTimeline(context, order.status),
            const SizedBox(height: 24),
            
            // Order Items
            _buildSectionTitle('Order Items'),
            ...orderItems.map((item) => _buildOrderItem(context, item)),
            const SizedBox(height: 24),
            
            // Shipping Information
            _buildSectionTitle('Shipping Information'),
            _buildAddressCard(context, shippingAddress),
            const SizedBox(height: 24),
            
            // Payment Information
            _buildSectionTitle('Payment Information'),
            _buildPaymentSummary(context, subtotal, shippingFee, tax, order.total),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Implement cancel order or contact support
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Need Help?'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Implement track order or reorder
                      if (order.status == OrderStatus.processing || 
                          order.status == OrderStatus.shipped) {
                        // Track order
                      } else if (order.status == OrderStatus.delivered) {
                        // Reorder
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(
                      order.status == OrderStatus.delivered 
                          ? Icons.refresh 
                          : Icons.local_shipping,
                    ),
                    label: Text(
                      order.status == OrderStatus.delivered 
                          ? 'Buy Again' 
                          : 'Track Order',
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

  Widget _buildStatusCard(BuildContext context, OrderModel order) {
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.amber;
        break;
      case OrderStatus.processing:
        statusColor = Colors.blue;
        break;
      case OrderStatus.shipped:
        statusColor = Colors.purple;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ${order.status.label}',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                order.formattedDate,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(order.status),
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(BuildContext context, OrderStatus status) {
    // Define the order statuses in sequence
    final statuses = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];
    
    // If the order is cancelled, show a different timeline
    if (status == OrderStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'This order has been cancelled.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(
          statuses.length, 
          (index) {
            final isActive = statuses[index].index <= status.index;
            final isLast = index == statuses.length - 1;
            
            return Expanded(
              child: Row(
                children: [
                  // Status circle
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTimelineIcon(statuses[index]),
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  // Connecting line
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isActive && statuses[index + 1].index <= status.index
                            ? AppColors.primary
                            : Colors.grey[300],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getTimelineIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.receipt;
      case OrderStatus.processing:
        return Icons.inventory;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['image'] as String,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item['quantity']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(item['price'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Map<String, String> address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address['name']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(address['address']!),
          Text('${address['city']!}, ${address['state']!} ${address['zipCode']!}'),
          Text(address['country']!),
          const SizedBox(height: 8),
          Text(
            address['phone']!,
            style: const TextStyle(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(
    BuildContext context,
    double subtotal,
    double shipping,
    double tax,
    double total,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Payment Method', 'Credit Card'),
          const Divider(height: 16),
          _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
          _buildSummaryRow('Tax', '\$${tax.toStringAsFixed(2)}'),
          const Divider(height: 16),
          _buildSummaryRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isBold ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order is pending confirmation.';
      case OrderStatus.processing:
        return 'Your order is being processed and will be shipped soon.';
      case OrderStatus.shipped:
        return 'Your order has been shipped and is on its way.';
      case OrderStatus.delivered:
        return 'Your order has been delivered successfully.';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled.';
    }
  }
} 