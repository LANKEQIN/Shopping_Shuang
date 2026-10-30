import 'package:flutter/material.dart';

import '../data.dart';
import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';
import 'cart_page.dart';
import 'checkout_page.dart';
import 'group_buy_page.dart';
import 'store_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.product, this.heroTag});

  final Product product;
  final Object? heroTag;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product get product => widget.product;
  Object? get heroTag => widget.heroTag;

  @override
  void initState() {
    super.initState();
    // 足迹写入会触发全局通知，推迟到首帧之后再执行，避免在 build 期间标记重建。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppState.instance.recordFootprint(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final primary = Theme.of(context).colorScheme.primary;
    final palette = paletteOf(context);

    final related = AppState.instance.products
        .where((p) => p.category == product.category && p.id != product.id)
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
        actions: [
          ListenableBuilder(
            listenable: app,
            builder: (context, _) {
              final fav = app.isFavorite(product.id);
              return IconButton(
                onPressed: () {
                  final added = app.toggleFavorite(product.id);
                  showToast(
                    context,
                    added ? '已收藏，钱包松了一口气' : '已取消收藏，假装没心动过',
                    icon: added
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                  );
                },
                icon: Icon(
                  fav ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 20,
                  color: fav ? primary : null,
                ),
                tooltip: fav ? '取消收藏' : '收藏',
              );
            },
          ),
          IconButton(
            onPressed: () => showToast(context, '链接已复制，快去发给你的钱包'),
            icon: const Icon(Icons.share_rounded, size: 19),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: heroTag == null
                            ? ProductArt(product: product, radius: 0)
                            : Hero(
                                tag: heroTag!,
                                child: ProductArt(product: product, radius: 0),
                              ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < 3; i++)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: i == 0 ? 14 : 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: i == 0
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${product.rating} 分 · ${(product.sold * 10000).toString()}人买过',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: palette.card,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PriceText(product.price, size: 28, color: primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: OrigPrice(product.originalPrice, size: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final tag in product.tags) MiniTag(tag),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '已拼${product.sold}万+件',
                              style: TextStyle(fontSize: 10, color: primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          final group = app.startGroup(product);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  GroupBuyPage(highlightId: group.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '👥',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '拼团价 ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: primary,
                                    ),
                                  ),
                                  PriceText(
                                    product.price * 0.88,
                                    size: 16,
                                    color: primary,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '去拼团 ›',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '2 人成团 · 24 小时有效 · 好友由本地模拟',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
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
                const SizedBox(height: 10),
                _card(
                  context,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_num_rounded,
                            size: 17,
                            color: primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '优惠券',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: palette.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              '满99减10 · 满199减20 · 新人再减5',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: primary),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '领取 ›',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF5722),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 22, color: palette.divider),
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 17,
                            color: palette.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '配送',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: palette.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '幻想乡包邮 · 明日送达',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: palette.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: palette.textTertiary,
                          ),
                        ],
                      ),
                      Divider(height: 22, color: palette.divider),
                      InkWell(
                        onTap: () =>
                            showToast(context, '已选：${product.name} · 1件'),
                        child: Row(
                          children: [
                            Text(
                              '已选',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: palette.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: palette.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: palette.fill,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                '1件',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: palette.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _card(
                  context,
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('🏬', style: TextStyle(fontSize: 21)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.store,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '商品描述 4.9 · 服务 4.9 · 物流 4.8',
                              style: TextStyle(
                                fontSize: 10,
                                color: palette.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StorePage(store: product.store),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(64, 28),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          side: BorderSide(
                            color: primary.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          foregroundColor: primary,
                        ),
                        child: const Text('进店', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  color: palette.card,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '宝贝评价',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.rating}',
                            style: TextStyle(
                              fontSize: 13,
                              color: primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          StarRow(rating: 5),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _writeReview(context),
                            child: Text(
                              '写评价 ›',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final r in app.reviewsFor(product.id))
                        _reviewTile(
                          context,
                          palette,
                          r.nickname,
                          r.emoji,
                          r.rating,
                          r.text,
                          mine: true,
                        ),
                      for (final review in _reviews)
                        _reviewTile(
                          context,
                          palette,
                          review.$1,
                          review.$2,
                          review.$3,
                          review.$4,
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => _writeReview(context),
                          child: Text(
                            '写一条我的评价',
                            style: TextStyle(fontSize: 11, color: primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _qaCard(context, app, primary, palette),
                const SizedBox(height: 10),
                Container(
                  color: palette.card,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '商品详情',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.detailText,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: artColors(product)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              product.emoji,
                              style: const TextStyle(fontSize: 46),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '解压保障 · 模拟交易',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '本商品为演示数据，不会产生真实扣款',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  color: palette.card,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader('相似推荐', subtitle: '同类解压好物'),
                      const SizedBox(height: 10),
                      ProductMasonry(
                        products: related,
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
          ),
          _buildBottomBar(context, app, primary),
        ],
      ),
    );
  }

  Widget _reviewTile(
    BuildContext context,
    SkinPalette palette,
    String name,
    String emoji,
    int rating,
    String text, {
    bool mine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: palette.cardAlt,
            child: Text(emoji, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    if (mine) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: palette.cardAlt,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '我的',
                          style: TextStyle(
                            fontSize: 8,
                            color: palette.textTertiary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    StarRow(rating: rating, size: 10),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qaCard(
    BuildContext context,
    AppState app,
    Color primary,
    SkinPalette palette,
  ) {
    final mine = app.questionsFor(product.id);
    return Container(
      color: palette.card,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '问大家',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${commonQa.length + mine.length} 个问答',
                style: TextStyle(fontSize: 10, color: palette.textTertiary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _askQuestion(context),
                child: Text(
                  '我要提问 ›',
                  style: TextStyle(fontSize: 10.5, color: primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final qa in commonQa)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q：${qa.$1}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'A：${qa.$2}',
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.4,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          for (final qa in mine)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q：${qa.question}（我的提问）',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'A：${qa.answer}',
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.4,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Future<void> _writeReview(BuildContext context) async {
    final app = AppState.instance;
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    var rating = 5;
    final controller = TextEditingController();
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                  '评价这件宝贝',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '你的评价会保存在本机，卖家不会真的看到',
                  style: TextStyle(fontSize: 10, color: palette.textTertiary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 5; i++)
                      GestureDetector(
                        onTap: () => setSheetState(() => rating = i + 1),
                        child: Icon(
                          i < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 30,
                          color: const Color(0xFFFFB300),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  maxLength: 80,
                  style: TextStyle(fontSize: 12, color: palette.textPrimary),
                  decoration: InputDecoration(
                    hintText: '说说这件好物有多解压…',
                    hintStyle: TextStyle(
                      fontSize: 11,
                      color: palette.textTertiary,
                    ),
                    filled: true,
                    fillColor: palette.cardAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: const Text('发布评价'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (submitted != true || !context.mounted) {
      controller.dispose();
      return;
    }
    app.addReview(
      ProductReview(
        id: 'R${DateTime.now().millisecondsSinceEpoch}',
        productId: product.id,
        nickname: app.nickname,
        emoji: '🌸',
        rating: rating,
        text: controller.text.trim().isEmpty
            ? '很不错，解压效果拉满。'
            : controller.text.trim(),
        tags: const [],
        time: DateTime.now(),
      ),
    );
    controller.dispose();
    setState(() {});
    showToast(context, '评价已发布，积分 +0（但快乐 +1）');
  }

  Future<void> _askQuestion(BuildContext context) async {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final controller = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('问大家'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '问题会保存在本机，回答由店主假装思考后自动生成。',
              style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 2,
              maxLength: 40,
              style: TextStyle(fontSize: 12, color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: '例如：会掉色吗？',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: palette.textTertiary,
                ),
                filled: true,
                fillColor: palette.cardAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('提问', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
    if (submitted != true || !context.mounted) {
      controller.dispose();
      return;
    }
    AppState.instance.addQuestion(product.id, controller.text);
    controller.dispose();
    setState(() {});
    showToast(context, '提问成功，店主正在假装思考');
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      color: paletteOf(context).card,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: child,
    );
  }

  Widget _buildBottomBar(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    Widget iconItem(
      IconData icon,
      String label, {
      VoidCallback? onTap,
      int badge = 0,
    }) {
      return Semantics(
        button: true,
        label: badge > 0 ? '$label，$badge 件' : label,
        child: GestureDetector(
          onTap: onTap ?? () => showToast(context, '$label：客服正在捏捏乐，请稍等'),
          child: ExcludeSemantics(
            child: SizedBox(
              width: 46,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(icon, size: 22, color: palette.icon),
                      if (badge > 0)
                        Positioned(
                          right: -8,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$badge',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        6,
        8,
        12,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: palette.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          iconItem(Icons.headset_mic_outlined, '客服'),
          iconItem(
            Icons.storefront_outlined,
            '店铺',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StorePage(store: product.store),
              ),
            ),
          ),
          iconItem(
            Icons.shopping_cart_outlined,
            '购物车',
            badge: app.cartCount,
            onTap: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const CartPage())),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Builder(
              builder: (btnContext) {
                return Semantics(
                  button: true,
                  label: '加入购物车',
                  child: GestureDetector(
                    onTap: () {
                      app.addToCart(product);
                      Fx.addCart();
                      final mq = MediaQuery.of(context);
                      flyToCart(
                        btnContext,
                        product,
                        target: Offset(
                          121,
                          mq.size.height - mq.padding.bottom - 40,
                        ),
                      );
                      showToast(
                        context,
                        '已加入购物车，钱包毫无波动',
                        icon: Icons.shopping_cart_checkout_rounded,
                      );
                    },
                    child: ExcludeSemantics(
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.6),
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          '加入购物车',
                          style: TextStyle(
                            fontSize: 12,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              button: true,
              label: '立即购买',
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(
                        items: [
                          OrderItem(
                            product: product,
                            qty: 1,
                            price: product.price,
                          ),
                        ],
                        total: product.price,
                      ),
                    ),
                  );
                },
                child: ExcludeSemantics(
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      '立即购买',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

const _reviews = [
  ('幽幽子', '🌸', 5, '捏了两小时，压力真的没了，就是手有点酸。'),
  ('打工人小李', '☕', 5, '发货快，纸箱很结实，里面空气很新鲜。'),
  ('摆烂大师', '🛌', 4, '买完就忘了，但下单那一刻真的很快乐。'),
];
