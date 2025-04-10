import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _productsCollection => _firestore.collection('products');

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final querySnapshot = await _productsCollection.get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Add the document ID to the data map
            data['id'] = doc.id;
            return ProductModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error getting all products: $e');
      return [];
    }
  }

  // Get products by seller ID
  Future<List<ProductModel>> getProductsBySellerId(String sellerId) async {
    try {
      final querySnapshot = await _productsCollection
          .where('sellerId', isEqualTo: sellerId)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Add the document ID to the data map
            data['id'] = doc.id;
            return ProductModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error getting seller products: $e');
      return [];
    }
  }

  // Add a new product
  Future<String?> addProduct(ProductModel product) async {
    try {
      final docRef = await _productsCollection.add(product.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return null;
    }
  }

  // Update an existing product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).update(product.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }
} 