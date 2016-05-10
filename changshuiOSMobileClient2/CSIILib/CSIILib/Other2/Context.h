//
//  Context.h
//  MobileClient
//
//  Created by fb on 13-7-24.
//  Copyright (c) 2013年 pro. All rights reserved.
//
//单例  做扩展用
#import <Foundation/Foundation.h>
enum {
    // iPhone 1,3,3GS 标准分辨率(320x480px)
    UIDevice_iPhoneStandardRes      = 1,
    // iPhone 4,4S 高清分辨率(640x960px)
    UIDevice_iPhoneHiRes            = 2,
    // iPhone 5 高清分辨率(640x1136px)
    UIDevice_iPhoneTallerHiRes      = 3,
    // iPad 1,2 标准分辨率(1024x768px)
    UIDevice_iPadStandardRes        = 4,
    // iPad 3 High Resolution(2048x1536px)
    UIDevice_iPadHiRes              = 5
}; typedef NSUInteger UIDeviceResolution;

@interface Context : NSObject

@property (assign, nonatomic) int cunAnimationID;// 动画方向ID
@property (assign, nonatomic) int preAnimationID;// 前次动画方向ID
@property (assign, nonatomic) BOOL firstFlage;
@property (strong, nonatomic) NSMutableDictionary *rateDic;//4个利率
@property (strong, nonatomic) NSDictionary *menuInfo_UserInfo_Hints;
@property (assign, nonatomic) BOOL server_backend_ssl;
@property (strong, nonatomic) NSString *server_backend_name;
@property (strong, nonatomic) NSString *encryption_platform_modulus;
@property (strong, nonatomic) NSString *appVersionCode;
@property (strong, nonatomic) NSArray *curNativeRelatedPageServerHints;//当前显示的菜单关联原生页面的服务器温馨提示，包括录入页面，确认页，结果页的温馨提示

+ (Context *)sharedInstance;

+ (NSInteger)navigationBarHeight;
+ (BOOL)iOS7;


/******************************************************************************
 函数名称 : + (UIDeviceResolution) currentResolution
 函数描述 : 获取当前分辨率
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (UIDeviceResolution) currentResolution;

/******************************************************************************
 函数名称 : + (UIDeviceResolution) currentResolution
 函数描述 : 当前是否运行在iPhone5端
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (BOOL)iPhone5;
+ (BOOL)iPhone4;

/******************************************************************************
 函数名称 : + (BOOL)isRunningOniPhone
 函数描述 : 当前是否运行在iPhone端
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (BOOL)isRunningOniPhone;
/******************************************************************************
对存储本地的数据进行加密
******************************************************************************/
+ (void)setNSUserDefaults:(NSString*)text keyStr:(NSString*)key;

/******************************************************************************
 取出本地的加密内容，返回解密后的内容
 ******************************************************************************/
+ (NSString*)getNSUserDefaultskeyStr:(NSString*)key;


+(NSString *)isArm64OrArm32;//判断是32位还是64位的
+ (NSMutableDictionary *)jsonDicFromString:(NSString *)jsonStr;

+ (NSString *)jsonStrFromDic:(NSDictionary *)jsonDic;

@end
