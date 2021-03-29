# Flutter接入

## 一、配置
请先从[XInstall](https://xinstall.com/)申请开发者账号并创建应用，获取 AppKey

在 pubspec.yaml 添加依赖,
```
dependencies:
  ...
  # 依赖XInstall
  xinstall_flutter_plugin: ^0.0.5
```
终端进入项目目录并输入 flutter pub get 安装



### Android平台配置

在 /android/app/build.gradle 中添加下列代码：
```
android: {
  ....
  defaultConfig {
    ...
    manifestPlaceholders = [
        XINSTALL_APPKEY : "XInstall为应用分配的 AppKey",
    ]
  }    
}

在/android/app/src/main/AndroidMenifest.xml application
```

修改 /android/app/src/main/AndroidMenifest.xml 文件，  
在 application 标签内添加 
```
<meta-data
    android:name="com.xinstall.APP_KEY"
    android:value="${XINSTALL_APPKEY}" />
```

在 activity 标签内添加 intent-filter (一般为 MainActivity)
```
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>

    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>

    <data android:scheme="xi${XINSTALL_APPKEY}"/>
</intent-filter>
```


### iOS平台配置 

####1、配置appkey

在Flutter工程下的`ios/Runner/Info.plist`文件中配置`appkey`键值对，如下：

```
<key>com.xinstall.APP_KEY</key>
<string>xinstall分配给应用的appkey</string>
```

#####以下为一键拉起 功能相关配置和代码

####2、Universal Links相关配置（支持iOS9.0以后）

Xinstall 通过universal link（iOS≥9 ）,在app已安装的情况下，从各种浏览器（包括微信、QQ、新浪微博、钉钉等主流社交软件的内置浏览器）拉起app并传递动态参数，避免重复安装。

首先，我们需要到[苹果开发者网站](https://developer.apple.com/)  ，为当前的App ID开启关联域名(Associated Domains)服务：

<img src="https://www.xinstall.com/admin/static/img/step1.0d7e2aa7.png" width="800" height="500" alt="Associated Domains"/><br/>

为刚才开发关联域名功能的AppID创建新的（或更新现有的）描述文件，下载并导入到XCode中(通过xcode自动生成的描述文件，可跳过这一步)：

<img src="https://www.xinstall.com/admin/static/img/step2.9498cb64.png" width="800" height="500" alt="config"/><br/>

在XCode中配置Xinstall为当前应用生成的关联域名(Associated Domains)

<img src="https://www.xinstall.com/admin/static/img/step3.7b30881b.png" width="800" height="420" alt="applinks"/><br/>

在 `ios/Runner/AppDelegate.m` 中添加通用链接（Universal Link）回调方法，委托插件来处理：

在头部引入
```objc

#import <xinstall_flutter_plugin/XinstallFlutterPlugin.h>

```

添加如下方法

``` xml
//添加此方法以获取拉起参数
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    //判断是否通过Xinstall Universal Link 唤起App
    if ([XinstallFlutterPlugin continueUserActivity:userActivity]){//如果使用了Universal link ，此方法必写
        return YES;
    }
    //其他第三方回调；
    return YES;
}
```

####3、集成Scheme
首先，在Xcode选中Target -> Info -> URL Types,配置Xinstall 为当前应用生成的 Scheme,如图所示：
<img src="https://doc.xinstall.com/integrationGuide/iOS6.png" width="800" height="630" alt="applinks"/><br/>

代码部分：

在 AppDelegate 的两个scheme回调方法中添加Xinstall的Scheme方法

``` xml
//iOS9以下调用这个方法
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    // 处理通过Xinstall URL SchemeURL 唤起App的数据
    [XinstallFlutterPlugin handleSchemeURL:url];
    //其他第三方回调；
    return YES;
}
//iOS9以上会优先走这个方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options{
    // 处理通过Xinstall URL SchemeURL 唤起App的数据
    [XinstallFlutterPlugin handleSchemeURL:url];
    //其他第三方回调；
    return YES;
}
```

## 二、初始化

在 main.dart 添加  
`import 'package:xinstall_flutter_plugin/xinstall_flutter_plugin.dart';`

## 三、功能集成

###1.快速下载/一键拉起

如果只需要快速下载功能和一键拉起，无需其它功能（携带参数安装、渠道统计），完成初始化配置即可。其他影响因素如下图
![](https://xinstall-static-pro.oss-cn-hangzhou.aliyuncs.com/APICloud%E7%B4%A0%E6%9D%90/v1.1.0/xinstall_yjlqksaztj.png)

###2.携带参数安装/唤起
在 APP 需要安装参数时（由 web 网页中传递过来的，如邀请码、游戏房间号等动态参数），调用此接口，在回调中获取参数，参数在快速下载第一次打开应用时候，或被一键拉起时候会传递过来。


```
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
```


```
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

```
###3.高级数据统计

#### 注册统计
如需统计每个渠道的注册量（对评估渠道质量很重要），可根据自身的业务规则，在确保用户完成 APP 注册的情况下调用此接口  
```
  //注册统计
  void _reportRegister() {
    _xinstallFlutterPlugin.reportRegister();
  }
```

#### 事件统计
事件统计建立在渠道基础之上，主要用来统计终端用户对某些特殊业务的使用效果。调用此接口时，请使用后台创建的 “事件统计ID” 作为eventId
```
  //事件统计
  void _reportPoint() {
    _xinstallFlutterPlugin.reportPoint("eventId", 1);
  }
```

## 三、导出apk/ipa包并上传

参考官网文档 

[iOS集成-导出ipa包并上传](https://doc.xinstall.com/integrationGuide/iOSIntegrationGuide.html#%E5%9B%9B%E3%80%81%E5%AF%BC%E5%87%BAipa%E5%8C%85%E5%B9%B6%E4%B8%8A%E4%BC%A0)

[Android-集成](https://doc.xinstall.com/integrationGuide/AndroidIntegrationGuide.html#%E5%9B%9B%E3%80%81%E5%AF%BC%E5%87%BAapk%E5%8C%85%E5%B9%B6%E4%B8%8A%E4%BC%A0)

## **四、如何测试功能**

参考官方文档 
[测试集成效果](https://doc.xinstall.com/integrationGuide/comfirm.html)

## **五、更多 Xinstall 进阶功能**
若您想要自定义下载页面，或者查看数据报表等进阶功能，请移步 [Xinstall 官网](https://xinstall.com/) 查看对应文档。

若您在集成过程中如有任何疑问或者困难，可以随时联系 [Xinstall 官方客服](https://wpa1.qq.com/qsw1OZaM?_type=wpa&qidian=true) 在线解决。