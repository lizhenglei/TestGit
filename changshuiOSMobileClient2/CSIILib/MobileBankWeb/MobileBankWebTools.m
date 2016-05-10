//
//  MobileBankTools.m
//  MobileBankWeb
//
//  Created by Yuxiang on 13-6-8.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import "MobileBankWebTools.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"
#import "MobileBankSession.h"

#define HUD_TAG 10002

@implementation MobileBankWebTools
@synthesize taskInProgress;
+ (MobileBankWebTools *)sharedInstance
{
    static MobileBankWebTools *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{//线程安全
        sharedInstance = [[MobileBankWebTools alloc] init];
    });
    return sharedInstance;
}

-(id)jsonAnalysis:(NSString *)string{
    if ([string objectFromJSONString]==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"json解析出错，请检查json语法" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    return [string objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
}
-(void)showIndicatorViewWithMessage:(NSString *)mes  andViews:(UIView *)view;//显示等待遮罩层
{

    [[MobileBankSession sharedInstance]showMask:nil maskMessage:nil maskType:Common];
    
//    DebugLog(@"MobileBankWebTools ---Maskshow");
}



-(void)hideIndicatorView:(UIView *)view;//隐藏等待遮罩层
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleShowTimeOut) object:nil];//取消可能存在的遮罩层超时异步请求。
    [[MobileBankSession sharedInstance]hideMask];
}
-(NSString *)otherTojson:(id )other{
    
    if (other!=nil) {
        BOOL isTurnableToJSON =[NSJSONSerialization isValidJSONObject: other];
        if (isTurnableToJSON) {
            return [other   JSONString] ;
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"转换json失败，请检查数据" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    return nil;
}

/*
-(void)showAlertView:(id)obj withTag:(int)tag;{
    
    if ([obj isKindOfClass:[NSString class]]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:obj delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = tag;
        [alert show];
    }
    
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[obj objectForKey:@"title"] message:[obj objectForKey:@"message"] delegate:self cancelButtonTitle:[obj objectForKey:@"negativeText"] otherButtonTitles:[obj objectForKey:@"positiveText"], nil];
        alert.tag=tag;
        [alert show];
    }
}*/

@end

