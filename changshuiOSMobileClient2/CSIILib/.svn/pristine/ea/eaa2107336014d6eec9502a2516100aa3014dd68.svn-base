//
//  MobileBankTools.h
//  MobileBankWeb
//
//  Created by Yuxiang on 13-6-8.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MobileBankWebTools : NSObject

@property(assign)BOOL taskInProgress;
+ (MobileBankWebTools *)sharedInstance;
-(id)jsonAnalysis:(NSString *)string;
-(void)showIndicatorViewWithMessage:(NSString *)mes  andViews:(UIView *)view;
-(void)hideIndicatorView:(UIView *)view;
-(NSString *)otherTojson:(id )other;

@end
