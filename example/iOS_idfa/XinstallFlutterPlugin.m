#import "XinstallFlutterPlugin.h"
#import "XinstallSDK.h"

#import <AdSupport/AdSupport.h>
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#endif

typedef NS_ENUM(NSUInteger, XinstallSDKPluginMethod) {
    XinstallSDKPluginMethodInit,
    XinstallSDKPluginMethodGetInstallParams,
    XinstallSDKPluginMethodReportRegister,
    XinstallSDKPluginMethodReportEventPoint,
    XinstallSDKPluginMethodInitWithAd,
};

@interface XinstallFlutterPlugin () <XinstallDelegate>

@property (strong, nonatomic, readonly) NSDictionary *methodDict;
@property (strong, nonatomic) FlutterMethodChannel * flutterMethodChannel;

@property (assign, nonatomic) BOOL hasInit;
@property (copy, nonatomic) XinstallData * cacheData;

@end

static NSString * const XinstallThirdPlatformFlag = @"XINSTALL_THIRDPLATFORM_FLUTTER_THIRDPLATFORM_XINSTALL";
static NSString * const XinstallThirdVersionFlag = @"XINSTALL_THIRDSDKVERSION_1.5.7_THIRDSDKVERSION_XINSTALL";
static NSInteger const XinstallThirdPlatform = 8;
static NSString * const XinstallThirdVersion = @"1.5.7";


@implementation XinstallFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"xinstall_flutter_plugin"
            binaryMessenger:[registrar messenger]];
  XinstallFlutterPlugin* instance = [[XinstallFlutterPlugin alloc] init];
  instance.flutterMethodChannel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
        //这两句代码写在这里是为了使用一下这两个静态字符串，以免被编辑器认为没有使用而去除掉
        if (XinstallThirdPlatformFlag.length > 0) {
            
        }
        if (XinstallThirdVersionFlag.length > 0) {
            
        }
    }
    return self;
}

- (void)initData {
    _methodDict = @{
                    @"initWithAd"               :      @(XinstallSDKPluginMethodInitWithAd),
                    @"init"                     :      @(XinstallSDKPluginMethodInit),
                    @"getInstallParam"          :      @(XinstallSDKPluginMethodGetInstallParams),
                    @"reportRegister"           :      @(XinstallSDKPluginMethodReportRegister),
                    @"reportPoint"              :      @(XinstallSDKPluginMethodReportEventPoint)
                    };
}

- (void)getIdfa:(void(^)(NSString *)) complete {
    __block NSString *idfa = @"";
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
            complete(idfa);
        }];
    } else {
        idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
        complete(idfa);
    }
#else
    idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
    complete(idfa);
