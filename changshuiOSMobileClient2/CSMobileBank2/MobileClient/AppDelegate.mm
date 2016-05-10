//
//  AppDelegate.m
//  MobileClient
//
//  Created by 张海亮 on 13-7-11.
//  Copyright (c) 2013年 pro. All rights reserved.
//6251650000001003

#import "AppDelegate.h"
#import "CSIIMenuViewController.h"
#import "GlobalVariable.h"
#import "DeviceInfo.h"
//#import "CSIIUINavigationController.h"
#import "XHDrawerController.h"
#import "LoginViewController.h"
#import "GesturePasswordController.h"

#import "CSIIShareHandle.h"
#import <TencentOpenAPI/TencentOAuth.h>

#import <MAMapKit/MAMapKit.h>

#import "AdvertisementViewController.h"

#define CHECK_JAILBROJEN_TAG 1000



@implementation AppDelegate{
    UIImageView*homeBG;
    XHDrawerController *xhd;
    NSString *pushWebviewUrl;
    NSDictionary *jPushMessage;
}
@synthesize rootNavController;

#pragma mark  - UIApplication delegate

void uncaughtExceptionHandler(NSException*exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}
-(void)tttt
{
    ShowAlertView(@"rrr", @"rreg", nil, @"vrv", nil);
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //极光推送
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    
    
    // Required
    #if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            //categories
            [APService
             registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                 UIUserNotificationTypeSound |
                                                 UIUserNotificationTypeAlert)
             categories:nil];
        } else {
            //categories nil
            [APService
             registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                 UIRemoteNotificationTypeSound |
                                                 UIRemoteNotificationTypeAlert)
#else
             //categories nil
             categories:nil];
            [APService
             registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                 UIRemoteNotificationTypeSound |
                                                 UIRemoteNotificationTypeAlert)
#endif
             // Required
             categories:nil];
        }
    [APService setupWithOption:launchOptions];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
//    //将CA证书指纹保存到本地，作为安全凭证之一  (测试UAT6)
//    [[NSUserDefaults standardUserDefaults]setObject:@"eaa8b2065312a50dab43567d58575e036a9def61" forKey:@"LocaSha1Str"];
    
    //高德地图key
    [MAMapServices sharedServices].apiKey = @"d465da9d7ea818a9cfd25da8dd6b6400";

    if([Context getNSUserDefaultskeyStr:@"userID"]==nil){
        [GesturePasswordController clear];
    }
    /////////////////////////////////////////////////////
    //程序版本号设置
    [Context sharedInstance].appVersionCode = APP_VERSION_CODE;
        
    //设置IP
    NSString *server_backend_url = SERVER_BACKEND_URL;
    
    if ([server_backend_url hasPrefix:@"https://"]) {
        [Context sharedInstance].server_backend_ssl = YES;
        [Context sharedInstance].server_backend_name = [server_backend_url substringFromIndex:8];
    }
    else if ([server_backend_url hasPrefix:@"http://"]) {
        [Context sharedInstance].server_backend_ssl = NO;
        [Context sharedInstance].server_backend_name =[server_backend_url substringFromIndex:7];
    }
    else{
        [Context sharedInstance].server_backend_ssl = NO;
        [Context sharedInstance].server_backend_name = server_backend_url;
    }
    
    /////////////////////////////////////////////////////
    
#ifndef DEBUG
    /* 
       如果是真机安装ipa包运行，log输出就保存到程序Document目录下的huaxingbank.log文件中 
    */
    
//    NSLog(@"%@",[[UIDevice currentDevice] model]);
//    if ([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location==NSNotFound) {
//        [self redirectNSlogToDocumentFolder];
//    }
#endif
    
