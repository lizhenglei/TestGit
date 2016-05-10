//
//  SingleClass.m
//  MobileClient
//
//  Created by 何崇 on 14-6-19.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "SingleClass.h"

@implementation SingleClass
+(SingleClass *)shareClass {
    static SingleClass *single = nil;
    if (single == nil) {
        single = [[SingleClass alloc] init];
    }
    return single;
}
@end
