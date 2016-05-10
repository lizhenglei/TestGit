//
//  Myconfig.m
//  MobileBankSession
//
//  Created by Yuxiang on 13-6-21.
//  Copyright (c) 2013年 北京科蓝软件系统有限公司. All rights reserved.
//

#import "MyConfig.h"

@implementation MyConfig
+ (MyConfig *)sharedInstance
{
    static MyConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{//线程安全
        sharedInstance = [[MyConfig alloc] init];
    });
    return sharedInstance;
}
- (NSString*)urlOnBackendServer
{
   return @"http://192.201.202.199:8082/pmob";
}
    
@end
