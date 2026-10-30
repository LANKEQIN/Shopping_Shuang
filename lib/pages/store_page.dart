import 'package:flutter/material.dart';

import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'product_page.dart';

/// 店铺主页：店铺档案、关注、店内筛选与商品瀑布流。
class StorePage extends StatefulWidget {
  const StorePage({super.key, required this.store});

  final String store;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String _tab = '全部';

  static const _tabs = ['全部', '热销', '上新', '9.9包邮'];

  List<Product> get _all => AppState.instance.products
      .where((p) => p.store == widget.store)
      .toList();

  List<Product> _visible(List<Product> all) {
    final list = all.where((p) {
      if (_tab == '9.9包邮') return p.tags.contains('9.9包邮');
      return true;
    }).toList();
    if (_tab == '热销') {
      list.sort((a, b) => b.sold.compareTo(a.sold));
    } else if (_tab == '上新') {
      list.sort((a, b) => b.id.compareTo(a.id));
    } else {
      list.sort((a, b) => a.id.compareTo(b.id));
    }
    return list;
  }

  /// 店铺评分取店内商品评分均值，保留一位小数。
  double _avgRating(List<Product> all) {
    if (all.isEmpty) return 4.9;
    final total = all.fold<double>(0, (sum, p) => sum + p.rating);
    return (total / all.length * 10).roundToDouble() / 10;
  }

  String _mainCategories(List<Product> all) {
    final cats = <String>[];
    for (final p in all) {
      if (!cats.contains(p.category)) cats.add(p.category);
    }
    return cats.take(3).join(' · ');
  }

  int _totalSold(List<Product> all) =>
      all.fold<int>(0, (sum, p) => sum + p.sold);

  void _openProduct(Product p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ProductPage(product: p, heroTag: 'store-${p.id}-$_tab'),
      ),
    );
  }

  Widget _statChip(String text, SkinPalette palette) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: palette.fill,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 9, color: palette.textSecondary),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('店铺')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final palette = paletteOf(context);
          final primary = Theme.of(context).colorScheme.primary;
          final all = _all;
          final items = _visible(all);
          final rating = _avgRating(all);
          final sold = _totalSold(all);
          final fans = sold * 1.6 + 9.2;
          final categories = _mainCategories(all);
          final followed = app.isStoreFollowed(widget.store);
          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Container(
                color: palette.card,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('🏬', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.store,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  color: primary,
                                ),
                              ),
                              Text(
                                '店铺评分',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: palette.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _statChip('${all.length} 件商品', palette),
                              _statChip('已售 $sold 万件', palette),
                              _statChip(
                                '粉丝 ${fans.toStringAsFixed(1)} 万',
                                palette,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final now = app.toggleStoreFollowed(widget.store);
                        Fx.tap();
                        showToast(
                          context,
                          now ? '关注成功，店主开心地转了个圈' : '已取关，店主假装不在意',
                        );
                      },
                      child: Semantics(
                        button: true,
                        selected: followed,
                        label: followed
                            ? '取消关注${widget.store}'
                            : '关注${widget.store}',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: followed ? palette.fill : primary,
                            borderRadius: BorderRadius.circular(15),
                            border: followed
                                ? Border.all(color: palette.border)
                                : null,
                          ),
                          child: Text(
                            followed ? '已关注' : '关注',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: followed
                                  ? palette.textSecondary
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: palette.card,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    for (final metric in <(String, double)>[
                      ('描述相符', rating),
                      ('服务态度', 4.9),
                      ('物流速度', 4.8),
                    ])
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              metric.$2.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              metric.$1,
                              style: TextStyle(
                                fontSize: 10,
                                color: palette.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: palette.card,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📢', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '店铺公告',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            categories.isEmpty
                                ? '本店暂时没有上架商品，店主正在梦里补货。'
                                      '商品与交易均为本地模拟，不产生真实资金。'
                                : '本店主营 $categories 的解压好物。'
                                      '商品、价格与评价均为本地模拟，'
                                      '不产生真实资金，下单不花钱。',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.6,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: palette.card,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final tab = _tabs[i];
                      final selected = _tab == tab;
                      return GestureDetector(
                        onTap: () => setState(() => _tab = tab),
                        child: Semantics(
                          button: true,
                          selected: selected,
                          label: '店内$tab',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? primary : palette.cardAlt,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: selected
                                    ? Colors.white
                                    : palette.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                child: Row(
                  children: [
                    Text(
                      '店内商品 · 共 ${items.length} 件',
                      style: TextStyle(
                        fontSize: 10,
                        color: palette.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '数据为本地演示',
                      style: TextStyle(
                        fontSize: 9,
                        color: palette.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 44),
                  child: Column(
                    children: [
                      Text(
                        all.isEmpty ? '🏪' : '🗂️',
                        style: const TextStyle(fontSize: 44),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        all.isEmpty ? '这家店铺暂时没有商品' : '这个筛选下暂无商品',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textSecondary,
                        ),
                      ),
                      if (all.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _tab = '全部'),
                          child: const Text('查看全部商品'),
                        ),
                      ],
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ProductMasonry(
                    products: items,
                    tagOf: (p) => 'store-${p.id}-$_tab',
                    onTap: _openProduct,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
