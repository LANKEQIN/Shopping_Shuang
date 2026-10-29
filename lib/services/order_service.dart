import 'package:flutter/foundation.dart';

import '../models.dart';

/// 订单服务：订单流转、售后与发票记录。
///
/// 与用户资产/积分解耦，通过 [onOrderPlaced] 与 [onRefunded] 回调把奖励
/// 和退款交给上层编排，避免服务之间出现双向依赖。
class OrderService extends ChangeNotifier {
  final List<Order> orders = [];
  final List<AfterSaleRecord> afterSales = [];
  final List<InvoiceRecord> invoices = [];

  /// (订单, 是否免单)
  void Function(Order order, bool free)? onOrderPlaced;

  void Function(double amount)? onRefunded;

  Order createOrder(
    List<OrderItem> items,
    double total, {
    bool freeOrder = false,
  }) {
    final order = Order(
      id: 'SG${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      total: total,
      time: DateTime.now(),
      status: OrderStatus.pendingShip,
      freeOrder: freeOrder,
    );
    orders.insert(0, order);
    onOrderPlaced?.call(order, freeOrder);
    notifyListeners();
    return order;
  }

  /// 提交订单后选择稍后支付，30 分钟内可继续付款。
  Order createPendingOrder(List<OrderItem> items, double total) {
    final order = Order(
      id: 'SG${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      total: total,
      time: DateTime.now(),
      status: OrderStatus.pendingPay,
      payDeadline: DateTime.now().add(const Duration(minutes: 30)),
    );
    orders.insert(0, order);
    notifyListeners();
    return order;
  }

  Order createFreeOrder(Product product) {
    final order = Order(
      id: 'SG${DateTime.now().millisecondsSinceEpoch}',
      items: [OrderItem(product: product, qty: 1, price: 0)],
      total: 0,
      time: DateTime.now(),
      status: OrderStatus.pendingShip,
      freeOrder: true,
    );
    orders.insert(0, order);
    onOrderPlaced?.call(order, true);
    notifyListeners();
    return order;
  }

  /// 支付成功。超时订单会被取消并返回 false。
  bool payOrder(Order order) {
    if (order.status != OrderStatus.pendingPay) return false;
    final deadline = order.payDeadline;
    if (deadline != null && DateTime.now().isAfter(deadline)) {
      order.status = OrderStatus.cancelled;
      notifyListeners();
      return false;
    }
    order.status = OrderStatus.pendingShip;
    onOrderPlaced?.call(order, order.freeOrder);
    notifyListeners();
    return true;
  }

  void cancelOrder(Order order) {
    if (!order.status.active) return;
    order.status = OrderStatus.cancelled;
    notifyListeners();
  }

  /// 处理已超时的待付款订单，返回本次取消的数量。
  int expirePendingOrders() {
    var count = 0;
    for (final o in orders) {
      if (o.status != OrderStatus.pendingPay) continue;
      final deadline = o.payDeadline;
      if (deadline == null || DateTime.now().isBefore(deadline)) continue;
      o.status = OrderStatus.cancelled;
      count++;
    }
    if (count > 0) notifyListeners();
    return count;
  }

  void confirmReceive(Order order) {
    order.status = OrderStatus.pendingReview;
    notifyListeners();
  }

  void reviewOrder(Order order) {
    order.status = OrderStatus.completed;
    notifyListeners();
  }

  void removeOrder(Order order) {
    orders.remove(order);
    notifyListeners();
  }

  AfterSaleRecord requestAfterSale(
    Order order, {
    String type = '仅退款',
    String reason = '不想要了',
  }) {
    final record = AfterSaleRecord(
      id: 'AS${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      productName: order.items.first.product.name,
      type: type,
      reason: reason,
      amount: order.total,
      time: DateTime.now(),
    );
    afterSales.insert(0, record);
    order.status = OrderStatus.refunded;
    onRefunded?.call(order.total);
    notifyListeners();
    return record;
  }

  InvoiceRecord requestInvoice(
    Order order, {
    String title = '个人',
    String type = '电子普通发票',
    String email = 'yuyuko@hakugyokuro.jp',
  }) {
    final record = InvoiceRecord(
      id: 'INV${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      title: title,
      type: type,
      amount: order.total,
      email: email,
      time: DateTime.now(),
    );
    invoices.insert(0, record);
    notifyListeners();
    return record;
  }

  bool hasInvoice(String orderId) =>
      invoices.any((i) => i.orderId == orderId);

  void completeAfterSale(AfterSaleRecord record) {
    if (record.status == AfterSaleStatus.done) return;
    record.status = AfterSaleStatus.done;
    notifyListeners();
  }

  double get totalSpent => orders
      .where(
        (o) =>
            o.status != OrderStatus.cancelled &&
            o.status != OrderStatus.refunded,
      )
      .fold(0.0, (s, o) => s + o.total);

  int get paidOrderCount =>
      orders.where((o) => o.status != OrderStatus.cancelled).length;

  int get freeOrderCount => orders.where((o) => o.freeOrder).length;

  Map<String, dynamic> toJson() => {
    'orders': [
      for (final o in orders)
        {
          'id': o.id,
          'items': [
            for (final it in o.items)
              {'pid': it.product.id, 'qty': it.qty, 'price': it.price},
          ],
          'total': o.total,
          'time': o.time.toIso8601String(),
          'status': o.status.name,
          'address': o.address,
          'free': o.freeOrder,
          'deadline': o.payDeadline?.toIso8601String(),
        },
    ],
    'afterSales': [
      for (final a in afterSales)
        {
          'id': a.id,
          'order': a.orderId,
          'product': a.productName,
          'type': a.type,
          'reason': a.reason,
          'amount': a.amount,
          'time': a.time.toIso8601String(),
          'status': a.status.name,
        },
    ],
    'invoices': [
      for (final i in invoices)
        {
          'id': i.id,
          'order': i.orderId,
          'title': i.title,
          'type': i.type,
          'amount': i.amount,
          'email': i.email,
          'time': i.time.toIso8601String(),
        },
    ],
  };

