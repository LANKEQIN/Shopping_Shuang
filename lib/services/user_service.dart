import 'package:flutter/foundation.dart';

import '../data.dart';
import '../models.dart';

/// 用户域：资产、等级、签到、每日任务与用户生成内容（收藏 / 足迹 / 评价 / 问答）。
class UserService extends ChangeNotifier {
  int coins = 8888;
  double balance = 9999.00;
  String nickname = '幽幽子大人';
  bool followedLive = false;

  int points = 666;
  int growth = 0;

  final Set<String> checkInDates = {};

  String dailyDate = '';
  final Map<String, int> dailyProgress = {};
  final Set<String> dailyClaims = {};
  final Set<int> todayBrowsed = {};

  final Set<int> favorites = {};
  final List<Footprint> footprints = [];
  final List<ProductReview> myReviews = [];
  final List<QaEntry> myQuestions = [];

  int get growthValue => growth;

  MemberLevel get memberLevel => memberLevelOf(growth);

  MemberLevel? get nextMemberLevel {
    for (final l in memberLevels) {
      if (growth < l.threshold) return l;
    }
    return null;
  }

  double get memberProgress {
    final next = nextMemberLevel;
    if (next == null) return 1;
    final base = memberLevel.threshold;
    if (next.threshold <= base) return 1;
    return ((growth - base) / (next.threshold - base)).clamp(0.0, 1.0);
  }

  // ---------------- 资产 ----------------

  void setFollowedLive(bool value) {
    if (followedLive == value) return;
    followedLive = value;
    notifyListeners();
  }

  void addPoints(int n) {
    points += n;
    notifyListeners();
  }

  bool spendPoints(int n) {
    if (points < n) return false;
    points -= n;
    notifyListeners();
    return true;
  }

  void addBalance(double amount) {
    balance += amount;
    notifyListeners();
  }

  /// 下单/支付后的成长值与积分奖励。
  void rewardOrder(double total, {bool free = false}) {
    ensureDaily();
    dailyProgress['order'] = (dailyProgress['order'] ?? 0) + 1;
    if (free || total <= 0) {
      points += 10;
      growth += 5;
      notifyListeners();
      return;
    }
    growth += total.round();
    points += (total / 10).round() + 5;
    notifyListeners();
  }

  // ---------------- 签到 ----------------

  bool get checkedInToday => checkInDates.contains(_todayKey());

