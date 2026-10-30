import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/data.dart';
import 'package:shoping_shuang/pages/product_page.dart';
import 'package:shoping_shuang/pages/store_page.dart';
import 'package:shoping_shuang/state.dart';
import 'package:shoping_shuang/widgets/pieces.dart';

import 'helpers.dart';

void main() {
  setUp(() async {
    await initAppState();
  });

  testWidgets('店铺页展示店铺档案与店内商品', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final store = prod(1).store;
    final count = AppState.instance.products
        .where((p) => p.store == store)
        .length;
    await tester.pumpWidget(wrapPage(StorePage(store: store)));
    await tester.pump();

    expect(find.text(store), findsWidgets);
    expect(find.text('店铺评分'), findsOneWidget);
    expect(find.text('店铺公告'), findsOneWidget);
    expect(find.text('店内商品 · 共 $count 件'), findsOneWidget);
    expect(find.text('全部'), findsOneWidget);
  });

  testWidgets('关注店铺可切换并写入状态', (tester) async {
    final store = prod(1).store;
    await tester.pumpWidget(wrapPage(StorePage(store: store)));
    await tester.pump();

    expect(AppState.instance.isStoreFollowed(store), isFalse);
    await tester.tap(find.text('关注'));
    await tester.pump();

    expect(AppState.instance.isStoreFollowed(store), isTrue);
    expect(find.text('已关注'), findsOneWidget);

    await tester.tap(find.text('已关注'));
    await tester.pump();

    expect(AppState.instance.isStoreFollowed(store), isFalse);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('关注'), findsOneWidget);
  });

  testWidgets('点击店内商品进入商品详情', (tester) async {
    await tester.pumpWidget(wrapPage(StorePage(store: prod(1).store)));
    await tester.pump();

    final card = find.byType(ProductCard).first;
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ProductPage), findsOneWidget);
  });
}
