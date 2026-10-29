import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../fx.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';

String money(num v) {
  var s = v.toStringAsFixed(2);
  if (s.endsWith('0')) s = s.substring(0, s.length - 1);
  if (s.endsWith('0')) s = s.substring(0, s.length - 1);
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  return s;
}

String two(int n) => n.toString().padLeft(2, '0');

DateTime nextTwoHourBoundary() {
  final now = DateTime.now();
  final next = (now.hour ~/ 2 + 1) * 2;
  return DateTime(now.year, now.month, now.day, next);
}

const Map<String, List<Color>> _palettes = {
  '数码': [Color(0xFF4776E6), Color(0xFF8E54E9)],
  '服饰': [Color(0xFFF857A6), Color(0xFFFF5858)],
  '美食': [Color(0xFFFF9A44), Color(0xFFFC6076)],
  '家居': [Color(0xFF43C6AC), Color(0xFF3A6073)],
  '美妆': [Color(0xFFFF8AA6), Color(0xFFC86DD7)],
  '潮玩': [Color(0xFF00C6FF), Color(0xFF0072FF)],
  '运动': [Color(0xFFF7971E), Color(0xFFFFD200)],
  '宠物': [Color(0xFF56AB2F), Color(0xFFA8E063)],
  '解压': [Color(0xFF6A11CB), Color(0xFF2575FC)],
};

List<Color> artColors(Product p) =>
    _palettes[p.category] ?? const [Color(0xFF6A11CB), Color(0xFF2575FC)];

class PriceText extends StatelessWidget {
  const PriceText(
    this.value, {
    super.key,
    this.size = 18,
    this.color,
    this.prefix = '¥',
  });

  final double value;
  final double size;
  final Color? color;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: TextStyle(
              fontSize: size * 0.62,
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: money(value),
            style: TextStyle(
              fontSize: size,
              color: c,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class OrigPrice extends StatelessWidget {
  const OrigPrice(this.value, {super.key, this.size = 11});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      '¥${money(value)}',
      style: TextStyle(
        fontSize: size,
        color: SkinPalette.of(context).textTertiary,
        decoration: TextDecoration.lineThrough,
        decorationColor: SkinPalette.of(context).textTertiary,
      ),
    );
  }
}

class MiniTag extends StatelessWidget {
  const MiniTag(this.text, {super.key, this.color, this.filled = false});

  final String text;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      decoration: BoxDecoration(
        color: filled ? c.withValues(alpha: 0.1) : Colors.transparent,
        border: Border.all(color: c.withValues(alpha: 0.45), width: 0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: c, height: 1.2)),
    );
  }
}

/// 九大分类的本地插画资产。缺失或加载失败时自动回退到渐变 + Emoji。
const Map<String, String> kCategoryArt = {
  '数码': 'assets/products/cat_digital.jpg',
  '服饰': 'assets/products/cat_fashion.jpg',
  '美食': 'assets/products/cat_food.jpg',
  '家居': 'assets/products/cat_home.jpg',
  '美妆': 'assets/products/cat_beauty.jpg',
  '潮玩': 'assets/products/cat_toys.jpg',
  '运动': 'assets/products/cat_sports.jpg',
  '宠物': 'assets/products/cat_pets.jpg',
  '解压': 'assets/products/cat_relax.jpg',
};

class ProductArt extends StatelessWidget {
  const ProductArt({
    super.key,
    required this.product,
    this.radius = 12,
    this.badge = true,
  });