#ifdef INNER_SERVER
    //内部挡板
	httpServer = [[HTTPServer alloc] init];
	[httpServer setPort:9000];
	[httpServer setDocumentRoot:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"]];
	[httpServer start];
#endif
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    CSIIMenuViewController*menuViewController = [CSIIMenuViewController sharedInstance];
    
    xhd = [[XHDrawerController alloc]init];
    xhd.springAnimationOn = YES;
    
    LoginViewController *loginViewController = [[LoginViewController alloc]init];
    loginViewController.shahaiURL = _str;
    _str = [[NSString alloc]init];
    xhd.rightViewController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    xhd.rightViewController.navigationBarHidden = YES;
    xhd.centerViewController = [[UINavigationController alloc]initWithRootViewController:menuViewController];
    self.window.rootViewController = xhd;
    
    xhd.centerViewController.navigationBarHidden = YES;       //启动页面隐藏导航栏
    

    UIImageView*windowBG = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    windowBG.image = [UIImage imageNamed:@"login_bg.png"];
    [self.window addSubview:windowBG];

    
    UILabel *naviTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 0, 220, 44)];
    naviTitleLabel.center = CGPointMake(ScreenWidth/2, 22);
    naviTitleLabel.tag = 99;
    naviTitleLabel.textAlignment=NSTextAlignmentCenter;
    naviTitleLabel.font=[UIFont boldSystemFontOfSize:18];
    naviTitleLabel.textColor = [UIColor whiteColor];
    naviTitleLabel.backgroundColor=[UIColor clearColor];
    [xhd.centerViewController.navigationBar addSubview:naviTitleLabel];
    
    
    //注册QQ分享功能
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    handle.TCAuthor = [[TencentOAuth alloc] initWithAppId:TencentAppKey andDelegate:handle];
    [WXApi registerApp:kWeiXinAppKey withDescription:kWeiXinAppdesc];
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kSinaAppKey];
    
    /*
     在打开程序时，先校验设备是否越狱，如果越狱提示用户是否继续，继续访问则播放动画,连服务器去获取菜单，否则直接关闭程序
     */
    if([DeviceInfo isJailBrojen])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"提示"
                                                        message: @"尊敬的用户，检测到该设备已经越狱，可能存在安全隐患，是否继续访问常熟农商银行？如果继续访问，请检查是否有不安全程序运行。"
                                                       delegate: self
                                              cancelButtonTitle: @"退出应用"          
                                              otherButtonTitles: @"继续访问",nil];
        alert.tag=CHECK_JAILBROJEN_TAG;
        [alert show];
        
        return YES;
    }
    else
    {    
//        [[MobileBankSession sharedInstance] sessionInit];
        splash = [[SplashScreenViewController alloc] init];
        [xhd.centerViewController pushViewController:splash animated:NO];
        [self.window makeKeyAndVisible];
    }
    //
    _remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];

    //在打开程序时，先校验设备是否越狱，如果越狱提示用户是否继续，继续访问则播放动画,连服务器去获取菜单，否则直接关闭程序
    return YES;
}

