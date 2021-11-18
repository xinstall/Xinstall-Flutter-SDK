package com.shubao.xinstall_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.xinstall.XINConfiguration;
import com.xinstall.XInstall;
import com.xinstall.listener.XInstallAdapter;
import com.xinstall.listener.XWakeUpAdapter;
import com.xinstall.model.XAppData;
import com.xinstall.model.XAppError;

import java.util.HashMap;
import java.util.Map;
import org.json.JSONObject;

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
  private static final String TAG = "XinstallFlutterSDK";

  private static MethodChannel channel;

  private static volatile boolean hasCallInit = false;

  private static Registrar _registrar = null;
  private static Intent wakeupIntent = null;
  private static Activity wakeupActivity = null;

  private static final Handler UIHandler = new Handler(Looper.getMainLooper());

  private  static void runInUIThread(Runnable runnable) {
    if (Looper.myLooper() == Looper.getMainLooper()) {
      // 当前线程为UI主线程
      runnable.run();
    } else {
      UIHandler.post(runnable);
    }
  }

  public static void registerWith(final Registrar registrar) {
    runInUIThread(new Runnable() {
      @Override
      public void run() {
        registerWithInMain(registrar);
      }
    });
  }

  private static void  registerWithInMain(Registrar registrar) {
    _registrar = registrar;
    channel = new MethodChannel(registrar.messenger(), "xinstall_flutter_plugin");
    channel.setMethodCallHandler(new XinstallFlutterPlugin());

    System.out.println("registerWith");

    registrar.addNewIntentListener(new PluginRegistry.NewIntentListener() {
      @Override
      public boolean onNewIntent(Intent intent) {
        if (hasCallInit) {
          XInstall.getWakeUpParam(_registrar.activity(),intent, wakeUpAdapter);
        } else {
          wakeupIntent = intent;
          wakeupActivity = _registrar.activity();
        }
        return false;
      }
    });
  }

  private static XWakeUpAdapter wakeUpAdapter = new XWakeUpAdapter() {
    @Override
    public void onWakeUp(XAppData xAppData) {
      super.onWakeUp(xAppData);
      channel.invokeMethod("onWakeupNotification", xData2Map(xAppData,false));
      wakeupIntent = null;
      wakeupActivity = null;
    }

    @Override
    public void onWakeUpFinish(XAppData xAppData, XAppError xAppError) {
      super.onWakeUpFinish(xAppData, xAppError);
      channel.invokeMethod("onWakeupEvenErrorAlsoCallBackNotification", xDataHasErrorMap(xAppData,xAppError));
      wakeupIntent = null;
      wakeupActivity = null;
    }
  };

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    System.out.println("onMethodCall");

    if (call.method.equals("getInstallParam")) {
      // 安装参数获取
      getInstallParams(call);
      result.success("getInstallParam success, wait callback");

    } else if (call.method.equals("reportRegister")) {
      // 上报注册
      reportRegister();
      result.success("reportRegister success");

    } else if (call.method.equals("reportPoint")) {
      // 埋点上报
      reportPoint(call, result);

    } else if (call.method.equals("init")) {
      // 初始化
      init();
      result.success("init success");

    } else if (call.method.equals("initWithAd")){
      // 广告初始化
      initWithAd(call,result);

    } else if (call.method.equals("reportShareByXinShareId")){
      // 分享裂变事件上报
      reportShareByXinShareId(call,result);

    } else if (call.method.equals("setLog")){
          // 设置Log 答应
      runInUIThread(new Runnable() {
        @Override
        public void run() {
          XInstall.setDebug(true);
        }
      });
    } else {
      result.notImplemented();
    }
  }

  private void reportRegister() {
    XInstall.reportRegister();
  }

  private void reportPoint(MethodCall call, Result result) {
    String pointId = call.argument("pointId");
    Integer pointValue = call.argument("pointValue");
    Integer duration = call.argument("duration");
    XInstall.reportEvent(pointId, pointValue == null ? 0 : pointValue, duration == null ? 0 : duration);
    result.success("reportPoint success");
  }

  private void reportShareByXinShareId(MethodCall call, Result result) {
    String userId = call.argument("userId");
    XInstall.reportShareByXinShareId(userId);
    result.success("reportShareById success");
  }

  private void getInstallParams(final MethodCall call) {
    runInUIThread(new Runnable() {
      @Override
      public void run() {
        getInstallParamsInMain(call);
      }
    });
  }

  private void getInstallParamsInMain(MethodCall call) {
    Integer timeout = call.argument("timeout");
    XInstall.getInstallParam(new XInstallAdapter() {
      @Override
      public void onInstall(XAppData xAppData) {
        channel.invokeMethod("onInstallNotification", xData2Map(xAppData,true));
      }
    }, timeout == null ? 0 : timeout);
  }

  private void initWithAd(final MethodCall call, final Result result) {
    Context context = _registrar.context();
    if (context != null) {
      runInUIThread(new Runnable() {
        @Override
        public void run() {
          initWithAdInMain(call,result);
        }
      });
    } else {
      System.out.println("Context is null, can not init Xinstall");
    }
  }

  private void initWithAdInMain(final MethodCall call, final Result result) {
    hasCallInit = true;
    XINConfiguration configuration = XINConfiguration.Builder();
    boolean adEnable = true;
    if (call.hasArgument("adEnable")) {
      adEnable = call.argument("adEnable");
    }
    configuration.adEnable(adEnable);

    if (call.hasArgument("oaid")) {
      String oaid = call.argument("oaid");
      if (oaid instanceof String && oaid.length() > 0) {
        configuration.oaid(oaid);
      }
    }

    if (call.hasArgument("gaid")) {
      String gaid = call.argument("gaid");
      if (gaid instanceof String && gaid.length() > 0) {
        configuration.gaid(gaid);
      }
    }

    boolean isNeedDealPermission = true;
    if (call.hasArgument("isPermission")) {
      isNeedDealPermission = call.argument("isPermission");
    }

    if (isNeedDealPermission) {
      XInstall.initWithPermission(_registrar.activity(), configuration, new Runnable() {
        @Override
        public void run() {

          xinitialized();
          if (channel != null) {
            channel.invokeMethod("onPermissionBackNotification",new HashMap<>());
          }
          result.success("initWithAd success");
        }
      });
    } else {
      XInstall.initWithPermission(_registrar.activity(),configuration);

      xinitialized();
      if (channel != null) {
        channel.invokeMethod("onPermissionBackNotification", new HashMap<>());

      }
      result.success("initWithAd success");
    }
  }

  private void init() {
    final Context context = _registrar.context();
    if (context != null) {
      runInUIThread(new Runnable() {
        @Override
        public void run() {
          initInMain(context);
        }
      });
    } else {
      System.out.println("Context is null, can not init Xinstall");
    }
  }

  private void initInMain(Context context) {
    hasCallInit = true;
    XInstall.init(context);
    xinitialized();

  }

  private void xinitialized() {
    if (wakeupIntent != null && wakeupActivity != null) {
      XInstall.getWakeUpParam(wakeupActivity,wakeupIntent, wakeUpAdapter);
      wakeupActivity = null;
      wakeupIntent = null;
    } else {
      Activity activity = _registrar.activity();
      if (activity != null) {
        XInstall.getWakeUpParam(_registrar.activity(),activity.getIntent(), wakeUpAdapter);
      }
      wakeupActivity = null;
      wakeupIntent = null;
    }
  }


  private static Map<String, String> xData2Map(XAppData data,boolean isInit) {
    Map<String, String> result = new HashMap<>();
    if (data != null) {
      Map<String, String> extraData = data.getExtraData();
      result.putAll(extraData);
      JSONObject jo2 = data.toJsonObject();
      JSONObject da = new JSONObject();
      if (data.isEmpty()){

      }else {
        try{
          da = jo2.getJSONObject("data");
        }catch (Exception e){

        }
      }
      result.put("data",da.toString());
      System.out.println(jo2.toString());
      result.put("channelCode", data.getChannelCode());
      result.put("timeSpan", data.getTimeSpan());
      if (isInit) {
        result.put("isFirstFetch", data.isFirstFetch() + "");
      }
    }
    return result;
  }

  private static Map<String, Object> xDataHasErrorMap(XAppData data, XAppError xAppError) {
    Map<String, String> wakeUpData = xData2Map(data, false);
    Map<String, String> error = new HashMap<>();
    if (xAppError != null) {
      error.put("errorType",xAppError.getErrorCode());
      error.put("errorMsg",xAppError.getErrorMsg());
    }
    Map<String, Object> result = new HashMap<>();
    result.put("wakeUpData",wakeUpData);
    result.put("error",error);
    return  result;
  }
}
