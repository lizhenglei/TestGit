//
//  FTUserProtocol.h
//  FTSTDLib
//
//  Created by liyuelei on 15/1/26.
//  Copyright (c) 2015年 FT. All rights reserved.
//

#import <Foundation/Foundation.h>

//错误码
#define  FT_SUCCESS                         0x00000000  //操作成功
#define  FT_OPERATION_FAILED                0x00000001  //操作失败
#define  FT_NO_DEVICE                       0x00000002  //设备未连接
#define  FT_DEVICE_BUSY                     0x00000003  //设备忙
#define  FT_INVALID_PARAMETER               0x00000004  //参数错误
#define  FT_PASSWORD_INVALID                0x00000005  //密码错误
#define  FT_USER_CANCEL                     0x00000006  //用户取消操作
#define  FT_OPERATION_TIMEOUT               0x00000007  //操作超时
#define  FT_NO_CERT                         0x00000008  //没有证书
#define  FT_CERT_INVALID                    0x00000009  //证书格式不正确
#define  FT_UNKNOW_ERROR                    0x0000000A  //未知错误
#define  FT_PIN_LOCK                        0x0000000B  //PIN码锁定
#define  FT_OPERATION_INTERRUPT             0x0000000C  //操作被打断（如来电等）
#define  FT_COMM_FAILED                     0x0000000D  //通讯错误
#define  FT_ENERGY_LOW                      0x0000000E  //设备电量不足，不能进行通讯
#define  FT_INVALID_DEVICE_TYPE             0x0000000F  //设备类型不匹配
#define  FT_CERT_EXPIRED                    0x00000010  //证书过期
#define  FT_MICROPHONE_REFUSE               0x00000011  //麦克风拒绝访问(ios7)
#define  FT_COMM_TIMEOUT                    0x00000012  //通讯超时
#define  FT_SN_NOTMATCH                     0x00000013  //序列号不匹配
#define  FT_SAME_PASSWORD                   0x00000014  //新旧密码相同
#define  FT_PASSWORD_INVALID_LENGTH         0x00000015  //密码长度错误
#define  FT_PASSWORD_DIFFERENT              0x00000016  //新密码与确认密码不一致
#define  FT_PASSWORD_EMPTY                  0x00000017  //密码为空
#define  FT_PASSWORD_TOO_SIMPLE             0x00000018  //简单密码
#define  FT_CERT_DN_NOTMATCH                0x00000019  //证书dn值不匹配
#define  FT_BLE_APP_NOT_BLE_AUTHORIZE       0x0000001A  //此应用没有得到蓝牙设置的授权
#define  FT_BLE_BLUETOOTH_POWER_OFF         0x0000001B  //蓝牙功能关闭
#define  FT_BLE_PLATFORM_NOT_SUPPORT_BLE    0x0000001C  //此设备不支持蓝牙4.0协议
#define  FT_SIGN_MESSAGE_ERROR              0x0000001D  //签名报文格式不正确

//算法
#define  FT_ALG_RSA                    0x00000000  //RSA算法

#define  FT_ALG_SHA1                   0x00000000  //SHA1算法
#define  FT_ALG_SHA256                 0x00000001  //SHA256算法
#define  FT_ALG_SHA384                 0x00000002  //SHA384算法
#define  FT_ALG_SHA512                 0x00000003  //SHA512算法

//===============以下为key连接或断开的回调接口，如客户需要可实现==================
@protocol FTKeyEventsDelegate <NSObject>
@optional
/**
 *  需客户实现的连接回调函数
 *
 *  @param 无
 *
 *  @return 无
 */
-(void)FTDidDeviceConnected;

/**
 *  需客户实现的断开连接回调函数
 *
 *  @param 无
 *
 *  @return 无
 */
-(void)FTDidDeviceDisconnected;

@end

//=========================以下为具体功能的回调接口，需客户实现
@protocol FTFunctionDelegate <NSObject>
@optional

/**
 *  需客户实现的验证PIN提示按键回调接口
 *
 *  @param PinCanRetrys Pin的剩余可重试次数
 *
 *  @return 无
 */
-(void)FTShowVerifyPinView:(NSInteger)PinCanRetrys;

/**
 *  需客户实现的隐藏验证PIN提示按键回调接口
 *
 *  @param 无
 *
 *  @return 无
 */
-(void)FTHideVerifyPinView;

/**
 *  需客户实现的修改PIN提示按键回调接口
 *
 *  @param PinCanRetrys Pin的剩余可重试次数
 *
 *  @return 无
 */
-(void)FTShowChangePinView:(NSInteger)PinCanRetrys;

/**
 *  需客户实现的隐藏修改PIN提示按键回调接口
 *
 *  @param 无
 *
 *  @return 无
 */
-(void)FTHideChangePinView;

/**
 *  需客户实现的签名过程中的提示按键回调接口
 *
 *  @param  无
 *
 *  @return 无
 */
-(void)FTShowSignView;

/**
 *  需客户实现的隐藏签名过程中的提示按键回调接口
 *
 *  @param  无
 *
 *  @return 无
 */
-(void)FTHideSignView;

@end


