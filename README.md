# Flutter接入

> 【重要说明】：从 v1.5.0 版本（含）开始，调用  Xinstall 模块的任意方法前，必须先调用一次初始化方法（init 或者 initWithAd），否则将导致其他方法无法正常调用。
>
> 从 v1.5.0 以下升级到 v1.5.0 以上版本后，需要自行修改代码调用初始化方法，Xinstall 模块无法在升级后自动兼

## 一、配置
请先从[XInstall](https://xinstall.com/)申请开发者账号并创建应用，获取 AppKey

在 pubspec.yaml 添加依赖,
```xml
dependencies:
  ...
  # 依赖XInstall
  xinstall_flutter_plugin: ^1.5.0
```
终端进入项目目录并输入 flutter pub get 安装



### Android平台配置

在 /android/app/build.gradle 中添加下列代码：
```xml
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
```xml
<meta-data
    android:name="com.xinstall.APP_KEY"
    android:value="${XINSTALL_APPKEY}" />
```

在 activity 标签内添加 intent-filter (一般为 MainActivity)
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>

    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>

    <data android:scheme="xi${XINSTALL_APPKEY}"/>
</intent-filter>
```


### iOS平台配置 

#### 1、配置appkey

在Flutter工程下的`ios/Runner/Info.plist`文件中配置`appkey`键值对，如下：

```xml
<key>com.xinstall.APP_KEY</key>
<string>xinstall分配给应用的appkey</string>
```

##### 以下为一键拉起 功能相关配置和代码

#### 2、Universal Links相关配置（支持iOS9.0以后）

Xinstall 通过universal link（iOS≥9 ）,在app已安装的情况下，从各种浏览器（包括微信、QQ、新浪微博、钉钉等主流社交软件的内置浏览器）拉起app并传递动态参数，避免重复安装。

首先，我们需要到[苹果开发者网站](https://developer.apple.com/)  ，为当前的App ID开启关联域名(Associated Domains)服务：

<img src="https://www.xinstall.com/admin/static/img/step1.0d7e2aa7.png" width="800" height="500" alt="Associated Domains"/><br/>

为刚才开发关联域名功能的AppID创建新的（或更新现有的）描述文件，下载并导入到XCode中(通过xcode自动生成的描述文件，可跳过这一步)：

<img src="https://www.xinstall.com/admin/static/img/step2.9498cb64.png" width="800" height="500" alt="config"/><br/>

**配置 Universal links 关联域名**

在 Xcode 中配置 Xinstall 为当前应用生成的关联域名（Associated Domains）：**applinks:xxxx.xinstall.top** 和 **applinks:xxxx.xinstall.net**

> 具体的关联域名可在 Xinstall管理后台 - 对应的应用控制台 - iOS下载配置 页面中找到

<img src="https://doc.xinstall.com/ReactNative/res/3.png"/><br/>

在 `ios/Runner/AppDelegate.m` 中添加通用链接（Universal Link）回调方法，委托插件来处理：

在头部引入
```objective-c

#import <xinstall_flutter_plugin/XinstallFlutterPlugin.h>

```

添加如下方法

``` objective-c
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

#### 3、集成Scheme

首先，在Xcode选中Target -> Info -> URL Types,配置Xinstall 为当前应用生成的 Scheme,如图所示：
<img src="https://doc.xinstall.com/integrationGuide/iOS6.png" width="800" height="630" alt="applinks"/><br/>

代码部分：

在 AppDelegate 的两个scheme回调方法中添加Xinstall的Scheme方法

``` objective-c
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

```dart
 _xinstallFlutterPlugin = XinstallFlutterPlugin.getInstance();
// xwakeupParamHandler 为 一键拉起回调，如果不需要回调可以传空
 _xinstallFlutterPlugin.init(xwakeupParamHandler);

Future xwakeupParamHandler(Map<String, dynamic> data) async {
    setState(() {
      var d = data["data"];
      var timeSpan = data["timeSpan"];
      var channelCode = data["channelCode"];
      _wakeUpData = data.toString();
      print(_wakeUpData);
    });
  }
```



## 三、功能集成

###1.快速下载/一键拉起

如果只需要快速下载功能和一键拉起，无需其它功能（携带参数安装、渠道统计），完成初始化配置即可。其他影响因素如下图
![](https://xinstall-static-pro.oss-cn-hangzhou.aliyuncs.com/APICloud%E7%B4%A0%E6%9D%90/v1.1.0/xinstall_yjlqksaztj.png)

### 2.携带参数安装/唤起

在 APP 需要安装参数时（由 web 网页中传递过来的，如邀请码、游戏房间号等动态参数），调用此接口，在回调中获取参数，参数在快速下载第一次打开应用时候，或被一键拉起时候会传递过来。


```dart
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
      var d = data["data"];
      var timeSpan = data["timeSpan"];
      var channelCode = data["channelCode"];
      _wakeUpData = data.toString();
      print(_wakeUpData);
    });
  }
```


```dart
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

```
### 3.高级数据统计

#### 注册统计
如需统计每个渠道的注册量（对评估渠道质量很重要），可根据自身的业务规则，在确保用户完成 APP 注册的情况下调用此接口  
```dart
  //注册统计
  void _reportRegister() {
    _xinstallFlutterPlugin.reportRegister();
  }
```

#### 事件统计
事件统计建立在渠道基础之上，主要用来统计终端用户对某些特殊业务的使用效果。调用此接口时，请使用后台创建的 “事件统计ID” 作为eventId
```dart
  //事件统计
  void _reportPoint() {
    _xinstallFlutterPlugin.reportPoint("eventId", 1);
  }
```

### 4. 广告平台渠道功能

> 如果您在 Xinstall 管理后台对应 App 中，**只使用「自建渠道」，而不使用「广告平台渠道」，则无需进行本小节中额外的集成工作**，也能正常使用 Xinstall 提供的其他功能。
>
> 注意：根据目前已有的各大主流广告平台的统计方式，目前 iOS 端和 Android 端均需要用户授权并获取一些设备关键值后才能正常进行 [ 广告平台渠道 ] 的统计，如 IDFA / OAID / GAID 等，对该行为敏感的 App 请慎重使用该功能。

##### 4.1 配置工作

**iOS 端：**

4.1.1 在 Xcode 中打开 iOS 端的工程，在 `Info.plist` 文件中配置一个权限作用声明（如果不配置将导致 App 启动后马上闪退）：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>这里是针对获取 IDFA 的作用描述，请根据实际情况填写</string>
```

4.1.2 在 Xcode 中，找到 App 对应的「Target」，再点击「General」，然后在「Frameworks, Libraries, and Embedded Content」中，添加如下两个框架：

* AppTrackingTransparency.framework
* AdSupport.framework

4.1.3 `ios/Classes/XinstallFlutterPlugin.m` 替换成`example/iOS_idfa/XinstallFlutterPlugin.m`



**Android 端：**

相关接入可以参考广告平台联调指南中的[《Android集成指南》](https://doc.xinstall.com/AD/AndroidGuide.html)

1. 接入IMEI需要额外的全下申请，需要在`AndroidManifest`中添加权限声明

   ```java
   <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
   ```

2. 如果使用OAID，因为内部使用反射获取oaid 参数，所以都需要外部用户接入OAID SDK 。具体接入参考[《Android集成指南》](https://doc.xinstall.com/AD/AndroidGuide.html)

##### 4.2、更换初始化方法

**使用新的 initWithAd 方法，替代原先的 init 方法来进行模块的初始化**

> iOS 端使用该方法时，需要传入 IDFA（在 Dart 脚本内）。您可以使用任意方式在 Dart 脚本中获取到 IDFA，例如第三方获取 IDFA 的模块。
>

**入参说明**：需要主动传入参数，JSON对象

入参内部字段：

* iOS 端：

  <table>
         <tr>
             <th>参数名</th>
             <th>参数类型</th>
             <th>描述 </th>
         </tr>
         <tr>
             <th>idfa</th>
             <th>字符串</th>
             <th>iOS 系统中的广告标识符</th>
         </tr>
     </table>


* Android 端：

  <table>
            <tr>
                <th>参数名</th>
                <th>参数类型</th>
                <th>描述 </th>
            </tr>
            <tr>
                <th>adEnabled</th>
                <th>boolean</th>
                <th>是否使用广告功能</th>
            </tr>
    				<tr>
                <th>oaid （可选）</th>
                <th>string</th>
                <th>OAID</th>
            </tr>
    				<tr>
                <th>gaid（可选）</th>
                <th>string</th>
                <th>GaID(google Ad ID)</th>
            </tr>
        </table>



**调用示例**

```dart
XinstallFlutterPlugin _xinstallFlutterPlugin;

@override
  void initState() {
    super.initState();
    initXInstallPlugin();
  }

Future<void> initXInstallPlugin() async {
    if (!mounted) return;

    _xinstallFlutterPlugin = XinstallFlutterPlugin.getInstance();
   // idfa, gaid, oaid 为选填参数 如果外部不传如idfa，再替换XinstallFlutterPlugin.m，文件后，会内部自动获取
   // oaid和gaid 为选传，不传则代表使用SDK自动去获取（SDK内不包括OAID SDK，需要自己接入）
    _xinstallFlutterPlugin.initWithAd({"adEnable":true,"idfa":"外部传入idfa","gaid":"测试gaid","oaid":"测试oaid"},xwakeupParamHandler,null);
   // 如果希望在完成初始化，立即执行之后的步骤可以通过 下列代码实现-------------------------
   // _xinstallFlutterPlugin.initWithAd({"adEnable":true,"idfa":"外部传入idfa","gaid":"测试gaid","oaid":"测试oaid"},xwakeupParamHandler,xPermissionBackHandler);
   // -----------------------------------------------------------------------------
  
   // 如果 android 想外部获取IMEI权限
   // 使用 permission_handler
   //  if (await Permission.phone.request().isGranted) {
   // 获取到了权限
   //  _xinstallFlutterPlugin.initWithAd({"adEnable":true,"isPermission":false,"idfa":"外部传入idfa","gaid":"测试gaid","oaid":"测试oaid"},xwakeupParamHandler,null);
   //}
}

 Future xPermissionBackHandler() async {
    setState(() {
      print("执行了获取安装参数的方法");
      _getXInstallParam();
    });
 }
```

**可用性**

Android系统，iOS系统

可提供的 1.5.0 及更高版本



#### 4.3、上架须知

**在使用了广告平台渠道后，若您的 App 需要上架，请认真阅读本段内容。**

##### 4.3.1 iOS 端：上架 App Store

1. 如果您的 App 没有接入苹果广告（即在 App 中显示苹果投放的广告），那么在提交审核时，在广告标识符中，请按照下图勾选：

![IDFA](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_7.png)



1. 在 App Store Connect 对应 App —「App隐私」—「数据类型」选项中，需要选择：**“是，我们会从此 App 中收集数据”**：

![AppStore_IDFA_1](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_1.png)

在下一步中，勾选「设备 ID」并点击【发布】按钮：

![AppStore_IDFA_2](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_2.png)

点击【设置设备 ID】按钮后，在弹出的弹框中，根据实际情况进行勾选：

- 如果您仅仅是接入了 Xinstall 广告平台而使用了 IDFA，那么只需要勾选：**第三方广告**
- 如果您在接入 Xinstall 广告平台之外，还自行使用 IDFA 进行别的用途，那么在勾选 **第三方广告** 后，还需要您根据您的实际使用情况，进行其他选项的勾选

![AppStore_IDFA_3](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_3.png)

![AppStore_IDFA_4](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_4.png)

勾选完成后点击【下一步】按钮，在 **“从此 App 中收集的设备 ID 是否与用户身份关联？”** 选项中，请根据如下情况进行选择：

- 如果您仅仅是接入了 Xinstall 广告平台而使用了 IDFA，那么选择 **“否，从此 App 中收集的设备 ID 未与用户身份关联”**
- 如果您在接入 Xinstall 广告平台之外，还自行使用 IDFA 进行别的用途，那么请根据您的实际情况选择对应的选项

![AppStore_IDFA_5](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_5.png)

最后，在弹出的弹框中，选择 **“是，我们会将设备 ID 用于追踪目的”**，并点击【发布】按钮：

![AppStore_IDFA_6](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_6.png)



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