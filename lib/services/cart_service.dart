import 'package:flutter/foundation.dart';

import '../models.dart';

class CartEntry {
  CartEntry({required this.product, this.qty = 1, this.selected = true});

  final Product product;
  int qty;
  bool selected;

  double get subtotal => product.price * qty;
}

/// 购物车服务：只维护购物车条目与勾选/数量，不关心订单与优惠券。
class CartService extends ChangeNotifier {
  final List<CartEntry> cart = [];

  /// 加购成功后回调，用于驱动每日任务进度。
  void Function()? onItemAdded;

  int get cartCount => cart.fold(0, (s, e) => s + e.qty);

  bool get allSelected => cart.isNotEmpty && cart.every((e) => e.selected);

  List<CartEntry> get selectedEntries => cart.where((e) => e.selected).toList();

  double get selectedTotal =>
      selectedEntries.fold(0.0, (s, e) => s + e.subtotal);

  void addToCart(Product product, {int qty = 1}) {
    final idx = cart.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      cart[idx].qty += qty;
      cart[idx].selected = true;
    } else {
      cart.insert(0, CartEntry(product: product, qty: qty));
    }
    onItemAdded?.call();
    notifyListeners();
  }

  void removeEntry(CartEntry entry) {
    cart.remove(entry);
    notifyListeners();
  }

  void changeQty(CartEntry entry, int delta) {
    entry.qty = (entry.qty + delta).clamp(1, 99);
    notifyListeners();
  }

  void toggleSelected(CartEntry entry) {
    entry.selected = !entry.selected;
    notifyListeners();
  }

  void setAllSelected(bool value) {
    for (final e in cart) {
      e.selected = value;
    }
    notifyListeners();
  }

  void removePurchased(List<CartEntry> entries) {
    for (final e in entries) {
      cart.remove(e);
    }
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'cart': [
      for (final e in cart)
        {'pid': e.product.id, 'qty': e.qty, 'selected': e.selected},
    ],
  };

  void restoreFrom(
    Map<String, dynamic> data,
    Product? Function(int id) resolveProduct,
  ) {
    cart.clear();
    final cartRaw = data['cart'];
    if (cartRaw is! List) return;
    for (final item in cartRaw) {
      if (item is! Map) continue;
      final pid = item['pid'];
      if (pid is! num) continue;
      final product = resolveProduct(pid.toInt());
      if (product == null) continue;
      final qty = (item['qty'] as num?)?.toInt().clamp(1, 99) ?? 1;
      cart.add(
        CartEntry(
          product: product,
          qty: qty,
          selected: item['selected'] == true,
        ),
      );
    }
  }

  void seed(Product? Function(int id) resolveProduct) {
    cart.clear();
    final a = resolveProduct(48);
    final b = resolveProduct(49);
    if (a != null) cart.add(CartEntry(product: a));
    if (b != null) cart.add(CartEntry(product: b, qty: 2));
  }
}
