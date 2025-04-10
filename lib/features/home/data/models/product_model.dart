class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final bool isFavorite;
  final int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rating,
    this.isFavorite = false,
    this.stock = 10,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'isFavorite': isFavorite,
      'stock': stock,
    };
  }

  // Create from map for retrieval
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      rating: map['rating'],
      isFavorite: map['isFavorite'] ?? false,
      stock: map['stock'] ?? 10,
    );
  }

  // Create a copy of the product with modified properties
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? category,
    double? rating,
    bool? isFavorite,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      stock: stock ?? this.stock,
    );
  }
} 