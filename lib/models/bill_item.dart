import 'package:hive/hive.dart';

part 'bill_item.g.dart';

/// Represents a single line item in a bill
@HiveType(typeId: 1)
class BillItem extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final int quantity;

  BillItem({required this.name, required this.price, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