  int get checkInStreak {
    var streak = 0;
    var day = DateTime.now();
    while (checkInDates.contains(_dateKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// 记录今天的签到；重复签到返回 false。
  bool markCheckedInToday() {
    ensureDaily();
    final key = _todayKey();
    if (!checkInDates.add(key)) return false;
    notifyListeners();
    return true;
  }

  // ---------------- 每日任务 ----------------

  void ensureDaily() {
    final today = _todayKey();
    if (dailyDate == today) return;
    dailyDate = today;
    dailyProgress.clear();
    dailyClaims.clear();
    todayBrowsed.clear();
  }

  void bumpDaily(String metric, {int by = 1}) {
    ensureDaily();
    dailyProgress[metric] = (dailyProgress[metric] ?? 0) + by;
    notifyListeners();
  }

  void setDailyProgress(String metric, int value) {
    ensureDaily();
    dailyProgress[metric] = value;
    notifyListeners();
  }

  bool claimDaily(String key) {
    ensureDaily();
    if (!dailyClaims.add(key)) return false;
    notifyListeners();
    return true;
  }

  int taskProgress(DailyTaskDef task) {
    ensureDaily();
    return (dailyProgress[task.metric] ?? 0).clamp(0, task.target);
  }

  bool taskClaimed(DailyTaskDef task) => dailyClaims.contains(task.id);

  bool taskClaimable(DailyTaskDef task) =>
      !taskClaimed(task) && taskProgress(task) >= task.target;

  bool claimTask(DailyTaskDef task) {
    ensureDaily();
    if (!taskClaimable(task)) return false;
    dailyClaims.add(task.id);
    points += task.points;
    notifyListeners();
    return true;
  }

  // ---------------- 收藏 / 足迹 / 评价 / 问答 ----------------

  bool isFavorite(int productId) => favorites.contains(productId);

  bool toggleFavorite(int productId) {
    final added = favorites.add(productId);
    if (!added) favorites.remove(productId);
    notifyListeners();
    return added;
  }

  void recordFootprint(Product product) {
    ensureDaily();
    footprints.removeWhere((f) => f.productId == product.id);
    footprints.insert(
      0,
      Footprint(productId: product.id, time: DateTime.now()),
    );
    if (footprints.length > 30) {
      footprints.removeRange(30, footprints.length);
    }
    todayBrowsed.add(product.id);
    dailyProgress['browse'] = todayBrowsed.length;
    notifyListeners();
  }

  List<ProductReview> reviewsFor(int productId) =>
      myReviews.where((r) => r.productId == productId).toList();

  void addReview(ProductReview review) {
    myReviews.removeWhere((r) => r.id == review.id);
    myReviews.insert(0, review);
    bumpDaily('review');
  }

  List<QaEntry> questionsFor(int productId) =>
      myQuestions.where((q) => q.productId == productId).toList();

  void addQuestion(int productId, String question) {
    if (question.trim().isEmpty) return;
    myQuestions.insert(
      0,
      QaEntry(
        id: 'Q${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        question: question.trim(),
        answer: '已收到你的问题，店主正在假装思考，稍后会在梦里回复你。',
        time: DateTime.now(),
        mine: true,
      ),
    );
    notifyListeners();
  }

  // ---------------- 持久化 ----------------

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'balance': balance,
    'nickname': nickname,
    'followedLive': followedLive,
    'points': points,
    'growth': growth,
    'checkIns': checkInDates.toList(),
    'favorites': favorites.toList(),
    'footprints': [
      for (final f in footprints)
        {'pid': f.productId, 'time': f.time.toIso8601String()},
    ],
    'reviews': [
      for (final r in myReviews)
        {
          'id': r.id,
          'pid': r.productId,
          'name': r.nickname,
          'emoji': r.emoji,
          'rating': r.rating,
          'text': r.text,
          'tags': r.tags,
          'time': r.time.toIso8601String(),
        },
    ],
    'questions': [
      for (final q in myQuestions)
        {
          'id': q.id,
          'pid': q.productId,
          'q': q.question,
          'a': q.answer,
          'time': q.time.toIso8601String(),
        },
    ],
    'dailyDate': dailyDate,
    'dailyProgress': dailyProgress,
    'dailyClaims': dailyClaims.toList(),
    'todayBrowsed': todayBrowsed.toList(),
  };

  void restoreFrom(
    Map<String, dynamic> data,
    Product? Function(int id) resolveProduct,
  ) {
    coins = _nonNegativeInt(data['coins'], 8888);
    balance = _nonNegativeDouble(data['balance'], 9999.00);
    final name = data['nickname'];
    nickname = (name is String && name.trim().isNotEmpty) ? name : '幽幽子大人';
    followedLive = data['followedLive'] == true;
    points = _nonNegativeInt(data['points'], 666);
    growth = _nonNegativeInt(data['growth'], 0);

    checkInDates
      ..clear()
      ..addAll(_stringSet(data['checkIns']));
    favorites
      ..clear()
      ..addAll(_intSet(data['favorites']));

    dailyDate = (data['dailyDate'] as String?) ?? '';
    dailyProgress
      ..clear()
      ..addAll(_intMap(data['dailyProgress']));
    dailyClaims
      ..clear()
      ..addAll(_stringSet(data['dailyClaims']));
    todayBrowsed
      ..clear()
      ..addAll(_intSet(data['todayBrowsed']));

    footprints.clear();
    final footprintsRaw = data['footprints'];
    if (footprintsRaw is List) {
      for (final item in footprintsRaw) {
        if (item is! Map) continue;
        final pid = item['pid'];
        if (pid is! num) continue;
        final p = resolveProduct(pid.toInt());
        if (p == null) continue;
        footprints.add(
          Footprint(
            productId: p.id,
            time: _dateOrNull(item['time']) ?? DateTime.now(),
          ),
        );
      }
    }

    myReviews.clear();
    final reviewsRaw = data['reviews'];
    if (reviewsRaw is List) {
      for (final item in reviewsRaw) {
        if (item is! Map) continue;
        final pid = item['pid'];
        if (pid is! num) continue;
        final p = resolveProduct(pid.toInt());
        if (p == null) continue;
        myReviews.add(
          ProductReview(
            id: (item['id'] as String?) ?? 'R${myReviews.length}',
            productId: p.id,
            nickname: (item['name'] as String?) ?? nickname,
            emoji: (item['emoji'] as String?) ?? '🌸',
            rating: ((item['rating'] as num?)?.toInt() ?? 5).clamp(1, 5),
            text: (item['text'] as String?) ?? '',
            tags: _stringSet(item['tags']).toList(),
            time: _dateOrNull(item['time']) ?? DateTime.now(),
          ),
        );
      }
    }

    myQuestions.clear();
    final questionsRaw = data['questions'];
    if (questionsRaw is List) {
      for (final item in questionsRaw) {
        if (item is! Map) continue;
        final pid = item['pid'];
        if (pid is! num) continue;
        final p = resolveProduct(pid.toInt());
        if (p == null) continue;
        myQuestions.add(
          QaEntry(
            id: (item['id'] as String?) ?? 'Q${myQuestions.length}',
            productId: p.id,
            question: (item['q'] as String?) ?? '',
            answer: (item['a'] as String?) ?? '',
            time: _dateOrNull(item['time']) ?? DateTime.now(),
            mine: true,
          ),
        );
      }
    }
  }

  void seed() {
    coins = 8888;
    balance = 9999.00;
    nickname = '幽幽子大人';
    followedLive = false;
    points = 666;
    growth = 120;
    checkInDates.clear();
    favorites
      ..clear()
      ..addAll([48, 2, 70]);
    footprints
      ..clear()
      ..addAll([
        Footprint(
          productId: 48,
          time: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Footprint(
          productId: 2,
          time: DateTime.now().subtract(const Duration(hours: 7)),
        ),
        Footprint(
          productId: 70,
          time: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
    myReviews.clear();
    myQuestions.clear();
    dailyDate = _todayKey();
    dailyProgress.clear();
    dailyClaims.clear();
    todayBrowsed.clear();
  }

  // ---------------- 工具 ----------------

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${_two(now.month)}-${_two(now.day)}';
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';

  String _two(int n) => n.toString().padLeft(2, '0');

  DateTime? _dateOrNull(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Set<String> _stringSet(Object? value) {
    final set = <String>{};
    if (value is List) {
      for (final v in value) {
        if (v is String && v.trim().isNotEmpty) set.add(v);
      }
    }
    return set;
  }

  Set<int> _intSet(Object? value) {
    final set = <int>{};
    if (value is List) {
      for (final v in value) {
        if (v is num) set.add(v.toInt());
      }
    }
    return set;
  }

  Map<String, int> _intMap(Object? value) {
    final map = <String, int>{};
    if (value is Map) {
      value.forEach((key, v) {
        if (key is String && v is num) map[key] = v.toInt();
      });
    }
    return map;
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
