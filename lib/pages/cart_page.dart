import 'package:flutter/material.dart';

import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    final bottomPad = Navigator.of(context).canPop()
        ? MediaQuery.of(context).padding.bottom
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
        actions: [
          TextButton(
            onPressed: () => showToast(context, '管理模式：建议直接全选结算'),
            child: const Text('管理', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          if (app.cart.isEmpty) {
            return _empty(context, app, primary);
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 15,
                            color: primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '满 99 减 10，满 199 减 20 · 解压专享',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5, color: primary),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _showBundleSheet(context, app, primary),
                            child: const Text(
                              '去凑单 ›',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFFFF5722),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '共 ${app.cart.length} 种宝贝',
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '已选包邮，明天就到',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: palette.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final entry in app.cart)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _cartCard(context, app, entry, primary),
                      ),
                    const SizedBox(height: 4),
                    _recommend(context, app, primary),
                  ],
                ),
              ),
              _checkoutBar(context, app, primary, bottomPad),
            ],
          );
        },
      ),
    );
  }

  /// 满减凑单计算器：算出离下一档券门槛还差多少，并推荐补差商品。
  Future<void> _showBundleSheet(
    BuildContext context,
    AppState app,
    Color primary,
  ) async {
    final palette = paletteOf(context);
    final total = app.selectedTotal;

    double? target;
    for (final c in app.validCoupons) {
      if (c.threshold <= total) continue;
      if (target == null || c.threshold < target) target = c.threshold;
    }
    if (target == null) {
      for (final t in [59.0, 99.0, 199.0, 299.0]) {
        if (t > total) {
          target = t;
          break;
        }
      }
    }
    final gap = target == null ? 0.0 : (target - total);
    final cartIds = app.cart.map((e) => e.product.id).toSet();
    final candidates = AppState.instance.products
        .where((p) => !cartIds.contains(p.id))
        .where((p) => gap > 0 && p.price <= gap + 30)
        .toList()
      ..sort((a, b) => (a.price - gap).abs().compareTo((b.price - gap).abs()));
    final picks = candidates.take(3).toList();
    final fallback = AppState.instance.products
        .where((p) => !cartIds.contains(p.id))
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price));

    if (!context.mounted) return;
    await showModalBottomSheet(
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
                    '凑单计算器',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: palette.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '模拟计算 · 不产生真实交易',
                    style: TextStyle(fontSize: 9, color: palette.textDisabled),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '已选 ¥${money(total)}',
                          style: TextStyle(fontSize: 12, color: primary),
                        ),
                        if (target != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '目标 ¥${money(target)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: palette.textTertiary,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          gap > 0 ? '还差 ¥${money(gap)}' : '已达最高门槛',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: target == null || target <= 0
                            ? 1
                            : (total / target).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: palette.fill,
                        valueColor: AlwaysStoppedAnimation(primary),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      gap > 0
                          ? '再凑 ¥${money(gap)} 就能用上更高一档优惠券'
                          : '这一单已经可以吃到最大优惠了',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                gap > 0 ? '补差推荐' : '顺手看看',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              for (final p in (picks.isEmpty ? fallback.take(3) : picks))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 46,
                        height: 46,
                        child: ProductArt(product: p, badge: false),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      PriceText(p.price, size: 13, color: primary),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          app.addToCart(p);
                          Fx.addCart();
                          Navigator.of(sheetContext).pop();
                          showToast(
                            context,
                            '已加购：${p.name}，再回来看凑单进度',
                          );
                        },
                        child: Semantics(
                          button: true,
                          label: '加购凑单 ${p.name}',
                          child: Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '加购',
                              style: TextStyle(fontSize: 10, color: primary),
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
      },
    );
  }

  Widget _cartCard(
    BuildContext context,
    AppState app,
    CartEntry entry,
    Color primary,
  ) {
    final palette = paletteOf(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => app.toggleSelected(entry),
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: _checkbox(context, entry.selected, primary),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            height: 86,
            child: ProductArt(product: entry.product),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        app.removeEntry(entry);
                        showToast(context, '已移除，假装从未想买过');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: palette.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  children: [
                    for (final tag in entry.product.tags.take(2)) MiniTag(tag),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PriceText(entry.product.price, size: 16, color: primary),
                    const Spacer(),
                    _stepper(context, app, entry, primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkbox(BuildContext context, bool checked, Color primary) {
    final palette = paletteOf(context);
    return Semantics(
      label: checked ? '已选中' : '未选中',
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? primary : Colors.transparent,
          border: Border.all(
            color: checked ? primary : palette.border,
            width: 1.2,
          ),
        ),
        child: checked
            ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _stepper(
    BuildContext context,
    AppState app,
    CartEntry entry,
    Color primary,
  ) {
    final palette = paletteOf(context);
    Widget btn(IconData icon, VoidCallback onTap, String label) => Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(icon, size: 14, color: palette.textSecondary),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          btn(Icons.remove_rounded, () => app.changeQty(entry, -1), '减少数量'),
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '${entry.qty}',
              style: TextStyle(fontSize: 11.5, color: palette.textPrimary),
            ),
          ),
          btn(Icons.add_rounded, () => app.changeQty(entry, 1), '增加数量'),
        ],
      ),
    );
  }

  Widget _recommend(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    final cartIds = app.cart.map((e) => e.product.id).toSet();
    final items = AppState.instance.products
        .where((p) => !cartIds.contains(p.id))
        .take(4)
        .toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '凑单专区',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '再买一点，快乐加倍',
                style: TextStyle(fontSize: 10, color: palette.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final p = items[i];
                return SizedBox(
                  width: 82,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 82,
                        height: 82,
                        child: ProductArt(product: p, badge: false),
                      ),
                      const SizedBox(height: 4),
                      PriceText(p.price, size: 13, color: primary),
                      const SizedBox(height: 2),
                      Builder(
                        builder: (btnContext) {
                          return GestureDetector(
                            onTap: () {
                              app.addToCart(p);
                              Fx.addCart();
                              flyToCart(btnContext, p);
                              showToast(context, '已凑单：${p.name}');
                            },
                            child: Semantics(
                              button: true,
                              label: '加购 ${p.name}',
                              child: Container(
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+ 加购',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkoutBar(
    BuildContext context,
    AppState app,
    Color primary,
    double bottomPad,
  ) {
    final palette = paletteOf(context);
    final count = app.selectedEntries.fold(0, (s, e) => s + e.qty);
    final total = app.selectedTotal;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomPad),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => app.setAllSelected(!app.allSelected),
            child: Row(
              children: [
                _checkbox(context, app.allSelected, primary),
                const SizedBox(width: 6),
                const Text('全选', style: TextStyle(fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '合计: ',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textSecondary,
                        ),
                      ),
                      PriceText(total, size: 19, color: primary),
                    ],
                  ),
                ),
                Text(
                  '已优惠 ¥${money(app.selectedEntries.fold(0.0, (s, e) => (e.product.originalPrice - e.product.price) * e.qty))}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (app.selectedEntries.isEmpty) {
                showToast(context, '先选点什么吧，哪怕只是快乐');
                return;
              }
              Fx.tap();
              final entries = app.selectedEntries;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CheckoutPage(
                    items: [
                      for (final e in entries)
                        OrderItem(
                          product: e.product,
                          qty: e.qty,
                          price: e.product.price,
                        ),
                    ],
                    total: app.selectedTotal,
                    cartEntries: entries,
                  ),
                ),
              );
            },
            child: Semantics(
              button: true,
              label: '结算，共$count件',
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, Theme.of(context).colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '结算($count)',
                  style: const TextStyle(
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
    );
  }

  Widget _empty(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 62)),
          const SizedBox(height: 14),
          Text(
            '购物车空空如也',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '这不科学，快装点东西进来解压',
            style: TextStyle(fontSize: 11.5, color: palette.textTertiary),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              for (var i = 0; i < 3; i++) {
                app.addToCart(app.randomProduct());
              }
              Fx.addCart();
              showToast(context, '已无脑加购 3 件，感觉好多了');
            },
            child: Semantics(
              button: true,
              label: '随便来一单',
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, Theme.of(context).colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Text(
                  '随便来一单',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '不花钱，只花快乐',
            style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
          ),
        ],
      ),
    );
  }
}
