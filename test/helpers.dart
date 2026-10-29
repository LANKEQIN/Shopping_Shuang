import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_shuang/state.dart';
import 'package:shoping_shuang/storage.dart';
import 'package:shoping_shuang/theme.dart';

Future<void> initAppState() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.init(storage: MemoryStorage());
}

Widget wrapPage(Widget page, {Skin skin = Skin.taobao}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(skin),
    home: page,
  );
}
