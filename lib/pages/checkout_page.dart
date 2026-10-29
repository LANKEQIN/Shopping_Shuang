import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'orders_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.items,
    required this.total,
    this.cartEntries,
  });

  final List<OrderItem> items;
  final double total;
  final List<CartEntry>? cartEntries;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _payMethod = 0;
  Coupon? _coupon;

  @override
  void initState() {
    super.initState();
    _coupon = AppState.instance.bestCouponFor(widget.total);
  }

  double get _discount => _coupon?.amount ?? 0;

  double get _payTotal => math.max(widget.total - _discount, 0.01);

  int get _count => widget.items.fold(0, (s, e) => s + e.qty);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('确认订单')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.card, primary.withValues(alpha: 0.05)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('📍', style: TextStyle(fontSize: 17)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '幽幽子大人',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '138****8888',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: palette.textTertiary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    '默认',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '幻想乡 · 白玉楼 西行妖大道 1 号',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: palette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '（送货请交给门口的幽灵，谢谢）',
                              style: TextStyle(
                                fontSize: 10,
                                color: palette.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: palette.textTertiary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('🏬', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 5),
                          Text(
                            widget.items.first.product.store,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '解压专营',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: palette.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (final item in widget.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: ProductArt(
                                  product: item.product,
                                  badge: false,
                                ),
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.3,
                                        fontWeight: FontWeight.w600,
                                        color: palette.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.product.tags.take(2).join(' · '),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: palette.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  PriceText(item.price, size: 14),
                                  const SizedBox(height: 2),
                                  Text(
                                    '×${item.qty}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: palette.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Column(
                    children: [
                      _line(
                        '优惠券',
                        _coupon == null
                            ? '暂无可用'
                            : '${_coupon!.title}  -¥${money(_discount)}',
                        valueColor: _coupon == null ? null : primary,
                        onTap: () => _pickCoupon(context),
                      ),
                      Divider(height: 1, color: palette.divider),
                      _line(
                        '配送方式',
                        '顺丰包邮 · 预计明日送达',
                        onTap: () => showToast(context, '幻想乡快递，使命必达'),
                      ),
                      Divider(height: 1, color: palette.divider),
                      _line(
                        '订单备注',
                        '选填，给卖家一个惊喜',
                        onTap: () => showToast(context, '备注：麻烦包装得快乐一点'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '支付方式',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (var i = 0; i < 3; i++)
                        InkWell(
                          onTap: () => setState(() => _payMethod = i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  ['💳', '🏦', '💚'][i],
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    [
                                      '解压花呗 · 无限额度',
                                      '幻想乡余额 ¥99,999.00',
                                      '微信解压版',
                                    ][i],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  i == _payMethod
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: 18,
                                  color: i == _payMethod
                                      ? primary
                                      : palette.iconDisabled,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      _line('商品总额', '¥${money(widget.total)}'),
                      _line('运费', '包邮 ¥0'),
                      _line(
                        '优惠',
                        '-¥${money(_discount)}',
                        valueColor: primary,
                      ),
                      _line(
                        '优惠后应付',
                        '¥${money(_payTotal)}',
                        valueColor: primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '本单为解压模拟交易，不会产生任何真实扣款。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, color: palette.textDisabled),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              10,
              12,
              10 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: palette.card,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '共$_count件  实付 ',
                          style: const TextStyle(fontSize: 11),
                        ),
                        PriceText(_payTotal, size: 20, color: primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Fx.tap();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          items: widget.items,
                          total: _payTotal,
                          cartEntries: widget.cartEntries,
                          coupon: _coupon,
                        ),
                      ),
                    );
                  },
                  child: Semantics(
                    button: true,
                    label: '提交订单，实付 ${money(_payTotal)} 元',
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(21),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        '提交订单',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCoupon(BuildContext context) async {
    final app = AppState.instance;
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final usable = app.validCoupons
        .where((c) => c.usableFor(widget.total))
        .toList();
    final selected = await showModalBottomSheet<Object?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '选择优惠券',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: palette.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '本单 ¥${money(widget.total)}',
                    style: TextStyle(fontSize: 10, color: palette.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (usable.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      '本单暂无可用券，去福利中心领一张吧',
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.textTertiary,
                      ),
                    ),
                  ),
                )
              else
                for (final coupon in usable)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => Navigator.of(sheetContext).pop(coupon),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: palette.cardAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: coupon == _coupon
                                ? primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '¥${money(coupon.amount)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coupon.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${coupon.source} · 满${money(coupon.threshold)}可用',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: palette.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (coupon == _coupon)
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop('none'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '不使用优惠券',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    if (selected is Coupon) {
      setState(() => _coupon = selected);
    } else if (selected == 'none') {
      setState(() => _coupon = null);
    }
  }

  Widget _line(
    String label,
    String value, {
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final palette = paletteOf(context);
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: valueColor ?? palette.textPrimary,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15,
                    color: palette.textTertiary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.items,
    required this.total,
    this.cartEntries,
    this.coupon,
  });

  final List<OrderItem> items;
  final double total;
  final List<CartEntry>? cartEntries;
  final Coupon? coupon;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _phase = 0; // 0 待确认 1 支付中 2 成功
  String _orderId = '';

  Future<void> _pay() async {
    setState(() => _phase = 1);
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    if (widget.coupon != null) {
      AppState.instance.consumeCoupon(widget.coupon!);
    }
    final order = AppState.instance.createOrder(widget.items, widget.total);
    if (widget.cartEntries != null) {
      AppState.instance.removePurchased(widget.cartEntries!);
    }
    setState(() {
      _phase = 2;
      _orderId = order.id;
    });
    celebrate(context, text: '支付成功', subtitle: '本次消费已由幻想乡报销');
  }

  void _payLater() {
    // 下单即锁券：待付款订单金额已按券抵扣，券同步核销。
    if (widget.coupon != null) {
      AppState.instance.consumeCoupon(widget.coupon!);
    }
    final order = AppState.instance.createPendingOrder(
      widget.items,
      widget.total,
    );
    if (widget.cartEntries != null) {
      AppState.instance.removePurchased(widget.cartEntries!);
    }
    final navigator = Navigator.of(context);
    showToast(context, '订单已生成：${order.id}，30 分钟内有效');
    navigator.popUntil((r) => r.isFirst);
    navigator.push(MaterialPageRoute(builder: (_) => const OrdersPage()));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    return PopScope(
      canPop: _phase != 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_phase == 2 ? '支付结果' : '收银台'),
          automaticallyImplyLeading: _phase != 1,
        ),
        body: _phase == 2
            ? _success(primary, palette)
            : _phase == 1
            ? _paying(primary, palette)
            : _confirm(primary, palette),
      ),
    );
  }

  Widget _confirm(Color primary, SkinPalette palette) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          '订单金额',
          style: TextStyle(fontSize: 12, color: palette.textSecondary),
        ),
        const SizedBox(height: 6),
        PriceText(widget.total, size: 34, color: primary),
        const SizedBox(height: 4),
        Text(
          '解压支付 · 不扣真钱',
          style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
        ),
        const SizedBox(height: 26),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _row('解压花呗', '无限额度，随便刷', true, primary, palette),
              Divider(height: 1, color: palette.divider),
              _row('幻想乡余额', '¥99,999.00', false, primary, palette),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pay,
                child: Semantics(
                  button: true,
                  label: '确认支付 ${money(widget.total)} 元',
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      '确认支付（假装密码 123456）',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton(
                  onPressed: _payLater,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  child: const Text(
                    '稍后支付（30 分钟内有效）',
                    style: TextStyle(fontSize: 11.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(
    String title,
    String sub,
    bool selected,
    Color primary,
    SkinPalette palette,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(sub, style: TextStyle(fontSize: 10, color: palette.textTertiary)),
        const Spacer(),
        Icon(
          selected
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 18,
          color: selected ? primary : palette.iconDisabled,
        ),
      ],
    );
  }

  Widget _paying(Color primary, SkinPalette palette) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(strokeWidth: 3, color: primary),
          ),
          const SizedBox(height: 22),
          Text(
            '正在拉起解压支付…',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '正在和幻想乡财务对账，请稍候',
            style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _success(Color primary, SkinPalette palette) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
      children: [
        Center(
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary, Theme.of(context).colorScheme.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.28),
                  blurRadius: 26,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            '支付成功',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            '¥${money(widget.total)} · 已由幻想乡报销',
            style: TextStyle(fontSize: 12, color: palette.textSecondary),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _orderLine('订单编号', _orderId, palette),
              _orderLine('收货地址', '幻想乡 · 白玉楼', palette),
              _orderLine('预计送达', '明天下午，快递小哥会被幽灵吓到', palette),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text('继续逛逛'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const OrdersPage()));
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text('查看订单'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '恭喜，钱包毫发无伤，快乐已经到账。',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
        ),
      ],
    );
  }

  Widget _orderLine(String label, String value, SkinPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: palette.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 11, color: palette.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
