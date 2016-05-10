//
//  CSIIShareView.h
//
//  Created by 胡中楷 on 14-11-1.
//  Copyright (c) 2014年 胡中楷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"

#define BOUNDS [[UIScreen mainScreen] bounds]

@protocol CSIIShareViewDelegate <NSObject>

- (void)clickButton:(UIButton *) button withIndex:(NSInteger) index;//点击分享视图上按钮的回调方法

@end

@interface CSIIShareView : UIView

@property (nonatomic, strong) NSString *itemFlag;//分享标识
@property (nonatomic, strong) NSArray *buttonArray;
@property (nonatomic, assign) id<CSIIShareViewDelegate> delegate;//分享视图协议方法

+ (id)shareInstencesWithItems:(NSArray *) array;
+ (void)shareViewShow;
+ (void)shareViewHide;

- (void)show;
- (void)hide;

@end