//-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
//    NSLog(@"%@",url);
//    _str=[NSString stringWithFormat:@"%@",url];
//    
//    return 1;
//    
//    
//}
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"shake" object:self];
    
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion != UIEventSubtypeMotionShake) return;

}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"摇一摇...");
    if (motion != UIEventSubtypeMotionShake) return;
}
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    if ([[userInfo allKeys] containsObject:@"extras"]) {
        NSDictionary *extras = [userInfo valueForKey:@"extras"];
        pushWebviewUrl = [extras valueForKey:@"URL"];
        UIAlertView *alal = [[UIAlertView alloc]initWithTitle:@"提示" message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alal.tag = 1008;
        [alal show];
        
    }else{
        ShowAlertView(@"提示", content, self, @"确认", nil);
    }
    NSLog(@"***********%@",userInfo);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"____sourceAPPlication%@",sourceApplication);
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    if([handle.itemFlag isEqualToString:@"0"]){
        return [WeiboSDK handleOpenURL:url delegate:handle];
    }else if([handle.itemFlag isEqualToString:@"1"]){
        return [WXApi handleOpenURL:url delegate:handle];
    }else if ([handle.itemFlag isEqualToString:@"2"]){
        return [WXApi handleOpenURL:url delegate:handle];
    }else if([handle.itemFlag isEqualToString:@"3"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if([[url scheme] isEqualToString:@"csbank.cc"]){
        return YES;
    }else{
        return NO;
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [APService registerDeviceToken:deviceToken];
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // IOS 6 Support Required
    NSLog(@"极光推送的消息2");
    jPushMessage = [[NSDictionary alloc]initWithDictionary:userInfo];
    application.applicationIconBadgeNumber = 0;//角标清零
    NSString *alertMessage = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive||[UIApplication sharedApplication].applicationState == UIApplicationStateInactive)//在前台
    {
        
        if ([self.remoteNotification allKeys].count>0) {
            //说明是程序未启动时点击通知栏，弹框在ceiimenuviewcontroller里展示
        }
    else
    {
        if ([[userInfo allKeys] containsObject:@"URL"]) {
            pushWebviewUrl = [userInfo valueForKey:@"URL"];
            UIAlertView *alal = [[UIAlertView alloc]initWithTitle:@"提示" message:alertMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alal.tag = 1008;
            [alal show];
        }else
        {
            ShowAlertView(@"提示", alertMessage, nil, @"确定", nil);
        }
     
    }
    
    }else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)//在后台
    {
        if ([[userInfo allKeys] containsObject:@"URL"]) {
            AdvertisementViewController *pushController = [[AdvertisementViewController alloc]init];
            pushController.webTitleName = @"常熟农商银行";
            pushController.webUrl = pushWebviewUrl;
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:pushController animated:YES];
        }else
        {
            ShowAlertView(@"提示", alertMessage, nil, @"确定", nil);
            
        }
    }
    NSLog(@"***********%@",userInfo);
     [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [APService handleRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void
                        (^)(UIBackgroundFetchResult))completionHandler {
    
    /*
     
     (lldb) po userInfo//apns消息
     {
     URL = "https//:www.baidu.com";
     "_j_msgid" = 1358161782;
     aps =     {
     alert = "\U4ec5\U4f9b\U6d4b\U8bd5";
     badge = 1;
     sound = default;
     };
     }
     */
    // IOS >=7 Support Required

    NSLog(@"启动的类型%ld",(long)[UIApplication sharedApplication].applicationState);
    application.applicationIconBadgeNumber = 0;//角标清零
    NSString *alertMessage = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive||[UIApplication sharedApplication].applicationState == UIApplicationStateInactive)//在前台
    {
        if ([self.remoteNotification allKeys].count>0) {
            //说明是程序未启动时点击通知栏，弹框在ceiimenuviewcontroller里展示
        }
        else
        {
            if ([[userInfo allKeys] containsObject:@"URL"]) {
                pushWebviewUrl = [userInfo valueForKey:@"URL"];
                UIAlertView *alal = [[UIAlertView alloc]initWithTitle:@"提示" message:alertMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alal.tag = 1008;
                [alal show];
            }else
            {
                ShowAlertView(@"提示", alertMessage, nil, @"确定", nil);
                
            }
        }
    }else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)//在后台
    {
        if ([[userInfo allKeys] containsObject:@"URL"]) {
            AdvertisementViewController *pushController = [[AdvertisementViewController alloc]init];
            pushController.webTitleName = @"常熟农商银行";
            pushController.webUrl = pushWebviewUrl;
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:pushController animated:YES];

        }else
        {
            ShowAlertView(@"提示", alertMessage, nil, @"确定", nil);
            
        }
    }

    NSLog(@"***********%@",userInfo);
    
    [APService handleRemoteNotification:userInfo];
    NSLog(@"极光推送的消息3");

    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    if([handle.itemFlag isEqualToString:@"0"]){
        return [WeiboSDK handleOpenURL:url delegate:handle];
    }else if([handle.itemFlag isEqualToString:@"1"]){
        return [WXApi handleOpenURL:url delegate:handle];
    }else if ([handle.itemFlag isEqualToString:@"2"]){
        return [WXApi handleOpenURL:url delegate:handle];
    }else if([handle.itemFlag isEqualToString:@"3"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if([[url scheme] isEqualToString:@"csbank.cc"]){
        return YES;
    }else{
        return NO;
    }
}
- (void)applicationWillResignActive:(UIApplication *)application    //程序进入后台
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    UIWindow*window = [application keyWindow];
    
    homeBG = [[UIImageView alloc]initWithFrame:self.window.frame];
    homeBG.image = [UIImage imageNamed:@"Default_homeBG.png"];
    homeBG.backgroundColor = [UIColor clearColor];
    [window addSubview:homeBG];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [splash.movie stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [splash.movie play];
    
#ifdef INNER_SERVER
    //内部挡板
	httpServer = [[HTTPServer alloc] init];
	[httpServer setPort:9000];
	[httpServer setDocumentRoot:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"]];
	[httpServer start];
#endif
}
- (void)applicationDidBecomeActive:(UIApplication *)application      //从后台打开程序
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [homeBG removeFromSuperview];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}



//（实现定制的url模式 lwy）
/*- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url

{
    NSString *urlStr = [url absoluteString];
    DebugLog(@"handleOpenURL = %@",urlStr);
    
    if([[url scheme] isEqualToString:@"ghbank"])
    {
        if ([urlStr rangeOfString:@"?"].location!=NSNotFound)
        {
            NSRange range=[urlStr rangeOfString:@"?"];
            if(range.location+1 == urlStr.length)
            {
                //[Context sharedInstance].url = @"";
            }
            else
            {
                //[Context sharedInstance].url = [urlStr substringFromIndex:range.location+1];
            }
        }
        
        return YES;
    }
    
    return NO;
}*/

#pragma mark  - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==CHECK_JAILBROJEN_TAG)
    {
        if(buttonIndex == 0)
        {
            exit(0);
        }
        else if(buttonIndex == 1)
        {
//            [[MobileBankSession sharedInstance] sessionInit];
            splash = [[SplashScreenViewController alloc] init];
            [xhd.centerViewController pushViewController:splash animated:NO];
            [self.window makeKeyAndVisible];

        }
    }
    if (alertView.tag == 1008) {
        if (buttonIndex==1) {
            AdvertisementViewController *pushController = [[AdvertisementViewController alloc]init];
            pushController.webTitleName = @"常熟农商银行";
            pushController.webUrl = pushWebviewUrl;
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:pushController animated:YES];
            }
    }
}

