//
//  keyboardencrypt.h
//  keyboardencrypt
//
//  Created by 李强 on 14-5-12.
//  Copyright (c) 2014年 李强. All rights reserved.
//

#import <Foundation/Foundation.h>
#define isKeyBoardDebug 1
@interface keyboardencrypt : NSObject{
    
    void *pencrypt_ctx;
    
}
typedef enum {
    //以下是枚举成员
    
    low=13,
    cap,
    pun,
    num,
    sh_def
}Character;//枚举名称
@property (nonatomic,retain)NSString *strRealValue;

//-(int)InitCtx:(const char*)time;
//
//-(int)Encrypt:(const char*)pwd passwordLen:(int)pwdLen
//  encryptData:(char*)data DataLen:(int)dataMinLen;



//创建小写键盘序列
+(NSData*)creat_LowCharArray;
+(NSData*)creat_CapCharArray;
+(NSData*)creat_NumCharArray;
+(NSData*)creat_PunCharArray;

+(NSData*)creatLowCharArray;

//创建大写键盘序列
+(NSData*)creatCapCharArray;

//穿件符号键盘序列
+(NSData*)creatPunCharArray;


+(NSData*)creatNumCharArray;


+(void)cancel;




//初始化沙海加密
//只调用一次
+(void)init_keyboardencrypt;

//取得下标
+(NSString*)getYouButtonIndex:(NSString*)_strindex withCharachter:(Character)_chrachter;

//功能按键下标
+(void)functionClick:(NSString*)_strindex withCharachter:(Character)_chrachter;


+(NSString*)gFunctionOnClickEvent:(NSString*)pwdTextField maxLenPwd:(NSString*)maxLenPwd minLenPwd:(NSString*)minLenPwd timeStr:(NSMutableString*)timeStr;







@end
