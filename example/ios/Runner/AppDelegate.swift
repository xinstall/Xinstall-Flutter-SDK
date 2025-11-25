import Flutter
import UIKit
import xinstall_flutter_plugin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // 添加此方法以获取拉起参数
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // 判断是否通过Xinstall Universal Link 唤起App
    if XinstallFlutterPlugin.continue(userActivity) {
      return true
    }
    // 其他第三方回调
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
  
  // iOS9以下调用这个方法
  override func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
  ) -> Bool {
    // 处理通过Xinstall URL SchemeURL 唤起App的数据
    XinstallFlutterPlugin.handleSchemeURL(url)
    // 其他第三方回调
    return super.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  // iOS9以上会优先走这个方法
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // 处理通过Xinstall URL SchemeURL 唤起App的数据
    XinstallFlutterPlugin.handleSchemeURL(url)
    // 其他第三方回调
    return super.application(app, open: url, options: options)
  }
}
