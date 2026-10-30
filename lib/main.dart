import 'dart:math';

import 'package:flutter/material.dart';

import 'pages/cart_page.dart';
import 'pages/home_page.dart';
import 'pages/live_pages.dart';
import 'pages/mine_page.dart';
import 'state.dart';
import 'storage.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.init(storage: SharedPrefsStorage());
  AppLifecycleListener(
    onPause: AppState.instance.flush,
    onDetach: AppState.instance.flush,
  );
  runApp(const ShuangGouApp());
}

class ShuangGouApp extends StatelessWidget {
  const ShuangGouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Skin>(
      valueListenable: AppState.instance.skinNotifier,
      builder: (context, skin, _) {
        return MaterialApp(
          title: '爽购 · 解压模拟商城',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(skin),
          builder: (context, child) => _phoneFrame(context, child),
          home: const RootShell(),
        );
      },
    );
  }
}

/// 在宽屏浏览器里把 App 装进一个手机框，保证观感与手机一致。
Widget _phoneFrame(BuildContext context, Widget? child) {
  if (child == null) return const SizedBox.shrink();
  final media = MediaQuery.of(context);
  if (media.size.width <= 560) return child;

  final height = min(media.size.height - 32, 860.0);
  final width = min(media.size.width - 32, 400.0);
  return ColoredBox(
    color: const Color(0xFF15151B),
    child: Center(
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 40,
              spreadRadius: 6,
            ),
          ],
        ),
        child: MediaQuery(
          data: media.copyWith(
            size: Size(width, height),
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: child,
        ),
      ),
    ),
  );
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _labels = ['首页', '直播', '购物车', '我的'];
  static const _icons = [
    (Icons.home_rounded, Icons.home_outlined),
    (Icons.live_tv_rounded, Icons.live_tv_outlined),
    (Icons.shopping_cart_rounded, Icons.shopping_cart_outlined),
    (Icons.person_rounded, Icons.person_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ValueListenableBuilder<Skin>(
      valueListenable: app.skinNotifier,
      builder: (context, skin, _) {
        final cfg = skinOf(skin);
        final palette = paletteOf(context);
        return Scaffold(
          backgroundColor: palette.pageBg,
          body: IndexedStack(
            index: _index,
            children: const [
              HomePage(),
              LiveListPage(),
              CartPage(),
              MinePage(),
            ],
          ),
          bottomNavigationBar: ListenableBuilder(
            listenable: app,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  color: cfg.navBg,
                  border: Border(
                    top: BorderSide(
                      color: cfg.darkHeader
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        for (var i = 0; i < 4; i++)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: _index == i,
                              label: i == 2 && app.cartCount > 0
                                  ? '${_labels[i]}，${app.cartCount}件'
                                  : _labels[i],
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => _index = i),
                                child: ExcludeSemantics(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Icon(
                                            _index == i
                                                ? _icons[i].$1
                                                : _icons[i].$2,
                                            size: 22,
                                            color: _index == i
                                                ? cfg.primary
                                                : cfg.navFg,
                                          ),
                                          if (i == 1)
                                            Positioned(
                                              right: -3,
                                              top: -2,
                                              child: Container(
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  color: cfg.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          if (i == 2 && app.cartCount > 0)
                                            Positioned(
                                              right: -10,
                                              top: -6,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 1,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: cfg.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${app.cartCount}',
                                                  style: const TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _labels[i],
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: _index == i
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: _index == i
                                              ? cfg.primary
                                              : cfg.navFg,
                                        ),
                                      ),
                                    ],
                                  ),
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
        );
      },
    );
  }
}
