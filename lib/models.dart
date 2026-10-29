import 'package:flutter/material.dart';

/// 商品
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.store,
    required this.price,
    required this.originalPrice,
    required this.sold,
    required this.rating,
    required this.tags,
    this.desc = '',
  });

  final int id;
  final String name;
  final String emoji;
  final String category;
  final String store;
  final double price;
  final double originalPrice;

  /// 已售，单位：万件
  final int sold;
  final double rating;
  final List<String> tags;
  final String desc;

  bool get subsidy => tags.contains('百亿补贴');
  bool get selfRun => tags.contains('自营');

  double get discountAmount => originalPrice - price;

  String get detailText => desc.isNotEmpty
      ? desc
      : '【$store】官方正品，$category 解压好物。下单不花钱，快乐不打折，'
            '幻想乡全境包邮，明天就能送到你的白玉楼。';
}

/// 首页轮播
class PromoBanner {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.tag,
    required this.colors,
    required this.target,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final String tag;
  final List<Color> colors;

  /// subsidy / seckill / cut / live
  final String target;
}

/// 直播间
class LiveRoom {
  const LiveRoom({
    required this.title,
    required this.host,
    required this.hostEmoji,
    required this.viewers,
    required this.colors,
    required this.productIds,
    required this.notice,
  });

  final String title;
  final String host;
  final String hostEmoji;
  final String viewers;
  final List<Color> colors;
  final List<int> productIds;
  final String notice;
}

class OrderItem {
  const OrderItem({
    required this.product,
    required this.qty,
    required this.price,
  });

  final Product product;
  final int qty;
  final double price;

  double get subtotal => price * qty;
}

enum OrderStatus {
  pendingPay('待付款'),
  pendingShip('待发货'),
  pendingReceive('待收货'),
  pendingReview('待评价'),
  completed('已完成'),
  cancelled('已取消'),
  refunded('已退款');

  const OrderStatus(this.label);
  final String label;

  bool get active =>
      this != OrderStatus.completed &&
      this != OrderStatus.cancelled &&
      this != OrderStatus.refunded;
}

class Order {
  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.time,
    required this.status,
    this.address = '幻想乡 · 白玉楼 西行妖大道 1 号',
    this.freeOrder = false,
    this.payDeadline,
  });

  final String id;
  final List<OrderItem> items;
  final double total;
  final DateTime time;
  OrderStatus status;
  final String address;
  final bool freeOrder;

  /// 待付款订单的超时时间；为空表示不限制。
  final DateTime? payDeadline;

  int get count => items.fold(0, (s, e) => s + e.qty);

  bool get payable =>
      status == OrderStatus.pendingPay &&
      payDeadline != null &&
      DateTime.now().isBefore(payDeadline!);
}

/// 优惠券（本地模拟资产）。
class Coupon {
  const Coupon({
    required this.id,
    required this.title,
    required this.threshold,
    required this.amount,
    required this.source,
    this.emoji = '🎫',
    this.expireAt,
  });

  final String id;
  final String title;
  final double threshold;
  final double amount;
  final String source;
  final String emoji;
  final DateTime? expireAt;

  bool get expired => expireAt != null && expireAt!.isBefore(DateTime.now());

  bool usableFor(double total) => !expired && total >= threshold;
}

/// 领券中心里的可领取券模板。
class CouponOffer {
  const CouponOffer({
    required this.id,
    required this.title,
    required this.threshold,
    required this.amount,
    required this.emoji,
    required this.desc,
    required this.source,
  });

  final String id;
  final String title;
  final double threshold;
  final double amount;
  final String emoji;
  final String desc;
  final String source;
}

/// 签到日历里每天的奖励。
class CheckInReward {
  const CheckInReward({
    required this.day,
    required this.title,
    required this.emoji,
    this.points = 0,
    this.couponOfferId,
  });

  final int day;
  final String title;
  final String emoji;
  final int points;
  final String? couponOfferId;
}

/// 积分商城奖品。
class PointGood {
  const PointGood({
    required this.id,
    required this.title,
    required this.emoji,
    required this.cost,
    required this.kind,
    this.couponOfferId,
    this.productId,
    this.desc = '',
  });

  final String id;
  final String title;
  final String emoji;
  final int cost;

  /// coupon / product / balance
  final String kind;
  final String? couponOfferId;
  final int? productId;
  final String desc;
}

/// 会员等级。
class MemberLevel {
  const MemberLevel({
    required this.name,
    required this.threshold,
    required this.emoji,
    required this.perks,
  });

  final String name;
  final int threshold;
  final String emoji;
  final List<String> perks;
}

