//
//  GesturePasswordView.h
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

@protocol GesturePasswordDelegate <NSObject>

- (void)hiddenLoginAlert;
- (void)changeLoginFlag;

@end

#import <UIKit/UIKit.h>
#import "TentacleView.h"

@interface GesturePasswordView : UIView<TouchBeginDelegate>

@property (nonatomic,strong) TentacleView * tentacleView;

@property (nonatomic,strong) UILabel * state;

@property (nonatomic,assign) id<GesturePasswordDelegate> gesturePasswordDelegate;

@property (nonatomic,strong) UIImageView * imgView;
@property (nonatomic,strong) UIImageView * imgViewLogo;

@property (nonatomic,strong) UIButton * forgetButton;
@property (nonatomic,strong) UIButton * changeButton;
-(void)initHeaderView:(NSString*)passResult;          //传回结果
-(void)resetHeaderView;                              //重置提示view
@end
