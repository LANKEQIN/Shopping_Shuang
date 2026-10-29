import 'dart:async';

import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'benefits_page.dart';
import 'category_page.dart';
import 'cut_price_page.dart';
import 'group_buy_page.dart';
import 'live_pages.dart';
import 'lottery_page.dart';
import 'product_page.dart';
import 'search_page.dart';
import 'seckill_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController(
    viewportFraction: 0.94,
  );
  Timer? _bannerTimer;
  int _bannerIndex = 0;
  String _category = '推荐';
  int _feedTick = 0;

  static const int _pageSize = 12;
  int _visible = _pageSize + 2;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = (_bannerIndex + 1) % AppState.instance.banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _scroll.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter > 320) return;
    final total = _feed.length;
    if (_visible >= total) return;
    setState(() => _visible = (_visible + _pageSize).clamp(0, total));
  }

  void _resetFeed() {
    _visible = _pageSize + 2;
  }

  List<Product> get _feed {
    final base = AppState.instance.feedProducts;
    final list = _category == '推荐'
        ? base
        : base.where((p) => p.category == _category).toList();
    if (list.isEmpty) return list;
    final start = _feedTick % list.length;
    return [...list.skip(start), ...list.take(start)];
  }

  List<Product> get _visibleFeed => _feed.take(_visible).toList();

  String _heroTag(Product p) => 'home-${p.id}-$_feedTick-$_category';

  void _openProduct(Product p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductPage(product: p, heroTag: _heroTag(p)),
      ),
    );
  }

  void _openSearch([String tag = '']) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SearchPage(initialTag: tag)));
  }

  void _openKong(String label) {
    switch (label) {
      case '百亿补贴':
        _openSearch('百亿补贴');
        break;
      case '限时秒杀':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SeckillPage()));
        break;
      case '砍一刀':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CutPricePage()));
        break;
      case '抽免单':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const LotteryPage()));
        break;
      case '直播购':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                LiveRoomPage(room: AppState.instance.liveRooms.first),
          ),
        );
        break;
      case '天天特卖':
        _openSearch('9.9包邮');
        break;
      case '签到领券':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BenefitsPage()),
        );
        break;
      case '品牌馆':
        _openSearch('自营');
        break;
      case '拼团':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GroupBuyPage()),
        );
        break;
      case '全部分类':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CategoryPage()),
        );
        break;
      case '更多':
        _showMore(context);
        break;
    }
  }

  void _showMore(BuildContext context) {
    final palette = paletteOf(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final items = [
          ['限时秒杀', '⚡'],
          ['砍一刀', '🔪'],
          ['抽免单', '🎡'],
          ['直播购', '📺'],
          ['拼团', '👥'],
          ['百亿补贴', '🧧'],
          ['9.9包邮', '🪙'],
          ['签到领券', '🎫'],
          ['品牌馆', '🏬'],
          ['全部分类', '🗂️'],
          ['解压专区', '🫠'],
          ['二手闲置', '♻️'],
        ];
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
              Text(
                '全部频道',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                mainAxisSpacing: 14,
                childAspectRatio: 0.8,
                children: [
                  for (final item in items)
                    Semantics(
                      button: true,
                      label: item[0],
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          if (item[0] == '二手闲置') {
                            showToast(context, '二手区正在建设中，先买新的吧');
                          } else if (item[0] == '解压专区') {
                            _openSearch('解压');
                          } else {
                            _openKong(item[0]);
                          }
                        },
                        child: ExcludeSemantics(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: palette.cardAlt,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  item[1],
                                  style: const TextStyle(fontSize: 21),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item[0],
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: palette.textSecondary,
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
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Skin>(
      valueListenable: AppState.instance.skinNotifier,
      builder: (context, skin, _) {
        final cfg = skinOf(skin);
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context, cfg),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [
                    _buildBanner(context),
                    const SizedBox(height: 12),
                    _buildKong(context, cfg),
                    _buildSkinZone(context, cfg),
                    const SizedBox(height: 12),
                    _buildSeckillStrip(context, cfg),
                    const SizedBox(height: 14),
                    _buildCategoryBar(context, cfg),
                    const SizedBox(height: 16),
                    SectionHeader(
                      '猜你喜欢',
                      subtitle: '大数据已经看透你了',
                      actionLabel: '换一批',
                      onAction: () => setState(() {
                        _feedTick++;
                        _resetFeed();
                      }),
                    ),
                    const SizedBox(height: 10),
                    ProductMasonry(
                      products: _visibleFeed,
                      tagOf: _heroTag,
                      onTap: _openProduct,
                    ),
                    if (_visible < _feed.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Center(
                          child: Text(
                            '继续下滑，还有更多解压好物',
                            style: TextStyle(
                              fontSize: 10,
                              color: paletteOf(context).textTertiary,
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

  Widget _buildHeader(BuildContext context, SkinConfig cfg) {
    final palette = paletteOf(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cfg.headerGradient,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        14,
        MediaQuery.of(context).padding.top + 10,
        14,
        13,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🛍️', style: TextStyle(fontSize: 17)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cfg.brand,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    cfg.slogan,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => showToast(context, '扫一扫：检测到 1 个想买的灵魂'),
                child: Semantics(
                  button: true,
                  label: '扫一扫',
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => showToast(context, '暂无新消息，只有新的想买东西'),
                child: Semantics(
                  button: true,
                  label: '消息',
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      Positioned(
                        right: -3,
                        top: -2,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD54F),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          GestureDetector(
            onTap: () => _openSearch(),
            child: Semantics(
              button: true,
              label: '搜索商品',
              child: Container(
                height: 38,
                padding: const EdgeInsets.fromLTRB(12, 0, 5, 0),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 18, color: cfg.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        cfg.searchHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: palette.textTertiary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cfg.primary, cfg.accent],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        '搜索',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: AppState.instance.banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, i) {
              final banner = AppState.instance.banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () {
                    switch (banner.target) {
                      case 'subsidy':
                        _openSearch('百亿补贴');
                        break;
                      case 'cut':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CutPricePage(),
                          ),
                        );
                        break;
                      case 'live':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LiveRoomPage(
                              room: AppState.instance.liveRooms.first,
                            ),
                          ),
                        );
                        break;
                      case 'seckill':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SeckillPage(),
                          ),
                        );
                        break;
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: banner.colors,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: -8,
                          child: Text(
                            banner.emoji,
                            style: const TextStyle(fontSize: 70),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          top: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.24),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  banner.tag,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                banner.subtitle,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 14,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '立即进入 ›',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 18,
            bottom: 0,
            child: Row(
              children: [
                for (var i = 0; i < AppState.instance.banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 4),
                    width: i == _bannerIndex ? 12 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: i == _bannerIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKong(BuildContext context, SkinConfig cfg) {
    final palette = paletteOf(context);
    final items = <List<Object>>[
      [
        '百亿补贴',
        '🧧',
        [Color(0xFFFF4D4F), Color(0xFFFF7A45)],
      ],
      [
        '限时秒杀',
        '⚡',
        [Color(0xFFFF6A00), Color(0xFFFFC300)],
      ],
      [
        '砍一刀',
        '🔪',
        [Color(0xFFE02E24), Color(0xFFFF6B4A)],
      ],
      [
        '抽免单',
        '🎡',
        [Color(0xFF7C4DFF), Color(0xFFB388FF)],
      ],
      [
        '直播购',
        '📺',
        [Color(0xFF161823), Color(0xFF3A3A4A)],
      ],
      [
        '天天特卖',
        '🪙',
        [Color(0xFFF7971E), Color(0xFFFFD200)],
      ],
      [
        '签到领券',
        '🎫',
        [Color(0xFFFF7043), Color(0xFFFFAB40)],
      ],
      [
        '拼团',
        '👥',
        [Color(0xFF4776E6), Color(0xFF8E54E9)],
      ],
      [
        '解压专区',
        '🫠',
        [Color(0xFF00C6FF), Color(0xFF0072FF)],
      ],
      [
        '更多',
        '⋯',
        [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
      ],
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
        children: [
          for (final item in items)
            Semantics(
              button: true,
              label: item[0] as String,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final label = item[0] as String;
                  if (label == '解压专区') {
                    _openSearch('解压');
                  } else {
                    _openKong(label);
                  }
                },
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: item[2] as List<Color>,
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          item[1] as String,
                          style: TextStyle(
                            fontSize: (item[1] as String) == '⋯' ? 19 : 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item[0] as String,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 京东皮肤的自营专区 / 拼多多皮肤的拼单氛围条。
  Widget _buildSkinZone(BuildContext context, SkinConfig cfg) {
    final isJd = cfg.id == Skin.jd;
    final isPdd = cfg.id == Skin.pdd;
    if (!isJd && !isPdd) return const SizedBox.shrink();
    final palette = paletteOf(context);
    final items = isJd
        ? AppState.instance.products.where((p) => p.selfRun).take(3).toList()
        : AppState.instance.products.where((p) => p.subsidy).take(3).toList();
    final title = isJd ? '自营专区 · 次日达' : '拼单热榜 · 2 人成团';
    final badgeText = isJd ? '自营' : '拼单';
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cfg.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _openSearch(isJd ? '自营' : '百亿补贴'),
                child: Row(
                  children: [
                    Text(
                      isJd ? '逛自营' : '去拼单',
                      style: TextStyle(
                        fontSize: 10,
                        color: palette.textTertiary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: palette.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (final p in items)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openProduct(p),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ProductArt(product: p, badge: false),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          PriceText(p.price, size: 12, color: cfg.primary),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeckillStrip(BuildContext context, SkinConfig cfg) {
    final palette = paletteOf(context);
    final items = AppState.instance.seckillIds
        .take(4)
        .map(AppState.instance.findProduct)
        .whereType<Product>()
        .toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '⚡',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 5),
              Text(
                '限时秒杀',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CountdownText(
                    target: nextTwoHourBoundary(),
                    prefix: '距结束 ',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: cfg.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SeckillPage())),
                child: Row(
                  children: [
                    Text(
                      '更多',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: palette.textTertiary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: palette.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final p = items[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductPage(product: p)),
                  ),
                  child: SizedBox(
                    width: 78,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 78,
                          width: 78,
                          child: ProductArt(product: p, badge: false),
                        ),
                        const SizedBox(height: 5),
                        PriceText(p.price, size: 14, color: cfg.primary),
                        const SizedBox(height: 1),
                        OrigPrice(p.originalPrice, size: 9),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context, SkinConfig cfg) {
    final palette = paletteOf(context);
    const cats = ['推荐', '数码', '服饰', '美食', '家居', '美妆', '潮玩', '运动', '宠物', '解压'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = cats[i];
          final selected = _category == cat;
          return GestureDetector(
            onTap: () => setState(() {
              _category = cat;
              _resetFeed();
            }),
            child: Semantics(
              button: true,
              selected: selected,
              label: '$cat分类',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? cfg.primary : palette.card,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: cfg.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? Colors.white : palette.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
