//
//  NSString+Substring.m
//  MobileClient
//
//  Created by 杨楠 on 14-8-14.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "NSString+Substring.h"

@implementation NSString (Substring)

- (NSString *)substringFromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
    NSString* temp = [self substringFromIndex:from];
    if (temp.length > to) {
        return [temp substringToIndex:to];
    } else {
        return temp;
    }
}

- (BOOL)isEqualToItem:(NSArray *)items {
    for (NSString* s in items) {
        if ([self isEqualToString:s]) {
            return YES;
        }
    }
    return NO;
}

@end
