import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/data.dart';
import 'package:shoping_shuang/models.dart';
import 'package:shoping_shuang/services/cart_service.dart';
import 'package:shoping_shuang/services/coupon_service.dart';
import 'package:shoping_shuang/services/order_service.dart';
import 'package:shoping_shuang/services/play_service.dart';
import 'package:shoping_shuang/services/user_service.dart';

void main() {
  group('CartService', () {
    test('重复加购合并条目，数量与勾选状态正确', () {
      final cart = CartService();
      cart.addToCart(prod(1));
      cart.addToCart(prod(1), qty: 2);
      expect(cart.cart, hasLength(1));
      expect(cart.cart.first.qty, 3);
      expect(cart.cartCount, 3);
      expect(cart.allSelected, isTrue);

      cart.toggleSelected(cart.cart.first);
      expect(cart.selectedEntries, isEmpty);
      expect(cart.selectedTotal, 0);

      cart.setAllSelected(true);
      expect(cart.selectedTotal, closeTo(prod(1).price * 3, 0.001));
    });

    test('数量下限与上限被限制在 1–99', () {
      final cart = CartService();
      cart.addToCart(prod(2));
      cart.changeQty(cart.cart.first, -5);
      expect(cart.cart.first.qty, 1);
      cart.changeQty(cart.cart.first, 200);
      expect(cart.cart.first.qty, 99);
    });

    test('加购触发每日任务回调，移除已购条目', () {
      var added = 0;
      final cart = CartService()..onItemAdded = () => added++;
      cart.addToCart(prod(3));
      expect(added, 1);
      cart.removePurchased(cart.cart.toList());
      expect(cart.cart, isEmpty);
    });

    test('购物车序列化可往返恢复', () {
      final cart = CartService()
        ..addToCart(prod(2))
        ..addToCart(prod(1), qty: 2);
      cart.cart.first.selected = false;
      final restored = CartService()
        ..restoreFrom(cart.toJson(), (id) => prod(id));
      expect(restored.cart, hasLength(2));
      expect(restored.cart.first.product.id, 1);
      expect(restored.cart.first.qty, 2);
      expect(restored.cart.first.selected, isFalse);
      expect(restored.cart.last.product.id, 2);
    });
  });

  group('CouponService', () {
    test('领券、选最优券与核销计数', () {
      final coupons = CouponService();
      coupons.addOffer('c59');
      coupons.addOffer('c199');
      expect(coupons.coupons, 2);
      final best = coupons.bestCouponFor(200);
      expect(best, isNotNull);
      expect(best!.amount, 20);
      expect(coupons.consumeCoupon(best), isTrue);
      expect(coupons.couponsUsed, 1);
      expect(coupons.couponWallet, hasLength(1));
      expect(coupons.consumeCoupon(best), isFalse);
    });

    test('旧版券数量迁移为通用券', () {
      final coupons = CouponService()
        ..restoreFrom({'coupons': 3, 'couponsUsed': 2});
      expect(coupons.couponWallet, hasLength(3));
      expect(coupons.coupons, 3);
      expect(coupons.couponsUsed, 2);
      expect(coupons.couponWallet.first.source, '旧版数据迁移');
    });
  });

  group('OrderService', () {
    test('下单触发奖励回调，免单标记正确', () {
      final orders = OrderService();
      final placed = <bool>[];
      orders.onOrderPlaced = (order, free) => placed.add(free);
      orders.createOrder([
        OrderItem(product: prod(1), qty: 1, price: prod(1).price),
      ], prod(1).price);
      orders.createFreeOrder(prod(2));
      expect(placed, [false, true]);
      expect(orders.orders, hasLength(2));
      expect(orders.freeOrderCount, 1);
      expect(orders.paidOrderCount, 2);
    });

    test('待付款超时取消并拒绝支付', () {
      final orders = OrderService();
      final expired = Order(
        id: 'LATE',
        items: [OrderItem(product: prod(1), qty: 1, price: 1)],
        total: 1,
        time: DateTime.now(),
        status: OrderStatus.pendingPay,
        payDeadline: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      orders.orders.add(expired);
      expect(orders.payOrder(expired), isFalse);
      expect(expired.status, OrderStatus.cancelled);
    });

    test('退款回调金额，并写入售后与发票记录', () {
      final orders = OrderService();
      var refunded = 0.0;
      orders.onRefunded = (amount) => refunded = amount;
      final order = orders.createOrder([
        OrderItem(product: prod(14), qty: 1, price: prod(14).price),
      ], prod(14).price);
      final record = orders.requestAfterSale(order, reason: '测试退款');
      expect(refunded, order.total);
      expect(record.orderId, order.id);
      expect(order.status, OrderStatus.refunded);

      orders.requestInvoice(order, title: '单位');
      expect(orders.hasInvoice(order.id), isTrue);
      expect(orders.invoices.first.title, '单位');
    });

    test('订单序列化可往返恢复', () {
      final orders = OrderService()
        ..createOrder([
          OrderItem(product: prod(23), qty: 2, price: prod(23).price),
        ], prod(23).price * 2);
      final restored = OrderService()
        ..restoreFrom(orders.toJson(), (id) => prod(id));
      expect(restored.orders, hasLength(1));
      expect(restored.orders.first.items.first.qty, 2);
      expect(restored.orders.first.status, OrderStatus.pendingShip);
    });
  });

  group('UserService', () {
    test('下单奖励成长值与积分', () {
      final user = UserService();
      final points = user.points;
      final reward = (199 / 10).round() + 5;
      user.rewardOrder(199);
      expect(user.growth, 199);
      expect(user.points, points + reward);
      expect(user.dailyProgress['order'], 1);

      user.rewardOrder(0, free: true);
      expect(user.points, points + reward + 10);
      expect(user.growth, 199 + 5);
    });

    test('签到、每日领取与任务领取幂等', () {
      final user = UserService();
      expect(user.markCheckedInToday(), isTrue);
      expect(user.checkedInToday, isTrue);
      expect(user.checkInStreak, 1);
      expect(user.markCheckedInToday(), isFalse);

      expect(user.claimDaily('offer:c99'), isTrue);
      expect(user.claimDaily('offer:c99'), isFalse);

      user.setDailyProgress('checkIn', 1);
      final task = dailyTasks.first;
      expect(user.taskClaimable(task), isTrue);
      final points = user.points;
      expect(user.claimTask(task), isTrue);
      expect(user.points, points + task.points);
      expect(user.claimTask(task), isFalse);
    });

    test('积分不足时不能兑换', () {
      final user = UserService();
      expect(user.spendPoints(user.points + 1), isFalse);
      expect(user.points, 666);
    });

    test('收藏、足迹与评价进入每日统计', () {
      final user = UserService();
      expect(user.toggleFavorite(11), isTrue);
      expect(user.isFavorite(11), isTrue);
      expect(user.toggleFavorite(11), isFalse);

      user.recordFootprint(prod(1));
      expect(user.dailyProgress['browse'], 1);
      user.addReview(
        ProductReview(
          id: 'R1',
          productId: 1,
          nickname: user.nickname,
          emoji: '🌸',
          rating: 5,
          text: '测试评价',
          tags: const [],
          time: DateTime.now(),
        ),
      );
      expect(user.reviewsFor(1), hasLength(1));
      expect(user.dailyProgress['review'], 1);
    });
  });

  group('PlayService', () {
    test('拼团成团后回调订单创建', () {
      final play = PlayService()..productResolver = prod;
      Product? grouped;
      double? groupedPrice;
      play.onGroupSuccess = (product, price) {
        grouped = product;
        groupedPrice = price;
      };
      final group = play.startGroup(prod(55));
      var guard = 0;
      while (group.status == GroupStatus.forming && guard < 100) {
        play.inviteGroupFriend(group);
        guard++;
      }
      expect(group.status, GroupStatus.success);
      expect(grouped?.id, 55);
      expect(groupedPrice, closeTo(prod(55).price * 0.88, 0.01));
    });

    test('砍价最后一元保底并回调免单', () {
      final play = PlayService()..productResolver = prod;
      Product? freeProduct;
      play.onCutSuccess = (product) => freeProduct = product;
      play.ensureCutRecord(prod(10));
      var guard = 0;
      while (play.cutRecord!.done == false && guard < 300) {
        play.cutOnce();
        guard++;
      }
      expect(play.cutRecord!.remaining, 0);
      expect(play.cutSuccessCount, 1);
      expect(freeProduct?.id, 10);
    });

    test('抽奖达到保底次数必定返回免单', () {
      final play = PlayService();
      // 权重只落在非免单格子，前 4 次必定落空，第 5 次触发保底。
      const weights = [0, 100, 0];
      var index = 1;
      for (var i = 0; i < 5; i++) {
        index = play.rollLottery(weights, 0, pityLimit: 5);
      }
      expect(index, 0);
      expect(play.lotteryCount, 5);
      expect(play.lotteryMissStreak, 0);
    });
  });
}
