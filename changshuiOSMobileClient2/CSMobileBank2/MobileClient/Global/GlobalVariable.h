//
//  GlobalVariable.h
//  MobileClient
//
//  Created by 张海亮 on 13-7-12.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#ifndef MobileClient_GlobalVariable_h
#define MobileClient_GlobalVariable_h

#import "Config.h"
#import "Context.h"


/**************************************************/

//#define SPLASH_SCREEN_PATH [[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory ,NSUserDomainMask , YES ) objectAtIndex : 0] stringByAppendingPathComponent : @"iphone_loading.mp4"]

#define SPLASH_SCREEN_PATH(name) [[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory ,NSUserDomainMask , YES ) objectAtIndex : 0] stringByAppendingPathComponent : name]

#define SPLASH_SCREEN_DATE [[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory ,NSUserDomainMask , YES ) objectAtIndex : 0] stringByAppendingPathComponent : @"/splash_date.plist"]

#define MENU_FILE_PATH [[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory ,NSUserDomainMask , YES ) objectAtIndex : 0] stringByAppendingPathComponent : @"menu.txt"]

#define PROGESS_WINDOW [[[UIApplication sharedApplication] windows] objectAtIndex:0]

//#define SPLASH_MOVIE @"splash_url"

#define IsPrintfUserInfo YES//是否打印日志


#define ACTION_NAME_ONE @"金融助手"
#define ACTION_NAME_TWO @"我的银行"
#define ACTION_NAME_THREE @"生活服务"
#define ACTION_NAME_FOUR @"我的最爱"

#define MENU_ACTION_NAME @"ActionName"
#define MENU_ACTION_IMAGE @"ActionImage"
#define MENU_ACTION_ID @"ActionId"
#define MENU_ACTION_CLICKABLE @"Clickable"
#define MENU_ACTION_ISLOGIN @"IsLogin"
#define MENU_ACTION_ROLECTR @"RoleCtr"
#define MENU_PRD_ID @"PrdId"
#define MENU_ID @"Id"
#define MENU_LIST @"MenuList"


#define ACTIONID_FOR_FINANCIALSERVICE @"100001"
#define ACTIONID_FOR_MOBILEBANK @"200001"
#define ACTIONID_FOR_MYFAVOURITE @"100001"
#define ACTIONID_FOR_MORESERVICE @"400001"

#define ACTIONID_FOR_ADD @"000000"
#define ACTIONID_FOR_EXIT @"000001"

#define LOGOUT @"logout"
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

//#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//#define iPhone5 ([UIScreen mainScreen].bounds.size.height > 480)

//iPhone
#define IPHONE ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
//iPad
#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 

#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)


#define BOUNDS [[UIScreen mainScreen] bounds]
#define COLOR(R,G,B,P) [UIColor colorWithRed:R green:G blue:B alpha:P]

#define ShowAlertView(T,M,D,BT,OBT) UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:T message:M delegate:D cancelButtonTitle:BT otherButtonTitles:OBT, nil];[alertView show];

#define ShowToast(Str) CustomAlertView*custom = [[CustomAlertView alloc]initToastWithDelegate:self context:Str];[custom show];

//捕获.do交易数据，写到文件里
//#define TRANS_DATA_WRITE_TO_FILE

//内部挡板，从文件读取.do交易数据和vx页面
//#define GET_DATA_FROM_LOCAL_FILE

/**************************************************/
#endif
