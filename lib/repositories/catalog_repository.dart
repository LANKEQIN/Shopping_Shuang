import '../catalog.dart';
import '../log.dart';
import '../storage.dart';

class CatalogImportResult {
  const CatalogImportResult._({this.catalog, this.error});

  const CatalogImportResult.success(Catalog catalog) : this._(catalog: catalog);

  const CatalogImportResult.failure(String error) : this._(error: error);

  final Catalog? catalog;
  final String? error;

  bool get ok => catalog != null;
}

/// 商品目录仓库：自定义导入 > 注入的数据源 > 内置种子数据。
///
/// 自定义目录保存在独立键 [customKey]，与应用状态 `shuang.app.state` 解耦，
/// 应用状态迁移不会影响用户导入的商品包。
class CatalogRepository {
  CatalogRepository(
    this._storage, {
    this.source = const AssetCatalogSource(),
  });

  static const String customKey = 'shuang.catalog.custom';

  final Storage _storage;
  CatalogSource source;
  Catalog? _current;
  bool _usingCustom = false;

  Catalog get current => _current ?? Catalog.fromSeed();

  bool get usingCustom => _usingCustom;

  String get sourceLabel => _usingCustom ? '自定义数据' : source.label;

  Future<Catalog> load() async {
    final custom = await _readCustom();
    if (custom != null) {
      _current = custom;
      _usingCustom = true;
      AppLog.info('使用自定义商品目录：${custom.products.length} 件商品');
      return custom;
    }
    final loaded = await source.load();
    _current = loaded ?? Catalog.fromSeed();
    _usingCustom = false;
    AppLog.info('使用${source.label}商品目录：${_current!.products.length} 件商品');
    return _current!;
  }

  Future<Catalog?> _readCustom() async {
    String? raw;
    try {
      raw = await _storage.read(customKey);
    } catch (e) {
      AppLog.warn('读取自定义商品目录失败', e);
      return null;
    }
    if (raw == null || raw.isEmpty) return null;
    final catalog = Catalog.tryParse(raw);
    if (catalog == null) {
      AppLog.warn('自定义商品目录校验失败，已回退到内置数据');
    }
    return catalog;
  }

  Future<CatalogImportResult> importFromJson(String raw) async {
    Catalog catalog;
    try {
      catalog = Catalog.decode(raw);
    } catch (e) {
      AppLog.warn('导入商品目录失败', e);
      final message = e is FormatException ? e.message : '$e';
      return CatalogImportResult.failure(message);
    }
    try {
      await _storage.write(customKey, catalog.encode());
    } catch (e) {
      AppLog.warn('保存自定义商品目录失败', e);
      return const CatalogImportResult.failure('本地存储不可用，导入未保存');
    }
    _current = catalog;
    _usingCustom = true;
    AppLog.info('商品目录已导入：${catalog.products.length} 件商品');
    return CatalogImportResult.success(catalog);
  }

  Future<Catalog> restoreBuiltIn() async {
    try {
      await _storage.remove(customKey);
    } catch (e) {
      AppLog.warn('清除自定义商品目录失败', e);
    }
    _usingCustom = false;
    final loaded = await source.load();
    _current = loaded ?? Catalog.fromSeed();
    AppLog.info('已恢复${source.label}商品目录');
    return _current!;
  }

  String exportJson() => current.encode();
}
