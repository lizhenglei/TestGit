//
//  singleCheckButtonView.m
//  MobileClient
//
//  Created by xiaoxin on 15/5/5.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "singleCheckButtonView.h"
@interface singleCheckButtonView ()
{
    UIButton*leftBtn;
    UIButton*rightBtn;
}
@end

@implementation singleCheckButtonView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame title1:(NSString *)leftTitle title2:(NSString *)rightTitle{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage*singleimg = [UIImage imageNamed:@"singleBtnBG"];
        UIImage*singleimg_sec = [UIImage imageNamed:@"singleBtnBG_sec"];

        leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.backgroundColor = [UIColor clearColor];
        leftBtn.frame = CGRectMake(0, (self.frame.size.height-singleimg.size.height)/2, singleimg.size.width+45, singleimg.size.height);
        [leftBtn setTitle:@"" forState:UIControlStateNormal];
        [leftBtn setImage:singleimg forState:UIControlStateNormal];
        [leftBtn setImage:singleimg_sec forState:UIControlStateSelected];
        leftBtn.selected = YES;
        leftBtn.tag = 101;
        [leftBtn addTarget:self action:@selector(singleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftBtn];
        
        UILabel*leftLab = [[UILabel alloc]initWithFrame:CGRectMake(singleimg.size.width+28, 0, 40, singleimg.size.height)];
        leftLab.backgroundColor = [UIColor clearColor];
        leftLab.text = leftTitle;
        leftLab.font = [UIFont systemFontOfSize:14];
        [leftBtn addSubview:leftLab];

        
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.backgroundColor = [UIColor clearColor];
        rightBtn.frame = CGRectMake(70, (self.frame.size.height-singleimg.size.height)/2, singleimg.size.width+45, singleimg.size.height);
        [rightBtn setTitle:@"" forState:UIControlStateNormal];
        [rightBtn setImage:singleimg forState:UIControlStateNormal];
        [rightBtn setImage:singleimg_sec forState:UIControlStateSelected];
        rightBtn.tag = 102;
        [rightBtn addTarget:self action:@selector(singleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        
        UILabel*rightLab = [[UILabel alloc]initWithFrame:CGRectMake(singleimg.size.width+28, 0, 40, singleimg.size.height)];
        rightLab.backgroundColor = [UIColor clearColor];
        rightLab.text = rightTitle;
        rightLab.font = [UIFont systemFontOfSize:14];
        [rightBtn addSubview:rightLab];
    }
    return self;
}

-(void)singleAction:(UIButton*)btn{
    if (btn.selected) {
        return;
    }else{
        if (btn == leftBtn) {
            leftBtn.selected = YES;
            rightBtn.selected = NO;
        }else{
            rightBtn.selected = YES;
            leftBtn.selected = NO;
        }
    }
    if ([self.delegate respondsToSelector:@selector(selectedBtn:leftBtnTag:rightBtnTag:)]) {
        [self.delegate selectedBtn:btn leftBtnTag:101 rightBtnTag:102];
    }
}


@end
