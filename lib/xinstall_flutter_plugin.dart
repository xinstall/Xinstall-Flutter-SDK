import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> data);
typedef Future<dynamic> EventNoParamsHanlder();

class XinstallFlutterPlugin {
  XinstallFlutterPlugin._();

  static final XinstallFlutterPlugin _instance = XinstallFlutterPlugin._();

  factory XinstallFlutterPlugin.getInstance() => _instance;

  Future defaultHandler() async {}

  EventHandler _wakeupHandler;
  EventHandler _wakeupDetailHanlder;
  EventHandler _installHandler;
  EventNoParamsHanlder _permissionBackHandler;

  static const MethodChannel _channel =
      const MethodChannel('xinstall_flutter_plugin');

  void init() {
    _channel.invokeMethod("init");
    _channel.setMethodCallHandler(_handleMethod);
  }

  void initWithAd(Map params,EventNoParamsHanlder permissionBackHandler) {
    _permissionBackHandler = permissionBackHandler;

    _channel.invokeMethod("initWithAd",params);
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<Null> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onWakeupNotification":
        if (_wakeupHandler == null) {
          return defaultHandler();
        }
        return _wakeupHandler(call.arguments.cast<String, dynamic>());
      case "onWakeupDetailNotification":
        if (_wakeupDetailHanlder == null) {
          return defaultHandler();
        }
        return _wakeupDetailHanlder(call.arguments.cast<String, dynamic>());
      case "onInstallNotification":
        if (_installHandler == null) {
          return defaultHandler();
        }
        return _installHandler(call.arguments.cast<String, dynamic>());
      case "onPermissionBackNotification":
        print("onPermissionBackNotification 通知");
        if (_permissionBackHandler == null) {
          return defaultHandler();
        }
        return _permissionBackHandler();

      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }

  void getInstallParam(EventHandler installHandler, [int timeout = 10]) {
    var args = new Map();
    args["timeout"] = timeout;
    this._installHandler = installHandler;
    _channel.invokeMethod('getInstallParam', args);
  }

  void registerWakeUpHandler(EventHandler wakeupHandler) {
    if (this._wakeupHandler != null) {
       print("重复注册WakeUp，只有最近一次回调会有效");
    }
    this._wakeupHandler = wakeupHandler;
    _channel.invokeMethod('registerWakeUpHandler');
  }
  
  void registerWakeUpDetailHandler(EventHandler wakeupDetailHandler) {
    if(this._wakeupDetailHanlder != null) {
      print("重复注册wakeUpDetail, 只有最近一次回调会有效");
    }
    this._wakeupDetailHanlder = wakeupDetailHandler;
    _channel.invokeMethod("registerWakeUpDetailHandler");
  }

  void reportRegister() {
    _channel.invokeMethod('reportRegister');
  }

  void reportPoint(String pointId, int pointValue, [int duration = 0]) {
    var args = new Map();
    args["pointId"] = pointId;
    args["pointValue"] = pointValue;
    args["duration"] = duration;
    _channel.invokeMethod('reportPoint', args);
  }

  void reportShareByXinShareId(String shareId) {
    var args = new Map();
    args["shareId"] = shareId;
    _channel.invokeMethod('reportShareByXinShareId',args);
  }
}
