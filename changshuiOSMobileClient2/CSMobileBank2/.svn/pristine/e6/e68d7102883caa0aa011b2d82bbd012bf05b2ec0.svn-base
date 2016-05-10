//
//  UINavigationBar+setbackgroud.m
//  MobileClient
//
//  Created by 李文友 on 14-3-13.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "UINavigationBar+setbackgroud.h"
#import "ThemeManager.h"

@implementation UINavigationBar (setbackgroud)

//5.0以下系统自定义UINavigationBar背景

- (void)drawRect:(CGRect)rect {
    UIImage *image = [[ThemeManager shareInstance] getThemeImage:@"navigationbar_background.png"];
    [image drawInRect:rect];
}

@end
