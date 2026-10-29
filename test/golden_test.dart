import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/data.dart';
import 'package:shoping_shuang/pages/cart_page.dart';
import 'package:shoping_shuang/pages/category_page.dart';
import 'package:shoping_shuang/pages/mine_page.dart';
import 'package:shoping_shuang/pages/product_page.dart';
import 'package:shoping_shuang/pages/settings_page.dart';

import 'helpers.dart';

/// 关键页面的 golden 基线。
///
/// 基线在 Windows + Flutter 3.47 环境生成，CI 使用 windows-latest 保持一致；
/// 页面内不包含倒计时与随机动画，避免时间相关的像素漂移。
void main() {
  setUp(() async {
    await initAppState();
  });

  final pages = <String, Widget Function()>{
    'product': () => ProductPage(product: prod(1)),
    'cart': () => const CartPage(),
    'mine': () => const MinePage(),
    'settings': () => const SettingsPage(),
    'category': () => const CategoryPage(),
  };

  for (final entry in pages.entries) {
    testWidgets('${entry.key} 390×844 golden', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrapPage(entry.value()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${entry.key}.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
}