/// 秒杀场次。
class SeckillSession {
  const SeckillSession({
    required this.label,
    required this.hour,
    required this.productIds,
    required this.tagline,
  });

  final String label;
  final int hour;
  final List<int> productIds;
  final String tagline;
}

/// 每日任务定义。
class DailyTaskDef {
  const DailyTaskDef({
    required this.id,
    required this.title,
    required this.desc,
    required this.emoji,
    required this.metric,
    required this.target,
    required this.points,
  });

  final String id;
  final String title;
  final String desc;
  final String emoji;

  /// browse / addCart / order / review / checkIn
  final String metric;
  final int target;
  final int points;
}

/// 成就定义。
class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.title,
    required this.desc,
    required this.emoji,
    required this.metric,
    required this.target,
  });

  final String id;
  final String title;
  final String desc;
  final String emoji;

  /// orders / spend / freeOrders / cuts / checkIns / favorites / reviews /
  /// groups / lottery / couponsUsed
  final String metric;
  final int target;
}

/// 拼团成员。
class GroupMember {
  const GroupMember({
    required this.name,
    required this.emoji,
    this.isMe = false,
  });

  final String name;
  final String emoji;
  final bool isMe;
}

enum GroupStatus {
  forming('拼团中'),
  success('拼团成功'),
  failed('拼团失败');

  const GroupStatus(this.label);
  final String label;
}

/// 一次拼团记录。
class GroupBuy {
  GroupBuy({
    required this.id,
    required this.productId,
    required this.required,
    required this.members,
    required this.createdAt,
    required this.endsAt,
    this.status = GroupStatus.forming,
  });

  final String id;
  final int productId;
  final int required;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime endsAt;
  GroupStatus status;

  int get joined => members.length;
  bool get success => status == GroupStatus.success;
  double get progress => (joined / required).clamp(0.0, 1.0);
}

/// 用户发布的商品评价。
class ProductReview {
  const ProductReview({
    required this.id,
    required this.productId,
    required this.nickname,
    required this.emoji,
    required this.rating,
    required this.text,
    required this.tags,
    required this.time,
  });

  final String id;
  final int productId;
  final String nickname;
  final String emoji;
  final int rating;
  final String text;
  final List<String> tags;
  final DateTime time;
}

/// 浏览足迹。
class Footprint {
  const Footprint({required this.productId, required this.time});

  final int productId;
  final DateTime time;
}

/// 商品问答。
class QaEntry {
  const QaEntry({
    required this.id,
    required this.productId,
    required this.question,
    required this.answer,
    required this.time,
    this.mine = false,
  });

  final String id;
  final int productId;
  final String question;
  final String answer;
  final DateTime time;
  final bool mine;
}

/// 砍价记录。
class CutSlice {
  const CutSlice({
    required this.name,
    required this.emoji,
    required this.amount,
    required this.time,
  });

  final String name;
  final String emoji;
  final double amount;
  final DateTime time;
}

class CutRecord {
  CutRecord({
    required this.productId,
    required this.original,
    required this.remaining,
    required this.cuts,
    required this.startedAt,
    this.done = false,
    this.sharedPoster = false,
    this.shownOff = false,
  });

  final int productId;
  final double original;
  double remaining;
  final List<CutSlice> cuts;
  final DateTime startedAt;
  bool done;
  bool sharedPoster;
  bool shownOff;

  double get saved => original - remaining;
  double get progress => original <= 0 ? 1 : (saved / original).clamp(0.0, 1.0);
}

/// 抽奖记录。
class LotteryRecord {
  const LotteryRecord({
    required this.title,
    required this.emoji,
    required this.note,
    required this.time,
    this.free = false,
    this.freeProductName,
  });

  final String title;
  final String emoji;
  final String note;
  final DateTime time;
  final bool free;
  final String? freeProductName;
}

/// 退款售后记录。
enum AfterSaleStatus {
  processing('处理中'),
  done('已完成');

  const AfterSaleStatus(this.label);
  final String label;
}

class AfterSaleRecord {
  AfterSaleRecord({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.type,
    required this.reason,
    required this.amount,
    required this.time,
    this.status = AfterSaleStatus.processing,
  });

  final String id;
  final String orderId;
  final String productName;
  final String type;
  final String reason;
  final double amount;
  final DateTime time;
  AfterSaleStatus status;
}

/// 发票申请记录。
class InvoiceRecord {
  const InvoiceRecord({
    required this.id,
    required this.orderId,
    required this.title,
    required this.type,
    required this.amount,
    required this.email,
    required this.time,
  });

  final String id;
  final String orderId;
  final String title;
  final String type;
  final double amount;
  final String email;
  final DateTime time;
}
