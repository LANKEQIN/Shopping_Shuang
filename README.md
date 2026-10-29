# 爽购 · 解压模拟商城

> 一个不花真钱、只花快乐的「缝合怪」购物 App。交互与视觉参考淘宝、京东、拼多多、抖音商城，用 Flutter 实现，本地离线运行。

---

## 一、项目简介

每天都有想买的东西，但钱包和理智不允许。**爽购**把国内主流购物平台的整套体验搬进一个模拟商城：搜索、加购、秒杀、砍一刀、抽免单、直播带货、下单支付、订单流转全部保留，唯独不产生任何真实交易。

- 无需登录、无需网络、无后端
- 商品、订单、优惠券、直播数据全部为本地模拟数据
- 支持淘宝橙 / 京东红 / 拼多多红 / 抖音黑四套皮肤，一键切换全局主题，抖音皮肤为完整暗色
- 购物车、订单、皮肤、搜索历史、优惠券与体验设置本地持久化，重启不丢
- 九大分类本地插画 + Emoji 兜底，断网也有稳定视觉
- 已固化 273 项自动化测试（冒烟、布局、持久化、玩法、服务层、商品目录、关键页面 golden）
- 已接入 GitHub Actions：analyze / test / APK / Web 构建产物，另提供手动触发的安卓端到端测试
- 已构建安卓 APK，同时保留 Flutter Web 版本用于预览

项目名称 `shoping_shuang`，应用显示名「爽购」，版本 `1.2.0+3`（阶段三已完成）。

---

## 二、功能一览

| 模块 | 已实现内容 |
| --- | --- |
| 首页 | 品牌渐变头部、搜索入口、自动轮播 Banner、十宫格金刚区、限时秒杀条、分类筛选、双列瀑布流「猜你喜欢」、分页懒加载、商品卡 Hero 过渡 |
| 搜索 | 搜索历史（持久化）、热搜榜、关键词检索、标签筛选（百亿补贴 / 自营 / 9.9 包邮 / 分类）、综合 / 销量 / 价格 / 好评排序、筛选弹窗 |
| 商品详情 | 大图展示、价格与原价、优惠券、配送与规格、店铺卡、模拟评价与我的评价发布、问大家、收藏、足迹、商品详情、相似推荐、拼团入口、Hero 进场、加购飞入动画 |
| 购物车 | 勾选、数量加减、删除、全选、凑单专区、满减凑单计算器、合计与优惠计算、去结算 |
| 结算与支付 | 收货地址、订单商品、自动选券与手动选券、支付方式、提交订单、收银台假支付、稍后支付（30 分钟待付款）、支付成功撒花页 |
| 福利中心 | 签到日历与连续签到、7 天签到奖励、每日领券中心、优惠券钱包、积分商城、会员等级与成长值、每日任务 |
| 拼团 | 商品详情发起拼团、拼团中心、模拟好友参团、成团进度、成功自动下单、失败结局、拼团记录 |
| 限时秒杀 | 四场整点场次与自动切换、场次预约提醒、排队抢购动画、抢购失败与补货、库存进度与抖动 |
| 砍一刀 | 随机好友帮砍、最后 3 元保底、进度条与砍价金额、好友排行榜、本地分享海报、0 元晒单、砍价记录持久化 |
| 抽免单 | 八格幸运转盘、权重奖池与概率公示、保底机制、每日任务、免单记录、晒单卡片 |
| 直播带货 | 直播列表、直播间弹幕、飘心、关注、讲解卡轮播、商品上下架、福袋倒计时、点赞榜、沉浸全屏、主播切换、购物袋、一键加购、进场动画 |
| 商品体验 | 类目页（分类 / 店铺 / 筛选 / 排序）、收藏与浏览足迹、评价发布、商品问答、相似推荐 |
| 订单中心 | 状态筛选、待付款倒计时与超时取消、稍后支付、申请退款、售后记录、物流轨迹动画、发票申请与记录、评价、再来一单、删除订单 |
| 解压报告 | 成就墙与解锁进度、年度账单、情绪价值指数、近 7 天消费曲线、分类偏好、每日解压任务 |
| 我的 | 会员信息与等级、资产卡、订单快捷入口、拼团 / 福利 / 报告 / 收藏入口、解压特权、平台皮肤切换、地址 / 客服 / 发票售后入口、设置入口 |
| 设置与反馈 | 动效 / 触觉 / 音效独立开关、清除本地数据、关于信息、数据本地持久化与 schema v2 迁移 |
| 商品数据 | 商品 / Banner / 直播间 / 秒杀清单迁移到 `assets/data/catalog.json`，支持导出、粘贴导入自定义商品包、恢复内置数据 |
| 全局体验 | 自定义 Toast、全屏撒花庆祝、倒计时组件、四套皮肤（含抖音全暗色）、无障碍语义、320–430 宽度与字体缩放适配、宽屏 Web 手机框预览 |

