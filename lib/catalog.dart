import 'dart:convert';

import 'package:flutter/services.dart';

import 'data.dart' as seed;
import 'log.dart';
import 'models.dart';

/// 可配置的商品目录：商品、Banner、直播间、秒杀清单与热搜词。
///
/// 内置目录写入 `assets/data/catalog.json`，`lib/data.dart` 保留为回退种子数据。
/// 用户导入的自定义目录会先做结构校验，校验失败不会覆盖当前目录。
class Catalog {
  Catalog({
    required this.products,
    required this.banners,
    required this.liveRooms,
    required this.seckillIds,
    required this.hotSearches,
  });

  static const int formatVersion = 1;
  static const List<String> categories = [
    '数码',
    '服饰',
    '美食',
    '家居',
    '美妆',
    '潮玩',
    '运动',
    '宠物',
    '解压',
  ];

  final List<Product> products;
  final List<PromoBanner> banners;
  final List<LiveRoom> liveRooms;
  final List<int> seckillIds;
  final List<String> hotSearches;

  /// 用 `lib/data.dart` 的静态数据构造目录，作为资产读取失败时的兜底。
  factory Catalog.fromSeed() => Catalog(
    products: List<Product>.unmodifiable(seed.products),
    banners: List<PromoBanner>.unmodifiable(seed.banners),
    liveRooms: List<LiveRoom>.unmodifiable(seed.liveRooms),
    seckillIds: List<int>.unmodifiable(seed.seckillIds),
    hotSearches: List<String>.unmodifiable(seed.hotSearches),
  );

  Map<String, dynamic> toJson() => {
    'version': formatVersion,
    'categories': categories,
    'products': [for (final p in products) _productToJson(p)],
    'banners': [for (final b in banners) _bannerToJson(b)],
    'liveRooms': [for (final r in liveRooms) _roomToJson(r)],
    'seckillIds': seckillIds,
    'hotSearches': hotSearches,
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// 严格解析：任何结构或取值不符合规则都会抛 [FormatException]。
  static Catalog decode(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      throw FormatException('JSON 格式错误：${e.message}');
    }
    if (decoded is! Map) {
      throw const FormatException('顶层结构必须是 JSON 对象');
    }
    final data = Map<String, dynamic>.from(decoded);

    final products = <Product>[];
    final productsRaw = data['products'];
    if (productsRaw is! List || productsRaw.isEmpty) {
      throw const FormatException('products 必须是非空数组');
    }
    for (var i = 0; i < productsRaw.length; i++) {
      products.add(_productFromJson(productsRaw[i], i));
    }

    final banners = <PromoBanner>[];
    final bannersRaw = data['banners'];
    if (bannersRaw is! List || bannersRaw.isEmpty) {
      throw const FormatException('banners 必须是非空数组');
    }
    for (var i = 0; i < bannersRaw.length; i++) {
      banners.add(_bannerFromJson(bannersRaw[i], i));
    }

    final rooms = <LiveRoom>[];
    final roomsRaw = data['liveRooms'];
    if (roomsRaw is! List || roomsRaw.isEmpty) {
      throw const FormatException('liveRooms 必须是非空数组');
    }
    for (var i = 0; i < roomsRaw.length; i++) {
      rooms.add(_roomFromJson(roomsRaw[i], i));
    }

    final seckillIds = _intList(data['seckillIds'], 'seckillIds');
    final hotSearches = _stringList(data['hotSearches'], 'hotSearches');

    final catalog = Catalog(
      products: List<Product>.unmodifiable(products),
      banners: List<PromoBanner>.unmodifiable(banners),
      liveRooms: List<LiveRoom>.unmodifiable(rooms),
      seckillIds: List<int>.unmodifiable(seckillIds),
      hotSearches: List<String>.unmodifiable(hotSearches),
    );
    catalog.validate();
    return catalog;
  }

  static Catalog? tryParse(String raw) {
    try {
      return decode(raw);
    } catch (e) {
      AppLog.warn('商品目录解析失败', e);
      return null;
    }
  }

