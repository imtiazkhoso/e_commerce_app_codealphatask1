enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get color {
    switch (this) {
      case OrderStatus.pending:
        return '#FFC107'; // Amber
      case OrderStatus.processing:
        return '#2196F3'; // Blue
      case OrderStatus.shipped:
        return '#9C27B0'; // Purple
      case OrderStatus.delivered:
        return '#4CAF50'; // Green
      case OrderStatus.cancelled:
        return '#F44336'; // Red
    }
  }
}

class OrderModel {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final int items;
  final double total;

  OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status.index,
      'items': items,
      'total': total,
    };
  }

  // Create from map for retrieval
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      status: OrderStatus.values[map['status']],
      items: map['items'],
      total: map['total'],
    );
  }

  String get formattedDate {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
} 