### 四套皮肤

| 皮肤 | 品牌名 | 主色 | 特点 |
| --- | --- | --- | --- |
| 淘宝 | 爽购淘 | 淘宝橙 `#FF5000` | 橙色渐变头部、暖色底部导航 |
| 京东 | 爽购京 | 京东红 `#E1251B` | 红色渐变、自营标签，首页增加「自营专区」 |
| 拼多多 | 爽购拼 | 拼多多红 `#E02E24` | 红橙渐变、补贴与包邮氛围，首页增加「拼单热榜」 |
| 抖音 | 爽购抖 | 抖音粉 `#FE2C55` + 青色 `#25F4EE` | 深色头部与底栏，首页 / 购物车 / 订单 / 我的 / 直播间 / 弹窗全暗色 |

皮肤在「我的 → 平台皮肤」中切换，`MaterialApp` 主题、头部渐变、价格色、底部导航会同步更新。

---

## 三、技术栈

| 项目 | 选型 |
| --- | --- |
| 框架 | Flutter 3.47.8 / Dart 3.13.7（单代码运行 Android + Web） |
| UI | Material 3，自定义 `ColorScheme` 与 `SkinConfig` + `SkinPalette` 主题系统 |
| 状态 | `ChangeNotifier` + Service / Repository 分层：`AppState` 只做组合根与门面，业务状态拆到 7 个域服务；不引入第三方状态库 |
| 数据 | `assets/data/catalog.json` 商品目录资产 + `CatalogSource` 数据源抽象（内置资产 / 模拟远端可注入），`lib/data.dart` 作为回退种子数据；无网络请求、无后端 |
| 持久化 | `AppRepository` + `Storage` 抽象（测试可注入 `MemoryStorage`），schema version 与迁移；自定义商品目录独立键 |
| 图片 | 九大分类本地插画（512×512 JPEG，约 150 KB）+ Emoji 兜底，断网可用 |
| 测试 | `flutter_test`：273 项（冒烟、布局矩阵、持久化、玩法、服务层、商品目录）+ 5 张关键页面 golden + `integration_test` 端到端脚本 |
| 持续集成 | GitHub Actions：Windows runner 执行 analyze / test（golden 基线一致），Linux runner 构建 APK 与 Web 并上传产物 |
| 依赖 | Flutter SDK、模板自带 `cupertino_icons`、`shared_preferences`、`integration_test`（dev） |

技术选型参考了国内电商常见的「原生 + 跨端混合」思路：真实平台多为原生主 App 配合 Flutter / H5 活动页；本项目为了单代码快速覆盖双端，整体采用 Flutter，并将主题、数据、状态分层，方便后续替换为真实接口。

---

## 四、快速开始

### 环境要求

- Flutter SDK 3.47 及以上（含 Dart 3.13）
- Android Studio / Android SDK（构建 APK）
- Chrome（调试 Web 版）

### 运行

```bash
flutter pub get
flutter run -d chrome        # Web 预览
flutter run                  # 连接安卓设备或模拟器后运行
```

### 构建

```bash
flutter build apk --release
# 产物：build/app/outputs/flutter-apk/app-release.apk

flutter build web --release
# 产物：build/web
```

### 测试

