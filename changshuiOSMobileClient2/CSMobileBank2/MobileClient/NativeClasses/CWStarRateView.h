//
//  CWStarRateView.h
//  MobileClient
//
//  Created by KJ on 15/5/13.
//  Copyright (c) 2015年 pro. All rights reserved.
//星级评价的类

#import <UIKit/UIKit.h>

@class CWStarRateView;
@protocol CWStarRateViewDelegate <NSObject>
@optional
- (void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent;
@end

@interface CWStarRateView : UIView

@property (nonatomic, assign) CGFloat scorePercent;//得分值，范围为0--1，默认为1
@property (nonatomic, assign) BOOL hasAnimation;//是否允许动画，默认为NO
@property (nonatomic, assign) BOOL allowIncompleteStar;//评分时是否允许不是整星，默认为NO
@property(nonatomic,strong)UITapGestureRecognizer *gestureTap;
@property (nonatomic, weak) id<CWStarRateViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars;

@end
