//  1.5.9
//  XinstallSDK.h
//  XinstallSDK
//
//  Created by Xinstall on 2020/5/7.
//  Copyright © 2021 Shu Bao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XinstallData.h"
#import "XinstallError.h"
#import "XinstallDefault.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XinstallDelegate <NSObject>
@optional
/**
 * 一键拉起时获取 H5页面 携带的动态参数，参数中如果携带渠道，也会在方法中一起返回渠道号
 * @param appData 动态参数对象
 * appData 的 uo co 数据如果前端传入不是正常的json 数据，会返回前端传入的 String ，如果为正常 JSON 数据 会返回字典或数组
 * @discuss 【注意】该方法只会在成功获取到拉起参数时，才会回调。如果无法成功获取到拉起参数，则不会执行该回调方法。
 */
- (void)xinstall_getWakeUpParams:(nullable XinstallData *)appData;

/**
 * 一键拉起时获取 H5页面 携带的动态参数，参数中如果携带渠道，也会在方法中一起返回渠道号
 * @param appData 动态参数对象
 * @param error 如果没有正确处理唤醒参数，则 appData == nil 且 error != nil ；如果正确处理了唤醒参数，则 appData != nil 且 error == nil
 * appData 的 uo co 数据如果前端传入不是正常的json 数据，会返回前端传入的 String ，如果为正常 JSON 数据 会返回字典或数组
 * @discuss 【注意】该方法无论是否成功获取到拉起参数，均会回调。
 * @discuss 【注意】如果同时实现了 「- xinstall_getWakeUpParams:」 和 「- xinstall_getWakeUpParams:error:」方法，那么只会回调「- xinstall_getWakeUpParams:error:」方法
 */
- (void)xinstall_getWakeUpParams:(nullable XinstallData *)appData error:(nullable XinstallError *)error;

/**
 * 安装时获取 H5页面 携带的动态参数，参数中如果携带渠道，也会在方法中一起返回渠道号
 * @param appData 动态参数对象
 * appData 的 uo co 数据如果前端传入不是正常的json 数据，会返回前端传入的 String ，如果为正常 JSON 数据 会返回字典或数组
 *
 * 【注意】该方法已经废弃，请勿使用，后续版本中将移除该方法。请使用 getInstallParamsWithCompletion: 方法进行替代！
 */
- (void)xinstall_getInstallParams:(nullable XinstallData *)appData DEPRECATED_MSG_ATTRIBUTE("方法已废弃，后续版本将移除该方法。请使用 getInstallParamsWithCompletion: 方法进行代替");

@end


@interface XinstallSDK : NSObject

/**
 * 获取 Xinstall SDK 当前版本
 */
+ (NSString *)sdkVersion;

/// 设置是否显示SDK日志
+ (void)setShowLog:(BOOL)isShow;

/// 是否显示SDK日志
+ (BOOL)isShowLog;

+ (instancetype _Nullable)defaultManager;

/**
 * 【重要】初始化 Xinstall SDK
 * 该方法只需要调用一次，调用时机尽量提前，一般在 App 启动时调用该方法进行初始化
 * 调用该方法前，需在 Info.plist 文件中配置键值对，键为固定值 com.xinstall.APP_KEY ，值为 Xinstall 后台对应应用的 appKey，可在 Xinstall 官方后台获取
 *
 * @param delegate 实现 XinstallDelegate 的对象
 */
+ (void)initWithDelegate:(id<XinstallDelegate> _Nonnull)delegate;

/**
 * 【重要】初始化 Xinstall SDK（支持广告平台渠道。若您不使用广告平台渠道，请使用 + initWithDelegate: 方法，否则可能导致上架 App Store 时被拒绝）
 * 该方法只需要调用一次，调用时机尽量提前，一般在 App 启动时调用该方法进行初始化
 * 调用该方法前，需在 Info.plist 文件中配置键值对，键为固定值 com.xinstall.APP_KEY ，值为 Xinstall 后台对应应用的 appKey，可在 Xinstall 官方后台获取
 *
 * @param delegate 实现 XinstallDelegate 的对象
 * @param idfa 当前手机 IDFA 字符串
 *
 * @discuss [该方法和 + initWithDelegate: 的区别]：使用该方法初始化时，需要根据文档获取 IDFA 后进行初始化，支持上报广告平台渠道的数据（在 Xinstall 管理后台新建的广告平台渠道）；使用 + initWithDelegate: 方法初始化，则无法统计广告平台渠道的数据。
 */
+ (void)initWithDelegate:(id<XinstallDelegate> _Nonnull)delegate idfa:(NSString *)idfa;

