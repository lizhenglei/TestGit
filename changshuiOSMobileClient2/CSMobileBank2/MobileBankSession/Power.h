//
//  Power.h
//  MobileBankSession
//
//  Created by dhw on 13-7-22.
//  Copyright (c) 2013年 北京科蓝软件系统有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    power =0,
    nopower=1,
    login =2,
    nologin=3,
}powerList;
@interface Power : NSObject
{
    powerList*powerlist;
}
-(int)initWithLogin:(BOOL)islogin actionID:(int)actionID;
@end
