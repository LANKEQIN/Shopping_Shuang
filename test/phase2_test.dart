import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/data.dart';
import 'package:shoping_shuang/models.dart';
import 'package:shoping_shuang/pages/benefits_page.dart';
import 'package:shoping_shuang/pages/checkout_page.dart';
import 'package:shoping_shuang/state.dart';
import 'package:shoping_shuang/storage.dart';
import 'package:shoping_shuang/theme.dart';

import 'helpers.dart';

void main() {
  setUp(() async {
    await initAppState();
  });

  test('签到与领券形成每日闭环', () async {
    final app = AppState.instance;
    expect(app.coupons, 6);
    expect(app.checkedInToday, isFalse);

    final first = app.checkInToday();
    expect(first.ok, isTrue);
    expect(first.reward, isNotNull);
    expect(app.checkedInToday, isTrue);
    expect(app.points, greaterThan(666));
    expect(app.checkInStreak, 1);

    expect(app.checkInToday().ok, isFalse);

    final before = app.coupons;
    expect(app.claimCouponOffer('c199'), isTrue);
    expect(app.coupons, before + 1);
    expect(app.claimCouponOffer('c199'), isFalse);
  });

  test('最佳优惠券选择与核销', () async {
    final app = AppState.instance;
    final coupon = app.bestCouponFor(120);
    expect(coupon, isNotNull);
    expect(coupon!.amount, 10);

    app.consumeCoupon(coupon);
    expect(app.coupons, 5);
    expect(app.couponsUsed, 1);
    expect(app.bestCouponFor(120), isNotNull);
  });

  test('拼团可成团并自动生成订单', () async {
    final app = AppState.instance;
    final before = app.orders.length;
    final group = app.startGroup(prod(55));
    expect(group.joined, 1);
    expect(group.status, GroupStatus.forming);

    var guard = 0;
    while (group.status == GroupStatus.forming && guard < 60) {
      app.inviteGroupFriend(group);
      guard++;
    }
    expect(group.status, GroupStatus.success);
    expect(group.joined, 2);
    expect(app.orders.length, before + 1);
    expect(app.groupSuccessCount, greaterThanOrEqualTo(1));
  });

  test('砍价最后一刀有保底并生成免单订单', () async {
    final app = AppState.instance;
    final record = app.ensureCutRecord(prod(10));
    expect(record.remaining, prod(10).price);

    var guard = 0;
    while (app.cutRecord!.done == false && guard < 200) {
      app.cutOnce();
      guard++;
    }
    expect(app.cutRecord!.done, isTrue);
    expect(app.cutRecord!.remaining, 0);
    expect(app.cutSuccessCount, 1);
    expect(
      app.orders.any(
        (o) => o.freeOrder && o.items.first.product.id == 10,
      ),
      isTrue,
    );
  });

  test('抽奖保底机制必定触发免单', () async {
    final app = AppState.instance;
    const weights = [1, 14, 20, 3, 22, 12, 13, 15];
    var free = false;
    for (var i = 0; i < app.lotteryPityLimit; i++) {
      final index = app.rollLottery(weights, 0);
      if (index == 0) free = true;
    }
    expect(app.lotteryCount, app.lotteryPityLimit);
    expect(free, isTrue);
  });

  test('收藏 / 足迹 / 评价 / 问答 / 任务', () async {
    final app = AppState.instance;
    expect(app.toggleFavorite(11), isTrue);
    expect(app.isFavorite(11), isTrue);
    expect(app.favoriteProducts.any((p) => p.id == 11), isTrue);
    expect(app.toggleFavorite(11), isFalse);

    app.recordFootprint(prod(1));
    expect(app.footprintProducts.first.id, 1);
    expect(app.todayBrowsed.contains(1), isTrue);

    app.addReview(
      ProductReview(
        id: 'RTEST',
        productId: 1,
        nickname: app.nickname,
        emoji: '🌸',
        rating: 5,
        text: '测试评价',
        tags: const [],
        time: DateTime.now(),
      ),
    );
    expect(app.reviewsFor(1).length, 1);
    expect(app.dailyProgress['review'], 1);

    app.addQuestion(1, '会掉色吗');
    expect(app.questionsFor(1).length, 1);

    app.checkInToday();
    expect(app.taskClaimable(dailyTasks.first), isTrue);
    final points = app.points;
    expect(app.claimTask(dailyTasks.first), isTrue);
    expect(app.points, points + dailyTasks.first.points);
    expect(app.claimTask(dailyTasks.first), isFalse);
  });

  test('待付款超时取消，售后与发票记录闭环', () async {
    final app = AppState.instance;
    final expired = Order(
      id: 'EXPIRE-TEST',
      items: [
        OrderItem(product: prod(1), qty: 1, price: 1),
      ],
      total: 1,
      time: DateTime.now(),
      status: OrderStatus.pendingPay,
      payDeadline: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    app.orders.add(expired);
    expect(app.expirePendingOrders(), 1);
    expect(expired.status, OrderStatus.cancelled);

    final order = app.createOrder([
      OrderItem(product: prod(14), qty: 1, price: prod(14).price),
    ], prod(14).price);
    expect(order.status, OrderStatus.pendingShip);

    final after = app.requestAfterSale(order, reason: '测试退款');
    expect(order.status, OrderStatus.refunded);
    expect(app.afterSales.first.id, after.id);
    expect(after.status, AfterSaleStatus.processing);
    app.completeAfterSale(after);
    expect(after.status, AfterSaleStatus.done);

    app.requestInvoice(order);
    expect(app.hasInvoice(order.id), isTrue);
    expect(app.invoices.first.orderId, order.id);
  });

  test('阶段二字段可跨重启恢复', () async {
    final storage = MemoryStorage();
    await AppState.instance.init(storage: storage);
    final app = AppState.instance;

    app.checkInToday();
    app.toggleFavorite(11);
    app.startGroup(prod(50));
    app.ensureCutRecord(prod(10));
    app.cutOnce();
    app.addReview(
      ProductReview(
        id: 'RPERSIST',
        productId: 11,
        nickname: app.nickname,
        emoji: '🌸',
        rating: 4,
        text: '持久化评价',
        tags: const [],
        time: DateTime.now(),
      ),
    );
    app.addQuestion(11, '能包邮吗');
    app.rollLottery(const [1, 14, 20, 3, 22, 12, 13, 15], 0);
    app.toggleSeckillReminder(1);
    app.requestInvoice(app.orders.first);
    await app.flush();

    await app.init(storage: storage);
    expect(app.favorites.contains(11), isTrue);
    expect(app.checkInDates, hasLength(1));
    expect(app.cutRecord, isNotNull);
    expect(app.cutRecord!.cuts, isNotEmpty);
    expect(app.myReviews.any((r) => r.id == 'RPERSIST'), isTrue);
    expect(app.myQuestions.any((q) => q.productId == 11), isTrue);
    expect(app.seckillReminders.contains(1), isTrue);
    expect(app.invoices, isNotEmpty);
    expect(app.groupBuys.length, greaterThanOrEqualTo(2));
    expect(app.lotteryCount, 1);
    expect(app.points, greaterThan(666));
  });

  test('v1 数据迁移后保留券数量并补齐新字段', () async {
    final storage = MemoryStorage({
      AppState.storageKey: jsonEncode({
        'version': 1,
        'skin': 'jd',
        'cart': [
          {'pid': 48, 'qty': 1, 'selected': true},
        ],
        'orders': <Object>[],
        'history': ['旧关键词'],
        'coupons': 3,
        'coins': 8888,
        'balance': 9999,
        'nickname': '幽幽子大人',
        'followedLive': false,
        'settings': {'animations': true, 'haptics': true, 'sounds': true},
      }),
    });
    await AppState.instance.init(storage: storage);
    final app = AppState.instance;
    expect(app.skin, Skin.jd);
    expect(app.coupons, 3);
    expect(app.points, 666);
    expect(app.lotteryCount, 0);
    expect(app.cutRecord, isNull);
    expect(app.favorites, isEmpty);
  });

  testWidgets('结算自动选券并在支付后核销', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final app = AppState.instance;
    final before = app.coupons;
    await tester.pumpWidget(
      wrapPage(
        CheckoutPage(
          items: [
            OrderItem(product: prod(1), qty: 1, price: prod(1).price),
          ],
          total: prod(1).price,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('满 99 减 10'), findsOneWidget);

    await tester.tap(find.text('提交订单'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认支付（假装密码 123456）'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(const Duration(milliseconds: 600));

    expect(app.coupons, before - 1);
    expect(app.couponsUsed, 1);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('福利中心签到按钮生效', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrapPage(const BenefitsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('立即签到'));
    await tester.pump();

    expect(AppState.instance.checkedInToday, isTrue);
    expect(find.text('今日已签到'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
