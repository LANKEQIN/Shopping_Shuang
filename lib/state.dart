import 'dart:async';

import 'package:flutter/material.dart';

import 'catalog.dart';
import 'data.dart' as seed;
import 'log.dart';
import 'models.dart';
import 'repositories/app_repository.dart';
import 'repositories/catalog_repository.dart';
import 'services/cart_service.dart';
import 'services/catalog_service.dart';
import 'services/coupon_service.dart';
import 'services/order_service.dart';
import 'services/play_service.dart';
import 'services/preference_service.dart';
import 'services/user_service.dart';
import 'storage.dart';
import 'theme.dart';

export 'services/cart_service.dart' show CartEntry;

/// 应用组合根与兼容门面。
///
/// 业务状态按域拆到 services/，持久化交给 repositories/app_repository.dart；
/// AppState 只负责服务装配、跨域编排（下单奖励、签到发券、积分兑换等）、
/// 全局通知与防抖落盘。页面继续通过 [AppState.instance] 访问，保持调用面稳定。
class AppState extends ChangeNotifier {
  AppState._() {
    cartService.onItemAdded = () => userService.bumpDaily('addCart');
    orderService.onOrderPlaced = (order, free) =>
        userService.rewardOrder(order.total, free: free);
    orderService.onRefunded = userService.addBalance;
    playService.productResolver = findProduct;
    playService.onGroupSuccess = (product, price) {
      orderService.createOrder([
        OrderItem(product: product, qty: 1, price: price),
      ], price);
    };
    playService.onCutSuccess = orderService.createFreeOrder;
    for (final service in _children) {
      service.addListener(_onChildChanged);
    }
  }

  static final AppState instance = AppState._();

  /// 本地数据键。版本号写在 JSON 内部，键名保持不变。
  static const String storageKey = AppRepository.storageKey;
  static const int schemaVersion = AppRepository.schemaVersion;

  final CatalogService catalogService = CatalogService();
  final PreferenceService preferenceService = PreferenceService();
  final CartService cartService = CartService();
  final CouponService couponService = CouponService();
  final UserService userService = UserService();
  final OrderService orderService = OrderService();
  final PlayService playService = PlayService();

  Storage _storage = MemoryStorage();
  AppRepository? _repository;
  bool _ready = false;
  bool _silenced = true;
  Timer? _saveTimer;

  bool get ready => _ready;

  List<ChangeNotifier> get _children => [
    catalogService,
    preferenceService,
    cartService,
    couponService,
    userService,
    orderService,
    playService,
  ];

  // ---------------- 生命周期与持久化 ----------------

  /// 读取商品目录与本地快照；没有或损坏时回退到默认种子数据。
  Future<void> init({
    Storage? storage,
    CatalogSource? catalogSource,
  }) async {
    if (storage != null) _storage = storage;
    _saveTimer?.cancel();
    _saveTimer = null;
    _ready = false;
    _silenced = true;

    _repository = AppRepository(_storage);
    try {
      await catalogService.boot(
        CatalogRepository(
          _storage,
          source: catalogSource ?? const AssetCatalogSource(),
        ),
      );
    } catch (e) {
      AppLog.error('加载商品目录失败，继续使用内置种子数据', e);
    }

    var restored = false;
    try {
      final data = await _repository!.read();
      if (data != null) {
        _restoreAll(data);
        restored = true;
      }
    } catch (e) {
      AppLog.error('恢复本地数据失败，回退默认种子数据', e);
    }
    if (!restored) _seed();

    userService.ensureDaily();
    _silenced = false;
    _ready = true;
    notifyListeners();
    await flush();
  }