//=============以下为key厂商实现的功能接口，需厂商实现=============
@protocol FTUserProtocol <NSObject>
@required

/**
 *  获取静态库版本
 *
 *  @param Version 返回的静态库版本
 *
 *  @return 成功：0，失败：错误码
 */
+(NSInteger)FTGetLibVersion:(NSString **)Version;

/**
 *  设置key断开或连接的回调代理
 *
 *  @param delegate key连接或断开的回调代理
 *
 *  @return 无
 */
+(void)FTSetKeyEventsDelegate:(id<FTKeyEventsDelegate>)delegate;


/**
 *  移除key断开或连接的回调代理
 *
 *  注意:在delegate释放前需要调用此方法，否则会导致调用已释放的delegate出现崩溃
 *
 *  @param 无
 *
 *  @return 无
 */
+(void)FTRemoveKeyEventsDelegate;

/**
 * 设置通讯类型
 * @param  Type 通讯类型(0-音频(默认值), 1-蓝牙4.0(BLE))
 * @return 成功-0, 失败-错误码
 */
+(NSInteger)FTSetTransmitType:(NSInteger)Type;

/**
 * 根据Ukey序列号连接蓝牙设备(只适用于BLE)
 * @param  sn 要连接的Ukey的序列号
 * @param  timeout 连接Ukey等待的超时时间(以秒为单位)
 * @return 成功-0，失败-错误码
 */
+(NSInteger)FTConnectBLEDevice:(NSString *)sn timeout:(float)timeout;


/**
 *断开已经连接的蓝牙设备(只适用于BLE)
 *@param 无
 *
 *@return 成功-0，失败-错误码
 *
 */
+(NSInteger)FTDisconnectBLEDevice;

/**
 *  翻转Ukey屏显内容
 *
 *  @param 无
 *
 *  @return 成功-0，失败-错误码
 */
+(NSInteger)FTTurnOverKeyScreenState;

/**
 *  读取序列号
 *
 *  @param SN 返回的序列号
 *
 *  @return 成功-0，失败-错误码
 */
+(NSInteger)FTReadSN:(NSString **)SN;

/**
 *  读取证书
 *
 *  @param CertData 证书信息(base64编码)
 *
 *  @return 成功-0，失败-错误码
 */
+(NSInteger)FTReadCert:(NSString **)CertData;

/**
 *  校验pin码
 *
 *  @param Pin PIN码
 *  @param PinRemainTimes 功能执行后的PIN的可重试次数
 *  @param delegate 当key需要用户按键时，会调用delegate的实现的回调方法
 *
 *  @return 成功-0，失败-错误码
 */
+(NSInteger)FTVerifyPIN:(NSString*)Pin PinRemaintimes:(unsigned int *)PinRemainTimes delegate:(id<FTFunctionDelegate>)delegate;

/**
 *  修改pin码
 *
 *  @param oldPIN 原PIN码
 *  @param newPIN 新PIN码
 *  @param PinRemainTimes 功能执行后的PIN的可重试次数
 *  @param delegate 当key需要用户按键时，会调用delegate的实现的回调方法
 *
 *  @return 成功-0，失败-错误码
 */
+(NSInteger)FTChangePIN:(NSString *)oldPIN newPIN:(NSString *)newPIN PinRemainTimes:(unsigned int *)PinRemainTimes delegate:(id<FTFunctionDelegate>)delegate;

/**
 *  复核签名
 *
 *  @param signData 签名原文
 *  @param SignResult   签名结果(base64编码)
 *  @param hashAlg  哈希算法（sha1 - 0 ,sha256 - 1,sha384 - 2,sha512 - 3）
 *  @param DN       要使用签名的证书的使用者的DN值
 *  @param delegate 当key需要用户按键时，会调用delegate的实现的回调方法
 *
 *  @return 成功-0，失败-错误码
 */
+(NSInteger)FTSign:(NSString *)signData retData:(NSString **)SignResult hashAlg:(NSInteger)hashAlg byDN:(NSString *)DN delegate:(id<FTFunctionDelegate>)delegate;

/**
 *  签名
 *
 *  @param signData 签名原文
 *  @param SignResult   签名结果(base64编码)
 *  @param pin      PIN码
 *  @param pinRetryTimes      PIN码剩余可输入次数
 *  @param hashAlg  哈希算法（sha1 - 0 ,sha256 - 1,sha384 - 2,sha512 - 3）
 *  @param DN       要使用签名的证书的使用者的DN值
 *  @param delegate 当key需要用户按键时，会调用delegate的实现的回调方法
 *
 *  @return 成功-0，失败-错误码
 */
+(NSInteger)FTSign:(NSString *)signData retData:(NSString **)SignResult pin:(NSString *)pin pinRetryTimes:(unsigned int *)pinReTimes hashAlg:(NSInteger)hashAlg byDN:(NSString *)DN delegate:(id<FTFunctionDelegate>)delegate;

/**
 *  获取电量
 *
 *  @param energy 获取到的电量值(0 - 低电量，1 － 有电)
 *
 *  @return 成功-0，失败-错误码
 */
+(NSInteger)FTGetEnergy:(unsigned char *)energy;

@end