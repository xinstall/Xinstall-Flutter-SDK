import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:xinstall_flutter_plugin/xinstall_flutter_plugin.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    // _xinstallFlutterPlugin.init();
    _xinstallFlutterPlugin.initWithConfigure({"androidId":"1234","serial":"1234","canClip":false});
    // _xinstallFlutterPlugin.initWithConfigure({"serial":"1234","canClip":false});

    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"gaid":"测试gaid","isPermission":true,"androidId":"1234","serial":"1234","canClip":false},xPermissionBackHandler);

    // if (await Permission.phone.request().isGranted) {
    //   _xinstallFlutterPlugin.resultWithPermission({"isSuccess":true});
    // } else {
    //   _xinstallFlutterPlugin.resultWithPermission({"isSuccess":false});
    // }


    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"isPermission":true,"gaid":"测试gaid"},xwakeupParamHandler,xPermissionBackHandler);
    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"isPermission":true,"gaid":"测试gaid","oaid":"测试oaid"},xwakeupParamHandler,xPermissionBackHandler);
    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"isPermission":true,"gaid":"测试gaid","oaid":"测试oaid"},xwakeupParamHandler,null);

    // _xinstallFlutterPlugin.initWithAd({"idfa":"测试外传idfa"},xwakeupParamHandler,xPermissionBackHandler);
    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"isPermission":true,"gaid":"测试gaid","oaid":"测试oaid"},xwakeupParamHandler,xPermissionBackHandler);
    //_xinstallFlutterPlugin.initWithAd({"idfa":"测试外传idfa"},xwakeupParamHandler,null);
    // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"idfa":"测试外传idfa","asaEnable":true},xPermissionBackHandler);

    _getXInstallParam();
    _wakeUpRegister();
    // _wakeUpDetailRegister();
  }

  Future xPermissionBackHandler() async {
    setState((){
      print("执行了获取安装参数的方法");
      _getXInstallParam();
    });
  }

  Future xwakeupParamHandler(Map<String, dynamic> data) async {
    setState(() {
      var d = data["data"];
      var timeSpan = data["timeSpan"];
      var channelCode = data["channelCode"];
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
      var d = data["data"];
      var timeSpan = data["timeSpan"];
      var channelCode = data["channelCode"];
      var isFirstFetch = data["isFirstFetch"];
      _installData = data.toString();
      print(_installData);
    });
  }

  //注册统计
  void _reportRegister() {
    _xinstallFlutterPlugin.reportRegister();
  }

  //事件统计
  void _reportPoint() {
    _xinstallFlutterPlugin.reportPoint("eventId", 1);
  }

  //事件详情统计
  void _reportEventWhenOpenDetailInfo() {
    _xinstallFlutterPlugin.reportEventWhenOpenDetailInfo("122", 122, "华文杰Flutter_Android");
  }

  //注册wakeup 函数
  void _wakeUpRegister() {
    _xinstallFlutterPlugin.registerWakeUpHandler(xwakeupParamHandler);
  }

  void _wakeUpDetailRegister() {
    _xinstallFlutterPlugin.registerWakeUpDetailHandler(xwakeupDetailParamHandler);
  }

  // 分享裂变上报
  void _reportShareByXinShareId() {
    _xinstallFlutterPlugin.reportShareByXinShareId("Flutter Test");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Xinstall Plugin example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("调试日志请在控制台查看change"),
            Text("唤起参数-wakeUpData:$_wakeUpData"),
            Text("唤醒参数-wakeUpDetailData:$_wakeUpDetailData"),
            Text("安装参数-installData:$_installData"),
            MaterialButton(
              child: Text("获取安装参数-getInstall"),
              onPressed: _getXInstallParam,
            ),
            MaterialButton(
              child: Text("注册事件上报-reportRegister"),
              onPressed: _reportRegister,
            ),
            Row(
              children: [],
            ),
            MaterialButton(
              child: Text("自定义事件上报-reportPoint"),
              onPressed: _reportPoint,
            ),
            Row(
              children: [],
            ),
            MaterialButton(
              child: Text("事件详情上报-reportPoint"),
              onPressed: _reportEventWhenOpenDetailInfo,
            ),
            Row(
              children: [],
            ),
            MaterialButton(
              child: Text("分享裂变上报-reportShareByXinShareId"),
              onPressed: _reportShareByXinShareId,
            )

          ],
        ),
      ),
    );
  }
}
