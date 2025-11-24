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
public class XinstallFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware , PluginRegistry.NewIntentListener {
    private static final String TAG = "XinstallFlutterSDK";

    private static volatile boolean hasCallInit = false;
    private static volatile boolean hasRegister = false;
    private static volatile boolean hasDetailRegister = false;

    private static Map<String, String> wakeUpData;
    private static Map<String, Object> wakeUpDetailData;


    private static Intent wakeupIntent = null;
    private static Activity wakeupActivity = null;

    private ActivityPluginBinding activityPluginBinding;
    private FlutterPluginBinding flutterPluginBinding;
    private MethodChannel channel = null;
    private static final Handler UIHandler = new Handler(Looper.getMainLooper());

    private static void runInUIThread(Runnable runnable) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            // 当前线程为UI主线程
            runnable.run();
        } else {
            UIHandler.post(runnable);
        }
    }

    private Activity getActivity() {
        return activityPluginBinding.getActivity();
    }

    private void onWakeUp(Intent intent) {
        Activity activity = getActivity();

        if (hasCallInit) {
            XInstall.getWakeUpParamEvenErrorAlsoCallBack(activity, intent, wakeUpAdapter);
        } else {
            wakeupIntent = intent;
            wakeupActivity = activity;
        }
    }

    private XWakeUpAdapter wakeUpAdapter = new XWakeUpAdapter() {
        @Override
        public void onWakeUp(XAppData xAppData) {
            super.onWakeUp(xAppData);
            if (hasRegister) {
                channel.invokeMethod("onWakeupNotification", xData2Map(xAppData, false));
            } else {
                wakeUpData = xData2Map(xAppData, false);
            }

            wakeupIntent = null;
            wakeupActivity = null;
        }

        @Override
        public void onWakeUpFinish(XAppData xAppData, XAppError xAppError) {
            super.onWakeUpFinish(xAppData, xAppError);
            if (hasDetailRegister) {
                channel.invokeMethod("onWakeupDetailNotification", xDataHasErrorMap(xAppData, xAppError));
            } else {
                wakeUpDetailData = xDataHasErrorMap(xAppData, xAppError);
            }
            wakeupIntent = null;
            wakeupActivity = null;
        }
    };

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
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
        } else if (call.method.equals("reportEventWhenOpenDetailInfo")) {
            // 事件详情上报
            reportEventWhenOpenDetailInfo(call, result);
        } else if (call.method.equals("init")) {
            // 初始化
            init();
            result.success("init success");

        } else if (call.method.equals("initWithConfigure")) {
            // 初始化
            initWithConfigure(call, result);
            result.success("initWithConfigure success");

        } else if (call.method.equals("resultWithPermission")) {
            resultWithPermission(call, result);
            result.success("resultWithPermission success");
        } else if (call.method.equals("initWithAd")) {
            // 广告初始化
            initWithAd(call, result);

        } else if (call.method.equals("reportShareByXinShareId")) {
            // 分享裂变事件上报
            reportShareByXinShareId(call, result);
        } else if (call.method.equals("setLog")) {
            // 设置Log 答应
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    XInstall.setDebug(true);
                    result.success("setDebug success");
                }
            });
        } else if (call.method.equals("registerWakeUpHandler")) {
            hasRegister = true;
            Map<String, String> wakeupData = null;
            synchronized (this) {
                if (this.wakeUpData != null) {
                    Map<String, String> wakeupDataMap = new HashMap<>();
                    wakeupDataMap.putAll(this.wakeUpData);
                    wakeupData = wakeupDataMap;
                }
            }

            if (wakeupData != null) {
                channel.invokeMethod("onWakeupNotification", wakeupData);
                this.wakeUpData = null;
            }

        } else if (call.method.equals("registerWakeUpDetailHandler")) {
            hasDetailRegister = true;
            Map<String, Object> wakeupDetailData = null;
            synchronized (this) {
                if (this.wakeUpDetailData != null) {
                    Map<String, Object> wakeupDetailDataMap = new HashMap<>();
                    wakeupDetailDataMap.putAll(this.wakeUpDetailData);
                    wakeupDetailData = wakeupDetailDataMap;
                }
            }

            if (wakeupDetailData != null) {
                channel.invokeMethod("onWakeupDetailNotification", wakeupDetailData);
                this.wakeUpDetailData = null;
            }

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

    private void reportEventWhenOpenDetailInfo(MethodCall call, Result result) {
        String eventId = call.argument("eventId");
        Integer eventValue = call.argument("eventValue");
        String eventSubValue = call.argument("eventSubValue");
        XInstall.reportEventWhenOpenDetailInfo(eventId, eventValue == null ? 0 : eventValue, eventSubValue);
        result.success("reportPoint success");
    }

    private void reportShareByXinShareId(MethodCall call, Result result) {
        String userId = call.argument("shareId");
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
                if (xAppData == null) {
                    xAppData = new XAppData();
                }
                channel.invokeMethod("onInstallNotification", xData2Map(xAppData, true));
            }
        }, timeout == null ? 0 : timeout);
    }

    private void initWithAd(final MethodCall call, final Result result) {
        Context context = getActivity();
        if (context != null) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    initWithAdInMain(call, result);
                }
            });
        } else {
            System.out.println("Context is null, can not init Xinstall");
        }
    }

    private void initWithAdInMain(final MethodCall call, final Result result) {
        XINConfiguration configuration = XINConfiguration.Builder();
        boolean adEnable = true;
        boolean canClip = true;
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

        if (call.hasArgument("androidId")) {
            String androidId = call.argument("androidId");
            if (androidId instanceof String) {
                configuration.androidId(androidId);
            }
        }

        if (call.hasArgument("serial")) {
            String serial = call.argument("serial");
            if (serial instanceof String) {
                configuration.serial(serial);
            }
        }

        if (call.hasArgument("canClip")) {
            canClip = call.argument("canClip");
        }
        configuration.canClip(canClip);

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
            XInstall.initWithPermission(getActivity(), configuration, new Runnable() {
                @Override
                public void run() {

                    xinitialized();
                    if (channel != null) {
                        channel.invokeMethod("onPermissionBackNotification", call.arguments);
                    }
                    result.success("initWithAd success");
                }
            });
        } else {
            XInstall.initWithPermission(getActivity(), configuration);

            xinitialized();
            if (channel != null) {
                channel.invokeMethod("onPermissionBackNotification", call.arguments);

            }
            result.success("initWithAd success");
        }
    }

    private void resultWithPermission(final MethodCall call, final Result result) {
        Context context = getActivity();
        if (context != null) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    resultWithPermissionInMain(call,result);
                }
            });
        } else {
            System.out.println("Context is null, can not resultWithPermission Xinstall");
        }
    }
    private void initWithConfigure(final MethodCall call, final Result result) {
        Context context = getActivity();
        if (context != null) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    initWithConfigureInMain(call,result);
                }
            });
        } else {
            System.out.println("Context is null, can not initWithConfig Xinstall");
        }
    }

    private void resultWithPermissionInMain(final MethodCall call, final Result result) {
        boolean isSuccess = false;
        if (call.hasArgument("isSuccess")) {
            isSuccess = true;
        }
        String[] strs = new String[]{};

        if (isSuccess) {
            int[] ints = new int[]{0};
            XInstall.onRequestPermissionsResult(1111,strs,ints);
        } else {
            int[] ints = new int[]{};
            XInstall.onRequestPermissionsResult(1111,strs,ints);
        }
    }

    private void initWithConfigureInMain(final MethodCall call, final Result result) {
        Context context = getActivity();
        XINConfiguration configuration = XINConfiguration.Builder();
        boolean adEnable = false;
        boolean canClip = true;

        configuration.adEnable(adEnable);

        if (call.hasArgument("androidId")) {
            String androidId = call.argument("androidId");
            if (androidId instanceof String) {
                configuration.androidId(androidId);
                System.out.println("Xinstall:initWithConfig:androidId " + androidId);
            }
        }

        if (call.hasArgument("serial")) {
            String serial = call.argument("serial");
            if (serial instanceof String) {
                configuration.serial(serial);
                System.out.println("Xinstall:initWithConfig:serial: " + serial);
            }
        }

        if (call.hasArgument("canClip")) {
            canClip = call.argument("canClip");
        }
        configuration.canClip(canClip);


        XInstall.init(context, configuration);
        xinitialized();
    }

    private void init() {
        final Context context = getActivity();
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
        XInstall.init(context);
        xinitialized();
    }

    private void xinitialized() {
        this.hasCallInit = true;
        if (wakeupIntent != null && wakeupActivity != null) {
            XInstall.getWakeUpParamEvenErrorAlsoCallBack(wakeupActivity, wakeupIntent, wakeUpAdapter);
            wakeupActivity = null;
            wakeupIntent = null;
        } else {
            Activity activity = getActivity();
            if (activity != null) {
                XInstall.getWakeUpParamEvenErrorAlsoCallBack(activity, activity.getIntent(), wakeUpAdapter);
            }
            wakeupActivity = null;
            wakeupIntent = null;
        }
    }


    private static Map<String, String> xData2Map(XAppData data, boolean isInit) {
        Map<String, String> result = new HashMap<>();
        if (data != null) {
            Map<String, String> extraData = data.getExtraData();
            result.putAll(extraData);
            JSONObject jo2 = data.toJsonObject();
            JSONObject da = new JSONObject();
            if (data.isEmpty()) {

            } else {
                try {
                    da = jo2.getJSONObject("data");
                } catch (Exception e) {

                }
            }
            result.put("data", da.toString());
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
            error.put("errorType", xAppError.getErrorCode());
            error.put("errorMsg", xAppError.getErrorMsg());
        }
        Map<String, Object> result = new HashMap<>();
        result.put("wakeUpData", wakeUpData);
        result.put("error", error);
        return result;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        flutterPluginBinding = binding;
        channel = new MethodChannel(binding.getBinaryMessenger(), "xinstall_flutter_plugin");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        binding.addOnNewIntentListener(this);
        onWakeUp(binding.getActivity().getIntent());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        binding.addOnNewIntentListener(this);
    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public boolean onNewIntent(Intent intent) {
        onWakeUp(intent);
        return false;
    }
}
