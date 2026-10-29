import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'product_page.dart';

/// 类目页：分类切换、店铺筛选、排序与商品瀑布流。
class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    this.initialCategory = '全部',
    this.store,
  });

  final String initialCategory;
  final String? store;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String _category = widget.initialCategory;
  int _sort = 0;
  bool _priceAsc = true;
  String _filter = '全部';

  static const _categories = [
    '全部',
    '数码',
    '服饰',
    '美食',
    '家居',
    '美妆',
    '潮玩',
    '运动',
    '宠物',
    '解压',
  ];

  List<Product> get _items {
    var list = AppState.instance.products.where((p) {
      if (_category != '全部' && p.category != _category) return false;
      if (widget.store != null && p.store != widget.store) return false;
      if (_filter == '自营' && !p.selfRun) return false;
      if (_filter == '百亿补贴' && !p.subsidy) return false;
      if (_filter == '9.9包邮' && !p.tags.contains('9.9包邮')) return false;
      return true;
    }).toList();
    switch (_sort) {
      case 1:
        list.sort((a, b) => b.sold.compareTo(a.sold));
        break;
      case 2:
        list.sort(
          (a, b) => _priceAsc
              ? a.price.compareTo(b.price)
              : b.price.compareTo(a.price),
        );
        break;
      case 3:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list.sort((a, b) => a.id.compareTo(b.id));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final items = _items;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store ?? (_category == '全部' ? '全部分类' : _category)),
      ),
      body: Column(
        children: [
          if (widget.store != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              color: palette.card,
              child: Text(
                '🏬 ${widget.store} · 按店铺筛选',
                style: TextStyle(fontSize: 11, color: palette.textSecondary),
              ),
            ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: '$cat分类',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? primary : palette.card,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11.5,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: palette.card,
            child: Column(
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            if (i == 2 && _sort == 2) {
                              _priceAsc = !_priceAsc;
                            } else {
                              _sort = i;
                              _priceAsc = true;
                            }
                          }),
                          child: Semantics(
                            button: true,
                            selected: _sort == i,
                            label: ['综合排序', '销量优先', '价格排序', '好评优先'][i],
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ['综合', '销量', '价格', '好评'][i],
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: _sort == i
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: _sort == i
                                          ? primary
                                          : palette.textSecondary,
                                    ),
                                  ),
                                  if (i == 2)
                                    Icon(
                                      _priceAsc
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      size: 12,
                                      color: _sort == 2
                                          ? primary
                                          : palette.textTertiary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final filter = ['全部', '自营', '百亿补贴', '9.9包邮'][i];
                      final selected = _filter == filter;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? primary.withValues(alpha: 0.1)
                                : palette.cardAlt,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 10,
                              color: selected
                                  ? primary
                                  : palette.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                Text(
                  '共 ${items.length} 件',
                  style: TextStyle(fontSize: 10, color: palette.textTertiary),
                ),
                const Spacer(),
                Text(
                  '数据为本地演示',
                  style: TextStyle(fontSize: 9, color: palette.textDisabled),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🗂️', style: TextStyle(fontSize: 46)),
                        const SizedBox(height: 10),
                        Text(
                          '这个筛选下没有商品',
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => setState(() {
                            _filter = '全部';
                            _category = '全部';
                          }),
                          child: const Text('重置筛选'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                    children: [
                      ProductMasonry(
                        products: items,
                        onTap: (p) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductPage(product: p),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
