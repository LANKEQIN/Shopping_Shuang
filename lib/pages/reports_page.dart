import 'package:flutter/material.dart';

import '../data.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'benefits_page.dart';

/// 解压报告：成就墙、年度账单、情绪消费报告与今日任务。
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late int _tab = widget.initialTab.clamp(0, 2);
  static const _tabs = ['成就', '年度账单', '情绪报告'];

  List<Order> get _validOrders => AppState.instance.orders
      .where(
        (o) =>
            o.status != OrderStatus.cancelled &&
            o.status != OrderStatus.refunded,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final cfg = skinOf(app.skin);
    final palette = paletteOf(context);
    final primary = cfg.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('解压报告')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, cfg.accent],
                  ),
                ),
                child: Row(
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 38)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '我的解压报告',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '已解锁 ${achievements.where(app.achievementUnlocked).length}'
                            '/${achievements.length} 个成就 · '
                            '累计 ${app.paidOrderCount} 单',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: palette.card,
                child: Row(
                  children: [
                    for (var i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _tab = i),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Text(
                                  _tabs[i],
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: _tab == i
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: _tab == i
                                        ? primary
                                        : palette.textSecondary,
                                  ),
                                ),
                              ),
                              Container(
                                width: _tab == i ? 24 : 0,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                child: switch (_tab) {
                  0 => _achievements(context, app, primary),
                  1 => _bill(context, app, primary),
                  _ => _emotion(context, app, primary),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: paletteOf(context).card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _title(BuildContext context, String title, {String? sub}) {
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
        if (sub != null) ...[
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: palette.textTertiary),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------- 成就 ----------------

  Widget _achievements(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    final unlocked = achievements.where(app.achievementUnlocked).length;
    return Column(
      children: [
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '成就进度', sub: '$unlocked / ${achievements.length}'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: achievements.isEmpty
                      ? 0
                      : unlocked / achievements.length,
                  minHeight: 8,
                  backgroundColor: palette.fill,
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                unlocked == achievements.length
                    ? '全部成就已解锁，你已是白玉楼传说'
                    : '继续买买买，解锁更多解压成就',
                style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
              ),
            ],
          ),
        ),
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '成就墙', sub: '每一格都是一次快乐'),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.32,
                children: [
                  for (final a in achievements)
                    _achievementTile(context, app, a, primary),
                ],
              ),
            ],
          ),
        ),
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '今日解压任务', sub: '完成任务领积分'),
              const SizedBox(height: 8),
              for (final task in dailyTasks)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Text(task.emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '${app.taskProgress(task)}/${task.target}',
                        style: TextStyle(
                          fontSize: 9,
                          color: app.taskClaimed(task)
                              ? primary
                              : palette.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (app.taskClaimable(task))
                        GestureDetector(
                          onTap: () {
                            app.claimTask(task);
                            showToast(context, '任务完成：积分 +${task.points}');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '领取',
                              style: TextStyle(fontSize: 9, color: primary),
                            ),
                          ),
                        )
                      else
                        Text(
                          app.taskClaimed(task) ? '已领' : '未完成',
                          style: TextStyle(
                            fontSize: 9,
                            color: palette.textDisabled,
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BenefitsPage(initialTab: 3),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text('去福利中心看任务', style: TextStyle(fontSize: 10.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _achievementTile(
    BuildContext context,
    AppState app,
    AchievementDef a,
    Color primary,
  ) {
    final palette = paletteOf(context);
    final value = app.achievementValue(a.metric);
    final unlocked = value >= a.target;
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: lockedColor(palette, unlocked),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? primary.withValues(alpha: 0.35) : palette.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                a.emoji,
                style: TextStyle(
                  fontSize: 17,
                  color: unlocked ? null : palette.textDisabled,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  a.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? palette.textPrimary : palette.textTertiary,
                  ),
                ),
              ),
              if (unlocked)
                Icon(Icons.check_circle_rounded, size: 13, color: primary),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            a.desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 8.5, color: palette.textTertiary),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: a.target == 0 ? 0 : (value / a.target).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: palette.fill,
              valueColor: AlwaysStoppedAnimation(
                unlocked ? primary : palette.textDisabled,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value/${a.target}',
            style: TextStyle(fontSize: 8, color: palette.textTertiary),
          ),
        ],
      ),
    );
  }

  Color lockedColor(SkinPalette palette, bool unlocked) =>
      unlocked ? palette.card : palette.cardAlt;

  // ---------------- 年度账单 ----------------

  Widget _bill(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    final year = DateTime.now().year;
    final orders = _validOrders.where((o) => o.time.year == year).toList();
    final total = orders.fold(0.0, (s, o) => s + o.total);
    final count = orders.fold(0, (s, o) => s + o.count);
    final saved = orders.fold(
      0.0,
      (s, o) =>
          s +
          o.items.fold(
            0.0,
            (a, it) => a + (it.product.originalPrice - it.price) * it.qty,
          ),
    );
    final categoryAmount = <String, double>{};
    for (final o in orders) {
      for (final it in o.items) {
        categoryAmount[it.product.category] =
            (categoryAmount[it.product.category] ?? 0) + it.subtotal;
      }
    }
    final topCategories = categoryAmount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topOrder = orders.isEmpty
        ? null
        : (orders.toList()..sort((a, b) => b.total.compareTo(a.total))).first;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, skinOf(app.skin).accent],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$year 年度账单',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '这一年，你在幻想乡花掉了',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¥${money(total)}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '共 ${orders.length} 笔订单 · $count 件好物 · 省下 ¥${money(saved)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _stat(context, '订单数', '${orders.length}', primary),
            _stat(context, '件数', '$count', primary),
            _stat(context, '免单', '${app.freeOrderCount}', primary),
          ],
        ),
        const SizedBox(height: 12),
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '年度关键词', sub: '数据来自本机模拟订单'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _keyword(context, '解压收藏家', primary),
                  if (app.freeOrderCount > 0) _keyword(context, '白嫖小能手', primary),
                  if (topCategories.isNotEmpty)
                    _keyword(context, '${topCategories.first.key}爱好者', primary),
                  if (topOrder != null)
                    _keyword(
                      context,
                      '最贵一单 ¥${money(topOrder.total)}',
                      primary,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (topOrder != null)
                Text(
                  '最贵的一单买了 ${topOrder.items.first.product.name}，'
                  '那一刻一定很解压。',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.5,
                    color: palette.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '分类偏好', sub: '钱都花在哪了'),
              const SizedBox(height: 10),
              if (topCategories.isEmpty)
                Text(
                  '还没有订单，先去买点快乐',
                  style: TextStyle(fontSize: 11, color: palette.textTertiary),
                )
              else
                for (var i = 0; i < topCategories.length && i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              topCategories[i].key,
                              style: TextStyle(
                                fontSize: 11,
                                color: palette.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '¥${money(topCategories[i].value)}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: total <= 0
                                ? 0
                                : topCategories[i].value / total,
                            minHeight: 6,
                            backgroundColor: palette.fill,
                            valueColor: AlwaysStoppedAnimation(primary),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '年度账单为本地模拟统计，不包含任何真实消费。',
            style: TextStyle(
              fontSize: 9,
              color: palette.textDisabled,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color primary) {
    final palette = paletteOf(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyword(BuildContext context, String text, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: primary)),
    );
  }

  // ---------------- 情绪报告 ----------------

  Widget _emotion(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    final orders = _validOrders;
    final score = (orders.length * 6 +
            app.freeOrderCount * 12 +
            app.checkInDates.length * 2 +
            app.lotteryCount +
            app.favorites.length)
        .clamp(0, 100);
    final count = orders.fold(0, (s, o) => s + o.count);
    final saved = orders.fold(
      0.0,
      (s, o) =>
          s +
          o.items.fold(
            0.0,
            (a, it) => a + (it.product.originalPrice - it.price) * it.qty,
          ),
    );
    final style = score >= 80
        ? '重度解压大师'
        : score >= 50
        ? '稳定解压选手'
        : score >= 20
        ? '初级解压萌新'
        : '佛系围观群众';
    final days = <(DateTime, double)>[];
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final spend = orders
          .where(
            (o) =>
                o.time.year == day.year &&
                o.time.month == day.month &&
                o.time.day == day.day,
          )
          .fold(0.0, (s, o) => s + o.total);
      days.add((day, spend));
    }
    final maxSpend = days.fold(0.0, (s, d) => d.$2 > s ? d.$2 : s);
    return Column(
      children: [
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '情绪价值指数', sub: style),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      letterSpacing: -1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      '/ 100',
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.textTertiary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text('🧠', style: TextStyle(fontSize: 30)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 8,
                  backgroundColor: palette.fill,
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '你一共买下 $count 件好物，其中 ${app.freeOrderCount} 件免单，'
                '相当于省下 ¥${money(saved)}。',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.55,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '近 7 天消费曲线', sub: '并不是在劝你少买'),
              const SizedBox(height: 14),
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in days)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                day.$2 <= 0 ? '·' : '¥${money(day.$2)}',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 7.5,
                                  color: palette.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: maxSpend <= 0
                                    ? 6
                                    : 8 + 70 * (day.$2 / maxSpend),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      primary,
                                      primary.withValues(alpha: 0.35),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${day.$1.month}/${day.$1.day}',
                                style: TextStyle(
                                  fontSize: 7.5,
                                  color: palette.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '情绪诊断', sub: '一本正经地胡说八道'),
              const SizedBox(height: 8),
              _emotionRow(context, '🛍️', '购物冲动', '${orders.length} 笔订单'),
              _emotionRow(context, '🎡', '运气指数', '${app.lotteryCount} 次抽奖'),
              _emotionRow(context, '📅', '自律程度', '${app.checkInDates.length} 天签到'),
              _emotionRow(context, '🎫', '省钱能力', '${app.couponsUsed} 张券已用'),
              const SizedBox(height: 6),
              Text(
                '建议：压力大的时候可以来砍一刀，'
                '反正这里的钱都不是真的。',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: palette.textTertiary,
                ),
              ),
            ],
          ),
        ),
        _card(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, '今日解压任务', sub: '完成一项，快乐 +1'),
              const SizedBox(height: 8),
              for (final task in dailyTasks)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Text(task.emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '${app.taskProgress(task)}/${task.target}',
                        style: TextStyle(
                          fontSize: 9,
                          color: palette.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BenefitsPage(initialTab: 3),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text('去领取任务奖励', style: TextStyle(fontSize: 10.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emotionRow(
    BuildContext context,
    String emoji,
    String title,
    String value,
  ) {
    final palette = paletteOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: palette.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 10.5, color: palette.textPrimary),
          ),
        ],
      ),
    );
  }
}
