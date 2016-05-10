//
//  NSString+Substring.h
//  MobileClient
//
//  Created by 杨楠 on 14-8-14.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Substring)

- (NSString *)substringFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (BOOL)isEqualToItem:(NSArray *)items;

@end
