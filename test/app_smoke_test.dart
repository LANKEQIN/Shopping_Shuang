import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/main.dart';
import 'package:shoping_shuang/pages/mine_page.dart';
import 'package:shoping_shuang/state.dart';
import 'package:shoping_shuang/theme.dart';
import 'package:shoping_shuang/widgets/pieces.dart';

import 'helpers.dart';

void main() {
  setUp(() async {
    await initAppState();
  });

  testWidgets('浏览 → 加购 → 结算 → 支付 → 订单 主流程', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ShuangGouApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('猜你喜欢'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('猜你喜欢'), findsOneWidget);

    // 继续下滑到瀑布流首件商品，进入商品详情
    final card = find.byType(ProductCard).first;
    await tester.scrollUntilVisible(
      card,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.text('商品详情'), findsOneWidget);

    // 加购
    final cartBefore = AppState.instance.cartCount;
    await tester.tap(find.text('加入购物车'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(AppState.instance.cartCount, greaterThan(cartBefore));
    expect(find.text('已加入购物车，钱包毫无波动'), findsOneWidget);

    // 返回首页，进入购物车
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_cart_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('全选'), findsOneWidget);

    // 结算
    await tester.tap(find.textContaining('结算('));
    await tester.pumpAndSettle();
    expect(find.text('确认订单'), findsOneWidget);

    await tester.tap(find.text('提交订单'));
    await tester.pumpAndSettle();
    expect(find.text('收银台'), findsOneWidget);

    // 假支付
    final ordersBefore = AppState.instance.orders.length;
    await tester.tap(find.text('确认支付（假装密码 123456）'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(const Duration(milliseconds: 600));
    expect(AppState.instance.orders.length, ordersBefore + 1);
    expect(find.text('支付成功'), findsWidgets);

    // 撒花动画结束后卸载，避免遗留定时器
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('我的 → 设置：动效/触觉/音效开关生效', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ShuangGouApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    expect(find.byType(MinePage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsOneWidget);

    expect(AppState.instance.animationsEnabled, isTrue);
    await tester.tap(find.text('动效'));
    await tester.pump();
    expect(AppState.instance.animationsEnabled, isFalse);

    await tester.tap(find.text('音效'));
    await tester.pump();
    expect(AppState.instance.soundsEnabled, isFalse);

    // 等待持久化防抖计时器触发
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('皮肤切换为抖音后主要页面不抛异常', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    AppState.instance.setSkin(Skin.douyin);
    await tester.pumpWidget(const ShuangGouApp());
    await tester.pumpAndSettle();

    expect(find.text('爽购抖'), findsOneWidget);

    await tester.tap(find.text('购物车').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
