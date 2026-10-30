import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/data.dart';
import 'package:shoping_shuang/models.dart';
import 'package:shoping_shuang/state.dart';
import 'package:shoping_shuang/storage.dart';
import 'package:shoping_shuang/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('首次启动写入种子数据', () async {
    final storage = MemoryStorage();
    await AppState.instance.init(storage: storage);

    expect(AppState.instance.cart.length, 2);
    expect(AppState.instance.orders.length, 3);
    expect(AppState.instance.skin, Skin.taobao);
    expect(await storage.read(AppState.storageKey), isNotNull);
  });

  test('购物车/订单/皮肤/历史/优惠券/设置可在重启后恢复', () async {
    final storage = MemoryStorage();
    await AppState.instance.init(storage: storage);

    AppState.instance.setSkin(Skin.douyin);
    AppState.instance.addToCart(prod(70), qty: 3);
    AppState.instance.addCoupons(2);
    AppState.instance.pushHistory('测试关键词');
    AppState.instance.setSoundsEnabled(false);
    AppState.instance.setFollowedLive(true);
    AppState.instance.toggleStoreFollowed(prod(1).store);
    final order = AppState.instance.createOrder([
      OrderItem(product: prod(1), qty: 1, price: prod(1).price),
    ], prod(1).price);
    await AppState.instance.flush();

    // 重新读取本地快照，模拟杀进程后重启
    await AppState.instance.init(storage: storage);

    expect(AppState.instance.skin, Skin.douyin);
    expect(AppState.instance.coupons, 8);
    expect(AppState.instance.soundsEnabled, isFalse);
    expect(AppState.instance.followedLive, isTrue);
    expect(AppState.instance.isStoreFollowed(prod(1).store), isTrue);
    expect(AppState.instance.searchHistory.first, '测试关键词');
    final restored = AppState.instance.cart
        .where((e) => e.product.id == 70)
        .toList();
    expect(restored, hasLength(1));
    expect(restored.first.qty, 3);
    expect(AppState.instance.orders.any((o) => o.id == order.id), isTrue);
    expect(
      AppState.instance.orders.firstWhere((o) => o.id == order.id).status,
      OrderStatus.pendingShip,
    );
  });

  test('损坏 JSON 安全回退到默认种子数据', () async {
    final storage = MemoryStorage({AppState.storageKey: '{broken json'});
    await AppState.instance.init(storage: storage);

    expect(AppState.instance.cart.length, 2);
    expect(AppState.instance.orders.length, 3);
    expect(AppState.instance.skin, Skin.taobao);
  });

  test('无版本号的旧数据可迁移并补齐默认字段', () async {
    final storage = MemoryStorage({
      AppState.storageKey: jsonEncode({
        'skin': 'jd',
        'cart': [
          {'pid': 48, 'qty': 1, 'selected': true},
        ],
        'history': ['旧关键词'],
        'coupons': 3,
      }),
    });
    await AppState.instance.init(storage: storage);

    expect(AppState.instance.skin, Skin.jd);
    expect(AppState.instance.cart, hasLength(1));
    expect(AppState.instance.searchHistory, ['旧关键词']);
    expect(AppState.instance.coupons, 3);
    expect(AppState.instance.animationsEnabled, isTrue);
    expect(AppState.instance.isStoreFollowed(prod(1).store), isFalse);
    expect(AppState.instance.orders, isEmpty);
  });

  test('清除本地数据恢复首次启动状态', () async {
    final storage = MemoryStorage();
    await AppState.instance.init(storage: storage);

    AppState.instance.setSkin(Skin.douyin);
    AppState.instance.cart.clear();
    AppState.instance.orders.clear();
    AppState.instance.addCoupons(5);
    await AppState.instance.flush();

    await AppState.instance.resetAll();

    expect(AppState.instance.skin, Skin.taobao);
    expect(AppState.instance.cart.length, 2);
    expect(AppState.instance.orders.length, 3);
    expect(AppState.instance.coupons, 6);
    expect(await storage.read(AppState.storageKey), isNotNull);
  });
}
