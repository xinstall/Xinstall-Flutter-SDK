#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <xinstall_flutter_plugin/XinstallFlutterPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

//添加此方法以获取拉起参数
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    //判断是否通过Xinstall Universal Link 唤起App
    if ([XinstallFlutterPlugin continueUserActivity:userActivity]){
        return YES;
    }
    //其他第三方回调；
    return YES;
}

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

@end