  /// 校验目录完整性；不通过时抛出 [FormatException]。
  ///
  /// 这些规则与 docs/店铺商品SKU清单.md 保持一致，防止导入的数据把首页、
  /// 直播间或秒杀条带进越界状态。
  void validate() {
    if (products.isEmpty) throw const FormatException('商品列表不能为空');
    final ids = <int>{};
    for (final p in products) {
      if (p.id <= 0) throw FormatException('商品 id 必须为正整数：${p.name}');
      if (!ids.add(p.id)) throw FormatException('商品 id 重复：${p.id}');
      if (p.name.trim().isEmpty) throw FormatException('商品 ${p.id} 缺少名称');
      if (p.store.trim().isEmpty) throw FormatException('商品 ${p.id} 缺少店铺');
      if (!categories.contains(p.category)) {
        throw FormatException('商品 ${p.id} 的分类不在九大类内：${p.category}');
      }
      if (p.price < 0.99 || p.price > 12999) {
        throw FormatException('商品 ${p.id} 价格超出 0.99–12999');
      }
      if (p.originalPrice <= p.price) {
        throw FormatException('商品 ${p.id} 原价必须大于售价');
      }
      if (p.rating < 4.7 || p.rating > 4.9) {
        throw FormatException('商品 ${p.id} 评分需在 4.7–4.9');
      }
    }
    if (banners.isEmpty) throw const FormatException('至少保留 1 张 Banner');
    if (liveRooms.isEmpty) throw const FormatException('至少保留 1 个直播间');
    for (final room in liveRooms) {
      if (room.productIds.isEmpty) {
        throw FormatException('直播间「${room.title}」没有商品');
      }
      for (final id in room.productIds) {
        if (!ids.contains(id)) {
          throw FormatException('直播间「${room.title}」引用了不存在的商品 $id');
        }
      }
    }
    for (final id in seckillIds) {
      if (!ids.contains(id)) throw FormatException('秒杀清单引用了不存在的商品 $id');
    }
  }

  static Map<String, dynamic> _productToJson(Product p) => {
    'id': p.id,
    'name': p.name,
    'emoji': p.emoji,
    'category': p.category,
    'store': p.store,
    'price': p.price,
    'originalPrice': p.originalPrice,
    'sold': p.sold,
    'rating': p.rating,
    'tags': p.tags,
    'desc': p.desc,
  };

  static Product _productFromJson(Object? raw, int index) {
    final label = '第 ${index + 1} 件商品';
    if (raw is! Map) throw FormatException('$label 不是对象');
    final id = _int(raw['id'], '$label 的 id');
    final name = _string(raw['name'], '$label 的 name');
    final emoji = _string(raw['emoji'], '$label 的 emoji');
    final category = _string(raw['category'], '$label 的 category');
    final store = _string(raw['store'], '$label 的 store');
    final price = _double(raw['price'], '$label 的 price');
    final originalPrice = _double(raw['originalPrice'], '$label 的 originalPrice');
    final sold = _int(raw['sold'], '$label 的 sold');
    final rating = _double(raw['rating'], '$label 的 rating');
    final tags = _stringList(raw['tags'], '$label 的 tags');
    final desc = raw['desc'] is String ? raw['desc'] as String : '';
    return Product(
      id: id,
      name: name,
      emoji: emoji,
      category: category,
      store: store,
      price: price,
      originalPrice: originalPrice,
      sold: sold,
      rating: rating,
      tags: List<String>.unmodifiable(tags),
      desc: desc,
    );
  }

  static Map<String, dynamic> _bannerToJson(PromoBanner b) => {
    'title': b.title,
    'subtitle': b.subtitle,
    'emoji': b.emoji,
    'tag': b.tag,
    'colors': [for (final c in b.colors) c.toARGB32()],
    'target': b.target,
  };

  static PromoBanner _bannerFromJson(Object? raw, int index) {
    final label = '第 ${index + 1} 张 Banner';
    if (raw is! Map) throw FormatException('$label 不是对象');
    return PromoBanner(
      title: _string(raw['title'], '$label 的 title'),
      subtitle: _string(raw['subtitle'], '$label 的 subtitle'),
      emoji: _string(raw['emoji'], '$label 的 emoji'),
      tag: _string(raw['tag'], '$label 的 tag'),
      colors: _colors(raw['colors'], '$label 的 colors'),
      target: _string(raw['target'], '$label 的 target'),
    );
  }

