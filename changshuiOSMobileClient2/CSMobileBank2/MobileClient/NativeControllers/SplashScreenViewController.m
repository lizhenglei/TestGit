//
//  SplashScreenViewController.m
//  MobileClient
//
//  Created by 张海亮 on 13-7-11.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "FirstOpenViewController.h"
#import "Context.h"
#import "CSIIMenuViewController.h"
#import "MobileBankSession.h"
#import "FMDatabase.h"
#import "DeviceInfo.h"

#import "CommonFunc.h"


@interface SplashScreenViewController ()<MobileSessionDelegate>
{
    BOOL isFirstFinish;
    UILabel *loadingStrLabel;
    int loadingStrState;
    UIImageView*LogoView;
    NSMutableArray*imageArray;
    int count;
    UIImageView*lastImg;
    UIImageView *backImage;
    UIImageView *backImage2;
    NSDictionary *menuDic;
    NSString *startNameStr;
    NSTimer *_skipTimer;
    UIButton *skipBtn;
    int skipTime;
    FMDatabase *_dataBase;
    NSMutableArray *fenxiArray;
}
@end

@implementation SplashScreenViewController
@synthesize localStorageSplash;
@synthesize movie;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        self.view=[[UIView alloc]initWithFrame:[self getScreenBoundsForCurrentOrientation]];
        self.view.autoresizesSubviews = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.backgroundColor = [UIColor clearColor];
        //启动图片
        count = 0;
        fenxiArray = [[NSMutableArray alloc]init];
        menuDic = [[NSDictionary alloc]init];
        backImage = [[UIImageView alloc] initWithFrame:self.view.frame];
        backImage2 = [[UIImageView alloc] initWithFrame:self.view.frame];
        backImage2.alpha = 0.1;
        skipTime = 3;
        [self.view addSubview:backImage2];
        if (IOS8_OR_LATER) {
            backImage.image = [UIImage imageNamed:@"qiDong3"];
        }else
        {
            backImage.image = [UIImage imageNamed:@"qiDong"];
        }
        [self.view addSubview:backImage];
        
        NSMutableDictionary*initDic = [[NSMutableDictionary alloc]init];
        [initDic setObject:@"1" forKey:@"ClientType"];                         //0 安卓正式版   1 iOS正式版  2 安卓测试版 3 iOS体验版
        
        [initDic setObject:APP_VERSION_CODE forKey:@"VersionId"];               //
        [initDic setObject:[DeviceInfo executablePathMD5] forKey:@"Signature"];//客户端特征值
        [initDic setObject:@"0" forKey:@"VersionType"];              //0正式版    1体验版
        NSString *ostype = [Context isArm64OrArm32];
        
        if ([ostype isEqualToString:@"64"]) {
            [initDic setObject:@"64" forKey: @"OSType"];
            NSLog(@"64");
        }else{
            [initDic setObject:@"" forKey: @"OSType"];
            NSLog(@"32");
        }
        NSLog(@"sessioninit%@",initDic);

        [MobileBankSession sharedInstance].delegate =self;
        [[MobileBankSession sharedInstance] postToServer:@"SessionInit.do" actionParams:initDic method:@"POST"];
        [[MobileBankSession sharedInstance] postToServer:@"GonggaoContent.do" actionParams:nil method:@"POST"];     //获取公告内容

        backImage.tag = 0;
        

