//
//  Power.m
//  MobileBankSession
//
//  Created by dhw on 13-7-22.
//  Copyright (c) 2013年 北京科蓝软件系统有限公司. All rights reserved.
//

#import "Power.h"

@implementation Power
-(int)initWithLogin:(BOOL)islogin actionID:(int)actionID
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"down" ofType:@"json"];
    NSData *jdata=[[NSData alloc] initWithContentsOfFile:path];
    NSError *error = nil;
    NSMutableDictionary*dic=[NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    NSArray*needloginArray=[NSArray arrayWithObjects:@"200001",@"Transfer",nil];
    NSArray*array=[dic objectForKey:@"AuthorityList"];
    for(int i=0;i<array.count;i++)
    {
        if((int)[[array objectAtIndex:i]objectForKey:@"ActionId"]==actionID)
        {
            return power;
        }
    }
    for(int i=0;i<needloginArray.count;i++)
    {
        if((int)[needloginArray objectAtIndex:i]==actionID)
        {
            if (!islogin) {
                return nologin;
            }
            return power;
        }
    }
    return 1;


}
@end
