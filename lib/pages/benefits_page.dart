import 'package:flutter/material.dart';

import '../data.dart';
import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';

/// 福利中心：签到日历、领券中心、积分商城、会员与每日任务。
class BenefitsPage extends StatefulWidget {
  const BenefitsPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<BenefitsPage> createState() => _BenefitsPageState();
}

class _BenefitsPageState extends State<BenefitsPage> {
  late int _tab = widget.initialTab.clamp(0, 3);
  static const _tabs = ['签到', '领券', '积分', '会员'];

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('福利中心')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          return Column(
            children: [
              _header(context, app, primary),
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    for (var i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _tab = i),
                          child: Semantics(
                            button: true,
                            selected: _tab == i,
                            label: _tabs[i],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _tabs[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _tab == i
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: _tab == i
                                        ? primary
                                        : palette.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: _tab == i ? 18 : 0,
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
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: palette.divider),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: switch (_tab) {
                    0 => _checkInTab(context, app, primary),
                    1 => _couponTab(context, app, primary),
                    2 => _pointsTab(context, app, primary),
                    _ => _memberTab(context, app, primary),
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, AppState app, Color primary) {
    final cfg = skinOf(app.skin);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cfg.headerGradient,
        ),
      ),
      child: Row(
        children: [
          _stat('🎫', '${app.coupons} 张', '优惠券'),
          _stat('🪙', '${app.points}', '积分'),
          _stat('⭐', '${app.growthValue}', '成长值'),
          _stat(
            '🏅',
            app.memberLevel.name,
            '当前等级',
            valueColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _stat(
    String emoji,
    String value,
    String label, {
    Color valueColor = Colors.white,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
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
          Flexible(
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

  // ---------------- 签到 ----------------

  List<Widget> _checkInTab(
    BuildContext context,
    AppState app,
    Color primary,
  ) {
    final palette = paletteOf(context);
    final streak = app.checkInStreak;
    final cycle = streak == 0 ? 0 : (streak % 7 == 0 ? 7 : streak % 7);
    return [
      _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, '每日签到', sub: '连续签到，快乐不断档'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    app.checkedInToday
                        ? '今天已签到，连胜 $streak 天'
                        : '今天还没签到，点一下领快乐',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '连续 $streak 天',
                    style: TextStyle(fontSize: 10, color: primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton(
                onPressed: () {
                  final result = app.checkInToday();
                  if (!result.ok) {
                    showToast(context, '今天已经签过了，明天再来');
                    return;
                  }
                  Fx.deal();
                  showToast(
                    context,
                    '签到成功：${result.reward?.emoji ?? ''} '
                    '${result.reward?.title ?? ''}',
                    icon: Icons.event_available_rounded,
                  );
                  if ((result.reward?.couponOfferId) != null) {
                    setState(() => _tab = 1);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: app.checkedInToday
                      ? palette.iconDisabled
                      : primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
                child: Text(
                  app.checkedInToday ? '今日已签到' : '立即签到',
                  style: const TextStyle(fontSize: 13),
                ),
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
            _title(context, '7 天签到大礼', sub: '第 7 天有满 199 减 20'),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < checkInRewards.length; i++)
                  Expanded(
                    child: _rewardCell(
                      context,
                      checkInRewards[i],
                      i < cycle,
                      i == cycle && !app.checkedInToday,
                      primary,
                    ),
                  ),
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
            _title(context, '签到日历', sub: '漏签也没关系，从今天继续'),
            const SizedBox(height: 10),
            _calendar(context, app, primary),
          ],
        ),
      ),
    ];
  }

  Widget _rewardCell(
    BuildContext context,
    CheckInReward reward,
    bool done,
    bool today,
    Color primary,
  ) {
    final palette = paletteOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
        decoration: BoxDecoration(
          color: done
              ? primary.withValues(alpha: 0.08)
              : palette.cardAlt,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: today ? primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              reward.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              '第${reward.day}天',
              style: TextStyle(fontSize: 8.5, color: palette.textTertiary),
            ),
            const SizedBox(height: 2),
            Text(
              reward.couponOfferId != null ? '券' : '+${reward.points}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: done ? primary : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendar(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final days = DateTime(now.year, now.month + 1, 0).day;
    final offset = first.weekday - 1;
    final today = DateTime.now().day;
    Widget weekday(String text) => Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
        ),
      ),
    );
    final cells = <Widget>[
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++)
        Builder(
          builder: (context) {
            final date = DateTime(now.year, now.month, d);
            final key =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-'
                '${d.toString().padLeft(2, '0')}';
            final checked = app.checkInDates.contains(key);
            final isToday = d == today;
            return Container(
              height: 34,
              margin: const EdgeInsets.all(1.5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: checked
                    ? primary.withValues(alpha: 0.12)
                    : palette.cardAlt,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: isToday ? primary : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$d',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: checked || isToday
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: checked || isToday
                          ? primary
                          : palette.textSecondary,
                    ),
                  ),
                  if (checked)
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
    ];
    return Column(
      children: [
        Row(
          children: [
            for (final w in ['一', '二', '三', '四', '五', '六', '日'])
              weekday(w),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          childAspectRatio: 1.15,
          children: cells,
        ),
      ],
    );
  }

  // ---------------- 领券 ----------------

  List<Widget> _couponTab(
    BuildContext context,
    AppState app,
    Color primary,
  ) {
    final palette = paletteOf(context);
    return [
      _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, '领券中心', sub: '每天都能领，不用白不用'),
            const SizedBox(height: 10),
            for (final offer in couponOffers)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _offerRow(context, app, offer, primary),
              ),
          ],
        ),
      ),
      _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(
              context,
              '我的券包',
              sub: '${app.couponWallet.length} 张，其中 ${app.coupons} 张可用',
            ),
            const SizedBox(height: 10),
            if (app.couponWallet.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    '券包空空，去上面领一张',
                    style: TextStyle(fontSize: 11, color: palette.textTertiary),
                  ),
                ),
              )
            else
              for (final coupon in app.couponWallet.take(20))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _walletRow(context, coupon, primary),
                ),
          ],
        ),
      ),
    ];
  }

  Widget _offerRow(
    BuildContext context,
    AppState app,
    CouponOffer offer,
    Color primary,
  ) {
    final palette = paletteOf(context);
    final claimed = app.couponOfferClaimed(offer.id);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(offer.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  offer.desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final ok = app.claimCouponOffer(offer.id);
              if (!ok) {
                showToast(context, '这张今天已经领过了');
                return;
              }
              Fx.deal();
              showToast(
                context,
                '领取成功：${offer.title}',
                icon: Icons.card_giftcard_rounded,
              );
            },
            child: Semantics(
              button: true,
              label: claimed ? '${offer.title}已领取' : '领取${offer.title}',
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: claimed
                      ? palette.iconDisabled
                      : primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  claimed ? '已领取' : '领取',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: claimed ? palette.textTertiary : primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _walletRow(BuildContext context, Coupon coupon, Color primary) {
    final palette = paletteOf(context);
    final expired = coupon.expired;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.cardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expired ? palette.border : primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '¥${money(coupon.amount)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: expired ? palette.textTertiary : primary,
                    ),
                  ),
                ),
                Text(
                  '满${money(coupon.threshold)}可用',
                  style: TextStyle(fontSize: 8, color: palette.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: expired
                        ? palette.textTertiary
                        : palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${coupon.source} · '
                  '${coupon.expireAt == null ? '长期有效' : expired ? '已过期' : '30 天内有效'}',
                  style: TextStyle(fontSize: 9, color: palette.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            expired ? '已过期' : '可用',
            style: TextStyle(
              fontSize: 10,
              color: expired ? palette.textTertiary : primary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- 积分 ----------------

  List<Widget> _pointsTab(
    BuildContext context,
    AppState app,
    Color primary,
  ) {
    final palette = paletteOf(context);
    return [
      _card(
        context,
        child: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${app.points} 积分',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '签到、下单、写评价都能攒积分',
                    style: TextStyle(fontSize: 10, color: palette.textTertiary),
                  ),
                ],
              ),
            ),
            Text(
              '不可折现',
              style: TextStyle(fontSize: 9, color: palette.textDisabled),
            ),
          ],
        ),
      ),
      _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, '积分商城', sub: '换点快乐，别让积分过期'),
            const SizedBox(height: 10),
            for (final good in pointGoods)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _goodRow(context, app, good, primary),
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          '说明：积分与兑换商品均为本地模拟，不涉及真实权益与资金。',
          style: TextStyle(
            fontSize: 9.5,
            height: 1.6,
            color: palette.textDisabled,
          ),
        ),
      ),
    ];
  }

  Widget _goodRow(
    BuildContext context,
    AppState app,
    PointGood good,
    Color primary,
  ) {
    final palette = paletteOf(context);
    final affordable = app.points >= good.cost;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(good.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  good.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${good.cost} 积分 · ${good.desc}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: palette.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              if (!app.redeemPointGood(good)) {
                showToast(context, '积分不够，先去签到攒一攒');
                return;
              }
              Fx.deal();
              showToast(
                context,
                '兑换成功：${good.title}',
                icon: Icons.redeem_rounded,
              );
            },
            child: Semantics(
              button: true,
              label: affordable ? '兑换${good.title}' : '${good.title}积分不足',
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: affordable
                      ? primary.withValues(alpha: 0.12)
                      : palette.fill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  affordable ? '兑换' : '积分不足',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: affordable ? primary : palette.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- 会员与任务 ----------------

  List<Widget> _memberTab(
    BuildContext context,
    AppState app,
    Color primary,
  ) {
    final palette = paletteOf(context);
    final cfg = skinOf(app.skin);
    final level = app.memberLevel;
    final next = app.nextMemberLevel;
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary, cfg.accent]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(level.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '成长值 ${app.growthValue}'
                        '${next == null ? ' · 已满级' : ' / ${next.threshold}'}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '${app.points} 积分',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: app.memberProgress,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              next == null
                  ? '你已经是白玉楼最会花钱的贵宾了'
                  : '再攒 ${next.threshold - app.growthValue} 成长值升级「${next.name}」',
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final perk in level.perks)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      perk,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
            _title(context, '每日任务', sub: '完成任务领积分，今天也要解压'),
            const SizedBox(height: 10),
            for (final task in dailyTasks)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _taskRow(context, app, task, primary),
              ),
          ],
        ),
      ),
      _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, '会员等级', sub: '成长值来自每一笔模拟消费'),
            const SizedBox(height: 8),
            for (final l in memberLevels)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(l.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: l.name == level.name
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: l.name == level.name
                              ? primary
                              : palette.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${l.threshold} 成长值',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: palette.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
  }

  Widget _taskRow(
    BuildContext context,
    AppState app,
    DailyTaskDef task,
    Color primary,
  ) {
    final palette = paletteOf(context);
    final progress = app.taskProgress(task);
    final claimed = app.taskClaimed(task);
    final claimable = app.taskClaimable(task);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(task.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '+${task.points} 积分',
                      style: TextStyle(fontSize: 9.5, color: primary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  task.desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: task.target == 0
                              ? 0
                              : progress / task.target,
                          minHeight: 5,
                          backgroundColor: palette.fill,
                          valueColor: AlwaysStoppedAnimation(primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$progress/${task.target}',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: palette.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (!app.claimTask(task)) {
                showToast(
                  context,
                  claimed ? '今天已经领过了' : '还没完成，再逛逛吧',
                );
                return;
              }
              Fx.deal();
              showToast(context, '任务完成：积分 +${task.points}');
            },
            child: Semantics(
              button: true,
              label: claimed
                  ? '${task.title}已领取'
                  : claimable
                  ? '领取${task.title}奖励'
                  : '${task.title}未完成',
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: claimed
                      ? palette.fill
                      : claimable
                      ? primary.withValues(alpha: 0.12)
                      : palette.fill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  claimed ? '已领' : claimable ? '领取' : '未完成',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: claimed
                        ? palette.textDisabled
                        : claimable
                        ? primary
                        : palette.textDisabled,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