```bash
flutter analyze                       # 静态分析，要求 0 issue
flutter test                          # 273 项单元 / 组件 / golden 测试
flutter test integration_test/app_test.dart -d <deviceId>
# 端到端：浏览 → 加购 → 用券 → 支付 → 退款（需要真机或模拟器）
```

CI 在每次 push / PR 时执行 analyze、test 与 APK / Web 构建；golden 基线在 Windows 生成，
因此测试任务固定在 `windows-latest`。端到端测试因模拟器成本较高，改为手动触发工作流。

Web 产物需要静态服务器托管（不能直接双击 `index.html`）。宽屏浏览器下会自动把页面装进居中的手机框，保证移动端观感。

### 安装说明

- APK 使用 Flutter 模板默认的 debug 签名，仅适合自用安装与演示，不适合直接上架应用市场。
- 安装时如提示「未知来源应用」，需在系统设置中允许对应来源。
- 当前构建环境未连接真机或模拟器，安装兼容性尚未实测；如遇问题请反馈机型和系统版本。

---

## 五、项目结构

```text
lib/
├── main.dart                    # 入口（加载商品目录与本地快照）、MaterialApp、四 Tab 根容器、底部导航、Web 手机框
├── theme.dart                   # 四套皮肤 SkinConfig、SkinPalette 语义色、全局 ThemeData（含暗色）
├── models.dart                  # 商品、Banner、直播间、订单、优惠券、拼团、砍价、抽奖、售后等模型
├── catalog.dart                 # 商品目录模型 + JSON 校验 + CatalogSource（内置资产 / 模拟远端）
├── data.dart                    # 回退种子数据：70 件商品、Banner、直播间、热搜、券模板、任务、成就
├── state.dart                   # AppState：组合根与门面（服务装配、跨域编排、通知与防抖落盘）
├── log.dart                     # 本地日志分级（内存环形缓冲，不联网、不集成崩溃监控）
├── storage.dart                 # Storage 抽象、SharedPrefsStorage、MemoryStorage
├── repositories/
│   ├── app_repository.dart      # 应用状态仓库：单一键、schema v2、迁移
│   └── catalog_repository.dart  # 商品目录仓库：自定义导入 / 数据源 / 种子回退
├── services/
│   ├── cart_service.dart        # 购物车条目与勾选
│   ├── order_service.dart       # 订单流转、售后、发票
│   ├── coupon_service.dart      # 优惠券钱包、选券与核销
│   ├── user_service.dart        # 资产、等级、签到、每日任务、收藏足迹评价问答
│   ├── play_service.dart        # 拼团、砍价、抽免单、秒杀预约
│   ├── preference_service.dart  # 皮肤、体验开关、搜索历史
│   └── catalog_service.dart     # 活动商品目录，页面统一读取入口
├── fx.dart                      # 触觉/音效反馈、加购飞入动画
├── widgets/
│   └── pieces.dart              # 价格、标签、商品视觉（分类插画）、瀑布流、倒计时、Toast、撒花、抖动、星级
├── pages/
│   ├── home_page.dart           # 首页（分页懒加载、Hero、玩法入口）
│   ├── search_page.dart         # 搜索、排序与筛选结果
│   ├── category_page.dart       # 类目页（分类 / 店铺 / 筛选 / 排序）
│   ├── product_page.dart        # 商品详情、评价发布、问答、收藏、拼团入口
│   ├── cart_page.dart           # 购物车、满减凑单计算器
│   ├── checkout_page.dart       # 确认订单（选券）+ 收银台 + 稍后支付 + 支付成功
│   ├── benefits_page.dart       # 福利中心：签到日历、领券、积分商城、会员与每日任务
│   ├── group_buy_page.dart      # 拼团中心与拼团记录
│   ├── seckill_page.dart        # 限时秒杀场次、预约、排队与补货
│   ├── cut_price_page.dart      # 砍一刀、保底、排行榜、海报与晒单
│   ├── lottery_page.dart        # 抽免单转盘、概率公示、保底与晒单
│   ├── live_pages.dart          # 直播列表 + 直播间（讲解卡、上下架、福袋、点赞榜、全屏、主播切换）
│   ├── favorites_page.dart      # 我的收藏 / 浏览足迹
│   ├── orders_page.dart         # 订单中心、倒计时、退款、物流、发票
│   ├── after_sale_page.dart     # 退款售后与发票记录
│   ├── reports_page.dart        # 成就墙、年度账单、情绪报告、每日任务
│   ├── mine_page.dart           # 我的、皮肤切换、玩法入口
│   └── settings_page.dart       # 体验开关、商品数据导入导出、清除本地数据、关于
assets/
├── products/                    # 九大分类本地插画
└── data/
    └── catalog.json             # 商品 / Banner / 直播间 / 秒杀清单 / 热搜词
test/
├── app_smoke_test.dart          # 主流程冒烟、设置开关、暗色皮肤
├── layout_test.dart             # 20 个页面 × 4 宽度 × 2 字体缩放 + 暗色/京东/拼多多 + 横屏平板
├── persistence_test.dart        # 重启恢复、损坏数据回退、v0 迁移、清除数据
├── phase2_test.dart             # 签到 / 券 / 拼团 / 砍价 / 抽奖 / 收藏 / 售后 / v2 持久化
├── service_test.dart            # 服务层单元测试（购物车 / 订单 / 券 / 用户 / 玩法）
├── catalog_test.dart            # 目录编解码、数据源、导入导出、资产与种子一致性
├── golden_test.dart             # 5 个关键页面 golden 基线
├── goldens/                     # golden 图片
└── helpers.dart                 # 测试初始化与主题包装
integration_test/
└── app_test.dart                # 浏览 → 加购 → 用券 → 支付 → 退款 端到端
.github/workflows/
├── ci.yml                       # analyze + test + APK / Web 构建
└── integration.yml              # 手动触发的安卓模拟器端到端测试
```

