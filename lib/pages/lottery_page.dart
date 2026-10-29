import 'dart:math';

import 'package:flutter/material.dart';

import '../data.dart';
import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'benefits_page.dart';

/// 抽免单增强版：权重奖池、概率公示、保底机制、记录与晒单。
class LotteryPage extends StatefulWidget {
  const LotteryPage({super.key});

  @override
  State<LotteryPage> createState() => _LotteryPageState();
}

class _LotteryPageState extends State<LotteryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  double _angle = 0;
  double _spinFrom = 0;
  double _spinDelta = 0;
  bool _spinning = false;

  static const _rewards = [
    ('免单', '🎉', '随机一件商品 0 元拿下，已自动生成订单', 1),
    ('5元券', '🎫', '优惠券 +1 张，满 99 可用', 14),
    ('谢谢参与', '🍃', '没关系，解压的过程本身就很快乐', 20),
    ('88元券', '🧧', '优惠券 +1 张，满 199 可用', 3),
    ('1元券', '🪙', '优惠券 +1 张，聊胜于无', 22),
    ('再来一次', '🔁', '白送一次机会，再点一下转盘就行', 12),
    ('10元券', '🎟️', '优惠券 +1 张，满 99 可用', 13),
    ('神秘礼包', '🎁', '优惠券 +1 张，里面是满满的祝福', 15),
  ];

  static const int _freeIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;
    final app = AppState.instance;
    final weights = [for (final r in _rewards) r.$4];
    final index = app.rollLottery(weights, _freeIndex);
    final desired = (360 - (index * 45 + 22.5)) % 360;
    final normalized = _angle % 360;
    var delta = desired - normalized;
    if (delta < 0) delta += 360;
    _spinFrom = _angle;
    _spinDelta = 5 * 360 + delta;
    setState(() => _spinning = true);
    Fx.spin();
    _controller.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _angle = _spinFrom + _spinDelta;
      setState(() => _spinning = false);
      _settle(index);
    });
  }

  Future<void> _settle(int index) async {
    final app = AppState.instance;
    final reward = _rewards[index];
    final name = reward.$1;

    Product? freeProduct;
    if (name == '免单') {
      freeProduct = app.randomProduct();
      app.createFreeOrder(freeProduct);
    } else if (name == '再来一次' || name == '谢谢参与') {
      // 无实物奖励。
    } else {
      app.addCoupons(1);
    }

    app.recordLottery(
      LotteryRecord(
        title: name,
        emoji: reward.$2,
        note: name == '免单' && freeProduct != null
            ? '${freeProduct.name} 已 0 元拿下'
            : reward.$3,
        time: DateTime.now(),
        free: name == '免单',
        freeProductName: freeProduct?.name,
      ),
    );

    if (name == '免单' && freeProduct != null) {
      celebrate(
        context,
        text: '恭喜免单！',
        subtitle: '${freeProduct.name} 已 0 元发货',
        icon: Icons.card_giftcard_rounded,
      );
    }

    if (!mounted) return;
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reward.$2, style: const TextStyle(fontSize: 50)),
              const SizedBox(height: 10),
              Text(
                name == '谢谢参与' ? '差一点点就中了' : '抽中「$name」',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name == '免单'
                    ? '${freeProduct!.name} 已 0 元拿下，请到订单页查看'
                    : reward.$3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.5,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text('开心收下'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOdds(BuildContext context) {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              '奖池概率公示',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '保底规则：连续 ${AppState.instance.lotteryPityLimit} 次未中免单，'
              '下一次必中免单',
              style: TextStyle(fontSize: 10, color: palette.textTertiary),
            ),
            const SizedBox(height: 12),
            for (final reward in _rewards)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Text(reward.$2, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reward.$1,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${reward.$4}%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Text(
              '概率为本地模拟配置，结果在设备本地生成，不涉及真实奖品。',
              style: TextStyle(
                fontSize: 9.5,
                height: 1.6,
                color: palette.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOff(LotteryRecord record) {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: palette.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Text(
                '晒单：抽中免单',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                record.freeProductName == null
                    ? '0 元拿下，快乐已经到账'
                    : '${record.freeProductName}\n0 元拿下，快乐已经发货',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.5,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
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
                  child: const Text('接受大家的羡慕'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final cfg = skinOf(app.skin);
    final palette = paletteOf(context);
    final primary = cfg.primary;
    final segmentColors = [
      primary,
      const Color(0xFFFFF3E0),
      cfg.accent,
      const Color(0xFFF5F5F5),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('抽免单'),
        actions: [
          TextButton(
            onPressed: () => _showOdds(context),
            child: const Text('概率公示', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final completedTasks = dailyTasks
              .where((t) => app.taskClaimed(t) || app.taskClaimable(t))
              .length;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, cfg.accent]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🎡', style: TextStyle(fontSize: 42)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '0 元抽免单',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '每日无限次 · 概率公示 · 有保底\n'
                            '反正也不扣钱，转就完了',
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
              Container(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              final angle = _spinning
                                  ? _spinFrom +
                                        _spinDelta *
                                            Curves.easeOutQuart.transform(
                                              _controller.value,
                                            )
                                  : _angle;
                              return Transform.rotate(
                                angle: angle * pi / 180,
                                child: CustomPaint(
                                  size: const Size.square(286),
                                  painter: _WheelPainter(
                                    colors: segmentColors,
                                    labels: _rewards
                                        .map((e) => e.$1)
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: -2,
                            child: Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                CustomPaint(
                                  size: const Size(26, 28),
                                  painter: _PointerPainter(color: primary),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _spin,
                            child: Semantics(
                              button: true,
                              label: _spinning ? '转盘转动中' : '抽一次',
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 68,
                                height: 68,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [primary, cfg.accent],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _spinning ? '转…' : '抽',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _spinning ? '转盘正在努力转动…' : '点中间按钮，立即抽一次',
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _pill('🎫 优惠券 ${app.coupons} 张', primary),
                        const SizedBox(width: 8),
                        _pill('∞ 剩余次数', primary),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text('🛡️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '保底进度 ${app.lotteryPityRemaining}/'
                              '${app.lotteryPityLimit} · 再抽 '
                              '${app.lotteryPityRemaining} 次必出免单',
                              style: TextStyle(fontSize: 10, color: primary),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showOdds(context),
                            child: Text(
                              '规则',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: palette.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(13, 13, 13, 8),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '抽奖记录',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '共 ${app.lotteryCount} 次',
                          style: TextStyle(
                            fontSize: 10,
                            color: palette.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (app.lotteryHistory.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            '还没抽过，手气正在蓄力',
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.textTertiary,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final h in app.lotteryHistory.take(6))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Text(h.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  h.free
                                      ? '${h.title} · ${h.freeProductName ?? ''}'
                                      : h.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ),
                              if (h.free)
                                GestureDetector(
                                  onTap: () => _showOff(h),
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
                                      '晒单',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '刚刚',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: palette.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(13, 13, 13, 8),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '每日任务',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '今日完成 $completedTasks/${dailyTasks.length}',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: palette.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    for (final task in dailyTasks)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              task.emoji,
                              style: const TextStyle(fontSize: 13),
                            ),
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
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const BenefitsPage(initialTab: 3),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          '去福利中心领取任务奖励',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  '说明：免单奖品为随机商品，会自动生成一笔 0 元订单；'
                  '优惠券仅用于本模拟商城，不可兑换真实商品。',
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

  Widget _pill(String text, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: primary)),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.colors, required this.labels});

  final List<Color> colors;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweep = 2 * pi / labels.length;
    final paint = Paint();
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < labels.length; i++) {
      paint.color = colors[i % colors.length];
      final start = -pi / 2 + i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        borderPaint,
      );

      final mid = start + sweep / 2;
      final textOffset = Offset(
        center.dx + cos(mid) * radius * 0.66,
        center.dy + sin(mid) * radius * 0.66,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: (i % colors.length == 1 || i % colors.length == 3)
                ? const Color(0xFF333333)
                : Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, textOffset - Offset(tp.width / 2, tp.height / 2));
    }

    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius - 2.5, ring);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  _PointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) =>
      oldDelegate.color != color;
}
