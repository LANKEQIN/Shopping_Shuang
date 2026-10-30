import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/catalog.dart';
import 'package:shoping_shuang/pages/settings_page.dart';
import 'package:shoping_shuang/repositories/catalog_repository.dart';
import 'package:shoping_shuang/state.dart';
import 'package:shoping_shuang/storage.dart';

import 'helpers.dart';

class _TestCatalogSource extends CatalogSource {
  _TestCatalogSource(this.catalog);

  final Catalog catalog;

  @override
  String get label => '测试数据源';

  @override
  Future<Catalog?> load() async => catalog;
}

String _customCatalogJson() {
  final data = Catalog.fromSeed().toJson();
  final products = data['products'] as List<dynamic>;
  (products.first as Map<String, dynamic>)['name'] = '自定义 iPhone';
  return jsonEncode(data);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('内置 catalog.json 可加载并通过校验', () async {
    final catalog = await const AssetCatalogSource().load();
    expect(catalog, isNotNull);
    expect(catalog!.products, hasLength(150));
    expect(catalog.banners, hasLength(4));
    expect(catalog.liveRooms, hasLength(6));
    expect(catalog.seckillIds, hasLength(12));
    expect(catalog.hotSearches, hasLength(8));
  });

  test('资产目录与 data.dart 种子数据保持一致', () async {
    final asset = await const AssetCatalogSource().load();
    expect(asset, isNotNull);
    expect(asset!.encode(), Catalog.fromSeed().encode());
  });

  test('目录 JSON 编解码往返一致', () {
    final seed = Catalog.fromSeed();
    final decoded = Catalog.decode(seed.encode());
    expect(decoded.products, hasLength(seed.products.length));
    expect(decoded.products.first.name, seed.products.first.name);
    expect(decoded.products.first.tags, seed.products.first.tags);
    expect(decoded.banners.first.colors, seed.banners.first.colors);
    expect(decoded.liveRooms.first.productIds, seed.liveRooms.first.productIds);
    expect(decoded.seckillIds, seed.seckillIds);
    expect(decoded.hotSearches, seed.hotSearches);
  });

  test('非法目录被拒绝且不会崩溃', () {
    expect(Catalog.tryParse('{broken'), isNull);
    expect(Catalog.tryParse(jsonEncode({'products': <Object>[]})), isNull);

    final data = Catalog.fromSeed().toJson();
    (data['products'] as List<dynamic>).first['price'] = -1;
    expect(Catalog.tryParse(jsonEncode(data)), isNull);

    final dup = Catalog.fromSeed().toJson();
    final products = dup['products'] as List<dynamic>;
    (products[1] as Map<String, dynamic>)['id'] =
        (products.first as Map<String, dynamic>)['id'];
    expect(Catalog.tryParse(jsonEncode(dup)), isNull);
  });

  test('自定义目录优先于数据源，恢复内置后回到数据源', () async {
    final storage = MemoryStorage();
    final repository = CatalogRepository(
      storage,
      source: _TestCatalogSource(Catalog.fromSeed()),
    );
    final result = await repository.importFromJson(_customCatalogJson());
    expect(result.ok, isTrue);
    expect(repository.sourceLabel, '自定义数据');

    final loaded = await repository.load();
    expect(loaded.products.first.name, '自定义 iPhone');
    expect(repository.usingCustom, isTrue);
    expect(await storage.read(CatalogRepository.customKey), isNotNull);

    await repository.restoreBuiltIn();
    expect(repository.usingCustom, isFalse);
    expect(
      repository.current.products.first.name,
      Catalog.fromSeed().products.first.name,
    );
    expect(await storage.read(CatalogRepository.customKey), isNull);
  });

  test('导入错误返回可读提示', () async {
    final repository = CatalogRepository(
      MemoryStorage(),
      source: _TestCatalogSource(Catalog.fromSeed()),
    );
    final result = await repository.importFromJson(
      jsonEncode({'products': <Object>[]}),
    );
    expect(result.ok, isFalse);
    expect(result.error, contains('products'));
  });

  test('AppState 导入目录后跨启动恢复，重置后回到内置', () async {
    final storage = MemoryStorage();
    final source = _TestCatalogSource(Catalog.fromSeed());
    await AppState.instance.init(storage: storage, catalogSource: source);
    expect(AppState.instance.catalogUsingCustom, isFalse);
    expect(AppState.instance.products, hasLength(150));

    final result = await AppState.instance.importCatalog(_customCatalogJson());
    expect(result.ok, isTrue);
    expect(AppState.instance.catalogUsingCustom, isTrue);
    expect(AppState.instance.products.first.name, '自定义 iPhone');
    await AppState.instance.flush();

    await AppState.instance.init(storage: storage, catalogSource: source);
    expect(AppState.instance.catalogUsingCustom, isTrue);
    expect(AppState.instance.products.first.name, '自定义 iPhone');
    expect(
      AppState.instance.findProduct(1)?.name,
      '自定义 iPhone',
    );

    await AppState.instance.resetAll();
    expect(AppState.instance.catalogUsingCustom, isFalse);
    expect(AppState.instance.products, hasLength(150));
  });

  testWidgets('设置页商品数据入口可打开导出与导入弹窗', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrapPage(const SettingsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('导出 JSON'));
    await tester.pumpAndSettle();
    expect(find.text('导出商品数据'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('导入 JSON'));
    await tester.pumpAndSettle();
    expect(find.text('导入商品数据'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
