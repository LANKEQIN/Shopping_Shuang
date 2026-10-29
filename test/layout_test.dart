import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/data.dart';
import 'package:shoping_shuang/models.dart';
import 'package:shoping_shuang/pages/after_sale_page.dart';
import 'package:shoping_shuang/pages/benefits_page.dart';
import 'package:shoping_shuang/pages/cart_page.dart';
import 'package:shoping_shuang/pages/category_page.dart';
import 'package:shoping_shuang/pages/checkout_page.dart';
import 'package:shoping_shuang/pages/cut_price_page.dart';
import 'package:shoping_shuang/pages/favorites_page.dart';
import 'package:shoping_shuang/pages/group_buy_page.dart';
import 'package:shoping_shuang/pages/home_page.dart';
import 'package:shoping_shuang/pages/live_pages.dart';
import 'package:shoping_shuang/pages/lottery_page.dart';
import 'package:shoping_shuang/pages/mine_page.dart';
import 'package:shoping_shuang/pages/orders_page.dart';
import 'package:shoping_shuang/pages/product_page.dart';
import 'package:shoping_shuang/pages/reports_page.dart';
import 'package:shoping_shuang/pages/search_page.dart';
import 'package:shoping_shuang/pages/seckill_page.dart';
import 'package:shoping_shuang/pages/settings_page.dart';
import 'package:shoping_shuang/theme.dart';

import 'helpers.dart';

void main() {
  setUp(() async {
    await initAppState();
  });

  final pages = <String, Widget Function()>{
    'home': () => const HomePage(),
    'search': () => const SearchPage(),
    'product': () => ProductPage(product: prod(1)),
    'cart': () => const CartPage(),
    'checkout': () => CheckoutPage(
      items: [OrderItem(product: prod(1), qty: 1, price: prod(1).price)],
      total: prod(1).price,
    ),
    'orders': () => const OrdersPage(),
    'mine': () => const MinePage(),
    'settings': () => const SettingsPage(),
    'seckill': () => const SeckillPage(),
    'cut': () => const CutPricePage(),
    'lottery': () => const LotteryPage(),
    'liveList': () => const LiveListPage(),
    'liveRoom': () => LiveRoomPage(room: liveRooms.first),
    'benefits': () => const BenefitsPage(),
    'benefitsMember': () => const BenefitsPage(initialTab: 3),
    'groupBuy': () => const GroupBuyPage(),
    'category': () => const CategoryPage(),
    'favorites': () => const FavoritesPage(),
    'reports': () => const ReportsPage(),
    'afterSale': () => const AfterSalePage(),
  };

  final sizes = <Size>[
    const Size(320, 640),
    const Size(360, 780),
    const Size(390, 844),
    const Size(430, 932),
  ];

  for (final size in sizes) {
    for (final scale in <double>[1.0, 1.3]) {
      for (final entry in pages.entries) {
        testWidgets('${entry.key} ${size.width.toInt()}宽 字体$scale 不溢出', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(wrapPage(entry.value()));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        });
      }
    }
  }

  for (final entry in pages.entries) {
    testWidgets('${entry.key} 抖音暗色 390宽 字体1.3 不溢出', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(wrapPage(entry.value(), skin: Skin.douyin));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }

  // 京东自营区 / 拼多多拼单条在窄屏与大字号下的额外检查
  for (final skin in <Skin>[Skin.jd, Skin.pdd]) {
    for (final size in <Size>[const Size(320, 640), const Size(430, 932)]) {
      testWidgets('home ${skin.name} ${size.width.toInt()}宽 字体1.3 不溢出', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(wrapPage(const HomePage(), skin: skin));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      });
    }
  }

  // 横屏与平板基础适配
  for (final size in <Size>[const Size(844, 390), const Size(800, 1280)]) {
    for (final entry in pages.entries) {
      testWidgets(
        '${entry.key} ${size.width.toInt()}×${size.height.toInt()} 不溢出',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(wrapPage(entry.value()));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        },
      );
    }
  }
}
