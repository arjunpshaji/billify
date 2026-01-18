import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/bill.dart';

class BillProvider with ChangeNotifier {
  static const String _boxName = 'bills';
  late Box<Bill> _box;

  List<Bill> _bills = [];
  String _searchQuery = '';
  SortOption _sortBy = SortOption.dateNewest;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _box = await Hive.openBox<Bill>(_boxName);
    _loadBills();
    _isLoading = false;
    notifyListeners();
  }

  void _loadBills() {
    _bills = _box.values.toList();
  }

  List<Bill> get bills {
    List<Bill> filtered = _bills.where((bill) {
      final matchesSearch =
          bill.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bill.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    switch (_sortBy) {
      case SortOption.dateNewest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateOldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHigh:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountLow:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortBy = option;
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    await _box.put(bill.id, bill);
    _loadBills();
    notifyListeners();
  }

  Future<void> deleteBill(String id) async {
    await _box.delete(id);
    _loadBills();
    notifyListeners();
  }
}

enum SortOption { dateNewest, dateOldest, amountHigh, amountLow }
