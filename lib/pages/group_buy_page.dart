import 'package:flutter/material.dart';

import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'orders_page.dart';
import 'product_page.dart';

/// 拼团中心：发起、邀请、成功/失败结局与拼团记录。
class GroupBuyPage extends StatefulWidget {
  const GroupBuyPage({super.key, this.highlightId});

  final String? highlightId;

  @override
  State<GroupBuyPage> createState() => _GroupBuyPageState();
}

class _GroupBuyPageState extends State<GroupBuyPage> {
  @override
  void initState() {
    super.initState();
    AppState.instance.expireGroups();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final cfg = skinOf(app.skin);
    final palette = paletteOf(context);
    final primary = cfg.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('拼团中心')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final forming = app.groupBuys
              .where((g) => g.status == GroupStatus.forming)
              .toList();
          final finished = app.groupBuys
              .where((g) => g.status != GroupStatus.forming)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, cfg.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('👥', style: TextStyle(fontSize: 38)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '拼着买 · 更便宜',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '2 人成团 · 拼团价 8.8 折 · 24 小时有效\n'
                            '好友没来也没关系，可以随时放弃',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (forming.isNotEmpty) ...[
                _sectionTitle(context, '进行中的拼团', '${forming.length} 个'),
                const SizedBox(height: 8),
                for (final g in forming)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _groupCard(context, app, g, primary),
                  ),
                const SizedBox(height: 4),
              ],
              _sectionTitle(context, '拼团记录', '${finished.length} 条'),
              const SizedBox(height: 8),
              if (finished.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('🧑‍🤝‍🧑', style: TextStyle(fontSize: 42)),
                      const SizedBox(height: 8),
                      Text(
                        '还没有拼团记录',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '去商品详情页发起一个拼团吧',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: palette.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final g in finished)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _groupCard(context, app, g, primary),
                  ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  '说明：拼团为本地模拟玩法，团友由本地随机生成，'
                  '不会向任何真实好友发送邀请。',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.6,
                    color: palette.textDisabled,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, String sub) {
    final palette = paletteOf(context);
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(sub, style: TextStyle(fontSize: 10, color: palette.textTertiary)),
      ],
    );
  }

  Widget _groupCard(
    BuildContext context,
    AppState app,
    GroupBuy group,
    Color primary,
  ) {
    final palette = paletteOf(context);
    final product = AppState.instance.findProduct(group.productId);
    if (product == null) return const SizedBox.shrink();
    final highlighted = widget.highlightId == group.id;
    final forming = group.status == GroupStatus.forming;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? Border.all(color: primary.withValues(alpha: 0.6))
            : null,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProductPage(product: product)),
                ),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: ProductArt(product: product, badge: false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          group.status.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: group.status == GroupStatus.failed
                                ? palette.textTertiary
                                : primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '拼团价 ',
                            style: TextStyle(fontSize: 9, color: primary),
                          ),
                          PriceText(
                            product.price * 0.88,
                            size: 15,
                            color: primary,
                          ),
                          const SizedBox(width: 5),
                          OrigPrice(product.price, size: 9),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < group.required; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: palette.cardAlt,
                    child: Text(
                      i < group.members.length ? group.members[i].emoji : '?',
                      style: TextStyle(
                        fontSize: 13,
                        color: i < group.members.length
                            ? null
                            : palette.textDisabled,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  '${group.joined}/${group.required} 人',
                  style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
                ),
              ),
              if (forming)
                CountdownText(
                  target: group.endsAt,
                  prefix: '距结束 ',
                  style: TextStyle(fontSize: 9.5, color: primary),
                ),
            ],
          ),
          if (forming) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: group.progress,
                minHeight: 6,
                backgroundColor: palette.fill,
                valueColor: AlwaysStoppedAnimation(primary),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  group.status == GroupStatus.success
                      ? '成团成功，已自动生成订单'
                      : group.status == GroupStatus.failed
                      ? '拼团未成，可重新发起'
                      : '还差 ${group.required - group.joined} 人，叫个好友来',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: palette.textTertiary,
                  ),
                ),
              ),
              if (forming) ...[
                _action(
                  context,
                  '放弃',
                  primary,
                  filled: false,
                  onTap: () {
                    app.abandonGroup(group);
                    showToast(context, '已放弃这次拼团，好友表示理解');
                  },
                ),
                const SizedBox(width: 6),
                _action(
                  context,
                  '邀请好友',
                  primary,
                  filled: true,
                  onTap: () => _invite(context, app, group),
                ),
              ] else if (group.status == GroupStatus.success) ...[
                _action(
                  context,
                  '再来一单',
                  primary,
                  filled: false,
                  onTap: () {
                    final g = app.startGroup(product);
                    showToast(context, '已开启新拼团：${g.id}');
                  },
                ),
                const SizedBox(width: 6),
                _action(
                  context,
                  '查看订单',
                  primary,
                  filled: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrdersPage()),
                  ),
                ),
              ] else
                _action(
                  context,
                  '重新发起',
                  primary,
                  filled: true,
                  onTap: () {
                    app.startGroup(product);
                    showToast(context, '已重新发起拼团');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _invite(BuildContext context, AppState app, GroupBuy group) {
    final member = app.inviteGroupFriend(group);
    if (member == null) {
      showToast(context, '好友婉拒了，但你的快乐不受影响');
      return;
    }
    Fx.deal();
    if (group.status == GroupStatus.success) {
      celebrate(
        context,
        text: '拼团成功！',
        subtitle: '${member.name} 已参团，订单已生成',
        icon: Icons.groups_rounded,
      );
    } else {
      showToast(
        context,
        '${member.name} 加入了拼团，还差 ${group.required - group.joined} 人',
        icon: Icons.person_add_alt_1_rounded,
      );
    }
  }

  Widget _action(
    BuildContext context,
    String text,
    Color primary, {
    required bool filled,
    required VoidCallback onTap,
  }) {
    final palette = paletteOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: text,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? primary : Colors.transparent,
            border: filled ? null : Border.all(color: palette.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
              color: filled ? Colors.white : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
