//
//  MenuButton.h
//  MobileClient
//
//  Created by 杨楠 on 14-8-14.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuButton : UIButton

@property (nonatomic, strong)NSDictionary* info;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title imageName:(NSString *)image iconKey:(NSInteger)key;

@end