//        NSString *filePath = [[MobileBankSession sharedInstance] getMarketData];
//        NSLog(@"splash filePath=%@",filePath);
//        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        if ([Context getNSUserDefaultskeyStr:@"skin"].length==0||[[Context getNSUserDefaultskeyStr:@"skin"] isEqualToString:@"101"]||[[Context getNSUserDefaultskeyStr:@"skin"] isEqualToString:@"102"]||[[Context getNSUserDefaultskeyStr:@"skin"] isEqualToString:@"103"]) {
            [Context setNSUserDefaults:@"skyblue" keyStr:@"skin"];
            [MobileBankSession sharedInstance].changeSkinColor = @"skyblue";
            [dic setObject:@"skyblue" forKey:@"SkinName"];
        }else{
            [MobileBankSession sharedInstance].changeSkinColor = [Context getNSUserDefaultskeyStr:@"skin"];
            [dic setObject:[Context getNSUserDefaultskeyStr:@"skin"] forKey:@"SkinName"];
        }
        
        if ([Context getNSUserDefaultskeyStr:[NSString stringWithFormat:@"%@SkinUpdateTime",[Context getNSUserDefaultskeyStr:@"skin"]]].length==0) {
            [dic setObject:@"" forKey:@"UpdateTime"];
        }else{
            [dic setObject:[Context getNSUserDefaultskeyStr:[NSString stringWithFormat:@"%@SkinUpdateTime",[Context getNSUserDefaultskeyStr:@"skin"]]] forKey:@"UpdateTime"];
        }
        [MobileBankSession sharedInstance].delegate = self;
        [[MobileBankSession sharedInstance] postToServer:@"IconZipInfoQry.do" actionParams:dic method:@"POST"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initDataFinsh:) name:@"APPInitDataFinish" object:nil];
        
        
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString* plistPath1 = [paths objectAtIndex:0];
//        NSString *filename =[plistPath1 stringByAppendingPathComponent:@"UserAnalysis.sqlite"];
//        _dataBase  = [[FMDatabase alloc] initWithPath:filename];
//        
//        [_dataBase open];
//        // 查询不同，查询会返回结果集
//        FMResultSet *res = [_dataBase executeQuery:@"select * from User"];
//        // 即便结果集中只有一行数据也需要遍历查询，没循环一次就是一行数据
//        while ([res next])
//        {
//            // 取出一行中每一个字段的值
//            NSString *userName22 = [res stringForColumn:@"UserName"];
//            NSLog(@"数据库操作%@",userName22);
//            NSString *userName = [CommonFunc textFromBase64StringDES:userName22];
//            NSLog(@"数据库操作%@",userName);
//
//            NSDictionary *dic = [Context jsonDicFromString:userName];
//            [fenxiArray addObject:dic];
//        }
////        NSLog(@"字符串%@",[Context jsonStrFromArray:fenxiArray]);
//        NSMutableDictionary *dicc = [[NSMutableDictionary alloc]init];
//        [dicc setObject:fenxiArray forKey:@"List"];
//        NSLog(@"数据分析%@",dicc);
//        [MobileBankSession sharedInstance].delegate = self;
//        [[MobileBankSession sharedInstance]postToServer:@"PuserLogAdd.do" actionParams:dicc method:@"POST"];
//        [_dataBase close];
        
    }
    return self;
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    if ([action isEqualToString:@"SessionInit.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            menuDic = [data objectForKey:@"DisplayList"];
            
            if (([Context getNSUserDefaultskeyStr:@"isFirstOpenApp"])) {
            NSMutableDictionary *ddic = [data objectForKey:@"StartPageMap"];
            if ([[ddic objectForKey:@"IsStart"]isEqualToString:@"Y"]) {
                startNameStr = [ddic objectForKey:@"ImageName"];
            NSData *dataPage = [Context dataWithBase64EncodedString:[[NSUserDefaults standardUserDefaults] objectForKey:@"haveStartPage"]];
                if ([dataPage length]==0) {
                    [[MobileBankSession sharedInstance]postToServerStream:@"StartPageLoad.do" actionParams:nil];
                }else{
                    if ([[ddic objectForKey:@"ImageName"]isEqualToString:[Context getNSUserDefaultskeyStr:@"startNameStr"]]) {
                        backImage2.image = [UIImage imageWithData:dataPage];
                        [UIView beginAnimations:nil context:NULL];
                        [UIView setAnimationDuration:0.8];
                        backImage2.alpha = 1;
                        [UIView commitAnimations];
                        backImage.hidden = YES;
                        [self createBtnSkip];
                    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(pushBackImageView) userInfo:nil repeats:NO];

                    }else{
                        [[MobileBankSession sharedInstance]postToServerStream:@"StartPageLoad.do" actionParams:nil];
                    }
                
//                [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(pushBackImageView) userInfo:nil repeats:NO];
                }
            }
          else{
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(pushBackImageView) userInfo:nil repeats:NO];
            }
        }
        else{
                [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(pushBackImageView) userInfo:nil repeats:NO];
            }
        }
    }
    if ([action isEqualToString:@"StartPageLoad.do"]) {
        if ([data length]==0) {
            DebugLog(@"没有自定义的图片");
        }else{
            NSString *string = [CommonFunc base64EncodedStringFrom:data];
            [[NSUserDefaults standardUserDefaults]setObject:string forKey:@"haveStartPage"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            backImage2.image = [UIImage imageWithData:data];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.8];
            backImage2.alpha = 1;
            [UIView commitAnimations];
            backImage.hidden = YES;
            [self createBtnSkip];
            
            [Context setNSUserDefaults:[NSString stringWithFormat:@"%@",startNameStr] keyStr:@"startNameStr"];
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(pushBackImageView) userInfo:nil repeats:NO];
        }
    }
    if ([action isEqualToString:@"PuserLogAdd.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* plistPath1 = [paths objectAtIndex:0];
            NSString *filename =[plistPath1 stringByAppendingPathComponent:@"UserAnalysis.sqlite"];
            NSFileManager *ff = [[NSFileManager alloc]init];
            [ff removeItemAtPath:filename error:nil];
        }else
        {
        
        }
    }
}
-(void)createBtnSkip
{
    skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    skipBtn.frame = CGRectMake(self.view.frame.size.width-75, 30, 60, 25);
    skipBtn.backgroundColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.00f alpha:1.00f];
    [skipBtn setTitle:[NSString stringWithFormat:@"跳过 %d",skipTime] forState:UIControlStateNormal];
    _skipTimer  = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(skipTimeChange) userInfo:nil repeats:YES];
    skipBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    skipBtn.layer.masksToBounds = YES;
    skipBtn.layer.cornerRadius = 3;
    [skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [skipBtn addTarget:self action:@selector(pushBackImageView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipBtn];
}
-(void)skipTimeChange
{
    skipTime--;
    [skipBtn setTitle:[NSString stringWithFormat:@"跳过 %d",skipTime] forState:UIControlStateNormal];
}
-(void)pushBackImageView
{
    [MobileBankSession sharedInstance].delegate = [CSIIMenuViewController sharedInstance];
    [[MobileBankSession sharedInstance].delegate getReturnData:menuDic WithActionName:@"SessionInit.do"];
    [[MobileBankSession sharedInstance] sessionInit];
    
}

- (void)onCloseSplashScreen:(NSNotification *)note
{//网页加载完成,收到的通知
    [self.movie.view removeFromSuperview];
    [self performSelectorOnMainThread:@selector(switchView) withObject:nil waitUntilDone:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)initDataFinsh:(NSNotification *)noto
{
    if (![Context getNSUserDefaultskeyStr:@"isFirstOpenApp"]) {    //首次打开app,导航图片
        FirstOpenViewController*firstopenController = [[FirstOpenViewController alloc] init];
        [self.navigationController pushViewController:firstopenController animated:NO];
    }else
    [self.navigationController popToRootViewControllerAnimated:NO];
//    currentControllers = self.navigationController.viewControllers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;//表示视图是否覆盖到四周的区域，默认是UIRectEdgeAll，即上下左右四个方向都会覆盖
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;//禁止scroll view的内容自动调整
//        这样起始位置就是从导航下面开始的，既是0，0在导航下面，适配ios6
    }
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    else
    {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
}

-(CGRect)getScreenBoundsForCurrentOrientation
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        if ([Context iPhone5])
        {
            CGRect rect=CGRectMake(0,0,320,568);
            return rect;
        }
        else if(IPHONE)
        {
            CGRect rect=CGRectMake(0,0,320,480);
            return rect;
        }
        else
        {
            CGRect rect=CGRectMake(0,0,768,1024);
            return rect;
        }
 
    }
#endif
    
    if ([Context iPhone5])
    {
        CGRect rect=CGRectMake(0,0,320,548);
        return rect;
    }
    else if(IPHONE)
    {
        CGRect rect=CGRectMake(0,0,320,460);
        return rect;
    }
    else
    {
        CGRect rect=CGRectMake(0,0,768,1004);
        return rect;
    }
    
}

- (BOOL) shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
