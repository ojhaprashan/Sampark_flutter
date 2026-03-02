import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;
  bool _isLoading = false;
  bool _hasFetched = false;

  double get balance => _balance;
  bool get isLoading => _isLoading;

  /// Call this once at app startup (e.g., in initState of MainNavigation or root widget).
  Future<void> fetchWallet(String phone) async {
    if (_hasFetched || phone.isEmpty) return; // Skip if already fetched
    _isLoading = true;
    notifyListeners();
    try {
      final walletData = await WalletService.fetchWallet(phone: phone);
      _balance = walletData.balance;
      _hasFetched = true;
    } catch (_) {
      _balance = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Call this to force a refresh (e.g., after a transaction).
  Future<void> refreshWallet(String phone) async {
    _hasFetched = false;
    await fetchWallet(phone);
  }

  void reset() {
    _balance = 0.0;
    _isLoading = false;
    _hasFetched = false;
    notifyListeners();
  }
}
