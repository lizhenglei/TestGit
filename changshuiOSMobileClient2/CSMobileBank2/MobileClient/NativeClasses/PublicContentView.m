//
//  PublicContentView.m
//  MobileClient
//
//  Created by xiaoxin on 15/7/8.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "PublicContentView.h"
#import "MarqueeLabel.h"
#import "CSIIMenuViewController.h"
#define marQueeLabelHeight 50
@implementation PublicContentView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    if (![CSIIMenuViewController sharedInstance].isLoadPubview) {
        return;
    }
    
    count = 0;
    
    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, marQueeLabelHeight)];
    scrollview.contentSize = CGSizeMake(self.frame.size.width,_contentArray.count*marQueeLabelHeight);
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.showsVerticalScrollIndicator = NO;
    scrollview.scrollEnabled = NO;
    scrollview.pagingEnabled = YES;
    [scrollview setBounces:NO]; //禁止回弹
    scrollview.backgroundColor = [UIColor clearColor];
    scrollview.userInteractionEnabled = YES;
    scrollview.delegate = self;
    [self addSubview:scrollview];
    
    for (int x=0; x<_contentArray.count; x++) {
        
        UIButton *view = [[UIButton alloc]initWithFrame:CGRectMake(10, x*marQueeLabelHeight, self.frame.size.width-10, marQueeLabelHeight)];
        view.backgroundColor = [UIColor clearColor];
        view.tag = x;
//        MarqueeLabel.h 定义的类可以横向滚动
        UILabel*adverLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, x*marQueeLabelHeight-2, self.frame.size.width-10, 25)];
        adverLabel.backgroundColor = [UIColor clearColor];
//        adverLabel.marqueeType = MLContinuous;
        adverLabel.font = [UIFont systemFontOfSize:13];
        adverLabel.textColor = [UIColor whiteColor];
//        adverLabel.scrollDuration = 30.0f;
//        adverLabel.tag = x;
        adverLabel.userInteractionEnabled = YES;
        [view addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
//        adverLabel.animationCurve = UIViewAnimationCurveEaseOut;
//        adverLabel.fadeLength = 0;                                //两面虚化的长度
//        adverLabel.continuousMarqueeExtraBuffer =  10.0f;
        
        NSString *titleStr = [[_contentArray objectAtIndex:x]objectForKey:@"TITLE"];
        
        NSString *messageStr22 = [[_contentArray objectAtIndex:x] objectForKey:@"CONTENT"];
        NSString *str2 = [messageStr22 stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        NSString *str3 = [str2 stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        
        adverLabel.text = [NSString stringWithFormat:@"%@：%@",titleStr,str3] ;//常熟农商行手机银行全新改版，常乐生活，等你来享！！！！
        [scrollview addSubview:adverLabel];
        [scrollview addSubview:view];

    }
    [CSIIMenuViewController sharedInstance].isLoadPubview = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loopAction) userInfo:nil repeats:YES];
}

-(void)loopAction{
    
    if (count<_contentArray.count-1) {
        
        count++;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        scrollview.contentOffset = CGPointMake(0, count*marQueeLabelHeight);
        [UIView commitAnimations];

    }else{
        count = 0;
        scrollview.contentOffset = CGPointMake(0, 0);
    }
}

-(void)click:(UIButton*)tap{
    
    window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    bgBackView = [[UIView alloc]initWithFrame:window.frame];
    bgBackView.backgroundColor = [UIColor blackColor];
    bgBackView.alpha = 0.5f;
    [window addSubview:bgBackView];
    NSString *gongGaoStr;
    CGSize wenziSize;

    if (![[_contentArray[tap.tag] objectForKey:@"CONTENT"] isEqualToString:@""]) {
        
        gongGaoStr = [_contentArray[tap.tag] objectForKey:@"CONTENT"];
        gongGaoStr = [gongGaoStr stringByAppendingString:@"\n"];
        wenziSize = [gongGaoStr sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        
    }

    
    _alertView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth/2-140, (bgBackView.frame.size.height-(wenziSize.height+65))/2, 280, wenziSize.height+85)];
    _alertView.tag = 444;
    _alertView.layer.cornerRadius = 8;
    _alertView.layer.masksToBounds = YES;
    _alertView.layer.borderWidth = 1;
    _alertView.layer.borderColor = [UIColor grayColor].CGColor;
    _alertView.backgroundColor = [UIColor whiteColor];
    [window addSubview: _alertView];
    
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, _alertView.frame.size.width, 25)];
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.text = [_contentArray[tap.tag] objectForKey:@"TITLE"];
    titleLab.font = [UIFont boldSystemFontOfSize:17];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [_alertView addSubview:titleLab];
    
    UILabel *_gonggaoTV = [[UILabel alloc]initWithFrame:CGRectMake(10, 37, _alertView.frame.size.width-20, wenziSize.height+10)];

    _gonggaoTV.textAlignment = NSTextAlignmentLeft;
    _gonggaoTV.text = gongGaoStr;
    _gonggaoTV.numberOfLines = 0;
//    NSLog(@"公告内容%@",_gonggaoTV.text);
    _gonggaoTV.font = [UIFont systemFontOfSize:14.0];
    _gonggaoTV.backgroundColor = [UIColor clearColor];
    [_alertView addSubview:_gonggaoTV];
    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 45+wenziSize.height-1, _alertView.frame.size.width, 1)];
    lineView2.backgroundColor = [UIColor grayColor];
    lineView2.alpha = 0.4f;
    [_alertView addSubview:lineView2];
    
    UIButton *bottomButtom = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomButtom.frame = CGRectMake(0, _alertView.frame.size.height-50+5, _alertView.frame.size.width, 50);
    bottomButtom.backgroundColor = [UIColor clearColor];
    [bottomButtom addTarget:self action:@selector(hidePublicView) forControlEvents:UIControlEventTouchUpInside];
    bottomButtom.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [bottomButtom setTitleColor:[UIColor colorWithRed:0.00f green:0.46f blue:1.00f alpha:1.00f] forState:UIControlStateNormal];
    [bottomButtom setTitle:@"确认" forState:UIControlStateNormal];
    [_alertView addSubview:bottomButtom];
    //    ShowAlertView([_contentArray[tap.tag] objectForKey:@"TITLE"], [_contentArray[tap.tag] objectForKey:@"CONTENT"], nil, @"确定", nil);
    
}
-(void)hidePublicView
{
    [bgBackView removeFromSuperview];
    [_alertView removeFromSuperview];
}
@end
