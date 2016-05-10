//
//  MobileBankWeb.h
//  MobileBankWeb
//
//  Created by Yuxiang on 13-5-15.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CustomAlertView.h"
#import "WebViewController.h"

#pragma 沙海
#import "keyboardencrypt.h"
#import "shahaiKeyBoard.h"
#import "ShaHaiView.h"

/*!
 *  web模块
 *
 *
 */

@protocol MobileBankWebDelegate <NSObject>

// *action为PostToServer的action，Params为上传的参数
//  *id为服务端返回的数据。
@optional
-(id)WebPostToServer:(NSString *)action Params:(NSDictionary *)params;
-(void)hideBackButton;
-(void)openPassWordView;
@end


@interface MobileBankWeb : UIWebView<CustomAlertViewDelegate>{
@private
    id <MobileBankWebDelegate> WebDelegate;
}
@property (nonatomic,retain)shahaiKeyBoard *shahaiKeyBoard;
@property (nonatomic,retain)UIView*ZZview;
@property (nonatomic,retain)id <MobileBankWebDelegate> WebDelegate;
@property(nonatomic,assign)BOOL isYaoYiYao;
@property(nonatomic,strong)LWYTextField *datePickerTF;
@property(nonatomic,strong)UITableView *TransferTabelView;
-(id)initWithFrame:(CGRect)frame;
-(void)registerKeyboardNotification;
-(void)removeKeyboardNotification;
-(void)clearWebContent;

@end




