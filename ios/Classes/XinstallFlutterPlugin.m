#import "XinstallFlutterPlugin.h"
#import "XinstallSDK.h"

#if __has_include(<AdServices/AAAttribution.h>)
    #import <AdServices/AAAttribution.h>
#endif

typedef NS_ENUM(NSUInteger, XinstallSDKPluginMethod) {
    XinstallSDKPluginMethodInit,
    XinstallSDKPluginMethodGetInstallParams,
    XinstallSDKPluginMethodReportRegister,
    XinstallSDKPluginMethodReportEventPoint,
    XinstallSDKPluginMethodInitWithAd,
    XinstallSDKPluginMethodRegisterWakeUpHandler,
    XinstallSDKPluginMethodRegisterWakeUpDetailHandler,
    XinstallSDKPluginMethodReportShareByXinShareId,
    XinstallSDKPluginMethodReportEventSubValue
};

@interface XinstallFlutterPlugin () <XinstallDelegate>

@property (strong, nonatomic, readonly) NSDictionary *methodDict;
@property (strong, nonatomic) FlutterMethodChannel * flutterMethodChannel;

@property (assign, nonatomic) BOOL hasRegister;
@property (assign, nonatomic) BOOL hasDetailRegister;
@property (copy, nonatomic) XinstallData * wakeupData;
@property (copy, nonatomic) XinstallData * wakeupDetailData;
@property (copy, nonatomic) XinstallError * wakeupDetailError;

@end

static NSString * const XinstallThirdPlatformFlag = @"XINSTALL_THIRDPLATFORM_FLUTTER_THIRDPLATFORM_XINSTALL";
static NSString * const XinstallThirdVersionFlag = @"XINSTALL_THIRDSDKVERSION_1.5.9_THIRDSDKVERSION_XINSTALL";
static NSInteger const XinstallThirdPlatform = 8;
static NSString * const XinstallThirdVersion = @"1.5.9";


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
                    @"initWithAd"                  :      @(XinstallSDKPluginMethodInitWithAd),
                    @"init"                        :      @(XinstallSDKPluginMethodInit),
                    @"getInstallParam"             :      @(XinstallSDKPluginMethodGetInstallParams),
                    @"registerWakeUpHandler"       :      @(XinstallSDKPluginMethodRegisterWakeUpHandler),
                    @"registerWakeUpDetailHandler" :      @(XinstallSDKPluginMethodRegisterWakeUpDetailHandler),
                    @"reportEventWhenOpenDetailInfo":@(XinstallSDKPluginMethodReportEventSubValue),
                    @"reportRegister"              :      @(XinstallSDKPluginMethodReportRegister),
                    @"reportPoint"                 :      @(XinstallSDKPluginMethodReportEventPoint),
                    @"reportShareByXinShareId"     :      @(XinstallSDKPluginMethodReportShareByXinShareId)
                    };
}

