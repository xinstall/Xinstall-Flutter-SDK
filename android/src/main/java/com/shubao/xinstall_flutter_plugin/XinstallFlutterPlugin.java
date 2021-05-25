package com.shubao.xinstall_flutter_plugin;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import com.xinstall.XInstall;
import com.xinstall.listener.XInstallAdapter;
import com.xinstall.listener.XWakeUpAdapter;
import com.xinstall.model.XAppData;

import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPlugin
 */
public class XinstallFlutterPlugin implements MethodCallHandler {

  private static final String TAG = "XinstallFlutterPlugin";
  private static MethodChannel channel;
  private static Registrar _registrar = null;
  private static Intent intentHolder = null;
  private static volatile boolean INIT = false;


  public static void registerWith(Registrar registrar) {
    _registrar = registrar;
    channel = new MethodChannel(registrar.messenger(), "xinstall_flutter_plugin");
    channel.setMethodCallHandler(new com.shubao.xinstall_flutter_plugin.XinstallFlutterPlugin());

    Log.d(TAG,"registerWith");

    registrar.addNewIntentListener(new PluginRegistry.NewIntentListener() {
      @Override
      public boolean onNewIntent(Intent intent) {
        if (INIT) {
          XInstall.getWakeUpParam(intent, wakeUpAdapter);
        } else {
          intentHolder = intent;
        }
        return false;
      }
    });
    Activity activity = registrar.activity();
    if (activity != null) {
      Application application = activity.getApplication();
      if (application != null) {
        application.registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
          @Override
          public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
          }

          @Override
          public void onActivityStarted(Activity activity) {
          }

          @Override
          public void onActivityResumed(Activity activity) {
            Log.d(TAG,"onActivityResumed");
            XInstall.getYybWakeUpParam(activity,activity.getIntent(),wakeUpAdapter);
          }

          @Override
          public void onActivityPaused(Activity activity) {
          }

          @Override
          public void onActivityStopped(Activity activity) {
          }

          @Override
          public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
          }

          @Override
          public void onActivityDestroyed(Activity activity) {
          }
        });
      }
    }
  }

  private static XWakeUpAdapter wakeUpAdapter = new XWakeUpAdapter() {
    @Override
    public void onWakeUp(XAppData xAppData) {
      channel.invokeMethod("onWakeupNotification", xData2Map(xAppData,false));
      intentHolder = null;
    }
  };

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.d(TAG,"onMethodCall");

    if (call.method.equals("getInstallParam")) {
      Integer timeout = call.argument("timeout");
      XInstall.getInstallParam(new XInstallAdapter() {
        @Override
        public void onInstall(XAppData xAppData) {
          channel.invokeMethod("onInstallNotification", xData2Map(xAppData,true));
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
    } else if (call.method.equals("init")) {
      init();
      result.success("init success");
    } else if (call.method.equals("getWakeUpParam")) {
      result.success("getWakeUpParam Deprecated");
    } else {
      result.notImplemented();
    }
  }

  private void init() {
    Context context = _registrar.context();
    if (context != null) {
      XInstall.init(context);
      INIT = true;
      if (intentHolder == null) {
        Activity activity = _registrar.activity();
        if (activity != null) {
          XInstall.getWakeUpParam(activity.getIntent(), wakeUpAdapter);
        }
      } else {
        XInstall.getWakeUpParam(intentHolder, wakeUpAdapter);
      }
    } else {
      Log.d(TAG,"Context is null, can not init Xinstall");
    }
  }


  private static Map<String, String> xData2Map(XAppData data,boolean isInit) {
    Map<String, String> result = new HashMap<>();
    if (data != null) {
      Map<String, String> extraData = data.getExtraData();
      result.putAll(extraData);
      result.put("channelCode", data.getChannelCode());
      result.put("timeSpan", data.getTimeSpan());
      if (isInit) {
        result.put("isFirstFetch", data.isFirstFetch() + "");  
      }
    }

    return result;
  }
}
