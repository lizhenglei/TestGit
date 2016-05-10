//
//  PublicContentView.h
//  MobileClient
//
//  Created by xiaoxin on 15/7/8.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertView.h"
@interface PublicContentView : UIView<UIScrollViewDelegate,CustomAlertViewDelegate>
{
    NSTimer* timer;
    UIScrollView*scrollview;
    int count;
    
    UIView *_alertView;
    UIWindow *window;
    UIView *bgBackView;

}
@property(nonatomic,retain)NSMutableArray*contentArray;
@end