+ (NSString *)getASAToken {
#if __has_include(<AdServices/AAAttribution.h>)
    if (@available(iOS 14.3, *)) {
        NSError *error;
        NSString *asaToken = [AAAttribution attributionTokenWithError:&error];
        return asaToken;
    } else {
        return @"";
    }
#else
    return @"";
#endif
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSNumber *methodType = self.methodDict[call.method];
    if (methodType) {
        switch (methodType.intValue) {
            case XinstallSDKPluginMethodInit:
            {
                [XinstallSDK initWithDelegate:self];
                [self.flutterMethodChannel invokeMethod:@"onPermissionBackNotification" arguments:@{}];
    
                NSLog(@"Init");
                break;
            }
            case XinstallSDKPluginMethodReportEventSubValue:
            {
                NSDictionary *args = call.arguments;
                NSString *eventId = (NSString *)args[@"eventId"];
                NSNumber *eventValueNum = (NSNumber *)args[@"eventValue"];
                NSString *eventSubValue = (NSString *)args[@"eventSubValue"];
                long eventValue = [eventValueNum longValue];
                [[XinstallSDK defaultManager] reportEventWhenOpenDetailInfoWithEventPoint:eventId eventValue:eventValue  subValue:eventSubValue];
                NSLog(@"reportEventWhenOpenDetailInfo--%@",args);
                break;
            }
            case XinstallSDKPluginMethodRegisterWakeUpDetailHandler:
            {
                self.hasDetailRegister = YES;
                XinstallData *wakeupDetailData;
                XinstallError *wakeupDetailError;
                
                @synchronized (self) {
                    if (self.wakeupDetailData) {
                        wakeupDetailData = [self.wakeupDetailData copy];
                    }
                    if (self.wakeupDetailError) {
                        wakeupDetailError = [self.wakeupDetailError copy];
                    }
                }
                
                if (wakeupDetailData != NULL || wakeupDetailError != NULL) {
                    NSDictionary *args = @{};
                    NSDictionary *error = @{};
                    if (wakeupDetailData) {
                        args = [self convertDataArguments:wakeupDetailData isWakeUp:YES];
                    }
                    if (wakeupDetailError) {
                        error = @{@"errorType":@(wakeupDetailError.type),@"errorMsg":wakeupDetailError.errorMsg};
                    }
                    NSDictionary *params = @{@"wakeUpData":args,@"error":error};
                    [self.flutterMethodChannel invokeMethod:@"onWakeupDetailNotification" arguments:params];
                    self.wakeupDetailData = NULL;
                    self.wakeupDetailError = NULL;
                }
                
                break;
            }
            case XinstallSDKPluginMethodRegisterWakeUpHandler:
            {
                self.hasRegister = YES;
                XinstallData *wakeUpData;
                @synchronized(self){
                    if (self.wakeupData) {
                        wakeUpData = [self.wakeupData copy];
                    }
                }

                if (wakeUpData) {
                    NSDictionary *args = [self convertDataArguments:wakeUpData isWakeUp:YES];
                    [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:args];
                    self.wakeupData = NULL;
                }
                break;
            }
            case XinstallSDKPluginMethodInitWithAd:
            {
                
                NSDictionary *args = call.arguments;
                NSString *idfa = (NSString *)args[@"idfa"];
                BOOL asaEnable = [args[@"asaEnable"] boolValue];
                if (!(idfa.length > 0)) {
                    NSLog(@"该文件并不具备内部获取idfa的能力，请到example 中的iOS_idfa中的XinstallFlutterPlugin.m替换本文件");
                }
                
                NSString *asaToken = @"";
                if (asaEnable) {
                    asaToken = [XinstallFlutterPlugin getASAToken];
                }
                
                    
                [XinstallSDK initWithDelegate:self idfa:idfa asaToken:asaToken];
                [self.flutterMethodChannel invokeMethod:@"onPermissionBackNotification" arguments:@{}];
        
        
                
                NSLog(@"InitWithAd");
                break;
            }
            case XinstallSDKPluginMethodGetInstallParams:
            {
                int time = 0;
                if (call.arguments[@"timeout"] != nil) {
                    time = [call.arguments[@"timeout"] intValue];
                }
                 
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
            case XinstallSDKPluginMethodReportShareByXinShareId:
            {
                NSDictionary *args = call.arguments;
                NSString *shareId = (NSString *)args[@"shareId"];
                [[XinstallSDK defaultManager] reportShareByXinShareId:shareId];
                NSLog(@"reportShareByXinShareId--%@",args);
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
    NSDictionary *args = [self convertDataArguments:appData isWakeUp:NO];
    [self.flutterMethodChannel invokeMethod:@"onInstallNotification" arguments:args];
}

- (void)wakeUpParamsResponse:(XinstallData *) appData {
    NSDictionary *args = [self convertDataArguments:appData isWakeUp:YES];
    [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:args];
}

- (void)wakeUpDetailParamsResponse:(XinstallData *)wakeupDetailData withError:(XinstallError *)wakeupDetailError {
    if (wakeupDetailData != NULL || wakeupDetailError != NULL) {
        NSDictionary *args = @{};
        NSDictionary *error = @{};
        if (wakeupDetailData) {
            args = [self convertDataArguments:wakeupDetailData isWakeUp:YES];
        }
        if (wakeupDetailError) {
            error = @{@"errorType":@(wakeupDetailError.type),@"errorMsg":wakeupDetailError.errorMsg};
        }
        NSDictionary *params = @{@"wakeUpData":args,@"error":error};
        [self.flutterMethodChannel invokeMethod:@"onWakeupDetailNotification" arguments:params];
        self.wakeupData = NULL;
    }
}

- (NSDictionary *)convertDataArguments:(XinstallData *) appData isWakeUp:(BOOL)wakeUp{
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
- (void)xinstall_getWakeUpParams:(XinstallData *)appData error:(XinstallError *)error {
    
    if (appData != NULL) {
        if (self.hasRegister) {
            self.wakeupData = NULL;
            [self wakeUpParamsResponse:appData];
        } else {
            self.wakeupData = appData;
        }
    }
    if (self.hasDetailRegister) {
        self.wakeupDetailData = NULL;
        self.wakeupDetailError = NULL;
        [self wakeUpDetailParamsResponse:appData withError:error];
    } else {
        self.wakeupDetailData = appData;
        self.wakeupDetailError = error;
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

