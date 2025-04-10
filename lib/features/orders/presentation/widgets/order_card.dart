import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../pages/order_details_page.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert hex color to Flutter color
    Color statusColor = _getColorFromHex(order.status.color);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(orderId: order.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    order.formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Order Details
              Row(
                children: [
                  // Order Items
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.items} ${order.items == 1 ? 'item' : 'items'}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Order Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  // View Details Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsPage(orderId: order.id),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Conditional secondary action (track order, reorder, etc.)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement action based on order status
                        if (order.status == OrderStatus.processing || 
                            order.status == OrderStatus.shipped) {
                          // Track order
                        } else if (order.status == OrderStatus.delivered) {
                          // Reorder
                        } else {
                          // Contact support or other action
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: _getActionButtonColor(order.status),
                      ),
                      child: Text(_getActionButtonText(order.status)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _getActionButtonText(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
      case OrderStatus.shipped:
        return 'Track Order';
      case OrderStatus.delivered:
        return 'Buy Again';
      case OrderStatus.pending:
        return 'Cancel Order';
      case OrderStatus.cancelled:
        return 'Contact Support';
    }
  }

  Color _getActionButtonColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
      case OrderStatus.shipped:
      case OrderStatus.delivered:
        return _getColorFromHex('#4CAF50'); // Green
      case OrderStatus.pending:
        return _getColorFromHex('#F44336'); // Red
      case OrderStatus.cancelled:
        return _getColorFromHex('#607D8B'); // Blue Gray
    }
  }
} 