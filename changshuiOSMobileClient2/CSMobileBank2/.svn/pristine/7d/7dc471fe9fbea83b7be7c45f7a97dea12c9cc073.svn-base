//
//  WebViewController.h
//  MobileBankWeb
//
//  Created by wangfaguo on 13-7-23.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CSIISuperViewController.h"

#import "MobileBankWeb.h"

@class MobileBankWeb;

@protocol WebViewControllerDelegate
-(void)webViewHomeButtonAction;
-(void)webViewSettingButtonAction;
@end

@interface WebViewController : CSIISuperViewController

@property(nonatomic) id <WebViewControllerDelegate>delegate;
@property(nonatomic,retain)NSMutableDictionary*postDict;

@property(nonatomic) MobileBankWeb *webView;

+(BOOL)isSharedInstanceExist;
+(WebViewController*)sharedInstance;
-(void)setActionId:(NSString *)actionId actionName:(NSString*)actionName prdId:(NSString*)prdId Id:(NSString*)Id;
-(NSString *)getActionId;
-(NSString *)getSelfPrdId;
-(NSString *)getPrdIdByActionId:(NSString*)actionId;
-(NSString *)getHintsByActionId:(NSString*)actionId;
-(UIWebView *)startActionUrl:(NSString *)urlString WithFrame:(CGRect)rect;
-(void)clearWebContent;
@end
