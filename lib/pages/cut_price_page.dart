import 'package:flutter/material.dart';

import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';

/// 砍一刀增强版：本地海报、好友排行榜、最后 3 元保底、0 元晒单。
class CutPricePage extends StatefulWidget {
  const CutPricePage({super.key});

  @override
  State<CutPricePage> createState() => _CutPricePageState();
}

class _CutPricePageState extends State<CutPricePage> {
  final Product _product =
      AppState.instance.findProduct(10) ?? AppState.instance.products.first;

  @override
  void initState() {
    super.initState();
    AppState.instance.ensureCutRecord(_product);
  }

  void _cut() {
    final app = AppState.instance;
    final record = app.cutRecord;
    if (record == null || record.done) return;
    final slice = app.cutOnce();
    if (slice == null) return;
    Fx.deal();
    if (record.done) {
      celebrate(
        context,
        text: '0 元拿下！',
        subtitle: '好友们已经被你薅秃了',
        icon: Icons.celebration_rounded,
      );
    } else {
      showToast(
        context,
        '${slice.name} 帮你砍了 ¥${money(slice.amount)}，'
        '还差 ¥${money(record.remaining)}',
        icon: Icons.favorite_rounded,
      );
    }
  }

  void _showPoster(CutRecord record) {
    final app = AppState.instance;
    app.markCutPoster();
    final primary = Theme.of(context).colorScheme.primary;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🔪 砍一刀',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '帮我砍一刀，快乐分你一半',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ProductArt(product: _product, radius: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  record.done
                      ? '已经被砍到 0 元啦'
                      : '还差 ¥${money(record.remaining)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '口令：SHUANG-${record.productId}-'
                    '${record.cuts.length.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 9, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          minimumSize: const Size.fromHeight(38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        child: const Text('关闭', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          showToast(
                            context,
                            '海报已生成（本地模拟），没有真的上传',
                            icon: Icons.image_rounded,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primary,
                          minimumSize: const Size.fromHeight(38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        child: const Text(
                          '保存海报',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOff(CutRecord record) {
    if (record.shownOff) {
      showToast(context, '已经晒过单了，好友们都知道你白嫖了');
      return;
    }
    AppState.instance.markCutShownOff();
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
              const Text('🎉', style: TextStyle(fontSize: 46)),
              const SizedBox(height: 8),
              Text(
                '晒单成功',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_product.name}\n0 元拿下，快乐已经发货',
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
    final primary = cfg.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('砍一刀')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final palette = paletteOf(context);
          final record = app.cutRecord;
          if (record == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final ranked = [...record.cuts]
            ..sort((a, b) => b.amount.compareTo(a.amount));
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
                    const Text('🔪', style: TextStyle(fontSize: 40)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '砍一刀 · 白嫖专场',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '全网已有 1,024,567 人砍成 0 元\n'
                            '最后 3 元保底一刀砍完，绝不让你卡在 0.01',
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
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: ProductArt(product: _product, radius: 12),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _product.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '现在 ',
                          style: TextStyle(fontSize: 10, color: primary),
                        ),
                        PriceText(record.remaining, size: 28, color: primary),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: OrigPrice(_product.price, size: 12),
                          ),
                        ),
                        if (record.done) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '已免单',
                              style: TextStyle(fontSize: 10, color: primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 12,
                        child: Stack(
                          children: [
                            Container(color: palette.fill),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: record.progress),
                              duration: const Duration(milliseconds: 400),
                              builder: (context, value, _) {
                                return FractionallySizedBox(
                                  widthFactor: value.clamp(0.02, 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primary, cfg.accent],
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 5),
                                    child: const Text(
                                      '🐾',
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '已砍 ${(record.progress * 100).round()}%',
                          style: TextStyle(fontSize: 10, color: primary),
                        ),
                        const Spacer(),
                        Text(
                          record.done
                              ? '已免单 🎉'
                              : '还差 ¥${money(record.remaining)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _stat(
                          context,
                          '已砍金额',
                          '¥${money(record.saved)}',
                          primary,
                        ),
                        _stat(context, '已邀好友', '${record.cuts.length} 位', primary),
                        _stat(
                          context,
                          '剩余',
                          '¥${money(record.remaining)}',
                          primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: record.done ? null : _cut,
                      child: Semantics(
                        button: !record.done,
                        label: record.done ? '已成功免单' : '找好友帮砍一刀',
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: record.done
                                  ? [
                                      const Color(0xFFBDBDBD),
                                      const Color(0xFFAAAAAA),
                                    ]
                                  : [primary, cfg.accent],
                            ),
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: Text(
                            record.done ? '已成功免单 🎉' : '找好友帮砍一刀',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showPoster(record),
                            icon: const Icon(Icons.image_outlined, size: 15),
                            label: const Text(
                              '生成海报',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: record.done
                                ? () => _showOff(record)
                                : null,
                            icon: const Icon(Icons.celebration_outlined, size: 15),
                            label: Text(
                              record.shownOff ? '已晒单' : '晒单',
                              style: const TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (record.done) ...[
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {
                          app.resetCutRecord();
                          app.ensureCutRecord(_product);
                          showToast(context, '已重新开始砍一刀');
                        },
                        child: const Text(
                          '再砍一件（重新开始）',
                          style: TextStyle(fontSize: 10.5),
                        ),
                      ),
                    ],
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
                    Text(
                      '好友排行榜',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '按单次砍掉的金额排序，第一名将获得你的感谢',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: palette.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (ranked.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: Text(
                            '还没有好友出手，快点上面的按钮',
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.textTertiary,
                            ),
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < ranked.length && i < 8; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
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
                                  ranked[i].emoji,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ranked[i].name,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '-¥${money(ranked[i].amount)}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                child: Text(
                  '说明：砍价与海报均为本地模拟，好友由本地随机生成，'
                  '不会向真实好友发送任何邀请。',
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

  Widget _stat(
    BuildContext context,
    String label,
    String value,
    Color primary,
  ) {
    final palette = paletteOf(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
          ),
        ],
      ),
    );
  }
}
