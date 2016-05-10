//
//  CommonFunc.h
//  PRJ_base64
//
//  Created by wangzhipeng on 12-11-29.
//  Copyright (c) 2012年 com.comsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __BASE64( text )        [CommonFunc base64StringFromTextDES:text]
#define __TEXT( base64 )        [CommonFunc textFromBase64StringDES:base64]

@interface CommonFunc : NSObject
+ (NSString *)md5:(NSString *)str;
+ (NSString *)base64StringFromTextDES:(NSString *)text;
+ (NSString *)textFromBase64StringDES:(NSString *)base64;
/******************************************************************************
 函数名称 : + (NSString *)base64StringFromText:(NSString *)text
 函数描述 : 将文本转换为base64格式字符串
 输入参数 : (NSString *)text    文本
 输出参数 : N/A
 返回参数 : (NSString *)    base64格式字符串
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64StringFromText:(NSString *)text;

/******************************************************************************
 函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
 函数描述 : 将base64格式字符串转换为文本
 输入参数 : (NSString *)base64  base64格式字符串
 输出参数 : N/A
 返回参数 : (NSString *)    文本
 备注信息 :
 ******************************************************************************/
+ (NSString *)textFromBase64String:(NSString *)base64;
+ (NSString *)base64EncodedStringFrom:(NSData *)data;

+ (NSString *)base64StringFromText2:(NSString *)text;//先转成base64，再加密

+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key;

@end
