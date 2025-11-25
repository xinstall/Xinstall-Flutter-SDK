import 'package:flutter/material.dart';
import 'package:xinstall_flutter_plugin/xinstall_flutter_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xinstall Plugin example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Xinstall Plugin example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 唤醒参数
  String? _wakeUpData;

  // 唤醒参数
  String? _wakeUpDetailData;

  //  安装参数
  String? _installData;
  late XinstallFlutterPlugin _xinstallFlutterPlugin;

  @override
  void initState() {
    super.initState();
    initXInstallPlugin();
  }

  // 初始化时，需要传入拉起回调获取 web 端传过来的动态参数
  Future<void> initXInstallPlugin() async {
    if (!mounted) return;

    _xinstallFlutterPlugin = XinstallFlutterPlugin.getInstance();
    _xinstallFlutterPlugin.setDebug(true);

    // _xinstallFlutterPlugin.init();
    _xinstallFlutterPlugin.initWithConfigure(
        {"androidId": "1234", "serial": "1234", "canClip": false});

    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"gaid":"测试gaid","isPermission":true,"androidId":"1234","serial":"1234","canClip":false},xPermissionBackHandler);

    // if (await Permission.phone.request().isGranted) {
    //   _xinstallFlutterPlugin.resultWithPermission({"isSuccess":true});
    // } else {
    //   _xinstallFlutterPlugin.resultWithPermission({"isSuccess":false});
    // }

    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"isPermission":true,"gaid":"测试gaid"},xPermissionBackHandler);
    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"isPermission":true,"gaid":"测试gaid","oaid":"测试oaid"},xWakeupParamHandler,xPermissionBackHandler);

    // _xinstallFlutterPlugin.initWithAd({"idfa":"测试外传idfa"},xwakeupParamHandler,xPermissionBackHandler);
    _getXInstallParam();
    _wakeUpRegister();
    // _wakeUpDetailRegister();
  }

  Future xPermissionBackHandler() async {
    setState(() {
      print("执行了获取安装参数的方法");
      _getXInstallParam();
    });
  }

  Future xWakeupParamHandler(Map<String, dynamic> data) async {
    setState(() {
      _wakeUpData = data.toString();
      print(_wakeUpData);
    });
  }

  Future xwakeupDetailParamHandler(Map<String, dynamic> data) async {
    setState(() {
      _wakeUpDetailData = data.toString();
      print(_wakeUpDetailData);
    });
  }

  //获取安装参数
  void _getXInstallParam() {
    _xinstallFlutterPlugin.getInstallParam(xinstallParamHandler);
  }

  Future xinstallParamHandler(Map<String, dynamic> data) async {
    setState(() {
      _installData = data.toString();
      print(_installData);
    });
  }

  //注册统计
  void _reportRegister() {
    _xinstallFlutterPlugin.reportRegister();
    print("点击上报-注册统计");
  }

  //事件统计
  void _reportPoint() {
    _xinstallFlutterPlugin.reportPoint("eventId", 1);
    print("点击上报-事件统计");
  }

  //事件详情统计
  void _reportEventWhenOpenDetailInfo() {
    _xinstallFlutterPlugin.reportEventWhenOpenDetailInfo(
        "122", 122, "Flutter_Example");
    print("点击上报-事件详情统计");
  }

  //注册wakeup 函数
  void _wakeUpRegister() {
    _xinstallFlutterPlugin.registerWakeUpHandler(xWakeupParamHandler);
  }

  // ignore: unused_element
  void _wakeUpDetailRegister() {
    _xinstallFlutterPlugin
        .registerWakeUpDetailHandler(xwakeupDetailParamHandler);
  }

  // 分享裂变上报
  void _reportShareByXinShareId() {
    _xinstallFlutterPlugin.reportShareByXinShareId("Flutter Test");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Row(
          children: [
            Icon(Icons.settings_applications, color: colorScheme.onPrimary),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 提示信息卡片
            Card(
              elevation: 2,
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "调试日志请在控制台查看",
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 参数信息区域
            Text(
              "参数信息",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // 唤起参数卡片
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(Icons.wb_sunny, color: colorScheme.primary),
                title: const Text(
                  "唤起参数",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _wakeUpData ?? "暂无数据",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _wakeUpData != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                children: [
                  if (_wakeUpData != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SelectableText(
                        _wakeUpData!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "暂无数据",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 唤醒详情参数卡片
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(Icons.details, color: colorScheme.secondary),
                title: const Text(
                  "唤醒详情参数",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _wakeUpDetailData ?? "暂无数据",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _wakeUpDetailData != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                children: [
                  if (_wakeUpDetailData != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SelectableText(
                        _wakeUpDetailData!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "暂无数据",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 安装参数卡片
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: ExpansionTile(
                leading: Icon(Icons.download, color: colorScheme.tertiary),
                title: const Text(
                  "安装参数",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _installData ?? "暂无数据",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _installData != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                children: [
                  if (_installData != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SelectableText(
                        _installData!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "暂无数据",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 功能按钮区域
            Text(
              "功能操作",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // 获取安装参数按钮
            ElevatedButton.icon(
              onPressed: _getXInstallParam,
              icon: const Icon(Icons.get_app),
              label: const Text("获取安装参数"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 注册事件上报按钮
            ElevatedButton.icon(
              onPressed: _reportRegister,
              icon: const Icon(Icons.app_registration),
              label: const Text("注册事件上报"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 自定义事件上报按钮
            OutlinedButton.icon(
              onPressed: _reportPoint,
              icon: const Icon(Icons.track_changes),
              label: const Text("自定义事件上报"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 事件详情上报按钮
            OutlinedButton.icon(
              onPressed: _reportEventWhenOpenDetailInfo,
              icon: const Icon(Icons.info),
              label: const Text("事件详情上报"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 分享裂变上报按钮
            ElevatedButton.icon(
              onPressed: _reportShareByXinShareId,
              icon: const Icon(Icons.share),
              label: const Text("分享裂变上报"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
