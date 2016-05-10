//
//  SMSCodeButton.m
//  MobileClient
//
//  Created by 杨楠 on 14/8/21.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "SMSCodeButton.h"

@interface SMSCodeButton ()
{
    NSTimer* _clock;
    MobileBankSession* _session;
    int _time; //秒
}
@end

@implementation SMSCodeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds =  YES;
//        self.layer.borderWidth = 1.0f;
        [self setTitle:@"获取动态码" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.backgroundColor = [UIColor colorWithRed:0.00f green:0.49f blue:0.99f alpha:1.00f];
        [self addTarget:self action:@selector(getSMSCdodeAction) forControlEvents:UIControlEventTouchUpInside];
        _session = [MobileBankSession sharedInstance];
    }
    return self;
}

- (void)getSMSCdodeAction {
    if ([self.phoneNumber isEqualToString:@""]) {
        ShowAlertView(@"提示", @"手机号格式不正确", nil, @"完成", nil);
        return;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:UIKeyboardWillHideNotification object:nil];

    NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
    [postDic setObject:self.phoneNumber forKey:@"MobileNo"];
    [postDic setObject:self.actionName forKey:@"BusinessName"];

    [_session postToServer:@"GenTokenNameV1.do" actionParams:postDic method:@"POST"];
    [self startClock];
}

- (void)loopAction {
    if (_time == 0) {
        [self stopClock];
    } else {
        [self setTitle:[NSString stringWithFormat:@"点击重发(%d)", _time] forState:UIControlStateNormal];
        _time --;
        self.running = YES;
    }
}

- (void)startClock {
    self.userInteractionEnabled = NO;
    _time = 60; //1分钟
    self.backgroundColor = [UIColor grayColor];
    _clock = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loopAction) userInfo:nil repeats:YES];
}

- (void)stopClock {
    [self setTitle:@"点击重发" forState:UIControlStateNormal];
    self.backgroundColor = [UIColor colorWithRed:0.00f green:0.49f blue:0.99f alpha:1.00f];
    [_clock invalidate];
    _time = 60;
    self.running = NO;
    self.userInteractionEnabled = YES;
}

@end
