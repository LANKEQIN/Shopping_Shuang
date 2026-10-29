import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'state.dart';

/// 统一的触觉与音效反馈入口，受「设置」里的开关控制。
abstract final class Fx {
  static void tap() => _play(FxKind.tap);

  static void addCart() => _play(FxKind.addCart);

  static void success() => _play(FxKind.success);

  static void deal() => _play(FxKind.deal);

  static void spin() => _play(FxKind.spin);

  static void _play(FxKind kind) {
    final app = AppState.instance;
    if (app.hapticsEnabled) {
      switch (kind) {
        case FxKind.tap:
        case FxKind.spin:
          HapticFeedback.selectionClick();
        case FxKind.addCart:
          HapticFeedback.lightImpact();
        case FxKind.deal:
          HapticFeedback.mediumImpact();
        case FxKind.success:
          HapticFeedback.heavyImpact();
      }
    }
    if (app.soundsEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}

enum FxKind { tap, addCart, success, deal, spin }

/// 加购飞入购物车动画：从触发位置抛物线飞向底部购物车图标。
void flyToCart(BuildContext context, Product product, {Offset? target}) {
  if (!AppState.instance.animationsEnabled) return;
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return;
  final overlay = Overlay.of(context, rootOverlay: true);
  final size = MediaQuery.of(context).size;
  final start = box.localToGlobal(box.size.center(Offset.zero));
  final end = target ?? Offset(size.width * 0.625, size.height - 42);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _FlyingProduct(
      start: start,
      end: end,
      emoji: product.emoji,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _FlyingProduct extends StatefulWidget {
  const _FlyingProduct({
    required this.start,
    required this.end,
    required this.emoji,
    required this.onDone,
  });

  final Offset start;
  final Offset end;
  final String emoji;
  final VoidCallback onDone;

  @override
  State<_FlyingProduct> createState() => _FlyingProductState();
}

class _FlyingProductState extends State<_FlyingProduct>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
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
    final control = Offset(
      (widget.start.dx + widget.end.dx) / 2,
      math.min(widget.start.dy, widget.end.dy) - 140,
    );
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInCubic.transform(_controller.value);
            final one = 1 - t;
            final x =
                one * one * widget.start.dx +
                2 * one * t * control.dx +
                t * t * widget.end.dx;
            final y =
                one * one * widget.start.dy +
                2 * one * t * control.dy +
                t * t * widget.end.dy;
            final scale = 1 - 0.72 * t;
            final opacity = t < 0.85 ? 1.0 : (1 - (t - 0.85) / 0.15);
            return Stack(
              children: [
                Positioned(
                  left: x - 22,
                  top: y - 22,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
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