---

## 六、实现说明

### 皮肤系统

`theme.dart` 用 `SkinConfig` 描述每套平台的名称、品牌、口号、主色、强调色、头部渐变、价格色、底栏配色与明暗属性，并用 `SkinPalette` 提供 `pageBg / card / textPrimary / divider` 等语义色。页面只读取语义色，不硬编码白底黑字，因此抖音皮肤下首页、购物车、订单、我的、直播间与弹窗都会自动切换为完整暗色。

### 分层架构与状态管理

阶段三把原来的 `AppState` 单体拆成「仓储 + 域服务 + 组合根」三层：

- `AppState` 只保留组合根与门面职责：装配服务、串联跨域流程（下单奖励、签到发券、积分兑换、退款回余额）、转发通知与 300ms 防抖落盘。页面继续通过 `AppState.instance` 访问，调用面保持稳定。
- `services/` 按业务域拆成购物车、订单、优惠券、用户、玩法、偏好、商品目录 7 个 `ChangeNotifier`；服务之间不互相持有，跨域动作通过回调由 `AppState` 编排。
- `repositories/` 负责数据来源：`AppRepository` 管本地状态键与迁移，`CatalogRepository` 管商品目录（自定义导入 > 数据源 > 种子回退）。
- 状态管理方案经过评估后继续使用 `ChangeNotifier`：项目已有 273 项测试与大量 `ListenableBuilder` 调用，引入 Riverpod / Provider 的收益不足以覆盖迁移风险，因此不引入第三方状态库。

### 本地持久化与数据迁移

`AppState.init()` 先加载商品目录，再读取本地快照。快照是一段带 `version` 的 JSON（当前 v2），由各服务的 `toJson()` 汇总，覆盖购物车、订单、皮肤、搜索历史、优惠券钱包、金币、余额、关注状态、签到日期、拼团、砍价、抽奖、收藏与足迹、用户评价与问答、秒杀预约、售后与发票、每日任务进度以及动效 / 触觉 / 音效开关。状态变更后 300ms 防抖写盘，应用进入后台时立即 `flush()`。

