//
//  CSIIMenuListViewController.h
//  MobileClient
//
//  Created by shuangchun che on 13-7-24.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSIISuperViewController.h"
#import "MobileBankSession.h"
#import "CustomAlertView.h"
@interface CSIIMenuListViewController : CSIISuperViewController<MobileSessionDelegate,UITableViewDataSource,UITableViewDelegate,CustomAlertViewDelegate>

@property (nonatomic,strong)UITableView *menuTable;
@property(nonatomic,strong) UIButton * leftBarItem;
@property(nonatomic,strong) UIButton * rightBarItem;//对外提供引用，用于标识登陆对象的状态和性别，灰，红，蓝头像；
@property(nonatomic,assign) int theXBottomBtn;
+(CSIIMenuListViewController *)sharedInstance;
-(void)pushToNextViewController;
-(id)initWithDisplayList:(NSArray*)dicList actionId:(NSString*)actionId actionName:(NSString *)actionName;
@end