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
  //  唤醒参数
  String _wakeUpData;
  //  安装参数
  String _installData;

  XinstallFlutterPlugin _xinstallFlutterPlugin;

  @override
  void initState() {
    super.initState();
    initXInstallPlugin();
  }

  // 初始化时，需要传入拉起回调获取 web 端传过来的动态参数
  Future<void> initXInstallPlugin() async {
    if (!mounted) return;

    _xinstallFlutterPlugin = XinstallFlutterPlugin.getInstance();
    _xinstallFlutterPlugin.init(xwakeupParamHandler);
  }

  Future xwakeupParamHandler(Map<String, dynamic> data) async {
    setState(() {
      var uo = data["uo"];
      var co = data["co"];
      var timeSpan = data["timeSpan"];
      var channelCode = data["channelCode"];
      var isFirstFetch = data["isFirstFetch"];

      _wakeUpData = data.toString();

      print(_wakeUpData);
    });
  }

  //获取安装参数
  void _getXInstallParam() {
    _xinstallFlutterPlugin.getInstallParam(xinstallParamHandler);
  }

  Future xinstallParamHandler(Map<String, dynamic> data) async {
    setState(() {
      var uo = data["uo"];
      var co = data["co"];
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("wakeUpData:$_wakeUpData"),
            Text("installData:$_installData"),
            RaisedButton(
              child: Text("getInstall"),
              onPressed: _getXInstallParam,
            ),
            RaisedButton(
              child: Text("reportRegister"),
              onPressed: _reportRegister,
            ),
            Row(
              children: [],
            ),
            RaisedButton(
              child: Text("reportPoint"),
              onPressed: _reportPoint,
            )
          ],
        ),
      ),
    );
  }
}
