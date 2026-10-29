import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data.dart';
import '../models.dart';

/// 优惠券钱包：领取、选择、核销与持久化。
class CouponService extends ChangeNotifier {
  final List<Coupon> couponWallet = [];
  int couponsUsed = 0;

  final Random _rnd = Random();

  int get coupons => couponWallet.where((c) => !c.expired).length;

  List<Coupon> get validCoupons =>
      couponWallet.where((c) => !c.expired).toList();

  Coupon _couponFromOffer(String offerId, {String? source}) {
    final offer = couponOfferOf(offerId);
    return Coupon(
      id: 'CP${DateTime.now().microsecondsSinceEpoch}${_rnd.nextInt(999)}',
      title: offer.title,
      threshold: offer.threshold,
      amount: offer.amount,
      source: source ?? offer.source,
      emoji: offer.emoji,
      expireAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// 领取一张券模板，返回写入钱包的券。
  Coupon addOffer(String offerId, {String? source}) {
    final coupon = _couponFromOffer(offerId, source: source);
    couponWallet.add(coupon);
    notifyListeners();
    return coupon;
  }

  void addCoupons(int n) {
    for (var i = 0; i < n; i++) {
      couponWallet.add(_couponFromOffer('c99'));
    }
    notifyListeners();
  }

  Coupon? bestCouponFor(double total) {
    Coupon? best;
    for (final c in couponWallet) {
      if (!c.usableFor(total)) continue;
      if (best == null || c.amount > best.amount) best = c;
    }
    return best;
  }

  bool consumeCoupon(Coupon coupon) {
    if (!couponWallet.remove(coupon)) return false;
    couponsUsed++;
    notifyListeners();
    return true;
  }

  Map<String, dynamic> toJson() => {
    'wallet': [
      for (final c in couponWallet)
        {
          'id': c.id,
          'title': c.title,
          'threshold': c.threshold,
          'amount': c.amount,
          'source': c.source,
          'emoji': c.emoji,
          'expire': c.expireAt?.toIso8601String(),
        },
    ],
    'couponsUsed': couponsUsed,
  };

  void restoreFrom(Map<String, dynamic> data) {
    couponsUsed = _nonNegativeInt(data['couponsUsed'], 0);

    couponWallet.clear();
    final walletRaw = data['wallet'];
    if (walletRaw is List) {
      for (final item in walletRaw) {
        if (item is! Map) continue;
        final id = item['id'];
        final title = item['title'];
        if (id is! String || title is! String) continue;
        couponWallet.add(
          Coupon(
            id: id,
            title: title,
            threshold: _nonNegativeDouble(item['threshold'], 0),
            amount: _nonNegativeDouble(item['amount'], 0),
            source: (item['source'] as String?) ?? '本地',
            emoji: (item['emoji'] as String?) ?? '🎫',
            expireAt: _dateOrNull(item['expire']),
          ),
        );
      }
    }
    if (couponWallet.isEmpty) {
      // v1 及更早版本只存了券的数量，按通用券补齐，保证升级后不丢。
      final legacy = _nonNegativeInt(data['coupons'], 0);
      for (var i = 0; i < legacy; i++) {
        couponWallet.add(_couponFromOffer('c99', source: '旧版数据迁移'));
      }
    }
  }

  void seed() {
    couponWallet
      ..clear()
      ..addAll([
        for (var i = 0; i < 6; i++)
          _couponFromOffer('c99', source: '新人礼包'),
      ]);
    couponsUsed = 0;
  }

  DateTime? _dateOrNull(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  int _nonNegativeInt(Object? value, int fallback) {
    final v = (value as num?)?.toInt();
    if (v == null || v < 0) return fallback;
    return v;
  }

  double _nonNegativeDouble(Object? value, double fallback) {
    final v = (value as num?)?.toDouble();
    if (v == null || v.isNaN || v < 0) return fallback;
    return v;
  }
}
