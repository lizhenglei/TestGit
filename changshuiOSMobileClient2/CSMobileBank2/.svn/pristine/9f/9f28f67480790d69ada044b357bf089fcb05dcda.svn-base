//
//  singleCheckButtonView.h
//  MobileClient
//
//  Created by xiaoxin on 15/5/5.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleBtnDelegate <NSObject>

@optional
-(void)selectedBtn:(UIButton*)btn leftBtnTag:(int)left rightBtnTag:(int)right;

@end

@interface singleCheckButtonView : UIView
{
    id <SingleBtnDelegate> __unsafe_unretained  delegate;

}
@property(nonatomic,assign)id<SingleBtnDelegate> __unsafe_unretained delegate;

- (id)initWithFrame:(CGRect)frame title1:(NSString *)leftTitle title2:(NSString *)rightTitle;
@end
