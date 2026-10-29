import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shoping_shuang/main.dart';
import 'package:shoping_shuang/models.dart';
import 'package:shoping_shuang/state.dart';
import 'package:shoping_shuang/storage.dart';
import 'package:shoping_shuang/widgets/pieces.dart';

/// 端到端回归：浏览 → 加购 → 用券 → 支付 → 订单 → 退款。
///
/// 需要真机或模拟器运行：
/// `flutter test integration_test/app_test.dart -d <deviceId>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('浏览 → 用券 → 支付 → 退款 端到端', (tester) async {
    await AppState.instance.init(storage: MemoryStorage());
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ShuangGouApp());
    await tester.pumpAndSettle();

    // 1. 浏览：从首页搜索进入商品详情
    await tester.tap(find.bySemanticsLabel('搜索商品'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'iPhone');
    await tester.tap(find.text('搜索'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ProductRowCard).first);
    await tester.pumpAndSettle();
    expect(find.text('商品详情'), findsOneWidget);

    // 2. 加购
    final cartBefore = AppState.instance.cartCount;
    await tester.tap(find.text('加入购物车'));
    await tester.pump(const Duration(milliseconds: 900));
    expect(AppState.instance.cartCount, greaterThan(cartBefore));

    // 3. 回到首页后进入购物车结算
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_cart_outlined).last);
    await tester.pumpAndSettle();

    final couponsBefore = AppState.instance.coupons;
    await tester.tap(find.textContaining('结算('));
    await tester.pumpAndSettle();
    expect(find.text('确认订单'), findsOneWidget);
    // 自动选中满 99 减 10 的券
    expect(find.textContaining('满 99 减 10'), findsOneWidget);

    // 4. 提交订单并模拟支付
    final ordersBefore = AppState.instance.orders.length;
    await tester.tap(find.text('提交订单'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认支付（假装密码 123456）'));
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
    expect(AppState.instance.orders.length, ordersBefore + 1);
    expect(AppState.instance.coupons, couponsBefore - 1);

    // 5. 查看订单并申请退款
    await tester.tap(find.text('查看订单'));
    await tester.pumpAndSettle();
    expect(find.text('我的订单'), findsWidgets);

    final order = AppState.instance.orders.first;
    final balanceBefore = AppState.instance.balance;
    await tester.tap(find.text('申请退款').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('提交退款申请'));
    await tester.pumpAndSettle();

    expect(order.status, OrderStatus.refunded);
    expect(
      AppState.instance.balance,
      closeTo(balanceBefore + order.total, 0.01),
    );
    expect(AppState.instance.afterSales.first.orderId, order.id);

    await tester.pump(const Duration(seconds: 3));
  });
}
