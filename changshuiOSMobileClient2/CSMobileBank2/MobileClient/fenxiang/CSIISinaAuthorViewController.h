//
//  CSIISinaAuthorViewController.h
//
//  Created by 胡中楷 on 14-11-1.
//  Copyright (c) 2014年 胡中楷. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSIISinaAuthorViewController;

@protocol CSIISinaAuthorViewControllerDelegate <NSObject>

//完成授权
- (void)SinaAuthorViewDidFinishAndAuthorInfo:(NSDictionary *) authorInfo;
//授权失败
- (void)SinaAuthorViewDidFailAndErrorInfo:(NSDictionary *) error;
//用户取消
- (void)SinaAuthorViewUserCancel;

@end

@interface CSIISinaAuthorViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, assign) id<CSIISinaAuthorViewControllerDelegate> delegate;

- (id)initWithParms:(NSDictionary *) params andUrl:(NSString *) url;

@end
