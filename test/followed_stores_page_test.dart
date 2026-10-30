import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/pages/category_page.dart';
import 'package:shoping_shuang/pages/followed_stores_page.dart';
import 'package:shoping_shuang/pages/store_page.dart';
import 'package:shoping_shuang/state.dart';

import 'helpers.dart';

void main() {
  setUp(() async {
    await initAppState();
  });

  /// 取两家不同的店铺并关注，返回店铺名列表。
  Future<List<String>> followTwoStores() async {
    final stores = <String>[];
    for (final p in AppState.instance.products) {
      if (stores.length >= 2) break;
      if (!stores.contains(p.store)) stores.add(p.store);
    }
    AppState.instance.toggleStoreFollowed(stores[0]);
    AppState.instance.toggleStoreFollowed(stores[1]);
    await AppState.instance.flush();
    return stores;
  }

  testWidgets('关注店铺列表在窄屏大字号下展示并可取关', (tester) async {
    final stores = await followTwoStores();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(wrapPage(const FollowedStoresPage()));
    await tester.pump();

    expect(find.text(stores[0]), findsOneWidget);
    expect(find.text(stores[1]), findsOneWidget);
    expect(find.text('已关注'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('已关注').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(AppState.instance.isStoreFollowed(stores[0]), isFalse);
    expect(find.text(stores[0]), findsNothing);
    expect(find.text(stores[1]), findsOneWidget);

    await tester.tap(find.text('已关注').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('还没有关注的店铺'), findsOneWidget);
  });

  testWidgets('点击关注的店铺可进入店铺主页', (tester) async {
    final stores = await followTwoStores();
    await tester.pumpWidget(wrapPage(const FollowedStoresPage()));
    await tester.pump();

    await tester.tap(find.text(stores[0]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(StorePage), findsOneWidget);
    expect(find.text(stores[0]), findsWidgets);
  });

  testWidgets('空状态可跳转去逛逛', (tester) async {
    await tester.pumpWidget(wrapPage(const FollowedStoresPage()));
    await tester.pump();

    expect(find.text('还没有关注的店铺'), findsOneWidget);
    await tester.tap(find.text('去逛逛'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CategoryPage), findsOneWidget);
  });
}