  void restoreFrom(
    Map<String, dynamic> data,
    Product? Function(int id) resolveProduct,
  ) {
    orders.clear();
    final ordersRaw = data['orders'];
    if (ordersRaw is List) {
      for (final item in ordersRaw) {
        if (item is! Map) continue;
        final order = _orderFrom(item, resolveProduct);
        if (order != null) orders.add(order);
      }
    }

    afterSales.clear();
    final afterRaw = data['afterSales'];
    if (afterRaw is List) {
      for (final item in afterRaw) {
        if (item is! Map) continue;
        final orderId = item['order'];
        if (orderId is! String) continue;
        afterSales.add(
          AfterSaleRecord(
            id: (item['id'] as String?) ?? 'A${afterSales.length}',
            orderId: orderId,
            productName: (item['product'] as String?) ?? '商品',
            type: (item['type'] as String?) ?? '仅退款',
            reason: (item['reason'] as String?) ?? '',
            amount: _nonNegativeDouble(item['amount'], 0),
            time: _dateOrNull(item['time']) ?? DateTime.now(),
            status: AfterSaleStatus.values.firstWhere(
              (s) => s.name == item['status'],
              orElse: () => AfterSaleStatus.processing,
            ),
          ),
        );
      }
    }

    invoices.clear();
    final invoicesRaw = data['invoices'];
    if (invoicesRaw is List) {
      for (final item in invoicesRaw) {
        if (item is! Map) continue;
        final orderId = item['order'];
        if (orderId is! String) continue;
        invoices.add(
          InvoiceRecord(
            id: (item['id'] as String?) ?? 'I${invoices.length}',
            orderId: orderId,
            title: (item['title'] as String?) ?? '个人',
            type: (item['type'] as String?) ?? '电子普通发票',
            amount: _nonNegativeDouble(item['amount'], 0),
            email: (item['email'] as String?) ?? 'yuyuko@hakugyokuro.jp',
            time: _dateOrNull(item['time']) ?? DateTime.now(),
          ),
        );
      }
    }
  }

  Order? _orderFrom(
    Map raw,
    Product? Function(int id) resolveProduct,
  ) {
    final id = raw['id'];
    if (id is! String || id.isEmpty) return null;
    final items = <OrderItem>[];
    final itemsRaw = raw['items'];
    if (itemsRaw is! List) return null;
    for (final item in itemsRaw) {
      if (item is! Map) continue;
      final pid = item['pid'];
      if (pid is! num) continue;
      final p = resolveProduct(pid.toInt());
      if (p == null) continue;
      final qty = (item['qty'] as num?)?.toInt().clamp(1, 99) ?? 1;
      final price = (item['price'] as num?)?.toDouble() ?? p.price;
      items.add(OrderItem(product: p, qty: qty, price: price));
    }
    if (items.isEmpty) return null;
    final time =
        DateTime.tryParse(raw['time'] as String? ?? '') ?? DateTime.now();
    final status = OrderStatus.values.firstWhere(
      (s) => s.name == raw['status'],
      orElse: () => OrderStatus.pendingShip,
    );
    final address = raw['address'];
    return Order(
      id: id,
      items: items,
      total:
          (raw['total'] as num?)?.toDouble() ??
          items.fold(0.0, (s, e) => s + e.subtotal),
      time: time,
      status: status,
      address: address is String && address.isNotEmpty
          ? address
          : '幻想乡 · 白玉楼 西行妖大道 1 号',
      freeOrder: raw['free'] == true,
      payDeadline: _dateOrNull(raw['deadline']),
    );
  }

  void seed(Product? Function(int id) resolveProduct) {
    orders.clear();
    final o1 = resolveProduct(23);
    final o2 = resolveProduct(54);
    final o3 = resolveProduct(53);
    final o4 = resolveProduct(65);
    if (o1 != null) {
      orders.add(
        Order(
          id: 'SG202610210088',
          items: [OrderItem(product: o1, qty: 1, price: o1.price)],
          total: o1.price,
          time: DateTime.now().subtract(const Duration(days: 8)),
          status: OrderStatus.pendingReceive,
        ),
      );
    }
    if (o2 != null && o3 != null) {
      orders.add(
        Order(
          id: 'SG202610260012',
          items: [
            OrderItem(product: o2, qty: 1, price: o2.price),
            OrderItem(product: o3, qty: 1, price: o3.price),
          ],
          total: o2.price + o3.price,
          time: DateTime.now().subtract(const Duration(days: 3)),
          status: OrderStatus.pendingReview,
        ),
      );
    }
    if (o4 != null) {
      orders.add(
        Order(
          id: 'SG202610290003',
          items: [OrderItem(product: o4, qty: 1, price: o4.price)],
          total: o4.price,
          time: DateTime.now().subtract(const Duration(hours: 2)),
          status: OrderStatus.pendingPay,
          payDeadline: DateTime.now().add(const Duration(minutes: 42)),
        ),
      );
    }
    afterSales.clear();
    invoices.clear();
  }

  DateTime? _dateOrNull(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  double _nonNegativeDouble(Object? value, double fallback) {
    final v = (value as num?)?.toDouble();
    if (v == null || v.isNaN || v < 0) return fallback;
    return v;
  }
}
