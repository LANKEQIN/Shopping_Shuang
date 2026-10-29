import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'product_page.dart';

/// 我的收藏 / 浏览足迹。
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late int _tab = widget.initialTab.clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? '我的收藏' : '浏览足迹')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final items = _tab == 0
              ? app.favoriteProducts
              : app.footprintProducts;
          return Column(
            children: [
              Container(
                color: palette.card,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    for (var i = 0; i < 2; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _tab = i),
                          child: Semantics(
                            button: true,
                            selected: _tab == i,
                            label: i == 0 ? '我的收藏' : '浏览足迹',
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    i == 0
                                        ? '收藏 ${app.favorites.length}'
                                        : '足迹 ${app.footprints.length}',
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
                            Text(
                              _tab == 0 ? '⭐' : '🕘',
                              style: const TextStyle(fontSize: 52),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _tab == 0 ? '还没有收藏' : '还没有浏览记录',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _tab == 0
                                  ? '在商品详情点右上角星标，就能收藏'
                                  : '随便逛逛，足迹会自动记录',
                              style: TextStyle(
                                fontSize: 11,
                                color: palette.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final p = items[i];
                          return ProductRowCard(
                            product: p,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductPage(product: p),
                              ),
                            ),
                            trailing: _tab == 0
                                ? GestureDetector(
                                    onTap: () {
                                      app.toggleFavorite(p.id);
                                      showToast(
                                        context,
                                        '已取消收藏：${p.name}',
                                        icon: Icons.star_border_rounded,
                                      );
                                    },
                                    child: Semantics(
                                      button: true,
                                      label: '取消收藏 ${p.name}',
                                      child: Icon(
                                        Icons.star_rounded,
                                        size: 20,
                                        color: primary,
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