  /// 立即把当前状态写入本地存储。
  Future<void> flush() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    if (!_ready) return;
    final repository = _repository;
    if (repository == null) return;
    await repository.write(_snapshot());
  }

  /// 清除本地数据并恢复到首次启动状态（含自定义商品目录）。
  Future<void> resetAll() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    _ready = false;
    _silenced = true;
    await _repository?.clear();
    await catalogService.restoreBuiltIn();
    _seed();
    _silenced = false;
    _ready = true;
    notifyListeners();
    await flush();
  }

  void _onChildChanged() {
    if (_silenced) return;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_ready && !_silenced) _schedulePersist();
  }

  void _schedulePersist() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), () {
      _saveTimer = null;
      flush();
    });
  }

  Map<String, dynamic> _snapshot() => {
    'version': AppRepository.schemaVersion,
    ...preferenceService.toJson(),
    ...cartService.toJson(),
    ...couponService.toJson(),
    ...userService.toJson(),
    ...orderService.toJson(),
    ...playService.toJson(),
  };

  void _restoreAll(Map<String, dynamic> data) {
    preferenceService.restoreFrom(data);
    cartService.restoreFrom(data, findProduct);
    couponService.restoreFrom(data);
    userService.restoreFrom(data, findProduct);
    orderService.restoreFrom(data, findProduct);
    playService.restoreFrom(data, findProduct);
  }

  void _seed() {
    preferenceService.seed();
    cartService.seed(findProduct);
    orderService.seed(findProduct);
    couponService.seed();
    userService.seed();
    playService.seed();
  }

  Set<int> get seckillReminders => playService.seckillReminders;

  // ---------------- 商品目录 ----------------

  List<Product> get products => catalogService.products;

  List<PromoBanner> get banners => catalogService.banners;

  List<LiveRoom> get liveRooms => catalogService.liveRooms;

  List<int> get seckillIds => catalogService.seckillIds;

  List<String> get hotSearches => catalogService.hotSearches;

  List<Product> get feedProducts => catalogService.feedProducts;

  String get catalogSourceLabel => catalogService.sourceLabel;

  bool get catalogUsingCustom => catalogService.usingCustom;

  Product? findProduct(int id) => catalogService.findProduct(id);

  Product randomProduct() => catalogService.randomProduct();

  Future<CatalogImportResult> importCatalog(String raw) =>
      catalogService.importJson(raw);

  String exportCatalog() => catalogService.exportJson();

  Future<void> restoreBuiltInCatalog() => catalogService.restoreBuiltIn();

  // ---------------- 皮肤与体验开关 ----------------

  ValueNotifier<Skin> get skinNotifier => preferenceService.skinNotifier;

  Skin get skin => preferenceService.skin;

  void setSkin(Skin skin) => preferenceService.setSkin(skin);

  bool get animationsEnabled => preferenceService.animationsEnabled;

  bool get hapticsEnabled => preferenceService.hapticsEnabled;

  bool get soundsEnabled => preferenceService.soundsEnabled;

  void setAnimationsEnabled(bool value) =>
      preferenceService.setAnimationsEnabled(value);

  void setHapticsEnabled(bool value) =>
      preferenceService.setHapticsEnabled(value);

  void setSoundsEnabled(bool value) =>
      preferenceService.setSoundsEnabled(value);

  List<String> get searchHistory => preferenceService.searchHistory;

  void pushHistory(String keyword) => preferenceService.pushHistory(keyword);

  void clearHistory() => preferenceService.clearHistory();

  // ---------------- 购物车 ----------------

  List<CartEntry> get cart => cartService.cart;

  int get cartCount => cartService.cartCount;

  bool get allSelected => cartService.allSelected;

  List<CartEntry> get selectedEntries => cartService.selectedEntries;

  double get selectedTotal => cartService.selectedTotal;

  void addToCart(Product product, {int qty = 1}) =>
      cartService.addToCart(product, qty: qty);

  void removeEntry(CartEntry entry) => cartService.removeEntry(entry);

  void changeQty(CartEntry entry, int delta) =>
      cartService.changeQty(entry, delta);

  void toggleSelected(CartEntry entry) =>
      cartService.toggleSelected(entry);

  void setAllSelected(bool value) => cartService.setAllSelected(value);

  void removePurchased(List<CartEntry> entries) =>
      cartService.removePurchased(entries);

  // ---------------- 订单 ----------------

  List<Order> get orders => orderService.orders;

  Order createOrder(
    List<OrderItem> items,
    double total, {
    bool freeOrder = false,
  }) => orderService.createOrder(items, total, freeOrder: freeOrder);

  Order createPendingOrder(List<OrderItem> items, double total) =>
      orderService.createPendingOrder(items, total);

  Order createFreeOrder(Product product) =>
      orderService.createFreeOrder(product);

  bool payOrder(Order order) => orderService.payOrder(order);

  void cancelOrder(Order order) => orderService.cancelOrder(order);

  int expirePendingOrders() => orderService.expirePendingOrders();

  void confirmReceive(Order order) => orderService.confirmReceive(order);

  void reviewOrder(Order order) => orderService.reviewOrder(order);

  void removeOrder(Order order) => orderService.removeOrder(order);

  void reorder(Order order) {
    for (final item in order.items) {
      cartService.addToCart(item.product, qty: item.qty);
    }
  }

  double get totalSpent => orderService.totalSpent;

  int get paidOrderCount => orderService.paidOrderCount;

  int get freeOrderCount => orderService.freeOrderCount;

  List<AfterSaleRecord> get afterSales => orderService.afterSales;

  List<InvoiceRecord> get invoices => orderService.invoices;

  AfterSaleRecord requestAfterSale(
    Order order, {
    String type = '仅退款',
    String reason = '不想要了',
  }) => orderService.requestAfterSale(order, type: type, reason: reason);

  InvoiceRecord requestInvoice(
    Order order, {
    String title = '个人',
    String type = '电子普通发票',
    String email = 'yuyuko@hakugyokuro.jp',
  }) => orderService.requestInvoice(
    order,
    title: title,
    type: type,
    email: email,
  );

  bool hasInvoice(String orderId) => orderService.hasInvoice(orderId);

  void completeAfterSale(AfterSaleRecord record) =>
      orderService.completeAfterSale(record);

  // ---------------- 优惠券 / 积分 / 会员 ----------------

  List<Coupon> get couponWallet => couponService.couponWallet;

  int get coupons => couponService.coupons;

  List<Coupon> get validCoupons => couponService.validCoupons;

  int get couponsUsed => couponService.couponsUsed;

  void addCoupons(int n) => couponService.addCoupons(n);

  Coupon? bestCouponFor(double total) => couponService.bestCouponFor(total);

  bool consumeCoupon(Coupon coupon) => couponService.consumeCoupon(coupon);

  bool claimCouponOffer(String offerId) {
    if (!userService.claimDaily('offer:$offerId')) return false;
    couponService.addOffer(offerId);
    return true;
  }

  bool couponOfferClaimed(String offerId) =>
      userService.dailyClaims.contains('offer:$offerId');

  int get coins => userService.coins;

  double get balance => userService.balance;

  String get nickname => userService.nickname;

  bool get followedLive => userService.followedLive;

  void setFollowedLive(bool value) => userService.setFollowedLive(value);

  int get points => userService.points;

  int get growth => userService.growth;

  int get growthValue => userService.growthValue;

  MemberLevel get memberLevel => userService.memberLevel;

  MemberLevel? get nextMemberLevel => userService.nextMemberLevel;

  double get memberProgress => userService.memberProgress;

  void addPoints(int n) => userService.addPoints(n);

  bool redeemPointGood(PointGood good) {
    if (!userService.spendPoints(good.cost)) return false;
    switch (good.kind) {
      case 'coupon':
        if (good.couponOfferId != null) {
          couponService.addOffer(good.couponOfferId!);
        }
        break;
      case 'product':
        final id = good.productId;
        final p = id == null ? null : findProduct(id);
        if (p != null) orderService.createFreeOrder(p);
        break;
      case 'balance':
        userService.addBalance(100);
        break;
    }
    return true;
  }

  // ---------------- 签到 / 每日任务 ----------------

  Set<String> get checkInDates => userService.checkInDates;

  bool get checkedInToday => userService.checkedInToday;

  int get checkInStreak => userService.checkInStreak;

  ({bool ok, CheckInReward? reward}) checkInToday() {
    if (!userService.markCheckedInToday()) {
      return (ok: false, reward: null);
    }
    final streak = userService.checkInStreak;
    final reward =
        seed.checkInRewards[(streak - 1) % seed.checkInRewards.length];
    userService.addPoints(reward.points);
    final offerId = reward.couponOfferId;
    if (offerId != null) couponService.addOffer(offerId);
    userService.setDailyProgress('checkIn', 1);
    return (ok: true, reward: reward);
  }

  String get dailyDate => userService.dailyDate;

  Map<String, int> get dailyProgress => userService.dailyProgress;

  Set<String> get dailyClaims => userService.dailyClaims;

  Set<int> get todayBrowsed => userService.todayBrowsed;

  int taskProgress(DailyTaskDef task) => userService.taskProgress(task);

  bool taskClaimed(DailyTaskDef task) => userService.taskClaimed(task);

  bool taskClaimable(DailyTaskDef task) => userService.taskClaimable(task);

  bool claimTask(DailyTaskDef task) => userService.claimTask(task);

  // ---------------- 拼团 / 砍价 / 抽免单 / 秒杀预约 ----------------

  List<GroupBuy> get groupBuys => playService.groupBuys;

  CutRecord? get cutRecord => playService.cutRecord;

  int get cutSuccessCount => playService.cutSuccessCount;

  int get groupSuccessCount => playService.groupSuccessCount;

  GroupBuy startGroup(Product product, {int required = 2}) =>
      playService.startGroup(product, required: required);

  GroupMember? inviteGroupFriend(GroupBuy group) =>
      playService.inviteGroupFriend(group);

  void abandonGroup(GroupBuy group) => playService.abandonGroup(group);

  int expireGroups() => playService.expireGroups();

  CutRecord ensureCutRecord(Product product) =>
      playService.ensureCutRecord(product);

  void resetCutRecord() => playService.resetCutRecord();

  CutSlice? cutOnce() => playService.cutOnce();

  void markCutPoster() => playService.markCutPoster();

  void markCutShownOff() => playService.markCutShownOff();

  int get lotteryCount => playService.lotteryCount;

  int get lotteryMissStreak => playService.lotteryMissStreak;

  List<LotteryRecord> get lotteryHistory => playService.lotteryHistory;

  int get lotteryPityLimit {
    final index = seed.memberLevels.indexOf(memberLevel);
    return (20 - index * 3).clamp(5, 20);
  }

  int get lotteryPityRemaining =>
      (lotteryPityLimit - playService.lotteryMissStreak)
          .clamp(0, lotteryPityLimit);

  int rollLottery(List<int> weights, int freeIndex) {
    userService.ensureDaily();
    return playService.rollLottery(
      weights,
      freeIndex,
      pityLimit: lotteryPityLimit,
    );
  }

  void recordLottery(LotteryRecord record) =>
      playService.recordLottery(record);

  bool isSeckillReserved(int productId) =>
      playService.isSeckillReserved(productId);

  bool toggleSeckillReminder(int productId) =>
      playService.toggleSeckillReminder(productId);

  // ---------------- 收藏 / 足迹 / 评价 / 问答 ----------------

  Set<int> get favorites => userService.favorites;

  List<Footprint> get footprints => userService.footprints;

  List<ProductReview> get myReviews => userService.myReviews;

  List<QaEntry> get myQuestions => userService.myQuestions;

  bool isFavorite(int productId) => userService.isFavorite(productId);

  bool toggleFavorite(int productId) =>
      userService.toggleFavorite(productId);

  void recordFootprint(Product product) =>
      userService.recordFootprint(product);

  List<Product> get favoriteProducts => [
    for (final id in userService.favorites)
      for (final p in catalogService.products)
        if (p.id == id) p,
  ];

  List<Product> get footprintProducts => [
    for (final f in userService.footprints)
      for (final p in catalogService.products)
        if (p.id == f.productId) p,
  ];

  List<ProductReview> reviewsFor(int productId) =>
      userService.reviewsFor(productId);

  void addReview(ProductReview review) => userService.addReview(review);

  List<QaEntry> questionsFor(int productId) =>
      userService.questionsFor(productId);

  void addQuestion(int productId, String question) =>
      userService.addQuestion(productId, question);

  // ---------------- 成就与报告 ----------------

  int get reviewCount => userService.myReviews.length;

  int achievementValue(String metric) => switch (metric) {
    'orders' => orderService.paidOrderCount,
    'spend' => orderService.totalSpent.round(),
    'freeOrders' => orderService.freeOrderCount,
    'cuts' => playService.cutSuccessCount,
    'checkIns' => userService.checkInDates.length,
    'favorites' => userService.favorites.length,
    'reviews' => userService.myReviews.length,
    'groups' => playService.groupSuccessCount,
    'lottery' => playService.lotteryCount,
    'couponsUsed' => couponService.couponsUsed,
    _ => 0,
  };

  bool achievementUnlocked(AchievementDef a) =>
      achievementValue(a.metric) >= a.target;
}