  static Map<String, dynamic> _roomToJson(LiveRoom r) => {
    'title': r.title,
    'host': r.host,
    'hostEmoji': r.hostEmoji,
    'viewers': r.viewers,
    'colors': [for (final c in r.colors) c.toARGB32()],
    'productIds': r.productIds,
    'notice': r.notice,
  };

  static LiveRoom _roomFromJson(Object? raw, int index) {
    final label = '第 ${index + 1} 个直播间';
    if (raw is! Map) throw FormatException('$label 不是对象');
    return LiveRoom(
      title: _string(raw['title'], '$label 的 title'),
      host: _string(raw['host'], '$label 的 host'),
      hostEmoji: _string(raw['hostEmoji'], '$label 的 hostEmoji'),
      viewers: _string(raw['viewers'], '$label 的 viewers'),
      colors: _colors(raw['colors'], '$label 的 colors'),
      productIds: _intList(raw['productIds'], '$label 的 productIds'),
      notice: _string(raw['notice'], '$label 的 notice'),
    );
  }

  static List<Color> _colors(Object? raw, String label) {
    if (raw is! List || raw.length < 2) {
      throw FormatException('$label 至少需要 2 个颜色');
    }
    final colors = <Color>[];
    for (final v in raw) {
      if (v is! num) throw FormatException('$label 含非数字颜色值');
      colors.add(Color(v.toInt()));
    }
    return List<Color>.unmodifiable(colors);
  }

  static int _int(Object? value, String label) {
    if (value is num) return value.toInt();
    throw FormatException('$label 必须是数字');
  }

  static double _double(Object? value, String label) {
    if (value is num) return value.toDouble();
    throw FormatException('$label 必须是数字');
  }

  static String _string(Object? value, String label) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('$label 必须是非空字符串');
  }

  static List<int> _intList(Object? raw, String label) {
    if (raw is! List) throw FormatException('$label 必须是数组');
    final list = <int>[];
    for (final v in raw) {
      if (v is! num) throw FormatException('$label 含非数字项');
      list.add(v.toInt());
    }
    return list;
  }

  static List<String> _stringList(Object? raw, String label) {
    if (raw is! List) throw FormatException('$label 必须是数组');
    final list = <String>[];
    for (final v in raw) {
      if (v is! String || v.trim().isEmpty) {
        throw FormatException('$label 含空字符串');
      }
      list.add(v);
    }
    return list;
  }
}

/// 商品目录数据源抽象：内置资产与模拟远端二选一注入。
abstract class CatalogSource {
  const CatalogSource();

  String get label;

  /// 读取失败返回 null，由仓库层回退到下一级数据源。
  Future<Catalog?> load();
}

/// 从打包资产读取，完全离线。
class AssetCatalogSource extends CatalogSource {
  const AssetCatalogSource({this.assetPath = 'assets/data/catalog.json'});

  final String assetPath;

  @override
  String get label => '内置资产';

  @override
  Future<Catalog?> load() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final catalog = Catalog.tryParse(raw);
      if (catalog == null) {
        AppLog.warn('内置商品目录校验失败，回退种子数据');
      }
      return catalog;
    } catch (e) {
      AppLog.warn('读取内置商品目录失败，回退种子数据', e);
      return null;
    }
  }
}

/// 模拟远端数据源：包一层延迟，验证注入与可替换性，但不发起任何网络请求。
class MockRemoteCatalogSource extends CatalogSource {
  const MockRemoteCatalogSource({
    this.inner = const AssetCatalogSource(),
    this.latency = const Duration(milliseconds: 300),
  });

  final CatalogSource inner;
  final Duration latency;

  @override
  String get label => '模拟远端';

  @override
  Future<Catalog?> load() async {
    await Future<void>.delayed(latency);
    return inner.load();
  }
}