  final Product product;
  final double radius;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final colors = artColors(product);
    final asset = kCategoryArt[product.category];
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, cons) {
              final w = cons.maxWidth.isFinite ? cons.maxWidth : 120.0;
              final h = cons.maxHeight.isFinite ? cons.maxHeight : 120.0;
              final s = min(w, h);
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (asset != null)
                    Positioned.fill(
                      child: Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        cacheWidth: 512,
                        filterQuality: FilterQuality.low,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  if (asset != null)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.10),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (asset == null) ...[
                    Positioned(
                      right: -s * 0.22,
                      top: -s * 0.22,
                      child: _bubble(s * 0.6),
                    ),
                    Positioned(
                      left: -s * 0.24,
                      bottom: -s * 0.3,
                      child: _bubble(s * 0.72, alpha: 0.08),
                    ),
                  ],
                  Center(
                    child: asset == null
                        ? Text(
                            product.emoji,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (s * 0.42).clamp(24.0, 128.0),
                              height: 1.1,
                            ),
                          )
                        : Container(
                            width: s * 0.52,
                            height: s * 0.52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.86),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: s * 0.06,
                                  offset: Offset(0, s * 0.015),
                                ),
                              ],
                            ),
                            child: Text(
                              product.emoji,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (s * 0.30).clamp(16.0, 96.0),
                                height: 1.1,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    left: 7,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  if (badge && product.subsidy)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF161616),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '百亿补贴',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFFFD54F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _bubble(double size, {double alpha = 0.12}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.artHeight = 150,
    this.heroTag,
  });

  final Product product;
  final VoidCallback onTap;
  final double artHeight;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final palette = SkinPalette.of(context);
    final gray = TextStyle(color: palette.textTertiary, fontSize: 10);
    final art = ProductArt(product: product, radius: 0);
    return Semantics(
      button: true,
      label:
          '${product.name}，到手价${money(product.price)}元，'
          '${product.store}，已售${product.sold}万件',
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: artHeight,
                  child: heroTag == null
                      ? art
                      : Hero(tag: heroTag!, child: art),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(9, 8, 9, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        runSpacing: 3,
                        children: [
                          for (final tag in product.tags.take(2)) MiniTag(tag),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PriceText(product.price, size: 17),
                          const SizedBox(width: 4),
                          Flexible(child: OrigPrice(product.originalPrice)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (product.selfRun)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                '自营',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              product.store,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: gray,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('已拼${product.sold}万+', style: gray),
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
    );
  }
}

class ProductRowCard extends StatelessWidget {
  const ProductRowCard({
    super.key,
    required this.product,
    required this.onTap,
    this.artSize = 94,
    this.trailing,
  });

  final Product product;
  final VoidCallback onTap;
  final double artSize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final palette = SkinPalette.of(context);
    final gray = TextStyle(fontSize: 10, color: palette.textTertiary);
    return Semantics(
      button: true,
      label:
          '${product.name}，到手价${money(product.price)}元，'
          '${product.store}，已售${product.sold}万件',
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: artSize,
                  height: artSize,
                  child: ProductArt(product: product),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        runSpacing: 3,
                        children: [
                          for (final tag in product.tags.take(2)) MiniTag(tag),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PriceText(product.price, size: 18, color: primary),
                          const SizedBox(width: 5),
                          Flexible(child: OrigPrice(product.originalPrice)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.store,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: gray,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('已售${product.sold}万+', style: gray),
                        ],
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 6), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = SkinPalette.of(context);
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
            ),
          ),
        ],
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Semantics(
              button: true,
              label: '$title：$actionLabel',
              child: Row(
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(fontSize: 11, color: palette.textTertiary),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15,
                    color: palette.textTertiary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class CountdownText extends StatefulWidget {
  const CountdownText({
    super.key,
    required this.target,
    this.prefix = '距结束 ',
    this.style,
  });

  final DateTime target;
  final String prefix;
  final TextStyle? style;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = widget.target.difference(DateTime.now());
    final remain = diff.isNegative ? Duration.zero : diff;
    final text =
        '${two(remain.inHours)}:${two(remain.inMinutes % 60)}:${two(remain.inSeconds % 60)}';
    return Text(
      '${widget.prefix}$text',
      style:
          widget.style ??
          TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class CountdownBoxes extends StatefulWidget {
  const CountdownBoxes({
    super.key,
    required this.target,
    this.background,
    this.foreground = Colors.white,
  });

  final DateTime target;
  final Color? background;
  final Color foreground;

  @override
  State<CountdownBoxes> createState() => _CountdownBoxesState();
}

class _CountdownBoxesState extends State<CountdownBoxes> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = widget.target.difference(DateTime.now());
    final remain = diff.isNegative ? Duration.zero : diff;
    final bg = widget.background ?? Colors.black.withValues(alpha: 0.28);
    Widget box(String value) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          height: 1.1,
          color: widget.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    Widget sep() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: widget.foreground,
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        box(two(remain.inHours)),
        sep(),
        box(two(remain.inMinutes % 60)),
        sep(),
        box(two(remain.inSeconds % 60)),
      ],
    );
  }
}

class ProductMasonry extends StatelessWidget {
  const ProductMasonry({
    super.key,
    required this.products,
    required this.onTap,
    this.tagOf,
  });

  final List<Product> products;
  final void Function(Product) onTap;
  final Object? Function(Product)? tagOf;

  @override
  Widget build(BuildContext context) {
    final left = <Product>[];
    final right = <Product>[];
    var lh = 0.0;
    var rh = 0.0;
    for (final p in products) {
      final artHeight = 142.0 + (p.id % 3) * 24;
      final estimate = artHeight + 92;
      if (lh <= rh) {
        left.add(p);
        lh += estimate;
      } else {
        right.add(p);
        rh += estimate;
      }
    }

    Widget column(List<Product> items) => Column(
      children: [
        for (final p in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProductCard(
              product: p,
              artHeight: 142 + (p.id % 3) * 24,
              heroTag: tagOf?.call(p),
              onTap: () => onTap(p),
            ),
          ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: column(left)),
        const SizedBox(width: 10),
        Expanded(child: column(right)),
      ],
    );
  }
}

