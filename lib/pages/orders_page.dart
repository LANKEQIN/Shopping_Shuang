import 'dart:async';

import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'after_sale_page.dart';
import 'product_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late int _tab = widget.initialTab.clamp(0, 4);
  static const _tabs = ['全部', '待付款', '待发货', '待收货', '待评价'];
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    AppState.instance.expirePendingOrders();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      AppState.instance.expirePendingOrders();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  List<Order> _filtered(List<Order> orders) {
    if (_tab == 0) return orders;
    final status = [
      OrderStatus.pendingPay,
      OrderStatus.pendingShip,
      OrderStatus.pendingReceive,
      OrderStatus.pendingReview,
    ][_tab - 1];
    return orders.where((o) => o.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('我的订单')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final list = _filtered(app.orders);
          return Column(
            children: [
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final selected = _tab == i;
                    return GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _tabs[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: selected
                                    ? primary
                                    : palette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: selected ? 16 : 0,
                              height: 3,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? _empty(context, primary)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _orderCard(context, app, list[i], primary),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context, Color primary) {
    final palette = paletteOf(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📦', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 12),
          Text(
            '这里还没有订单',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '去下一单，给自己的情绪放个假',
            style: TextStyle(fontSize: 11, color: palette.textTertiary),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              final p = AppState.instance.randomProduct();
              AppState.instance.addToCart(p);
              showToast(context, '已加入购物车：${p.name}');
            },
            child: const Text('随便挑一件'),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(
    BuildContext context,
    AppState app,
    Order order,
    Color primary,
  ) {
    final palette = paletteOf(context);
    final finished = order.status == OrderStatus.completed ||
        order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.refunded;
    final deadline = order.payDeadline;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🏬', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.items.first.product.store,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                order.status.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: finished ? palette.textTertiary : primary,
                ),
              ),
            ],
          ),
          if (order.status == OrderStatus.pendingPay &&
              deadline != null) ...[
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: CountdownText(
                target: deadline,
                prefix: '待付款剩余 ',
                style: TextStyle(
                  fontSize: 10,
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '超时将自动取消，可重新下单',
                style: TextStyle(fontSize: 9, color: palette.textTertiary),
              ),
            ),
          ],
          const SizedBox(height: 10),
          for (final item in order.items)
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductPage(product: item.product),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: ProductArt(product: item.product, badge: false),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            order.freeOrder
                                ? '免单 · 0元拿下'
                                : '${money(item.price)} × ${item.qty}',
                            style: TextStyle(
                              fontSize: 10,
                              color: order.freeOrder
                                  ? primary
                                  : palette.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Divider(height: 1, color: palette.divider),
          const SizedBox(height: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '共${order.count}件  实付 ',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: palette.textSecondary,
                    ),
                  ),
                  PriceText(order.total, size: 15, color: palette.textPrimary),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: _actions(context, app, order, primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _actions(
    BuildContext context,
    AppState app,
    Order order,
    Color primary,
  ) {
    final palette = paletteOf(context);
    Widget fill(String text, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Theme.of(context).colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    Widget outline(String text, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 11, color: palette.textSecondary),
        ),
      ),
    );

    switch (order.status) {
      case OrderStatus.pendingPay:
        return [
          outline('取消订单', () {
            app.cancelOrder(order);
            showToast(context, '订单已取消，假装从未心动过');
          }),
          fill('立即付款', () => _payNow(context, app, order)),
        ];
      case OrderStatus.pendingShip:
        return [
          outline('申请退款', () => _showAfterSale(context, app, order)),
          outline('查看物流', () => _showLogistics(context, order)),
          fill('催一催', () {
            showToast(context, '仓库小哥：在跑了在跑了');
          }),
        ];
      case OrderStatus.pendingReceive:
        return [
          outline('申请退款', () => _showAfterSale(context, app, order)),
          outline('查看物流', () => _showLogistics(context, order)),
          fill('确认收货', () {
            app.confirmReceive(order);
            celebrate(
              context,
              text: '确认收货成功',
              subtitle: '快乐已经正式归你了',
              icon: Icons.inventory_2_rounded,
            );
          }),
        ];
      case OrderStatus.pendingReview:
        return [
          outline('发票', () => _showInvoice(context, app, order)),
          fill('去评价', () => _showReviewSheet(context, app, order)),
        ];
      case OrderStatus.completed:
        return [
          outline('删除订单', () {
            app.removeOrder(order);
            showToast(context, '订单已删除，历史随它去');
          }),
          outline('发票', () => _showInvoice(context, app, order)),
          fill('再来一单', () {
            app.reorder(order);
            showToast(context, '已重新加购，快乐需要续费');
          }),
        ];
      case OrderStatus.cancelled:
        return [
          outline('删除订单', () {
            app.removeOrder(order);
            showToast(context, '订单已删除，历史随它去');
          }),
          fill('重新下单', () {
            app.reorder(order);
            showToast(context, '已重新加购，这次记得付款');
          }),
        ];
      case OrderStatus.refunded:
        return [
          outline('查看售后', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AfterSalePage()),
            );
          }),
          fill('再来一单', () {
            app.reorder(order);
            showToast(context, '已重新加购，快乐需要续费');
          }),
        ];
    }
  }

  void _payNow(BuildContext context, AppState app, Order order) {
    final ok = app.payOrder(order);
    if (!ok) {
      showToast(context, '订单已超时取消，请重新下单');
      return;
    }
    celebrate(context, text: '支付成功', subtitle: '幻想乡财务已垫付');
  }

  void _showLogistics(BuildContext context, Order order) {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final nodes = [
      ('已下单', order.time),
      ('已付款', order.time.add(const Duration(hours: 1))),
      ('仓库打包', order.time.add(const Duration(hours: 3))),
      ('运输中', order.time.add(const Duration(hours: 8))),
      ('到达幻想乡', order.time.add(const Duration(hours: 20))),
    ];
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: palette.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '物流轨迹',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '订单 ${order.id} · 顺丰包邮（模拟）',
                  style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: AppState.instance.animationsEnabled
                      ? const Duration(milliseconds: 1400)
                      : Duration.zero,
                  builder: (context, value, _) {
                    final active = (value * (nodes.length - 1)).floor();
                    return Column(
                      children: [
                        for (var i = 0; i < nodes.length; i++)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: i <= active
                                          ? primary
                                          : palette.border,
                                      shape: BoxShape.circle,
                                    ),
                                    child: i <= active
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 7,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  if (i < nodes.length - 1)
                                    Container(
                                      width: 2,
                                      height: 30,
                                      color: i < active
                                          ? primary
                                          : palette.border,
                                    ),
                                ],
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nodes[i].$1,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: i == active
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: i <= active
                                              ? palette.textPrimary
                                              : palette.textTertiary,
                                        ),
                                      ),
                                      Text(
                                        _fmt(nodes[i].$2),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: palette.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  '包裹正在幻想乡边境兜圈，请耐心等待幽灵签收。',
                  style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('知道啦'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  Future<void> _showInvoice(
    BuildContext context,
    AppState app,
    Order order,
  ) async {
    if (app.hasInvoice(order.id)) {
      showToast(context, '这张订单已经开过票了');
      return;
    }
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    var title = '个人';
    var type = '电子普通发票';
    final email = TextEditingController(text: 'yuyuko@hakugyokuro.jp');
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              18 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '申请发票',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '订单 ${order.id} · 金额 ¥${money(order.total)}',
                  style: TextStyle(fontSize: 10, color: palette.textTertiary),
                ),
                const SizedBox(height: 12),
                Text(
                  '抬头',
                  style: TextStyle(fontSize: 11, color: palette.textSecondary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final t in ['个人', '公司'])
                      GestureDetector(
                        onTap: () => setSheetState(() => title = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: title == t
                                ? primary.withValues(alpha: 0.12)
                                : palette.cardAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 11,
                              color: title == t
                                  ? primary
                                  : palette.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '类型',
                  style: TextStyle(fontSize: 11, color: palette.textSecondary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final t in ['电子普通发票', '增值税普通发票'])
                      GestureDetector(
                        onTap: () => setSheetState(() => type = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: type == t
                                ? primary.withValues(alpha: 0.12)
                                : palette.cardAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 11,
                              color: type == t
                                  ? primary
                                  : palette.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: email,
                  style: TextStyle(fontSize: 12, color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: '接收邮箱',
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: palette.textTertiary,
                    ),
                    filled: true,
                    fillColor: palette.cardAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: const Text('提交开票申请'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (submitted != true || !context.mounted) {
      email.dispose();
      return;
    }
    app.requestInvoice(
      order,
      title: title,
      type: type,
      email: email.text.trim().isEmpty
          ? 'yuyuko@hakugyokuro.jp'
          : email.text.trim(),
    );
    email.dispose();
    showToast(context, '发票申请已提交（模拟，不会真的发送邮件）');
  }

  Future<void> _showAfterSale(
    BuildContext context,
    AppState app,
    Order order,
  ) async {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    var type = '仅退款';
    var reason = '不想要了';
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            18 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '申请退款',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '退款会回到幻想乡余额，不会产生真实资金流动',
                style: TextStyle(fontSize: 10, color: palette.textTertiary),
              ),
              const SizedBox(height: 12),
              Text(
                '售后类型',
                style: TextStyle(fontSize: 11, color: palette.textSecondary),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in ['仅退款', '退货退款'])
                    GestureDetector(
                      onTap: () => setSheetState(() => type = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: type == t
                              ? primary.withValues(alpha: 0.12)
                              : palette.cardAlt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 11,
                            color: type == t
                                ? primary
                                : palette.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '退款原因',
                style: TextStyle(fontSize: 11, color: palette.textSecondary),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in ['不想要了', '商品破损', '物流太慢', '纯属手滑'])
                    GestureDetector(
                      onTap: () => setSheetState(() => reason = r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: reason == r
                              ? primary.withValues(alpha: 0.12)
                              : palette.cardAlt,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          r,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: reason == r
                                ? primary
                                : palette.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                  child: const Text('提交退款申请'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (submitted != true || !context.mounted) return;
    final record = app.requestAfterSale(order, type: type, reason: reason);
    showToast(
      context,
      '退款申请已提交，¥${money(record.amount)} 已回到幻想乡余额',
      icon: Icons.assignment_return_rounded,
    );
  }

  void _showReviewSheet(BuildContext context, AppState app, Order order) {
    var rating = 5;
    final controller = TextEditingController();
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              18 + MediaQuery.of(context).padding.bottom,
            ),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '评价一下这次解压体验',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '你的每一条评价，都会被卖家认真看（假装）',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: palette.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 5; i++)
                          GestureDetector(
                            onTap: () => setSheetState(() => rating = i + 1),
                            child: Icon(
                              i < rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 32,
                              color: const Color(0xFFFFB300),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final tag in ['压力-100', '发货快', '包装精美', '下次还买'])
                          Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 10.5),
                            ),
                            backgroundColor: palette.cardAlt,
                            side: BorderSide.none,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      maxLines: 2,
                      maxLength: 60,
                      style: TextStyle(fontSize: 12, color: palette.textPrimary),
                      decoration: InputDecoration(
                        hintText: '补一句评价…',
                        hintStyle: TextStyle(
                          fontSize: 11,
                          color: palette.textTertiary,
                        ),
                        filled: true,
                        fillColor: palette.cardAlt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: () {
                          final product = order.items.first.product;
                          app.addReview(
                            ProductReview(
                              id: 'R${DateTime.now().millisecondsSinceEpoch}',
                              productId: product.id,
                              nickname: app.nickname,
                              emoji: '🌸',
                              rating: rating,
                              text: controller.text.trim().isEmpty
                                  ? '压力-100，下次还买。'
                                  : controller.text.trim(),
                              tags: const ['压力-100'],
                              time: DateTime.now(),
                            ),
                          );
                          app.reviewOrder(order);
                          app.addCoupons(1);
                          Navigator.of(sheetContext).pop();
                          celebrate(
                            context,
                            text: '评价成功',
                            subtitle: '卖家已被你的温柔感动',
                            icon: Icons.rate_review_rounded,
                          );
                          showToast(context, '感谢评价，优惠券 +1 张');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text('发布评价'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }
}