- `Storage` 抽象：运行时使用 `SharedPrefsStorage`，测试注入 `MemoryStorage`。
- 迁移入口：`AppRepository._migrate()` 按版本补齐字段；支持无版本号的 v0 数据升级到 v1，并将 v1 升级到 v2；旧版仅存券数量时自动按通用券补齐。
- 容错：JSON 损坏、字段类型异常、商品 ID 不存在时安全跳过或回退默认种子数据，失败原因写入本地日志。
- 重置：设置页可一键清除本地数据与自定义商品目录，恢复首次启动状态。

### 商品数据配置化

商品、Banner、直播间、秒杀清单与热搜词统一存放在 `assets/data/catalog.json`。`lib/catalog.dart` 定义 `Catalog` 模型、JSON 编解码与校验规则（九大分类、价格区间、原价大于售价、评分 4.7–4.9、直播间与秒杀引用完整性），`CatalogSource` 提供内置资产与模拟远端两种实现，可在 `AppState.init()` 注入。

- 页面只通过 `AppState.products / banners / liveRooms / seckillIds / hotSearches` 读取活动目录，不再直接引用 `data.dart` 常量。
- 设置页「商品数据」支持导出 JSON、粘贴导入自定义商品包、恢复内置数据；导入失败会给出具体校验原因，不会覆盖当前目录。
- 自定义目录保存在独立键 `shuang.catalog.custom`，应用状态 schema 迁移不会影响用户导入的商品包。
- `lib/data.dart` 保留为回退种子数据；`catalog_test.dart` 断言资产内容与种子数据一致，避免两份数据漂移。

### 日志与工程化

- `lib/log.dart` 提供 debug / info / warn / error 四级本地日志，内存环形缓冲最多 200 条；只用于本地问题定位，不上传、不联网、不集成崩溃监控 SDK。
- `.github/workflows/ci.yml` 在 push / PR 时执行 analyze、test 与 APK / Web 构建，构建产物作为 artifact 上传。
- `.github/workflows/integration.yml` 手动触发安卓模拟器端到端测试（浏览 → 加购 → 用券 → 支付 → 退款）。
- 质量门禁：analyze 0 issue、273 项测试全绿、golden 不变、布局矩阵无溢出。

### 商品视觉

商品视觉为「本地分类插画 + 白色圆形 Emoji 标识 + 分类角标 + 补贴角标」。九大分类各有一张 512×512 JPEG 插画，随包体总共约 150 KB，断网可用；资源缺失或加载失败时自动回退到原来的渐变 + Emoji 方案。图片按 512px 解码缓存，并通过 `RepaintBoundary` 隔离重绘。

### 动效与反馈

- 首页瀑布流商品卡到详情页使用 `Hero` 过渡（仅首页卡片携带 Hero tag，避免同路由重复 tag）。
- 加购时从按钮位置抛物线飞向底部购物车图标，并伴随 `HapticFeedback.lightImpact()` 与系统点击音。
- 秒杀抢购成功后库存文字抖动一次。
- 直播间进场使用缩放淡入，支付成功 / 免单 / 评价成功使用全屏撒花。
- 设置页可分别关闭「动效」「触觉反馈」「音效」，关闭后装饰动画降级为 Toast，震动与音效全部静默。

### 屏幕适配与测试

- 布局矩阵覆盖 320 / 360 / 390 / 430 四种宽度、字体缩放 1.0 / 1.3，以及 844×390 横屏与 800×1280 平板基础检查；关键行使用 `Flexible`、`FittedBox`、`Wrap` 与省略号避免溢出。
- `test/layout_test.dart` 对 20 个页面 × 4 宽度 × 2 字号 + 抖音暗色 + 京东/拼多多 + 横屏/平板组合做无溢出断言，共 224 项。
- `test/app_smoke_test.dart` 覆盖「浏览 → 加购 → 结算 → 支付 → 订单」主流程、设置开关与暗色皮肤切换。
- `test/persistence_test.dart` 覆盖重启恢复、损坏数据回退、v0 迁移与清除数据。
- `test/phase2_test.dart` 覆盖签到、领券、优惠券核销、拼团、砍价保底、抽奖保底、收藏足迹、评价问答、任务领取、超时取消、售后发票、v2 持久化与 v1→v2 迁移。
- `test/service_test.dart` 覆盖购物车、订单、优惠券、用户、玩法服务的纯逻辑与序列化往返。
- `test/catalog_test.dart` 覆盖目录编解码与校验、数据源优先级、导入导出、资产与种子一致性。
- `test/golden_test.dart` 为商品详情、购物车、我的、设置、类目 5 个稳定页面提供 golden 基线。
- `integration_test/app_test.dart` 覆盖「浏览 → 加购 → 用券 → 支付 → 退款」端到端脚本，需在真机或模拟器运行。

