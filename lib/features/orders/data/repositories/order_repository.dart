import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  
  // Get all orders (admin only)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final querySnapshot = await _ordersCollection
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Add the document ID to the data map
            data['id'] = doc.id;
            return OrderModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error getting all orders: $e');
      return [];
    }
  }
  
  // Get orders by customer ID
  Future<List<OrderModel>> getOrdersByCustomerId(String customerId) async {
    try {
      final querySnapshot = await _ordersCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Add the document ID to the data map
            data['id'] = doc.id;
            return OrderModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error getting customer orders: $e');
      return [];
    }
  }
  
  // Get orders for a seller
  Future<List<OrderModel>> getOrdersBySellerId(String sellerId) async {
    try {
      // This query assumes a 'sellerIds' array field in the order document
      // that contains IDs of all sellers involved in the order
      final querySnapshot = await _ordersCollection
          .where('sellerIds', arrayContains: sellerId)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Add the document ID to the data map
            data['id'] = doc.id;
            return OrderModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error getting seller orders: $e');
      return [];
    }
  }
  
  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final docSnapshot = await _ordersCollection.doc(orderId).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        // Add the document ID to the data map
        data['id'] = docSnapshot.id;
        return OrderModel.fromMap(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting order by ID: $e');
      return null;
    }
  }
  
  // Create a new order
  Future<String?> createOrder(OrderModel order) async {
    try {
      final docRef = await _ordersCollection.add(order.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }
  
  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': newStatus.index,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }
  
  // Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.cancelled);
  }
} 