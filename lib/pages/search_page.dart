import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'product_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialTag = ''});

  final String initialTag;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  late String _tag = widget.initialTag;
  String _query = '';
  final FocusNode _focus = FocusNode();
  int _sort = 0;
  bool _priceAsc = true;
  String _filter = '全部';

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<Product> get _results {
    var list = AppState.instance.products;
    if (_tag.isNotEmpty) {
      list = list.where((p) {
        if (_tag == '自营') return p.selfRun;
        return p.tags.contains(_tag) || p.category == _tag;
      }).toList();
    }
    if (_query.isNotEmpty) {
      list = list.where((p) {
        return p.name.contains(_query) ||
            p.category.contains(_query) ||
            p.store.contains(_query) ||
            p.tags.any((t) => t.contains(_query));
      }).toList();
    }
    if (_filter == '自营') list = list.where((p) => p.selfRun).toList();
    if (_filter == '百亿补贴') list = list.where((p) => p.subsidy).toList();
    if (_filter == '9.9包邮') {
      list = list.where((p) => p.tags.contains('9.9包邮')).toList();
    }
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
    }
    return list;
  }

  void _pickFilter(BuildContext context) {
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
              '筛选商品',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in ['全部', '自营', '百亿补贴', '9.9包邮'])
                  GestureDetector(
                    onTap: () {
                      setState(() => _filter = f);
                      Navigator.of(sheetContext).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _filter == f
                            ? primary.withValues(alpha: 0.12)
                            : palette.cardAlt,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _filter == f
                              ? primary
                              : palette.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '筛选只影响当前搜索结果，可随时点「筛选」修改。',
              style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  void _search(String text) {
    final q = text.trim();
    setState(() {
      _query = q;
      _focus.unfocus();
    });
    AppState.instance.pushHistory(q);
  }

  void _pickHot(String keyword) {
    _controller.text = keyword;
    _search(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 36,
          decoration: BoxDecoration(
            color: palette.fill,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            textInputAction: TextInputAction.search,
            onSubmitted: _search,
            style: TextStyle(fontSize: 13, color: palette.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: palette.icon,
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              hintText: '搜索解压好物',
              hintStyle: TextStyle(fontSize: 12, color: palette.textTertiary),
              contentPadding: const EdgeInsets.only(top: 10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _search(_controller.text),
            child: Text(
              '搜索',
              style: TextStyle(
                fontSize: 13,
                color: cfg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _query.isEmpty && _tag.isEmpty
          ? _discovery(context)
          : _resultView(context),
    );
  }

  Widget _discovery(BuildContext context) {
    final app = AppState.instance;
    final palette = paletteOf(context);
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        if (app.searchHistory.isNotEmpty) ...[
          Row(
            children: [
              Text(
                '搜索历史',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => app.clearHistory(),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 17,
                  color: palette.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in app.searchHistory)
                GestureDetector(
                  onTap: () => _pickHot(h),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      h,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '🔥 热搜榜',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: palette.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '实时热度',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (var i = 0; i < AppState.instance.hotSearches.length; i++)
                InkWell(
                  onTap: () => _pickHot(AppState.instance.hotSearches[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: i < 3
                                  ? Theme.of(context).colorScheme.primary
                                  : palette.textDisabled,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AppState.instance.hotSearches[i],
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                        if (i < 3)
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: Color(0xFFFF5722),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '${(98 - i * 9)}%',
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
        const SizedBox(height: 20),
        const SectionHeader('猜你喜欢', subtitle: '不搜也能直接买'),
        const SizedBox(height: 10),
        for (final p in AppState.instance.feedProducts.take(6))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProductRowCard(
              product: p,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductPage(product: p)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _resultView(BuildContext context) {
    final results = _results;
    final palette = paletteOf(context);
    return Column(
      children: [
        if (_tag.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _tag == '自营'
                            ? '自营好物'
                            : (_tag == '9.9包邮' ? '9.9 包邮' : _tag),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _tag = ''),
                        child: Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '共 ${results.length} 件',
                  style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
                ),
              ],
            ),
          ),
        Container(
          height: 38,
          color: palette.card,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < 4; i++)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (i == 2 && _sort == 2) {
                        _priceAsc = !_priceAsc;
                      } else {
                        _sort = i;
                        _priceAsc = true;
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Text(
                            ['综合', '销量', '价格', '好评'][i],
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: _sort == i
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: _sort == i
                                  ? Theme.of(context).colorScheme.primary
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
                                  ? Theme.of(context).colorScheme.primary
                                  : palette.textTertiary,
                            ),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () => _pickFilter(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Text(
                          _filter == '全部' ? '筛选' : '筛选 · $_filter',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _filter == '全部'
                                ? palette.textSecondary
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: palette.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔍', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        '没有找到这件解压好物',
                        style: TextStyle(
                          fontSize: 14,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '换一个关键词，比如“捏捏乐”',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _query = '';
                            _tag = '';
                          });
                        },
                        child: const Text('返回热搜'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => ProductRowCard(
                    product: results[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductPage(product: results[i]),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
