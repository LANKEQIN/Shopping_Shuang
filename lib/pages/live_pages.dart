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

class LiveListPage extends StatelessWidget {
  const LiveListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E14),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF15151D), Color(0xFF24242F)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '直播购',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE2C55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        '我的关注',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '主播们正在替你花钱，快乐免费',
                  style: TextStyle(fontSize: 10.5, color: Colors.white54),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LiveRoomPage(room: AppState.instance.liveRooms.first),
                      ),
                    ),
                    child: SizedBox(
                      height: 210,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppState.instance.liveRooms.first.colors,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -10,
                            top: 20,
                            child: Text(
                              AppState.instance.liveRooms.first.hostEmoji,
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            top: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE2C55),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '直播中',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppState.instance.liveRooms.first.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      child: Text(
                                        AppState.instance.liveRooms.first.hostEmoji,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppState.instance.liveRooms.first.host,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.visibility_outlined,
                                      size: 11,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${AppState.instance.liveRooms.first.viewers}人在看',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
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
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text(
                      '正在直播',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '下滑发现更多',
                      style: TextStyle(fontSize: 9.5, color: Colors.white38),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppState.instance.liveRooms.length - 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, i) {
                final room = AppState.instance.liveRooms[i + 1];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LiveRoomPage(room: room)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: room.colors,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -6,
                          top: 14,
                          child: Text(
                            room.hostEmoji,
                            style: const TextStyle(fontSize: 58),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFE2C55),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Text(
                              '直播中',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 9,
                          right: 9,
                          bottom: 9,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  height: 1.3,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      room.host,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${room.viewers}人',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white60,
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
                );
              },
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 20 + MediaQuery.of(context).padding.bottom,
              ),
              child: Text(
                '已经到底了，去直播间里逛逛吧',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({super.key, required this.room});

  final LiveRoom room;

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  final Random _rnd = Random();
  Timer? _commentTimer;
  final List<_Comment> _comments = [];
  final List<int> _hearts = [];
  int _nextId = 0;
  bool _entered = false;

  Timer? _talkTimer;
  Timer? _tickTimer;
  int _talkIndex = 0;
  final Set<int> _offShelf = {};
  DateTime _bagEnd = DateTime.now().add(const Duration(seconds: 120));
  bool _bagClaimed = false;
  int _likes = 0;
  bool _fullscreen = false;
  String _hostName = '';
  String _hostEmoji = '';

  static const _commentPool = [
    ('打工人小王', '这个真的解压吗？'),
    ('幽幽子的钱包', '已下单，钱包说它很好'),
    ('摸鱼冠军', '买一送一还有吗主播'),
    ('摆烂大王', '我要把压力寄给主播'),
    ('路过的幽灵', '这个价格我可以'),
    ('社恐小张', '手速快过我的只有主播'),
    ('手速超快的猫', '刚刚抢到了，快乐'),
    ('白玉楼管家', '求链接！'),
    ('熬夜冠军', '已加购三件，感觉被治愈了'),
    ('明天不上班', '今晚放肆买，反正不花钱'),
  ];

  @override
  void initState() {
    super.initState();
    _hostName = widget.room.host;
    _hostEmoji = widget.room.hostEmoji;
    _talkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _talkIndex++);
    });
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (DateTime.now().isAfter(_bagEnd)) {
          _bagEnd = DateTime.now().add(const Duration(seconds: 120));
          _bagClaimed = false;
        }
      });
    });
    _commentTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (!mounted) return;
      final c = _commentPool[_rnd.nextInt(_commentPool.length)];
      setState(() {
        _comments.add(_Comment(_nextId++, c.$1, c.$2));
        if (_comments.length > 4) _comments.removeAt(0);
      });
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _entered = true);
        showToast(
          context,
          '已进入直播间，主播正在替你花钱',
          icon: Icons.play_circle_fill_rounded,
        );
      }
    });
  }

  @override
  void dispose() {
    _commentTimer?.cancel();
    _talkTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  List<Product> get _talkItems {
    final all = widget.room.productIds.map(prod).toList();
    final onShelf = all.where((p) => !_offShelf.contains(p.id)).toList();
    return onShelf.isEmpty ? all : onShelf;
  }

  Product get _talking => _talkItems[_talkIndex % _talkItems.length];

  String get _bagCountdown {
    final diff = _bagEnd.difference(DateTime.now());
    final remain = diff.isNegative ? Duration.zero : diff;
    return '${remain.inMinutes.toString().padLeft(2, '0')}:'
        '${(remain.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void _claimBag() {
    if (_bagClaimed) {
      showToast(context, '福袋已领，等下一轮倒计时结束');
      return;
    }
    setState(() => _bagClaimed = true);
    AppState.instance.addCoupons(1);
    AppState.instance.addPoints(5);
    Fx.deal();
    showToast(
      context,
      '福袋已领：优惠券 +1，积分 +5',
      icon: Icons.card_giftcard_rounded,
    );
  }

  void _openLikeBoard() {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final board = <(String, String, int)>[
      ('我', '🌸', 3000 + _likes),
      for (var i = 0; i < playFriends.length && i < 5; i++)
        (playFriends[i].$1, playFriends[i].$2, 8800 - i * 700 + _likes),
    ]..sort((a, b) => b.$3.compareTo(a.$3));
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
              '直播间点赞榜',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '本周为你喜欢的主播点亮',
              style: TextStyle(fontSize: 10, color: palette.textTertiary),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < board.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        i < 3 ? ['🥇', '🥈', '🥉'][i] : '${i + 1}',
                        style: TextStyle(
                          fontSize: i < 3 ? 15 : 11,
                          color: palette.textTertiary,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: palette.cardAlt,
                      child: Text(
                        board[i].$2,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        board[i].$1,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: board[i].$1 == '我'
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '❤️ ${board[i].$3}',
                      style: TextStyle(fontSize: 10.5, color: primary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _switchHost() {
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
              '切换主播',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '换个人陪你花钱，快乐不变',
              style: TextStyle(fontSize: 10, color: palette.textTertiary),
            ),
            const SizedBox(height: 10),
            for (final host in playFriends.take(4))
              InkWell(
                onTap: () {
                  setState(() {
                    _hostName = host.$1;
                    _hostEmoji = host.$2;
                  });
                  Navigator.of(sheetContext).pop();
                  showToast(
                    context,
                    '已切换到主播「${host.$1}」',
                    icon: Icons.switch_account_rounded,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: palette.cardAlt,
                        child: Text(
                          host.$2,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          host.$1,
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      if (_hostName == host.$1)
                        Text(
                          '当前主播',
                          style: TextStyle(fontSize: 10, color: primary),
                        )
                      else
                        Text(
                          '切换',
                          style: TextStyle(
                            fontSize: 10,
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
    );
  }

  void _addHeart() {
    Fx.tap();
    final id = _nextId++;
    setState(() {
      _likes++;
      _hearts.add(id);
      if (_hearts.length > 6) _hearts.removeAt(0);
    });
  }

  void _openBag() {
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    final all = widget.room.productIds.map(prod).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final onShelf = all
                .where((p) => !_offShelf.contains(p.id))
                .toList();
            return Container(
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                14,
                16,
                14,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '直播购物袋',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${onShelf.length}/${all.length} 件在售',
                        style: TextStyle(
                          fontSize: 10,
                          color: palette.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '主播专享价',
                        style: TextStyle(fontSize: 10, color: primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final p in all)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _offShelf.contains(p.id)
                            ? palette.cardAlt
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: _offShelf.contains(p.id) ? 0.4 : 1,
                            child: SizedBox(
                              width: 62,
                              height: 62,
                              child: ProductArt(product: p, badge: false),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.3,
                                    fontWeight: FontWeight.w600,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '直播价 ',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: primary,
                                      ),
                                    ),
                                    PriceText(
                                      p.price * 0.88,
                                      size: 15,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 5),
                                    OrigPrice(p.price, size: 9),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: _offShelf.contains(p.id)
                                    ? null
                                    : () {
                                        AppState.instance.addToCart(p);
                                        Fx.addCart();
                                        showToast(context, '已加购：${p.name}');
                                      },
                                child: Semantics(
                                  button: !_offShelf.contains(p.id),
                                  label: _offShelf.contains(p.id)
                                      ? '${p.name}已下架'
                                      : '加购 ${p.name}',
                                  child: Container(
                                    height: 28,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: _offShelf.contains(p.id)
                                          ? null
                                          : LinearGradient(
                                              colors: [
                                                primary,
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                              ],
                                            ),
                                      color: _offShelf.contains(p.id)
                                          ? palette.iconDisabled
                                          : null,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      _offShelf.contains(p.id)
                                          ? '已下架'
                                          : '加购',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    if (_offShelf.contains(p.id)) {
                                      _offShelf.remove(p.id);
                                    } else {
                                      _offShelf.add(p.id);
                                    }
                                  });
                                  setState(() {});
                                  showToast(
                                    context,
                                    _offShelf.contains(p.id)
                                        ? '已下架：${p.name}'
                                        : '已重新上架：${p.name}',
                                  );
                                },
                                child: Text(
                                  _offShelf.contains(p.id) ? '重新上架' : '下架',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: palette.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onShelf.isEmpty
                              ? null
                              : () {
                                  for (final p in onShelf) {
                                    AppState.instance.addToCart(p);
                                  }
                                  Navigator.of(sheetContext).pop();
                                  showToast(
                                    context,
                                    '在售商品已全部加购，主播笑出了声',
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                          child: const Text('全部加购'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: onShelf.isEmpty
                              ? null
                              : () {
                                  Navigator.of(sheetContext).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductPage(product: onShelf.first),
                                    ),
                                  );
                                },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                          child: const Text('查看主推款'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final primary = Theme.of(context).colorScheme.primary;
    final room = widget.room;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B10),
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  room.colors.first.withValues(alpha: 0.75),
                  const Color(0xFF0B0B10),
                  const Color(0xFF0B0B10),
                ],
              ),
            ),
          ),
          Positioned(
            top: 108,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedScale(
                scale: _entered ? 1 : 0.85,
                duration: AppState.instance.animationsEnabled
                    ? const Duration(milliseconds: 400)
                    : Duration.zero,
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: AppState.instance.animationsEnabled
                      ? const Duration(milliseconds: 350)
                      : Duration.zero,
                  child: _talkCard(context, primary, room),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(top: 236),
                child: Text(
                  room.notice,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _circleButton(
                        Icons.close_rounded,
                        () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _switchHost,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.16,
                                ),
                                child: Text(
                                  _hostEmoji,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _hostName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '切换',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${room.viewers}人正在看',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Colors.white60,
                                    ),
                                  ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  app.setFollowedLive(!app.followedLive);
                                  Fx.tap();
                                  setState(() {});
                                  showToast(
                                    context,
                                    app.followedLive
                                        ? '关注成功，主播感动到多播一小时'
                                        : '已取关，主播假装不在意',
                                  );
                                },
                                child: Semantics(
                                  button: true,
                                  label: app.followedLive
                                      ? '取消关注主播'
                                      : '关注主播',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primary,
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      app.followedLive ? '已关注' : '关注',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _fullscreen = !_fullscreen),
                        child: _circleButton(
                          _fullscreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          () {},
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => showToast(context, '直播间已分享给空气'),
                        child: _circleButton(Icons.ios_share_rounded, () {}),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        room.title,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (!_fullscreen) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 132,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final c in _comments)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${c.name}：',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: const Color(0xFF25F4EE)
                                            .withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: c.message,
                                      style: const TextStyle(
                                        fontSize: 10.5,
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
                    ),
                  ],
                  if (!_fullscreen)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => showToast(context, '主播正在忙着吃零食，晚点回你'),
                              child: Container(
                                height: 38,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(19),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '和主播聊两句…',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(
                                            alpha: 0.65,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.send_rounded,
                                      size: 16,
                                      color: Colors.white54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _addHeart,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '❤️ ${3000 + _likes}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _openLikeBoard,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      '🏆 点赞榜',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _claimBag,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: _bagClaimed ? 0.06 : 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _bagClaimed
                                          ? '🧧 已领 · $_bagCountdown'
                                          : '🧧 福袋 $_bagCountdown',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _openBag,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_talkItems.length} 件',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _addHeart,
                            child: Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '❤️',
                                style: TextStyle(fontSize: 19),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _openBag,
                            child: Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '🛍️',
                                style: TextStyle(fontSize: 19),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _openBag,
                        child: Container(
                          width: 76,
                          height: 74,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '去抢购',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '主播专享',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_fullscreen) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('🎬', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              '沉浸全屏 · 讲解卡轮播中',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _openBag,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '购物袋',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _fullscreen = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '退出全屏',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 10 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
          for (final (i, id) in _hearts.indexed)
            Positioned(
              right: 64 + (i % 3) * 8,
              bottom: 200 + i * 8,
              child: _Heart(
                key: ValueKey(id),
                onDone: () {
                  setState(() => _hearts.remove(id));
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _talkCard(BuildContext context, Color primary, LiveRoom room) {
    final items = _talkItems;
    final product = _talking;
    final index = _talkIndex % items.length;
    return GestureDetector(
      key: ValueKey('talk-${product.id}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductPage(product: product)),
      ),
      child: Container(
        width: 208,
        height: 208,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: room.colors.first.withValues(alpha: 0.45),
              blurRadius: 36,
              spreadRadius: 3,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProductArt(product: product, radius: 0),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFE2C55),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '讲解中 ${index + 1}/${items.length}',
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(9, 18, 9, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '直播价 ',
                            style: TextStyle(fontSize: 8.5, color: primary),
                          ),
                          PriceText(
                            product.price * 0.88,
                            size: 14,
                            color: Colors.white,
                          ),
                          const Spacer(),
                          const Text(
                            '点击查看 ›',
                            style: TextStyle(
                              fontSize: 8.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}

class _Comment {
  const _Comment(this.id, this.name, this.message);

  final int id;
  final String name;
  final String message;
}

class _Heart extends StatefulWidget {
  const _Heart({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<_Heart> createState() => _HeartState();
}

class _HeartState extends State<_Heart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDone();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Transform.translate(
          offset: Offset(sin(t * 9) * 16, -t * 150),
          child: Opacity(opacity: (1 - t).clamp(0.0, 1.0), child: child),
        );
      },
      child: const Text('❤️', style: TextStyle(fontSize: 22)),
    );
  }
}
