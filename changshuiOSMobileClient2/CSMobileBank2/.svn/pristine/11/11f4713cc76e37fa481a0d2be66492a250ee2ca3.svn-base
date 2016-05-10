//
//  CSIIUtility.h
//
//  Created by lsh on 13-10-21
//  Copyright (c) 2013年 科蓝公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSIIUtility : NSObject

//+ (BOOL)isValidPassword:(NSString*)password;

+(NSDictionary*)findMenuByActionId:(NSString*)actionId OrByActionName:(NSString*)actionName InMenuArray:(NSArray*)menuarray ActionIdBranch:(NSMutableArray*)actionIdBranch;

+(NSArray*)findPageHintsById:(NSString*)Id;

+(NSArray*)getTotalHeightAndLinesWithText:(NSString*)text Font:(UIFont*)font Width:(CGFloat)width;

+ (CGRect)getCentreRect:(CGRect)outer inner:(CGRect)inner;
+ (CGRect)getCentreRect:(CGRect)outer innerSize:(CGSize)innerSize;
+ (CGRect)getCentreRect:(CGRect)outer innerSize:(CGSize)innerSize top:(NSInteger)top;
+ (CGRect)getCentreRect:(CGRect)outer left:(NSInteger)left right:(NSInteger)right top:(NSInteger)top buttom:(NSInteger)buttom;

+ (CGRect)getRectAdd:(CGRect)originRect x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height;

@end
