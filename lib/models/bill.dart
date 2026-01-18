import 'package:hive/hive.dart';

part 'bill.g.dart';

@HiveType(typeId: 0)
class Bill extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final String? originalFilePath;

  Bill({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
    this.originalFilePath,
    this.tags = const [],
  });
}
