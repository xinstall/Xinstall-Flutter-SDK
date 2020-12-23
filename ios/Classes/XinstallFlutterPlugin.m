#import "XinstallFlutterPlugin.h"
#import "XinstallSDK.h"

typedef NS_ENUM(NSUInteger, XinstallSDKPluginMethod) {
    XinstallSDKPluginMethodInit,
    XinstallSDKPluginMethodGetInstallParams,
    XinstallSDKPluginMethodReportRegister,
    XinstallSDKPluginMethodReportEffectPoint
};

@interface XinstallFlutterPlugin () <XinstallDelegate>

@property (strong, nonatomic, readonly) NSDictionary *methodDict;
@property (strong, nonatomic) FlutterMethodChannel * flutterMethodChannel;

@end

@implementation XinstallFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.shubao.xinstall/xinstall_flutter_plugin"
            binaryMessenger:[registrar messenger]];
  XinstallFlutterPlugin* instance = [[XinstallFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
        [XinstallSDK initWithDelegate:self];
    }
    return self;
}

- (void)initData {
    _methodDict = @{
                    @"registerWakeup"         :      @(XinstallSDKPluginMethodInit),
                    @"getInstallParam"        :      @(XinstallSDKPluginMethodGetInstallParams),
                    @"reportRegister"         :      @(XinstallSDKPluginMethodReportRegister),
                    @"reportPoint"            :      @(XinstallSDKPluginMethodReportEffectPoint)
                    };
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSNumber *methodType = self.methodDict[call.method];
    if (methodType) {
        switch (methodType.intValue) {
            case XinstallSDKPluginMethodInit:
            {
                NSLog(@"Init");
                break;
            }
            case XinstallSDKPluginMethodGetInstallParams:
            {
                int time = (int) call.arguments[@"timeout"];
                if (time <= 0) {
                    time = 8;
                }
                [self installParamsResponse:[[XinstallSDK defaultManager] installData]];
                NSLog(@"GetInstallParams");
                break;
            }
            case XinstallSDKPluginMethodReportRegister:
            {
                [XinstallSDK reportRegister];
                NSLog(@"ReportRegister");
                break;
            }
            case XinstallSDKPluginMethodReportEffectPoint:
            {
                NSDictionary * args = call.arguments;
                NSNumber * pointValue = (NSNumber *) args[@"pointValue"];
                [[XinstallSDK defaultManager] reportEffectPoint:(NSString *)args[@"pointId"] effectValue:[pointValue longValue]];
                NSLog(@"ReportEffectPoint");
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
    NSDictionary *args = [self convertInstallArguments:appData];
    [self.flutterMethodChannel invokeMethod:@"onInstallNotification" arguments:args];
}

- (void)wakeUpParamsResponse:(XinstallData *) appData {
    NSDictionary *args = [self convertInstallArguments:appData];
    [self.flutterMethodChannel invokeMethod:@"onWakeupNotification" arguments:args];
}

- (NSDictionary *)convertInstallArguments:(XinstallData *) appData {
    NSString *channelCode = @"";
    NSString *bindData = @"";
    if (appData.channelCode != nil) {
        channelCode = appData.channelCode;
    }
    if (appData.data != nil) {
        bindData = [self jsonStringWithObject:appData.data];
    }
    NSDictionary * dict = @{@"channelCode":channelCode, @"bindData":bindData};
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
-(void)getWakeUpParams:(XinstallData *) appData{
    [self wakeUpParamsResponse:appData];
}


+ (BOOL)continueUserActivity:(NSUserActivity *) userActivity {
    return [XinstallSDK continueUserActivity:userActivity];
}

@end
