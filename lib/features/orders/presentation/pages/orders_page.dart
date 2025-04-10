import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_card.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample orders data (in a real app, this would come from a provider/API)
    final List<OrderModel> orders = [
      OrderModel(
        id: 'ORD-5623891',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.processing,
        items: 3,
        total: 219.97,
      ),
      OrderModel(
        id: 'ORD-4587120',
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: OrderStatus.delivered,
        items: 2,
        total: 149.98,
      ),
      OrderModel(
        id: 'ORD-3892045',
        date: DateTime.now().subtract(const Duration(days: 15)),
        status: OrderStatus.delivered,
        items: 1,
        total: 79.99,
      ),
      OrderModel(
        id: 'ORD-2916734',
        date: DateTime.now().subtract(const Duration(days: 30)),
        status: OrderStatus.cancelled,
        items: 4,
        total: 299.96,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: orders.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return OrderCard(order: orders[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'When you place orders, they will appear here',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to homepage
            },
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }
} 