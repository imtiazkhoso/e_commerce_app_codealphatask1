import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  customer,
  seller,
  admin,
}

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.customer,
    this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['display_name'],
      photoUrl: data['photo_url'],
      role: _stringToUserRole(data['role'] ?? 'customer'),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      lastLogin: (data['last_login'] as Timestamp?)?.toDate(),
      isActive: data['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'role': role.name,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'last_login': lastLogin != null ? Timestamp.fromDate(lastLogin!) : FieldValue.serverTimestamp(),
      'is_active': isActive,
    };
  }

  // Convert from string to UserRole enum
  static UserRole _stringToUserRole(String roleStr) {
    switch (roleStr) {
      case 'admin':
        return UserRole.admin;
      case 'seller':
        return UserRole.seller;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  // Check permissions
  bool get canAddProducts => role == UserRole.seller || role == UserRole.admin;
  bool get canManageUsers => role == UserRole.admin;
  bool get canViewOrders => true; // All users can view their own orders
  bool get canManageAllOrders => role == UserRole.admin;
  bool get canManageOwnProducts => role == UserRole.seller || role == UserRole.admin;
  
  // Create a copy with updated properties
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }
} 