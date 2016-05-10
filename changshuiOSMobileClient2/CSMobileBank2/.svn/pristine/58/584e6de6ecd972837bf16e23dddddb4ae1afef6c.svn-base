//
//  CSIIUtility.m
//
//  Created by lsh on 13-10-21
//  Copyright (c) 2013年 科蓝公司. All rights reserved.
//

#import "CSIIUtility.h"

@implementation CSIIUtility

+(NSDictionary*)findMenuByActionId:(NSString*)actionId OrByActionName:(NSString*)actionName InMenuArray:(NSArray*)menuarray ActionIdBranch:(NSMutableArray*)actionIdBranch
{
    if (menuarray==nil || menuarray.count==0 )
        return nil;
    //NSLog(@"findMenuByActionId:");
    if ((actionId==nil || [actionId isEqualToString:@""]) && (actionName==nil || [actionName isEqualToString:@""]))
        return nil;
    
    for (int i = 0; i<menuarray.count; i++)
    {
        NSString *menuActionId = [menuarray[i] objectForKey:MENU_ACTION_ID];
        NSString *menuActionName = [menuarray[i] objectForKey:MENU_ACTION_NAME];
        
        BOOL isEqual = NO;
        if(actionId!=nil && ![actionId isEqualToString:@""])//优先用ActionId来比较
            isEqual = [menuActionId isEqualToString:actionId];
        else if(actionName!=nil && ![actionName isEqualToString:@""])
            isEqual = [menuActionName isEqualToString:actionName];
        
        if(isEqual)
        {
            //找到想要的菜单
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[menuarray[i] objectForKey:MENU_ACTION_ID],MENU_ACTION_ID, [menuarray[i] objectForKey:MENU_ACTION_NAME],MENU_ACTION_NAME, [menuarray[i] objectForKey:MENU_PRD_ID],MENU_PRD_ID,nil];
            [actionIdBranch addObject:dict];
            return (NSDictionary*)menuarray[i];
        }
    }
    
    for (int i = 0; i<menuarray.count; i++)
    {
        if ([menuarray[i] objectForKey:MENU_LIST]!=nil
            && ((NSArray*)[menuarray[i] objectForKey:MENU_LIST]).count>0)
        {
            //有下一级菜单列表
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[menuarray[i] objectForKey:MENU_ACTION_ID],MENU_ACTION_ID, [menuarray[i] objectForKey:MENU_ACTION_NAME],MENU_ACTION_NAME, [menuarray[i] objectForKey:MENU_PRD_ID],MENU_PRD_ID,nil];
            [actionIdBranch addObject:dict];
            
            NSDictionary* menuDict = [self findMenuByActionId:actionId OrByActionName:actionName InMenuArray:[menuarray[i] objectForKey:MENU_LIST] ActionIdBranch:actionIdBranch];
            
            if (menuDict!=nil)
                return menuDict;
            
            [actionIdBranch removeLastObject];
        }
    }
    
    return nil;
}

//通过Id查找温馨提示
+(NSArray*)findPageHintsById:(NSString*)Id
{
/*
     在菜单文件中有和ActionId平级的Id字段，然后通过该Id在menu.do返回的数据里查找到对应的页面号们，见menu.do里的PageNo字段，
     "PageNo":{
     "":["PM05000001","PM05000002"],
     "PayeeBookMgr":["PM02080001","PM02080002","PM02080003","PM02080004"]}
     
     通过页面号PM05000001，再找温馨提示。
     "Hints":{
     "PM02070303":["温馨提示1"],
     "PM07040001":["温馨提示2"],
     "PM02070301":["温馨提示3"]}
*/
    return nil;//加上这句话，可使动态温馨提示不显示。
    if(Id==nil || [Id isEqualToString:@""])
        return nil;
    
    // 特殊：银行公告Id为pbanknotice,对应如下
    //"Pcommon":["PM06000001","PM06000002"]
    if([Id isEqualToString:@"pbanknotice"])
        Id = @"Pcommon";
    
    NSDictionary *pageNoDict = [[Context sharedInstance].menuInfo_UserInfo_Hints objectForKey:@"PageNo"];
    NSArray *pageNoArray = [pageNoDict objectForKey:Id];
    
    if(pageNoArray == nil || [pageNoDict objectForKey:Id]==[NSNull null] || pageNoArray.count == 0)
        return  nil;
    
    NSDictionary *hintsDict = [[Context sharedInstance].menuInfo_UserInfo_Hints objectForKey:@"Hints"];
    NSMutableArray *pageHintsArray = [[NSMutableArray alloc]init];
    
    for(int i=0; i<pageNoArray.count; i++)
    {
        [pageHintsArray addObject:[NSNull null]];
        
        NSString* pageNo = pageNoArray[i];
        
        NSArray *singlePageHintsArray = [hintsDict objectForKey:pageNo];
        if(singlePageHintsArray != nil && [hintsDict objectForKey:pageNo]!=[NSNull null] && singlePageHintsArray.count != 0){
            [pageHintsArray replaceObjectAtIndex:i withObject:singlePageHintsArray];
        }
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pageHintsArray options:0 error:NULL];
    NSString* jsonString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    DebugLog(@"findPageHintsById:%@,\n%@\n",Id,jsonString);
    
    for(id item in pageHintsArray)
    {
        if(item!=[NSNull null] && item!=nil)
            return pageHintsArray;
    }
    
    return nil;
}

+(NSArray*)getTotalHeightAndLinesWithText:(NSString*)text Font:(UIFont*)font Width:(CGFloat)width
{
    //得到字符串在1行全显示时的总宽度
    CGSize sz = [text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT,15)];
    
    //得到字符串在宽度为参数width时，分行显示时的总高度
    CGSize linesSz = [text sizeWithFont:font constrainedToSize:CGSizeMake(width,MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    if ((NSInteger)sz.width == 0 || (NSInteger)linesSz.width == 0){
        return [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithFloat:0.0f],nil];
    }
    
    //计算显示的行数
    NSInteger lines = 0;
    lines = ((NSInteger)sz.width)/((NSInteger)linesSz.width);
    
    if( ((NSInteger)sz.width)%((NSInteger)linesSz.width) != 0 )
        lines += 1;
    
    return [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:lines], [NSNumber numberWithFloat:linesSz.height],nil];
}

+ (CGRect)getCentreRect:(CGRect)outer inner:(CGRect)inner {
    CGSize innerSize = inner.size;
    return [CSIIUtility getCentreRect:outer innerSize:innerSize];
}

+ (CGRect)getCentreRect:(CGRect)outer innerSize:(CGSize)innerSize {
    CGSize outerSize = outer.size;
    return CGRectMake((outerSize.width - innerSize.width)/2, (outerSize.height - innerSize.height)/2, innerSize.width, innerSize.height);
}

+ (CGRect)getCentreRect:(CGRect)outer innerSize:(CGSize)innerSize top:(NSInteger)top {
    CGSize outerSize = outer.size;
    return CGRectMake((outerSize.width - innerSize.width)/2, top, innerSize.width, innerSize.height);
}

+ (CGRect)getCentreRect:(CGRect)outer left:(NSInteger)left right:(NSInteger)right top:(NSInteger)top buttom:(NSInteger)buttom {
    CGSize outerSize = outer.size;
    return CGRectMake(left, top, outerSize.width - left - right, outerSize.height - top - buttom);
}

+ (CGRect)getRectAdd:(CGRect)originRect x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height {
    return CGRectMake(originRect.origin.x + x, originRect.origin.y + y, originRect.size.width + width, originRect.size.height + height);
}

@end
