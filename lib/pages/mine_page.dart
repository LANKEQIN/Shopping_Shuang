import 'package:flutter/material.dart';

import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'after_sale_page.dart';
import 'benefits_page.dart';
import 'cut_price_page.dart';
import 'favorites_page.dart';
import 'group_buy_page.dart';
import 'live_pages.dart';
import 'lottery_page.dart';
import 'orders_page.dart';
import 'reports_page.dart';
import 'seckill_page.dart';
import 'settings_page.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final cfg = skinOf(app.skin);
          final palette = paletteOf(context);
          final primary = cfg.primary;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _header(context, app, cfg, primary),
              Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _asset(
                      '💰',
                      '余额',
                      '¥${money(app.balance)}',
                      primary,
                      () => showToast(
                        context,
                        '余额充足，够你解压一辈子',
                      ),
                    ),
                    _asset(
                      '🎫',
                      '优惠券',
                      '${app.coupons} 张',
                      primary,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BenefitsPage(initialTab: 1),
                        ),
                      ),
                    ),
                    _asset(
                      '🪙',
                      '淘金币',
                      '${app.coins}',
                      primary,
                      () => showToast(context, '金币+1，快乐+1'),
                    ),
                    _asset(
                      '⭐',
                      '积分',
                      '${app.points}',
                      primary,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BenefitsPage(initialTab: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                context,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersPage()),
                      ),
                      child: const SectionHeader(
                        '我的订单',
                        subtitle: '每一单都是情绪价值',
                        actionLabel: '全部订单',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _orderShortcut(
                          context,
                          '💳',
                          '待付款',
                          app.orders
                              .where((o) => o.status == OrderStatus.pendingPay)
                              .length,
                          primary,
                          1,
                        ),
                        _orderShortcut(
                          context,
                          '📦',
                          '待发货',
                          app.orders
                              .where((o) => o.status == OrderStatus.pendingShip)
                              .length,
                          primary,
                          2,
                        ),
                        _orderShortcut(
                          context,
                          '🚚',
                          '待收货',
                          app.orders
                              .where(
                                (o) => o.status == OrderStatus.pendingReceive,
                              )
                              .length,
                          primary,
                          3,
                        ),
                        _orderShortcut(
                          context,
                          '✍️',
                          '待评价',
                          app.orders
                              .where(
                                (o) => o.status == OrderStatus.pendingReview,
                              )
                              .length,
                          primary,
                          4,
                        ),
                        _orderShortcut(context, '↩️', '退款/售后', 0, primary, 5),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader('解压特权', subtitle: '不花钱，但很解压'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _privilege(
                          context,
                          '🔪',
                          '砍一刀',
                          [primary, cfg.accent],
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CutPricePage(),
                            ),
                          ),
                        ),
                        _privilege(
                          context,
                          '🎡',
                          '抽免单',
                          [const Color(0xFF7C4DFF), const Color(0xFFB388FF)],
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LotteryPage(),
                            ),
                          ),
                        ),
                        _privilege(
                          context,
                          '⚡',
                          '限时秒杀',
                          [const Color(0xFFFF6A00), const Color(0xFFFFC300)],
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SeckillPage(),
                            ),
                          ),
                        ),
                        _privilege(
                          context,
                          '📺',
                          '直播间',
                          [const Color(0xFF161823), const Color(0xFF3A3A4A)],
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  LiveRoomPage(
                                    room: AppState.instance.liveRooms.first,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      '解压玩法',
                      subtitle: '签到、拼团、报告都在这里',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _privilege(
                          context,
                          '👥',
                          '拼团',
                          [const Color(0xFF4776E6), const Color(0xFF8E54E9)],
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GroupBuyPage(),
                            ),
                          ),
                        ),
                        _privilege(
                          context,
                          '🎁',
                          '福利中心',
                          [const Color(0xFFFF7043), const Color(0xFFFFAB40)],
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BenefitsPage(),
                            ),
                          ),
                        ),
                        _privilege(
                          context,
                          '📊',
                          '解压报告',
                          [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportsPage(),
                            ),
                          ),
                        ),
                        _privilege(
                          context,
                          '⭐',
                          '收藏足迹',
                          [const Color(0xFFF857A6), const Color(0xFFFF5858)],
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FavoritesPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      '平台皮肤',
                      subtitle: '四大平台，一键穿越',
                      actionLabel: cfg.name,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final skin in Skin.values)
                          Expanded(child: _skinChip(context, app, skin, cfg)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                context,
                child: Column(
                  children: [
                    _tool(
                      context,
                      '📍',
                      '收货地址',
                      '幻想乡 · 白玉楼',
                      () => showToast(context, '地址已默认，幽灵会帮忙签收'),
                    ),
                    _tool(
                      context,
                      '💝',
                      '我的收藏',
                      '${app.favorites.length} 件心头好',
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FavoritesPage(),
                        ),
                      ),
                    ),
                    _tool(
                      context,
                      '🕘',
                      '浏览足迹',
                      '${app.footprints.length} 条记录',
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FavoritesPage(initialTab: 1),
                        ),
                      ),
                    ),
                    _tool(
                      context,
                      '🧾',
                      '发票与售后',
                      '${app.afterSales.length} 条售后',
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AfterSalePage(),
                        ),
                      ),
                    ),
                    _tool(
                      context,
                      '🎧',
                      '客服中心',
                      '在线，但很困',
                      () => showToast(context, '客服：亲亲，这边建议您再下一单呢'),
                    ),
                    _tool(
                      context,
                      'ℹ️',
                      '关于爽购',
                      'v1.1.0 解压版',
                      () => _about(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '买买买不一定快乐，但不买一定不快乐',
                  style: TextStyle(fontSize: 11, color: palette.textTertiary),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '本 App 为模拟购物演示，不产生任何真实交易',
                  style: TextStyle(fontSize: 9.5, color: palette.textDisabled),
                ),
              ),
              SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
            ],
          );
        },
      ),
    );
  }

  Widget _header(
    BuildContext context,
    AppState app,
    SkinConfig cfg,
    Color primary,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 18,
        16,
        30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cfg.headerGradient,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
                child: const Text('🌸', style: TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            app.nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616)
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            app.memberLevel.name,
                            style: const TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFFFFD54F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '信用分 999 · 已连续爽购 7 天',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '身份：幻想乡最会花钱的亡灵',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
                child: Semantics(
                  button: true,
                  label: '设置',
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🏅', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    '今日已省 ¥0.00，但快乐已经到账',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
                Text(
                  '去看看 ›',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _asset(
    String emoji,
    String label,
    String value,
    Color primary,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 2),
            Builder(
              builder: (context) {
                return Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: paletteOf(context).textTertiary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderShortcut(
    BuildContext context,
    String emoji,
    String label,
    int count,
    Color primary,
    int tab,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (tab == 5) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AfterSalePage()),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OrdersPage(initialTab: tab)),
          );
        },
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                if (count > 0)
                  Positioned(
                    right: -10,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 7.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Builder(
              builder: (context) {
                return Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: paletteOf(context).textSecondary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _privilege(
    BuildContext context,
    String emoji,
    String label,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: paletteOf(context).textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skinChip(
    BuildContext context,
    AppState app,
    Skin skin,
    SkinConfig cfg,
  ) {
    final palette = paletteOf(context);
    final selected = app.skin == skin;
    final sc = skinOf(skin);
    return GestureDetector(
      onTap: () {
        app.setSkin(skin);
        Fx.tap();
        showToast(context, '已切换到「${sc.name}」皮肤', icon: Icons.palette_rounded);
      },
      child: Semantics(
        button: true,
        selected: selected,
        label: '${sc.name}皮肤',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? sc.primary.withValues(alpha: 0.07)
                : palette.cardAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? sc.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: sc.headerGradient),
                  shape: BoxShape.circle,
                ),
                child: Text(sc.emoji, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 4),
              Text(
                sc.name,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? sc.primary : palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tool(
    BuildContext context,
    String emoji,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    final palette = paletteOf(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.cardAlt,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 15)),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 12.5, color: palette.textPrimary),
            ),
            const Spacer(),
            Text(
              sub,
              style: TextStyle(fontSize: 10, color: palette.textTertiary),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: palette.iconDisabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: paletteOf(context).card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  void _about(BuildContext context) {
    final palette = paletteOf(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛍️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              '爽购 · 解压模拟商城',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.1.0 · 缝合了四家平台的全部快乐',
              style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
            ),
            const SizedBox(height: 14),
            Text(
              '这是一个不需要登录、不花真钱、收货地址在幻想乡的购物 App。'
              '加购、秒杀、砍一刀、抽免单、看直播，想怎么买就怎么买。\n\n'
              '所有商品与订单均为本地演示数据，不会产生任何真实交易。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.7,
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
                child: const Text('继续买买买'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
