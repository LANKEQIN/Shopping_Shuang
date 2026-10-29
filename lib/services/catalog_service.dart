import 'dart:math';

import 'package:flutter/foundation.dart';

import '../catalog.dart';
import '../models.dart';
import '../repositories/catalog_repository.dart';

/// 活动商品目录：页面只从这里读取商品、Banner、直播间与秒杀清单。
class CatalogService extends ChangeNotifier {
  CatalogService();

  Catalog _catalog = Catalog.fromSeed();
  CatalogRepository? _repository;
  final Random _rnd = Random();

  Catalog get catalog => _catalog;

  List<Product> get products => _catalog.products;

  List<PromoBanner> get banners => _catalog.banners;

  List<LiveRoom> get liveRooms => _catalog.liveRooms;

  List<int> get seckillIds => _catalog.seckillIds;

  List<String> get hotSearches => _catalog.hotSearches;

  String get sourceLabel => _repository?.sourceLabel ?? '内置种子数据';

  bool get usingCustom => _repository?.usingCustom ?? false;

  Future<void> boot(CatalogRepository repository) async {
    _repository = repository;
    _catalog = await repository.load();
    notifyListeners();
  }

  Product? findProduct(int id) {
    for (final p in _catalog.products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Product randomProduct() => products[_rnd.nextInt(products.length)];

  /// 首页「猜你喜欢」：固定随机种子打乱，保证每次打开顺序一致。
  List<Product> get feedProducts {
    final list = [...products];
    list.shuffle(Random(42));
    return list;
  }

  Future<CatalogImportResult> importJson(String raw) async {
    final repository = _repository;
    if (repository == null) {
      return const CatalogImportResult.failure('商品目录尚未初始化');
    }
    final result = await repository.importFromJson(raw);
    if (result.ok) {
      _catalog = result.catalog!;
      notifyListeners();
    }
    return result;
  }

  String exportJson() => _repository?.exportJson() ?? _catalog.encode();

  Future<void> restoreBuiltIn() async {
    final repository = _repository;
    if (repository == null) {
      _catalog = Catalog.fromSeed();
    } else {
      _catalog = await repository.restoreBuiltIn();
    }
    notifyListeners();
  }
}