void showToast(BuildContext context, String text, {IconData? icon}) {
  final overlay = Overlay.of(context);
  if (_activeToast?.mounted ?? false) {
    _activeToast!.remove();
  }
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ToastView(
      text: text,
      icon: icon,
      onDone: () {
        if (entry.mounted) entry.remove();
        if (_activeToast == entry) _activeToast = null;
      },
    ),
  );
  _activeToast = entry;
  overlay.insert(entry);
}

OverlayEntry? _activeToast;

class _ToastView extends StatefulWidget {
  const _ToastView({required this.text, this.icon, required this.onDone});

  final String text;
  final IconData? icon;
  final VoidCallback onDone;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
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
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final opacity = (t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3)).clamp(
            0.0,
            1.0,
          );
          final scale = (t < 0.15 ? 0.85 + t / 0.15 * 0.15 : 1.0);
          return Align(
            alignment: const Alignment(0, -0.62),
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xEF1A1A1A),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 16),
                  const SizedBox(width: 7),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 在 [trigger] 从 false 变为 true 时播放一次左右抖动。
class ShakeOnce extends StatefulWidget {
  const ShakeOnce({
    super.key,
    required this.trigger,
    required this.child,
    this.enabled = true,
    this.amplitude = 3,
  });

  final bool trigger;
  final Widget child;
  final bool enabled;
  final double amplitude;

  @override
  State<ShakeOnce> createState() => _ShakeOnceState();
}

class _ShakeOnceState extends State<ShakeOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void didUpdateWidget(ShakeOnce oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger && widget.enabled) {
      _controller.forward(from: 0);
    }
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
      builder: (context, child) => Transform.translate(
        offset: Offset(sin(_controller.value * pi * 6) * widget.amplitude, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// 全屏撒花庆祝
void celebrate(
  BuildContext context, {
  String text = '成功',
  String? subtitle,
  IconData icon = Icons.check_circle_rounded,
}) {
  if (!AppState.instance.animationsEnabled) {
    showToast(
      context,
      subtitle == null ? text : '$text · $subtitle',
      icon: icon,
    );
    return;
  }
  Fx.success();
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CelebrationView(
      text: text,
      subtitle: subtitle,
      icon: icon,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _CelebrationView extends StatefulWidget {
  const _CelebrationView({
    required this.text,
    this.subtitle,
    required this.icon,
    required this.onDone,
  });

  final String text;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onDone;

  @override
  State<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<_CelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
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
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final fade = t < 0.72
                ? 1.0
                : (1 - (t - 0.72) / 0.28).clamp(0.0, 1.0);
            final scale = Curves.elasticOut.transform((t * 4).clamp(0.0, 1.0));
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _ConfettiPainter(progress: t)),
                ),
                Center(
                  child: Opacity(
                    opacity: fade,
                    child: Transform.scale(
                      scale: 0.6 + scale * 0.4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary
                                      .withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.text,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Color(0x99000000), blurRadius: 8),
                              ],
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFEEEEEE),
                                shadows: [
                                  Shadow(
                                    color: Color(0x99000000),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static const _colors = [
    Color(0xFFFF3D00),
    Color(0xFFFFD200),
    Color(0xFF7C4DFF),
    Color(0xFF00C6FF),
    Color(0xFF00E676),
    Color(0xFFFF4081),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final rnd = Random(11);
    final paint = Paint();
    for (var i = 0; i < 90; i++) {
      final x = rnd.nextDouble() * size.width;
      final start = -30 - rnd.nextDouble() * size.height * 0.5;
      final speed = 0.9 + rnd.nextDouble() * 0.9;
      final y = start + progress * size.height * 1.6 * speed;
      final w = 4.0 + rnd.nextDouble() * 7;
      final h = 6.0 + rnd.nextDouble() * 8;
      paint.color = _colors[rnd.nextInt(_colors.length)].withValues(
        alpha: (1 - progress).clamp(0.0, 1.0),
      );
      canvas.save();
      canvas.translate(x + sin(progress * 6 + i) * 22, y);
      canvas.rotate(progress * 9 + i);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class StarRow extends StatelessWidget {
  const StarRow({super.key, this.rating = 5, this.size = 11});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: const Color(0xFFFFB300),
          ),
      ],
    );
  }
}
