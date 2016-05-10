//
//  GetPhoneNumberViewController.h
//  MobileClient
//
//  Created by xiaoxin on 15/7/1.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GetPhoneNumberViewControllerDelegate <NSObject>
@optional
-(void)gobackPhone:(NSString*)phone Name:(NSString*)name;
@end
@interface GetPhoneNumberViewController : UIViewController

@property(nonatomic,retain)id <GetPhoneNumberViewControllerDelegate> delegate;
@end
