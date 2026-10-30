import 'package:flutter/material.dart';

import '../fx.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'category_page.dart';
import 'store_page.dart';

/// 我的关注店铺：关注列表、取关与进店入口。
class FollowedStoresPage extends StatelessWidget {
  const FollowedStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('我的关注')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final palette = paletteOf(context);
          final stores = app.followedStores.toList();
          if (stores.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏬', style: TextStyle(fontSize: 46)),
                    const SizedBox(height: 10),
                    Text(
                      '还没有关注的店铺',
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '进店逛逛，随手关注，解压不迷路',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoryPage()),
                      ),
                      child: const Text('去逛逛'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
            itemCount: stores.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _storeCard(context, app, stores[i], palette),
          );
        },
      ),
    );
  }

  Widget _storeCard(
    BuildContext context,
    AppState app,
    String store,
    SkinPalette palette,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    final items = app.products.where((p) => p.store == store).toList();
    final sold = items.fold<int>(0, (sum, p) => sum + p.sold);
    final rating = items.isEmpty
        ? 4.9
        : items.fold<double>(0, (sum, p) => sum + p.rating) / items.length;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => StorePage(store: store)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text('🏬', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _meta('${items.length} 件商品', palette),
                        _meta('评分 ${rating.toStringAsFixed(1)}', palette),
                        _meta('已售 $sold 万件', palette),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Semantics(
                button: true,
                selected: true,
                label: '取消关注$store',
                child: GestureDetector(
                  onTap: () {
                    app.toggleStoreFollowed(store);
                    Fx.tap();
                    showToast(context, '已取关，店主假装不在意');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: palette.fill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: Text(
                      '已关注',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: palette.iconDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(String text, SkinPalette palette) => Container(
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
}
