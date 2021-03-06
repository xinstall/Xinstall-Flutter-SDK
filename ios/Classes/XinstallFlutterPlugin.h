#import <Flutter/Flutter.h>

@interface XinstallFlutterPlugin : NSObject<FlutterPlugin>

//scheme 处理
+ (BOOL)handleSchemeURL:(NSURL *)url;
/**
 * 处理 通用链接
 * @param userActivity 存储了页面信息，包括url
 * @return bool URL是否被Xinstall识别
 */
+ (BOOL)continueUserActivity:(NSUserActivity *) userActivity;

@end