### 交易流程

「立即购买 / 购物车结算 → 确认订单（自动选券，可手动换券）→ 收银台 → 支付成功」为完整本地流程：支付页延迟 1.7 秒模拟调用支付，成功后核销优惠券、写入本地订单并清理已购购物车条目，同时播放撒花动画。收银台也支持「稍后支付」，生成 30 分钟有效的待付款订单，超时后自动取消。所有金额、优惠券、退款与发票均为模拟值。

### Web 预览

`main.dart` 的 `MaterialApp.builder` 在宽度大于 560 时把应用放进 400px 宽的手机框，并覆写 `MediaQuery`，避免桌面宽屏把移动端布局拉变形。

---

## 七、数据与隐私

- 商品共 70 件，覆盖数码、服饰、美食、家居、美妆、潮玩、运动、宠物、解压服务九类，价格 0.99 元至 12999 元。
- 直播数据 6 个房间；Banner 4 张；秒杀商品 12 件。
- 收货人固定为「幽幽子大人」，地址为虚构的「幻想乡 · 白玉楼」。
- 不采集任何个人信息，不发起网络请求，不集成统计、广告或支付 SDK。
- 购物车、订单、皮肤、搜索历史、优惠券钱包、签到、拼团、砍价、抽奖、收藏与足迹、评价问答、售后发票、每日任务与体验开关仅保存在本机 `shared_preferences`，不上传、不云同步；可在设置页一键清除。
- 自定义商品目录保存在本机独立键 `shuang.catalog.custom`，同样不上传、不云同步；恢复内置数据或一键清除时会移除。

---

## 八、已知限制

- 分类插画为类别级视觉，不是每件商品实拍图；商品辨识仍依赖 Emoji 与文案。
- 无真实账号、登录、支付、物流、售后与后端接口。
- 订单状态为本地按钮驱动流转，没有后台履约逻辑；退款、物流与发票均为本地模拟。
- 拼团好友、砍价好友、直播点赞榜与福袋均为本地随机生成，不会向真实好友发送邀请。
- 抽奖概率与保底为本地配置，奖池、积分、会员成长值均不构成真实权益。
- APK 为 universal 包（1.2.0 release 约 51.7 MB），未做 ABI 拆分与体积优化（阶段四）。
- Release 包暂用 debug 签名（阶段四接入正式 keystore）。
- 端到端测试脚本已就绪，但当前环境未连接真机或模拟器，尚未实际跑通；CI 中为手动触发工作流。
- golden 基线在 Windows 环境生成，CI 固定使用 windows-latest 以保持一致。
- 商品目录导入通过粘贴 JSON 完成，未接入系统文件选择器。
- 多语言与桌面端专属布局尚未实现（规划在阶段四）。

---

## 九、后续计划

详细路线、优先级、质量目标与风险对策见 [ROADMAP.md](ROADMAP.md)，版本变更见 [CHANGELOG.md](CHANGELOG.md)，体积与性能记录见 [docs/性能基线.md](docs/性能基线.md)。

---

## 十、免责声明

本项目为个人学习与娱乐用途的**模拟购物演示**，与淘宝、京东、拼多多、抖音及任何真实电商平台无关联，不使用其商标、Logo 或受版权保护的商品素材。四套皮肤仅以配色与交互布局作风格化致敬，所有商品、店铺、评价、订单、价格与直播内容均为虚构，不构成任何真实交易、广告或要约。
