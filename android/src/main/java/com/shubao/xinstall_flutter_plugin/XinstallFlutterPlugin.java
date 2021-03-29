package com.shubao.xinstall_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.xinstall.XInstall;
import com.xinstall.listener.XInstallAdapter;
import com.xinstall.listener.XWakeUpAdapter;
import com.xinstall.model.XAppData;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPlugin
 */
public class XinstallFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

  private static MethodChannel channel;
  private static XAppData mXAppData = null;
  private static boolean wakeUpFlag = false;

  @java.lang.Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.shubao.xinstall/xinstall_flutter_plugin");
    channel.setMethodCallHandler(this);

    System.out.println("onAttachedToEngine");

    XInstall.setDebug(true);
    XInstall.init(flutterPluginBinding.getApplicationContext());
  }

  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "com.shubao.xinstall");
    channel.setMethodCallHandler(new com.shubao.xinstall_flutter_plugin.XinstallFlutterPlugin());

    System.out.println("registerWith");

    registrar.addNewIntentListener(new PluginRegistry.NewIntentListener() {
      @java.lang.Override
      public boolean onNewIntent(android.content.Intent intent) {
        XInstall.getWakeUpParam(intent, wakeUpAdapter);
        return true;
      }
    });

    Context context = registrar.context();
    if (context != null) {
      XInstall.init(context);
    }
    Activity activity = registrar.activity();
    if (activity != null) {
      XInstall.getWakeUpParam(activity.getIntent(), wakeUpAdapter);
    }
  }

  private static XWakeUpAdapter wakeUpAdapter = new XWakeUpAdapter() {
    @java.lang.Override
    public void onWakeUp(XAppData xAppData) {
      if (wakeUpFlag) {
        channel.invokeMethod("onWakeupNotification", xData2Map(mXAppData));
        mXAppData = null;
      } else {
        mXAppData = xAppData;
      }
    }
  };

  @java.lang.Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    System.out.println("onMethodCall");

    if (call.method.equals("getInstallParam")) {
      Integer timeout = call.argument("timeout");
      XInstall.getInstallParam(new XInstallAdapter() {
        @java.lang.Override
        public void onInstall(XAppData xAppData) {
          channel.invokeMethod("onInstallNotification", xData2Map(xAppData));
        }
      }, timeout == null ? 0 : timeout);
      result.success("getInstallParam success, wait callback");
    } else if (call.method.equals("reportRegister")) {
      XInstall.reportRegister();
      result.success("reportRegister success");
    } else if (call.method.equals("reportPoint")) {
      String pointId = call.argument("pointId");
      Integer pointValue = call.argument("pointValue");
      Integer duration = call.argument("duration");
      XInstall.reportPoint(pointId, pointValue == null ? 0 : pointValue, duration == null ? 0 : duration);
      result.success("reportPoint success");
    } else if (call.method.equals("getWakeUpParam")) {
      wakeUpFlag = true;
      if (mXAppData != null) {
        channel.invokeMethod("onWakeupNotification", xData2Map(mXAppData));
        mXAppData = null;
      }
      result.success("getWakeUpParam success");
    } else {
      result.notImplemented();
    }
  }

  @java.lang.Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    System.out.println("onDetachedFromEngine");
  }

  @java.lang.Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(new PluginRegistry.NewIntentListener() {
      @java.lang.Override
      public boolean onNewIntent(Intent intent) {
        XInstall.getWakeUpParam(intent, wakeUpAdapter);
        return true;
      }
    });

    XInstall.getWakeUpParam(binding.getActivity().getIntent(), wakeUpAdapter);
  }

  @java.lang.Override
  public void onDetachedFromActivityForConfigChanges() {
  }

  @java.lang.Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
  }

  @java.lang.Override
  public void onDetachedFromActivity() {

  }

  private static Map<String, String> xData2Map(XAppData data) {
    Map<String, String> result = new HashMap<>();
    Map<String, String> extraData = data.getExtraData();
    result.putAll(extraData);
    result.put("channelCode", data.getChannelCode());
    result.put("timeSpan", data.getTimeSpan());
    result.put("isFirstFetch", data.isFirstFetch()+"");
    return result;
  }
}