#endif
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSNumber *methodType = self.methodDict[call.method];
    if (methodType) {
        switch (methodType.intValue) {
            case XinstallSDKPluginMethodInit:
            {
                XinstallData *wakeUpData;
                @synchronized(self){
                    if (self.cacheData) {
                        wakeUpData = [self.cacheData copy];
                    }
                }
                
                if (wakeUpData) {
                    NSDictionary *args = [self convertInstallArguments:wakeUpData isWakeUp:YES];
                    [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:args];
                    self.cacheData = NULL;
                }
                
                self.hasInit = true;
                [XinstallSDK initWithDelegate:self];
                [self.flutterMethodChannel invokeMethod:@"onPermissionBackNotification" arguments:@{}];
    
                NSLog(@"Init");
                break;
            }
            case XinstallSDKPluginMethodInitWithAd:
            {
                XinstallData *wakeUpData;
                @synchronized(self){
                    if (self.cacheData) {
                        wakeUpData = [self.cacheData copy];
                    }
                }
                
                if (wakeUpData) {
                    NSDictionary *args = [self convertInstallArguments:wakeUpData isWakeUp:YES];
                    [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:args];
                    self.cacheData = NULL;
                }
                
                self.hasInit = true;
                NSDictionary *args = call.arguments;
                NSString *idfa = (NSString *)args[@"idfa"];
                if (!(idfa.length > 0)) {
                    [self getIdfa:^(NSString *idfa) {
                        [XinstallSDK initWithDelegate:self idfa:idfa];
                        [self.flutterMethodChannel invokeMethod:@"onPermissionBackNotification" arguments:@{}];
            
                    }];
                } else {
                    [XinstallSDK initWithDelegate:self idfa:idfa];
                    [self.flutterMethodChannel invokeMethod:@"onPermissionBackNotification" arguments:@{}];
        
                }
                
                NSLog(@"InitWithAd");
                break;
            }
            case XinstallSDKPluginMethodGetInstallParams:
            {
                int time = (int) call.arguments[@"timeout"];
                if (time <= 0) {
                    time = 8;
                }
                [[XinstallSDK defaultManager] getInstallParamsWithCompletion:^(XinstallData * _Nullable installData, XinstallError * _Nullable error) {
                    if (error) {
                        NSLog(@"errorMsg--%@", error.errorMsg);
                    }
                    [self installParamsResponse:installData];
                }];
                NSLog(@"GetInstallParams");
                break;
            }
            case XinstallSDKPluginMethodReportRegister:
            {
                [XinstallSDK reportRegister];
                NSLog(@"ReportRegister");
                break;
            }
            case XinstallSDKPluginMethodReportEventPoint:
            {
                NSDictionary *args = call.arguments;
                NSNumber *eventValue = (NSNumber *)args[@"pointValue"];
                [[XinstallSDK defaultManager] reportEventPoint:(NSString *)args[@"pointId"] eventValue:[eventValue longValue]];
                NSLog(@"reportPoint--%@",args);
                break;
            }
            default:
            {
                break;
            }
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Xinstall Notify Flutter Mehtod
- (void)installParamsResponse:(XinstallData *) appData {
    NSDictionary *args = [self convertInstallArguments:appData isWakeUp:NO];
    [self.flutterMethodChannel invokeMethod:@"onInstallNotification" arguments:args];
}

- (void)wakeUpParamsResponse:(XinstallData *) appData {
    NSDictionary *args = [self convertInstallArguments:appData isWakeUp:YES];
    [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:args];
}

- (NSDictionary *)convertInstallArguments:(XinstallData *) appData isWakeUp:(BOOL)wakeUp{
    NSString *channelCode = @"";
    NSString *bindData = @"";
    if (appData.channelCode != nil) {
        channelCode = appData.channelCode;
    }
    if (appData.data != nil) {
        bindData = [self jsonStringWithObject:appData.data];
    }else{
        bindData = [self jsonStringWithObject:@{@"uo" : @"",@"co" : @""}];
    }
    //唤醒
    if (wakeUp) {
        NSDictionary *dict = @{@"channelCode"   : channelCode,
                               @"bindData"      : bindData,
                               @"data"          : bindData,
                               @"timeSpan"      : @(appData.timeSpan)
                                };
        NSLog(@"dict:%@",dict);
        return dict;
    }
    //不是唤醒
    NSDictionary *dict = @{@"channelCode"   : channelCode,
                           @"bindData"      : bindData,
                           @"data"          : bindData,
                           @"timeSpan"      : @(appData.timeSpan),
                           @"isFirstFetch"  : @(appData.isFirstFetch)
                            };
    NSLog(@"dict:%@",dict);
    return dict;
}

- (NSString *)jsonStringWithObject:(id)jsonObject {
    id arguments = (jsonObject == nil ? [NSNull null] : jsonObject);
    NSArray* argumentsWrappedInArr = [NSArray arrayWithObject:arguments];
    NSString* argumentsJSON = [self cp_JSONString:argumentsWrappedInArr];
    argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];
    return argumentsJSON;
}

- (NSString *)cp_JSONString:(NSArray *)array {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([jsonString length] > 0 && error == nil){
        return jsonString;
    } else {
        return @"";
    }
}

#pragma mark - Xinstall API
//通过Xinstall获取已经安装App被唤醒时的参数（如果是通过渠道页面唤醒App时，会返回渠道编号）
//一键拉起时获取 H5页面 携带的动态参数，参数中如果携带渠道，也会在方法中一起返回渠道号
- (void)xinstall_getWakeUpParams:(nullable XinstallData *)appData{
    if (self.hasInit) {
        [self wakeUpParamsResponse:appData];
    } else {
        @synchronized(self){
            self.cacheData = appData;
        }
        
    }
    
}

+ (BOOL)handleSchemeURL:(NSURL *)url {
    return [XinstallSDK handleSchemeURL:url];
}


+ (BOOL)continueUserActivity:(NSUserActivity *)userActivity {
    return [XinstallSDK continueUserActivity:userActivity];
}

- (NSString *)xiSdkThirdVersion {
    return XinstallThirdVersion;
}

- (NSInteger)xiSdkType {
    return XinstallThirdPlatform;
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [XinstallFlutterPlugin handleSchemeURL:url];
    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [XinstallFlutterPlugin handleSchemeURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
#if defined(__IPHONE_12_0)
    restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring> > * _Nullable restorableObjects))restorationHandler
#else
    restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
#endif
{
    [XinstallFlutterPlugin continueUserActivity:userActivity];
    return YES;
}

@end

