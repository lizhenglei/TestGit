//
//  AppDelegate.h
//  MobileClient
//
//  Created by 张海亮 on 13-7-11.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashScreenViewController.h"
#import "MobileBankSession.h"
#import "APService.h"
#ifdef INNER_SERVER
//内部挡板
#import "HTTPServer.h"

#endif

@interface AppDelegate : UIResponder <UIApplicationDelegate,MobileSessionDelegate>
{
#ifdef INNER_SERVER
    HTTPServer *httpServer;
#endif
    
    SplashScreenViewController *splash;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *rootNavController;
@property (retain, nonatomic) UINavigationController *centerController;
@property (retain, nonatomic) UIViewController *rightController;
@property(nonatomic,assign) BOOL isSaoyiSao;
@property(nonatomic,strong) NSString *str;
@property(nonatomic,strong)NSDictionary *remoteNotification;
//- (IIViewDeckController*)generateControllerStack;


@end