/**
 * 【重要】初始化 Xinstall SDK（支持广告平台渠道。若您不使用广告平台渠道，请使用 + initWithDelegate: 方法，否则可能导致上架 App Store 时被拒绝）
 * 该方法只需要调用一次，调用时机尽量提前，一般在 App 启动时调用该方法进行初始化
 * 调用该方法前，需在 Info.plist 文件中配置键值对，键为固定值 com.xinstall.APP_KEY ，值为 Xinstall 后台对应应用的 appKey，可在 Xinstall 官方后台获取
 *
 * @param delegate 实现 XinstallDelegate 的对象
 * @param idfa 当前手机 IDFA 字符串，可以为空
 * @param asaToken 当前手机 ASA token，可以为空
 *
 * @discuss [该方法和 + initWithDelegate: 的区别]：使用该方法初始化时，需要根据文档获取 IDFA 后进行初始化，支持上报广告平台渠道的数据（在 Xinstall 管理后台新建的广告平台渠道）；支持上报 ASA 渠道的数据
 */
+ (void)initWithDelegate:(id<XinstallDelegate> _Nonnull)delegate idfa:(nullable NSString *)idfa asaToken:(nullable NSString *)asaToken;

/**
 * 处理 通用链接
 * @param userActivity 由 AppDelegate 和 SceneDelegate 内对应方法中传入
 * @return 本次唤起是否被 Xinstall 正常处理
 */
+ (BOOL)continueUserActivity:(NSUserActivity *_Nullable)userActivity;

/**
 * 获取安装数据（h5页面动态参数）
 * 业务中获取安装数据的地方可调用该方法进行获取，获取结果通过异步 block 方式进行回调
 * 获取到数据时，installData != nil， error == nil
 * 由于该方法在某些场景下需要联网获取数据，由于网络的不稳定性，可能无法获取到数据，当 error != nil 时代表获取失败，此时 installData == nil
 * 在获取数据失败时，可对 error.type 类型进行判断，从而进行错误处理
 *
 * @param completion 获取结束后回调。回调参数：installData：安装数据，error：获取失败时的错误对象
 */
- (void)getInstallParamsWithCompletion:(void (^)(XinstallData * __nullable installData, XinstallError * __nullable error))completion;

/**
 * 上报一次注册量
 *
 * 调用该方法后，会上报对应渠道的一次注册量，可以在 Xinstall 管理后台对应 App 的渠道报表中看到累计注册量等数据
 * 一般该方法会在 App 业务注册后进行调用，在实际使用场景中请注意不要重复调用，以免注册量上报次数过多
 */
+ (void)reportRegister;

/**
 * 上报一次事件（必须预先在 Xinstall 后台对应 App 内创建好事件ID，才能正确统计进去）
 *
 * 调用该方法后，会上报一次对应事件。上报机制非实时，会存在一定的延时，但不会超过1分钟
 *
 * @param eventID 事件ID（在 Xinstall 后台预先创建）
 * @param eventValue 事件值（精确到整数）
 */
- (void)reportEventPoint:(NSString *_Nonnull)eventID eventValue:(long)eventValue;

/**
 * 在用户开启详情按钮后，可以统计事件详情，并且可以上传关联数据(subValue)
 * 上报一次事件（必须预先在 Xinstall 后台对应 App 内创建好事件ID，才能正确统计进去）
 *
 * 调用该方法后，会上报一次对应事件。上报机制非实时，会存在一定的延时，但不会超过1分钟
 *
 * @param eventID 事件ID（在 Xinstall 后台预先创建）
 * @param eventValue 事件值（精确到整数）
 * @param subValue 事件关联值 (字符串)
 */
- (void)reportEventWhenOpenDetailInfoWithEventPoint:(NSString *)eventID eventValue:(long)eventValue subValue:(NSString *)subValue;

/**
 * 上报一次分享id（建议在分享成功后上报）
 *
 * @param xinShareId 分享id
 */
- (void)reportShareByXinShareId:(NSString *_Nonnull)xinShareId;

+ (BOOL)handleSchemeURL:(NSURL *_Nullable)URL;



#pragma mark - 以下为废弃方法，请使用对应的新方法进行替代使用，后续版本将会移除已废弃的方法
/**
 * 【注意】该属性已经废弃，请勿使用，后续版本中将移除该方法。请使用 getInstallParamsWithCompletion: 方法进行替代！
 */
@property (nonatomic, strong, readonly) XinstallData * __nullable installData DEPRECATED_MSG_ATTRIBUTE("属性已废弃，后续版本将移除该属性。请使用 getInstallParamsWithCompletion: 方法进行代替");



@end

NS_ASSUME_NONNULL_END