- (void)redirectNSlogToDocumentFolder
{
    // 将NSlog打印信息保存到Document目录下的文件中
#if (1)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"huaxingbank.log"];// 注意不是NSDate!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName =[NSString stringWithFormat:@"huaxing%@.log",[NSDate date]];
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
#endif
}


#pragma mark -GetReturenDate
- (void)getReturnData:(id)data WithActionName:(NSString *)action {
    if ([[data objectForKey:@"_RejCode"] isEqualToString:@"000000"]) {
        if ([action isEqualToString:@"ClientVersionQry.do"]) {
//            NSMutableDictionary *dic = [data objectForKey:@""];
        }
    }
}

//本地推送消息
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"常乐生活提醒您"
                                                    message:notification.alertBody
                                                   delegate:nil
                                          cancelButtonTitle:@"确认"
                                          otherButtonTitles:nil];
    [alert show];
    //这里，你就可以通过notification的useinfo，干一些你想做的事情了
    int tt = [[[NSUserDefaults standardUserDefaults]objectForKey:@"tuiSong"]intValue];
//    int bb = tt-1;
    application.applicationIconBadgeNumber = 0;
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%ld",(long)application.applicationIconBadgeNumber] forKey:@"tuiSong"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //取消某一个通知
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //获取当前所有的本地通知
    if (!notificaitons || notificaitons.count <= 0) {
        return;
    }
    for (UILocalNotification *notify in notificaitons) {
        if ([[notify.userInfo objectForKey:@"key"] isEqualToString:[NSString stringWithFormat:@"name%d",tt]]) {
            //取消一个特定的通知
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
            break;
        }
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // 获得 UIApplication
//    UIApplication *app = [UIApplication sharedApplication];
//    //获取本地推送数组
//    NSArray *localArray = [app scheduledLocalNotifications];
//    //声明本地通知对象
//    UILocalNotification *localNotification;
//    if (localArray) {
//        for (UILocalNotification *noti in localArray) {
//            NSDictionary *dict = noti.userInfo;
//            if (dict) {
//                NSString *inKey = [dict objectForKey:@"key"];
//                if ([inKey isEqualToString:[NSString stringWithFormat:@"name%d",tt]]) {
//                    [[UIApplication sharedApplication] cancelLocalNotification:noti];
//                    break;
//                }
//            }
//        }
//        
//        //判断是否找到已经存在的相同key的推送
//        if (!localNotification) {
//            //不存在初始化
//            localNotification = [[UILocalNotification alloc] init];
//        }
//        
//        if (localNotification) {
//            //不推送 取消推送
//            [app cancelLocalNotification:localNotification];
//            return;
//        }
//    }

}

@end
