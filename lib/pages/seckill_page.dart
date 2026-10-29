import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data.dart';
import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'product_page.dart';

/// 秒杀增强版：场次切换、预约提醒、排队动画、失败补货。
class SeckillPage extends StatefulWidget {
  const SeckillPage({super.key});

  @override
  State<SeckillPage> createState() => _SeckillPageState();
}

class _SeckillPageState extends State<SeckillPage> {
  final Random _rnd = Random();
  final Set<int> _grabbed = {};
  final Set<int> _retry = {};
  final Map<int, double> _progress = {};
  int? _sessionIndex;
  bool _followLive = true;
  int? _queueing;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _sessionIndex = _activeIndex() ?? _nextIndex();
    _clock = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      final active = _activeIndex();
      if (_followLive) {
        setState(() => _sessionIndex = active ?? _nextIndex());
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  int? _activeIndex() {
    final now = DateTime.now();
    int? active;
    for (var i = 0; i < seckillSessions.length; i++) {
      if (now.hour >= seckillSessions[i].hour) active = i;
    }
    return active;
  }

  int _nextIndex() {
    final now = DateTime.now();
    for (var i = 0; i < seckillSessions.length; i++) {
      if (now.hour < seckillSessions[i].hour) return i;
    }
    return 0;
  }

  SeckillSession get _session =>
      seckillSessions[_sessionIndex ?? 0];

  bool get _isLive => _sessionIndex == _activeIndex();

  DateTime get _sessionEnd {
    final index = _sessionIndex ?? 0;
    final now = DateTime.now();
    if (index == seckillSessions.length - 1) {
      return DateTime(now.year, now.month, now.day + 1, seckillSessions.first.hour);
    }
    final next = seckillSessions[index + 1];
    return DateTime(now.year, now.month, now.day, next.hour);
  }

  DateTime get _sessionStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, _session.hour);
  }

  double _progressOf(Product p) =>
      _progress[p.id] ?? 0.48 + (p.id % 5) * 0.08;

  bool get _reserved =>
      _session.productIds.every((id) => AppState.instance.isSeckillReserved(id));

  void _toggleReserve() {
    for (final id in _session.productIds) {
      AppState.instance.toggleSeckillReminder(id);
    }
    Fx.tap();
    showToast(
      context,
      _reserved
          ? '已预约本场，整点前会给你一个本地提醒'
          : '已取消预约，佛系抢购也挺好',
      icon: _reserved
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
    );
  }

  Future<void> _grab(Product p) async {
    if (!_isLive) {
      showToast(context, '本场还没开始，先点「预约本场」吧');
      return;
    }
    if (_grabbed.contains(p.id) || _queueing != null) return;

    setState(() => _queueing = p.id);
    final position = 120 + _rnd.nextInt(900);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _QueueDialog(position: position),
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pop();
    setState(() => _queueing = null);

    final success = _retry.contains(p.id) || _rnd.nextDouble() < 0.78;
    if (!success) {
      _retry.add(p.id);
      setState(() {
        _progress[p.id] = (_progressOf(p) + 0.18).clamp(0.0, 1.0);
      });
      showToast(
        context,
        '手慢了，库存瞬间被抢空 · 已为你补货，再试一次',
        icon: Icons.refresh_rounded,
      );
      return;
    }

    _retry.remove(p.id);
    setState(() {
      _grabbed.add(p.id);
      _progress[p.id] = (_progressOf(p) + 0.1).clamp(0.0, 0.98);
    });
    AppState.instance.addToCart(p);
    Fx.deal();
    celebrate(
      context,
      text: '抢到啦！',
      subtitle: '排队 $position 位也挡不住你的手速',
      icon: Icons.bolt_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = skinOf(AppState.instance.skin);
    final palette = paletteOf(context);
    final primary = cfg.primary;
    final app = AppState.instance;
    final items = _session.productIds.map(prod).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('限时秒杀')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, cfg.accent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _isLive
                                ? '$_session.label 场 · 正在疯抢'
                                : '$_session.label 场 · 即将开始',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleReserve,
                          child: Semantics(
                            button: true,
                            label: _reserved ? '取消本场预约' : '预约本场',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: _reserved ? 0.32 : 0.18,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _reserved
                                        ? Icons.notifications_active_rounded
                                        : Icons.notifications_none_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _reserved ? '已预约' : '预约本场',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _isLive ? '本场剩余' : '距开抢',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CountdownBoxes(
                          target: _isLive ? _sessionEnd : _sessionStart,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _session.tagline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (var i = 0; i < seckillSessions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _sessionIndex = i;
                                _followLive = i == _activeIndex();
                              }),
                              child: Semantics(
                                button: true,
                                selected: _sessionIndex == i,
                                label: '${seckillSessions[i].label}场',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _sessionIndex == i
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        seckillSessions[i].label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _sessionIndex == i
                                              ? primary
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        i == _activeIndex()
                                            ? '正在疯抢'
                                            : (i < (_activeIndex() ?? -1)
                                                  ? '已结束'
                                                  : '即将开始'),
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: _sessionIndex == i
                                              ? primary.withValues(alpha: 0.8)
                                              : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!_isLive) ...[
                      const SizedBox(height: 10),
                      Text(
                        '本场尚未开始，可先预约；到点不会真的响铃（本地模拟提醒）',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
                child: Row(
                  children: [
                    Text(
                      _isLive ? '本场商品' : '本场预告',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${items.length} 件 · 每人限抢 1 件',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: palette.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              for (final p in items)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: _seckillCard(context, palette, primary, p),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                child: Text(
                  '说明：秒杀为本地模拟玩法，抢购结果与库存均为演示数据，'
                  '不会产生任何真实交易。',
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

  Widget _seckillCard(
    BuildContext context,
    SkinPalette palette,
    Color primary,
    Product p,
  ) {
    final grabbed = _grabbed.contains(p.id);
    final progress = _progressOf(p);
    final remain = ((1 - progress) * 100).round();
    final queueing = _queueing == p.id;
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductPage(product: p)),
            ),
            child: SizedBox(
              width: 96,
              height: 96,
              child: ProductArt(product: p, badge: false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '秒杀价 ',
                          style: TextStyle(fontSize: 9.5, color: primary),
                        ),
                        PriceText(p.price, size: 17, color: primary),
                        const SizedBox(width: 5),
                        OrigPrice(p.originalPrice, size: 10),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: palette.fill,
                    valueColor: AlwaysStoppedAnimation(primary),
                  ),
                ),
                const SizedBox(height: 3),
                ShakeOnce(
                  trigger: grabbed,
                  enabled: AppState.instance.animationsEnabled,
                  child: Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '已抢${(progress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 9,
                              color: palette.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            remain > 0 ? '仅剩 $remain 件' : '已抢光，补货中',
                            style: TextStyle(fontSize: 9, color: primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: grabbed
                ? '${p.name}已抢到'
                : _isLive
                ? '马上抢 ${p.name}'
                : '${p.name}未开抢',
            child: GestureDetector(
              onTap: () => _grab(p),
              child: Container(
                width: 58,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: grabbed || !_isLive
                        ? [palette.iconDisabled, palette.textDisabled]
                        : [primary, skinOf(AppState.instance.skin).accent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  grabbed
                      ? '已抢到'
                      : queueing
                      ? '排队中'
                      : _isLive
                      ? '马上抢'
                      : '未开抢',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.2,
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
}

class _QueueDialog extends StatelessWidget {
  const _QueueDialog({required this.position});

  final int position;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    return Dialog(
      backgroundColor: palette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '正在排队抢购…',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '前面还有 $position 位手速怪',
              style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
