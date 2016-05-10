//
//  SMSCodeButton.h
//  MobileClient
//
//  Created by 杨楠 on 14/8/21.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileBankSession.h"
#define ShowAlertView(T,M,D,BT,OBT) UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:T message:M delegate:D cancelButtonTitle:BT otherButtonTitles:OBT, nil];[alertView show];

@interface SMSCodeButton : UIButton <MobileSessionDelegate>

@property (nonatomic, getter = isRunning)BOOL running;
@property (nonatomic, copy)NSString* phoneNumber;
@property (nonatomic, copy)NSString* actionName;

- (void)stopClock;

@end
