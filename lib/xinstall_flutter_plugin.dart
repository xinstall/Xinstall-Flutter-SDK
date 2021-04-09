import 'dart:async';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> data);

class XinstallFlutterPlugin {
  XinstallFlutterPlugin._();

  static final XinstallFlutterPlugin _instance = XinstallFlutterPlugin._();

  factory XinstallFlutterPlugin.getInstance() => _instance;

  Future defaultHandler() async {}

  EventHandler _wakeupHandler;
  EventHandler _installHandler;

  static const MethodChannel _channel =
      const MethodChannel('xinstall_flutter_plugin');

  void init(EventHandler wakeupHandler) {
    _wakeupHandler = wakeupHandler;
    _channel.invokeMethod("init");
    _channel.invokeMethod("getWakeUpParam");
    _channel.setMethodCallHandler(_handleMethod);

  }

  Future<Null> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onWakeupNotification":
        if (_wakeupHandler == null) {
          return defaultHandler();
        }
        return _wakeupHandler(call.arguments.cast<String, dynamic>());
      case "onInstallNotification":
        if (_installHandler == null) {
          return defaultHandler();
        }
        return _installHandler(call.arguments.cast<String, dynamic>());
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
}
