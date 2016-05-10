//
//  MobileBankSession.m
//  MobileBankSession
//
//  Created by Yuxiang on 13-6-20.
//  Copyright (c) 2013年 北京科蓝软件系统有限公司. All rights reserved.
//

#import "MobileBankSession.h"
#import "JSONKit.h"
#import "Communication.h"
#import "DeviceInfo.h"
#import "TYMActivityIndicatorView.h"
#import "Reachability.h"
//#import "MobileBankWeb.h"
#import "AESCrypt.h"
#import "WebViewController.h"
#import "CustomAlertView.h"
#import "CommonFunc.h"
#import "CSIIMenuViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "XHDrawerController.h"

#import "KeychainItemWrapper.h"
#import "GesturePasswordController.h"

#import "CSIIConfigDeviceInfo.h"
#import "LoginViewController.h"

//#import "CSIISuperViewController.h"

#import "BindingEquipmentViewController.h"

#import "ZipArchive.h"
#import "FMDatabase.h"

//@class CSIISuperViewController;

#define CC_SHA1_DIGEST_LENGTH   20          /* digest length in bytes */
#define CC_SHA1_BLOCK_BYTES     64          /* block size in bytes */
#define CC_SHA1_BLOCK_LONG      (CC_SHA1_BLOCK_BYTES / sizeof(CC_LONG))
static const char Base64[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const char Pad64 = '=';

#define ALERT_TAG 10000
#define CONFIRM_TAG 10001
#define HUD_TAG 10002
#define UPDATE_TAG 100003
#define UPDATE_TAG2 1000032
#define CHECKVERSION_FAIL_TAG 100004
#define SIGNATURE_VERIFY_FAIL_TAG 100005

//#define TEST_URL @"http://192.201.202.199:8082/pmob"
//#define TEST_URL @"http://124.207.86.60:8090/pweb"
//#define TEST_URL @"http://192.1.1.


//#define SAVE_MENU_TO_LOCAL


@interface MobileBankSession ()<CommunicationDelegate,UIAlertViewDelegate,CustomAlertViewDelegate>
{
    int times;//第几次请求
    NSString *returnCode;
    NSInteger curTransCount;//当前交易个数，用于保持遮罩的连续性
    NSDictionary *_menuDictionary;
    NSString*isGetOtpStr;
    BOOL isPostSuccess;            //控制遮罩层显示
    NSMutableDictionary*_postData;    //保存发送的参数
    NSString*_postActionStr;          //保存发送的交易名
    NSString*_postMethodStr;          //保存“POST”或“GET”
    CustomAlertView *loginAlertView;
    NSString *password;
    NSTimer *timer;
    NSDictionary *returnUpdateDic;
    FMDatabase *_dataBase;
}
//@property(nonatomic,retain)MobileBankStartWeb *web;
//@property(nonatomic,copy)MobileBankAuthentication *auth;
@property(nonatomic,assign)NSTimeInterval timeOffset;

@property(nonatomic,retain)NSString  *upgradeurl;
@property(nonatomic,retain)NSString  *reloadDataFileName;
@property(nonatomic,retain)NSString  *reloadDataUrl;
@property(nonatomic,retain)NSString  *UpdateType;
@property(nonatomic,retain)NSString  *UpdateHint;
@property(nonatomic,retain)NSString  *UpdateVersionName;
@property(nonatomic,retain)NSString  *VersionURL;            //升级所需url

@property(nonatomic,retain)NSMutableArray *AuthorityList;//权限池内容
@property(nonatomic,retain)NSMutableArray *MarketingData;//营销数据


//@property(nonatomic,retain)NSMutableArray *VersionCodeArray;//所有子功能版本号
@property(nonatomic,retain)NSData* returnData;//暂存返回数据
@property(nonatomic,retain)NSDictionary* returnDictionary;



@end


@implementation MobileBankSession
@synthesize delegate;
//@synthesize web;
@synthesize timeOffset;
//@synthesize MobileLife;
//@synthesize MobileBank;
//@synthesize MobilePay;
//@synthesize MobileSetting;
@synthesize AuthorityList;
@synthesize MenuArray;
@synthesize MarketingData;
//@synthesize PoiSortList;
@synthesize upgradeurl;
@synthesize reloadDataFileName;
@synthesize reloadDataUrl;
//@synthesize auth;
@synthesize isLogin;
@synthesize unloginMenuData;

@synthesize actionID;

+ (MobileBankSession *)sharedInstance
{
    static MobileBankSession *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{//线程安全
        sharedInstance = [[MobileBankSession alloc] init];
        
    });
    return sharedInstance;
}

-(void)sessionInit;//初始化
{
    isLogin=NO;
    times=1;
    _isExitnegative = NO;
    curTransCount = 0;
    isGetOtpStr = @"";
    self.isRightViewControllerDone = NO;
    //self.web =[[MobileBankStartWeb alloc]init];
    
    self.isPassiveLogin = NO;
    
    //记住换肤
    NSString *skinString = [Context getNSUserDefaultskeyStr:@"skin"];
    if (skinString.length==0||[skinString  isEqualToString:@""]||[skinString isEqualToString:@"101"]||[skinString isEqualToString:@"102"]||[skinString isEqualToString:@"103"]) {
        self.changeSkinColor = @"skyblue";
    }
    else self.changeSkinColor = skinString;
    //初始化一些数据
    self.AuthorityList=[[NSMutableArray alloc]init];
#ifdef INNER_SERVER
    //不连接服务器时，从本地Bundle读取菜单。
    NSDictionary *menuDict;
    NSData *menuJsonData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"menu"ofType:@"txt"]];
    //    NSLog(@"%@",[[NSBundle mainBundle] pathForResource:@"menu"ofType:@"txt"]);
    
    NSError *error = nil;
    menuDict = [NSJSONSerialization JSONObjectWithData:menuJsonData options:0 error:&error];
    if(error){
        DebugLog(@"Menu JSON Parsing Error: %@", error);
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"菜单JSON解析出错" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [self getReturnDataFromServer:menuDict withActionName:@"newjson.txt"];
    
#else
    //从服务器获取菜单
    [self getConfigMenuFromServer];
#endif
}

-(void)getConfigMenuFromServer
{
    /*
     先去本地查找是否有缓存的菜单文件。有就从本地菜单文件里读取菜单版本号，没有就默认版本号为"0.0"，然后发获取菜单接口（本地版本号作为参数）到服务器。服务器对比CheckVersion.do上传的版本号，如果不同，那么服务器下发的json数据DisplayList字段就有值，值就是新菜单，客户端在本地保存新菜单。如果相同，那么下发的DisplayList字段值为空，客户端则读取本地保存的菜单。
     注意：判断菜单版本号之前，应该先判断字段UpdateInfo 里面的程序版本号的，若程序有更新，则先升级程序。
     */
    
    //NSString *versionCode = @"0.0";
#ifdef SAVE_MENU_TO_LOCAL
    NSString *versionCode = @"0.0";
    if ([[NSFileManager defaultManager] fileExistsAtPath:MENU_FILE_PATH])
    {
        //读取存放在本地的菜单文件，取出版本号
        NSData *menuJsonData = [[NSData alloc] initWithContentsOfFile:MENU_FILE_PATH];
        DebugLog(@"sessionInit, exists MENU_FILE_PATH: %@",MENU_FILE_PATH);
        
        /////////////////密文转为明文
        NSString *encodedString = [[NSString alloc] initWithData:menuJsonData encoding:NSUTF8StringEncoding];
        NSString *decryptString = [AESCrypt decrypt:encodedString password:@"mmeennuu"];
        NSData *decrypt_menuJsonData = [decryptString dataUsingEncoding: NSUTF8StringEncoding];
        
        if(decrypt_menuJsonData != nil)
        {
            NSError *error = nil;
            NSDictionary *menuDict = [NSJSONSerialization JSONObjectWithData:decrypt_menuJsonData options:0 error:&error];
            
            if(error==nil)
            {
                if([menuDict objectForKey:@"ReturnCode"]!=nil && [[menuDict objectForKey:@"ReturnCode"] isEqualToString:@"000000"] && [menuDict objectForKey:@"VersionCode"]!=nil && [menuDict objectForKey:@"VersionCode"]!=[NSNull null])
                {
                    versionCode = [menuDict objectForKey:@"VersionCode"];
                }
            }
        }
    }
#endif
    /*版本更新*/
    //            NSMutableDictionary *versionDic = [[NSMutableDictionary alloc] initWithDictionary:[DeviceInfo appVersionInfo]];
    //            NSString *versionCodenew = [versionDic objectForKey:@"VersionCode"];
    //
    //            NSMutableDictionary *versionPostDic = [[NSMutableDictionary alloc] init];
    //            [versionPostDic setObject:@"4" forKey:@"ClientType"];//客户端类型      个人手机4   企业手机5   个人iPad6   企业iPad7
    //            [versionPostDic setObject:APP_VERSION_CODEID forKey:@"VersionId"];//客户端版本号
//                [versionPostDic setObject:[DeviceInfo executablePathMD5] forKey:@"ClientSignature"];//客户端特征值
    ////            [versionPostDic setObject:@"35359d858045d95c2aaeaabbe6aa57d7" forKey:@"ClientSignature"];//客户端特征值
    //
    //            [self postToServer:@"ClientVersionQry.do" actionParams:versionPostDic method:@"POST"];
    
    
    [self GotoMenu];
}

-(void)GotoMenu{
    
    //    //从服务器获取菜单
    //    NSMutableDictionary *initDic=[[NSMutableDictionary alloc]init];
    //    [initDic setObject:((IPHONE)?@"Iphone":@"Ipad") forKey:@"ClientType"];
    //    [initDic setObject:[DeviceInfo executablePathMD5] forKey:@"Signature"];
    //    //    [initDic setObject:@"bdce5f56df5de3cbd6b3ad817dacd427" forKey:@"Signature"];
    //
    //    //不从info.plist里读取版本号，以防有人恶意修改安装包里info.plist里的版本号，程序读取到错误版本号
    //    [initDic setObject:/*[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]*/[Context sharedInstance].appVersionCode forKey:@"AppVersionCode"];
    //    //    [initDic setObject:versionCode forKey:@"VersionCode"];
    //    //    DebugLog(@"CheckVersion : %@",initDic);
    //    [self postToServer:@"CheckVersion.do" actionParams:initDic method:@"POST"];
    
//    if ([self deviceNetWorkState]) {


//    }
    [self changeSkin];
}

-(void)changeSkin
{
    NSString *unZipPath = [Context unZipPath];
    // 文件管理器
    NSFileManager *fm = [[NSFileManager alloc] init];
    // 判断解压缩完的路径文件是否存在
//    if(![fm fileExistsAtPath:unZipPath])
//    {
//        NSLog(@"文件不存在,需要解压缩");
        // book.zip路径
        NSString *bookPath = [NSString stringWithFormat:@"%@/%@.zip",[[NSBundle mainBundle] resourcePath],self.changeSkinColor];
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        // 判断解压文件是否可以打开
        if([zipArchive UnzipOpenFile:bookPath])
        {
            // 解压缩到指定路径
            [zipArchive UnzipFileTo:unZipPath overWrite:YES];
            NSLog(@"文件解压缩成功");
        }
        else
            NSLog(@"文件无法打开，无法解压缩");
//    }
//    NSArray *arr = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@/%@",unZipPath,self.changeSkinColor]];
//    NSLog(@"1111%@",arr);
    
}


-(NSString*)getMarketData
{
    NSLog(@"SPLASH_SCREEN_DATE--->%@",SPLASH_SCREEN_DATE);
    if ([[NSFileManager defaultManager] fileExistsAtPath:SPLASH_SCREEN_DATE])
    {
        NSMutableArray* arrayOfSplash = [[NSMutableArray alloc] initWithContentsOfFile:SPLASH_SCREEN_DATE];
        for (int i=0; i<arrayOfSplash.count; i++) {
            NSString *endDate = [[arrayOfSplash objectAtIndex:i]  objectForKey:@"EndTime"];
            NSString *startDate = [[arrayOfSplash objectAtIndex:i]  objectForKey:@"StartTime"];
            NSDateFormatter*Formatter = [[NSDateFormatter alloc] init];
            [Formatter setDateFormat:@"yyyy'-'MM'-'dd"];
            NSDate *endOfDate = [Formatter dateFromString:endDate];
            NSDate *startOfDate =[Formatter dateFromString:startDate];
            NSString*FileName=[[arrayOfSplash objectAtIndex:i]objectForKey:@"FileName"];
            
            if ([endOfDate timeIntervalSinceNow]>=0&&[startOfDate timeIntervalSinceNow]<=0)//找到时间内url
            {
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:SPLASH_SCREEN_PATH(FileName)]) {
                    NSString*url=SPLASH_SCREEN_PATH(FileName);
                    return url;
                }
                
            }
        }
    }
    
    //第一次运行程序，播放本地mp4,同时向服务器获取mp4
    
    NSString *pVideoPath = [[NSBundle mainBundle]
                            pathForResource:@"iphone_loading"
                            ofType:@"mp4"];
    
    //    NSLog(@"%@",pVideoPath);
    return pVideoPath;
    
}
-(void)performgetMarketData
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:@"MarketingData" object:nil];
    NSLog(@"SPLASH_SCREEN_DATE--->%@",SPLASH_SCREEN_DATE);
    self.MarketingData=[self.returnDictionary objectForKey:@"MarketingData"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:SPLASH_SCREEN_DATE])
    {
        NSMutableArray* arrayOfSplash = [[NSMutableArray alloc] initWithContentsOfFile:SPLASH_SCREEN_DATE];
        
        for (int i=0; i<arrayOfSplash.count; i++)
        {
            //            NSString *endDate = [[arrayOfSplash objectAtIndex:i]  objectForKey:@"EndTime"];
            //            NSString *startDate = [[arrayOfSplash objectAtIndex:i]  objectForKey:@"StartTime"];
            //            NSDateFormatter*Formatter = [[NSDateFormatter alloc] init];
            //            [Formatter setDateFormat:@"yyyy'-'MM'-'dd"];
            //            NSDate *endOfDate = [Formatter dateFromString:endDate];
            //            NSDate *startOfDate =[Formatter dateFromString:startDate];
            NSString*FileName=[[arrayOfSplash objectAtIndex:i]objectForKey:@"FileName"];
            for (int j=0; j<self.MarketingData.count; j++) {
                if ([FileName isEqualToString:[[self.MarketingData objectAtIndex:j] objectForKey:@"FileName"]])//删除新获得营销数据
                {
                    break;
                }
                if ((j+1)==self.MarketingData.count) {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:SPLASH_SCREEN_PATH(FileName)]) {
                        NSString*url=SPLASH_SCREEN_PATH(FileName);
                        NSError*error;
                        [[NSFileManager defaultManager]removeItemAtPath:url error:&error];
                        
                    }
                }
            }
            
        }
        
        //向服务器获取mp4
        if ([self deviceNetWorkState]==2) {
            [self.MarketingData writeToFile:SPLASH_SCREEN_DATE atomically:NO];
            [self reloadData];
        }
        
    }
    else
    {
        //第一次运行程序，向服务器获取mp4
        if ([self deviceNetWorkState]==2)
        {
            self.MarketingData=[self.returnDictionary objectForKey:@"MarketingData"];
            //            NSLog(@"%@",self.MarketingData);
            [self.MarketingData writeToFile:SPLASH_SCREEN_DATE atomically:NO];
            [self reloadData];
        }
    }
    
}

-(void)reloadData
{
    [self performSelectorInBackground:@selector(performSelectorInBackgroundreloadData) withObject:nil];
}

-(void)performSelectorInBackgroundreloadData
{
    NSMutableArray *arrayOfSplash;
    if ([[NSFileManager defaultManager] fileExistsAtPath:SPLASH_SCREEN_DATE])
    {
        arrayOfSplash = [[NSMutableArray alloc] initWithContentsOfFile:SPLASH_SCREEN_DATE];
    }
    else
    {
        return;
    }
    for (int i=0; i<arrayOfSplash.count; i++)
    {
        self.reloadDataFileName=[[arrayOfSplash objectAtIndex:i]objectForKey:@"FileName"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:SPLASH_SCREEN_PATH(self.reloadDataFileName)]) {
            NSLog(@"%@",SPLASH_SCREEN_PATH(self.reloadDataFileName));
        }
        else
        {
            self.reloadDataUrl=[[arrayOfSplash objectAtIndex:i]objectForKey:@"URL"];
            NSString *path = [self.reloadDataUrl stringByAppendingString:self.reloadDataFileName];
            [self postToServerStream:path actionParams:nil];
            return;
        }
        
    }
}

- (void)setServerTimeStamp: (NSString*) timestamp
{
    NSTimeInterval myTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSTimeInterval serverTimeStamp= [timestamp doubleValue];
    timeOffset = serverTimeStamp - myTimestamp;
    
}

-(int)deviceNetWorkState;//网络状态 0:没网络,1:3G网,2:wlan网
{
    
    //    return 3;
    
#if defined(INNER_SERVER) || defined(GET_DATA_FROM_LOCAL_FILE)
    return 2;
#endif
    int isExistenceNetwork = 0;
    Reachability *netWorkState=[Reachability reachabilityWithHostname:TEST_CHECK_NETWORK_URL];
    DebugLog(@"deviceNetWorkState, Reachability=%@",netWorkState);
    NSString *msg = @"";
    NSString *title=@"";
    
    switch ([netWorkState currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=0;
            //            isExistenceNetwork=1;
            title=@"警告";
            msg=@"无法链接到互联网，请检查您的网络设置";
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=1;
            title=@"提示";
            msg=@"正在使用3G网络";
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=2;
            title=@"提示";
            msg=@"正在使用wifi网络";
            break;
            
    }
    
    DebugLog(@"deviceNetWorkState, msg=%@",msg);
    if (!isExistenceNetwork) {
        curTransCount = 0;
        isPostSuccess=YES;
        if (_IsVxData) {
            
            NSMutableDictionary*post = [[NSMutableDictionary alloc]init];
            [post setObject:@"999999" forKey:@"_RejCode"];
            [post setObject:msg forKey:@"jsonError"];
            [self hideMask];
            [self.delegate getReturnData:post WithActionName:@"xxxx.do"];
            return isExistenceNetwork;
        }
        [self hideMask];
        if (isExistenceNetwork == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            alert.tag = 600;
            [alert show];
        }
        else
        [self showAlert:title alertMessages:msg alertType:Alert];
    }
    
    return isExistenceNetwork;
}

-(void)showAlert:(NSString *)alertTitle alertMessages:(NSString *)alertMessages alertType:(alertType)alertType;//显示提示对话窗口
{
    UIAlertView *alertView;
    switch (alertType) {
        case Alert:
            alertView=[[UIAlertView alloc]initWithTitle:alertTitle message:alertMessages delegate:delegate cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            
            alertView.tag=ALERT_TAG;
            [alertView show];
            break;
        case Confirm:
            alertView=[[UIAlertView alloc]initWithTitle:alertTitle message:alertMessages delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
            alertView.tag=CONFIRM_TAG;
            [alertView show];
            break;
            
        default:
            break;
    }
}

-(void)showMask:(NSString *)maskTitle maskMessage:(NSString *)messages maskType:(maskType)type;//显示等待遮罩层
{
    if([PROGESS_WINDOW viewWithTag:HUD_TAG]!=nil)
    {
        return;
    }
    
    TYMActivityIndicatorView* indicatorView = [[TYMActivityIndicatorView alloc]initWithActivityIndicatorStyle:TYMActivityIndicatorViewStyleNormal];
    indicatorView.frame = [UIScreen mainScreen].bounds;
    UIWindow* window = PROGESS_WINDOW;
    
    window.userInteractionEnabled = NO;
    [PROGESS_WINDOW addSubview:indicatorView];
    [indicatorView startAnimating];
    indicatorView.tag = HUD_TAG;
    
    //    [self setMaskShowTimeOut:60];  //设置遮罩超时时间
    
    DebugLog(@"MobileBankSession ---Maskshow");
}

-(void)hideMask;//隐藏等待遮罩层
{
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleShowTimeOut) object:nil];//取消可能存在的遮罩层超时异步请求。
    
    if (curTransCount>0) {
        return;//可打开此处代码，用于保持遮罩的连续性
    }
    
    if([PROGESS_WINDOW viewWithTag:HUD_TAG]!=nil&&isPostSuccess==YES)
    {
        TYMActivityIndicatorView* indicatorView = (TYMActivityIndicatorView *)[PROGESS_WINDOW viewWithTag:HUD_TAG];
        [indicatorView stopAnimating];
        UIWindow* window = PROGESS_WINDOW;
        window.userInteractionEnabled = YES;
        [indicatorView removeFromSuperview];
        DebugLog(@"MobileBankSession ---Maskhide");
    }
}

-(void)setMaskShowTimeOut:(NSTimeInterval)interval
{
    TYMActivityIndicatorView* indicatorView = (TYMActivityIndicatorView *)[PROGESS_WINDOW viewWithTag:HUD_TAG];
    UIWindow* window = PROGESS_WINDOW;
    window.userInteractionEnabled = NO;
    indicatorView.frame = [UIScreen mainScreen].bounds;
    [indicatorView setShowTimeOut:interval];
}
-(void)userAnalysis:(NSString *)userActionID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* plistPath1 = [paths objectAtIndex:0];
    NSString *filename =[plistPath1 stringByAppendingPathComponent:@"UserAnalysis.sqlite"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:userActionID forKey:@"TransCode"];
    [dic setObject:userActionID forKey:@"ActionId"];
    [dic setObject:@"000000" forKey:@"RejCode"];
    if ([MobileBankSession sharedInstance].isLogin) {
        [dic setValue:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"] forKey:@"MobileNo"];
    }else
        [dic setObject:@"" forKey:@"MobileNo"];
    NSDate *date = [[NSDate alloc]init];
    NSDateFormatter *daff = [[NSDateFormatter alloc]init];
    [daff setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateSS = [daff stringFromDate:date];
    [dic setValue:dateSS forKey:@"TransTime"];
    NSString *infoString = [Context jsonStrFromDic:dic];
    NSString *infoStringDES = [CommonFunc base64StringFromTextDES:infoString];//将存到数据库里的东西加密了
    
    _dataBase  = [[FMDatabase alloc] initWithPath:filename];
    if([_dataBase open]){
        NSLog(@"数据库创建打开成功");
        [_dataBase open];
        [_dataBase executeUpdate:@"create table User(UserName text)"];
        [_dataBase executeUpdate:@"insert into User(UserName) values(?)",infoStringDES];
        [_dataBase close];
        
    }
    else
        NSLog(@"数据库创建打开失败");
    
    //        self.UserAnalysisActionId = @"";
}
-(void)menuStartAction:(NSDictionary*)menuDictionary
{
    //[self.web startActionUrl:nil WithFrame:[[UIScreen mainScreen]bounds]];
    //actionid
    
    if (menuDictionary) {
        NSLog(@"%@",[menuDictionary objectForKey:MENU_ACTION_ID]);
//        [self userAnalysis:[menuDictionary objectForKey:MENU_ACTION_ID]];//行为轨迹分析

    }
    
    if (menuDictionary) {
        _menuDictionary = menuDictionary;
    }else{
        //被动登陆成功后继续接着访问     前面需要[[MobileBankSession sharedInstance] menuStartAction:nil];
        menuDictionary = [NSDictionary dictionaryWithDictionary:_menuDictionary];
    }
    NSString* Clickable = [menuDictionary objectForKey:@"Clickable"];
    NSArray* menuList = [menuDictionary objectForKey:@"MenuList"];
    NSString* entryType = [menuDictionary objectForKey:@"EntryType"];
    NSString*RoleCtr = [menuDictionary objectForKey:@"RoleCtr"];
    
    if(Clickable!=nil && [Clickable isEqualToString:@"false"]){
        [self.delegate OpenNextView:EDisabled];
        return;
    }
    
    [MobileBankSession sharedInstance].isPassiveLogin = YES;
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserType"]isEqualToString:@""]&&![RoleCtr isEqualToString:@""]) {    //P 大众版  T专业版    “”游客
        NSLog(@"无权限");
        ShowAlertView(@"提示", @"您是大众版用户不能使用此功能，请通过网银或柜面升级为专业版！", nil, @"确认", nil);
        return;
    }
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserType"]isEqualToString:@"P"]&&[RoleCtr isEqualToString:@"T"]) {    //P 大众版  T专业版    “”游客
        NSLog(@"无权限");
        ShowAlertView(@"提示", @"您是大众版用户不能使用此功能，请通过网银或柜面升级为专业版！", nil, @"确认", nil);
        return;
    }
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&![[[MobileBankSession sharedInstance].Userinfo objectForKey:@"Security"]isEqualToString:@"05"]&&[RoleCtr isEqualToString:@"U"]) {    //P 大众版  T专业版    “”游客
        NSRange ran = NSMakeRange(4, 1);
        NSString *string = [[[MobileBankSession sharedInstance].Userinfo objectForKey:@"SecurityFlag"] substringWithRange:ran];
        if ([string isEqualToString:@"1"]) {//0000101000
            ShowAlertView(@"提示", @"当前认证方式是“动态码＋交易密码”方式，请切换到“音频Key”方式", nil, @"确认", nil);
            return;
        }
        else{
            NSLog(@"无权限");
            ShowAlertView(@"提示", @"您无权限操作此功能，请到柜台开通音频Key", nil, @"确认", nil);
            return;
        }
    }
    
    if(menuList!=nil && menuList.count>0)
        [self.delegate OpenNextView:ENativeList];
    
    else if (entryType!=nil && [entryType isEqualToString:@"native"])
        [self.delegate OpenNextView:ENative];
    
    else if (entryType!=nil && [entryType isEqualToString:@"web"])
    {
//        if ([self deviceNetWorkState]!=0) {
            [self.delegate OpenNextView:EWeburl];
//        }
    }else if (entryType!=nil&&[entryType isEqualToString:@"url"])
        [self.delegate OpenNextView:EOpenurl];
    else
        [self.delegate OpenNextView:EDisabled];
}
-(void)postToServerStream:(NSString *)action actionParams:(NSMutableDictionary *)params;//数据接口 返回(数据流)stream
{
//    if ([self deviceNetWorkState]) {
    
    
        Communication *comm =[[Communication alloc]init];
        comm.delegate=self;
        [comm getWorkModeState:Product];
        if ([action isEqualToString:@"GenTokenImg.do"]||[action isEqualToString:@"AdvertContent.do"]||[action isEqualToString:@"StartPageLoad.do"]) {
            
        }else{
            [self showMask:nil maskMessage:@"请稍候..." maskType:Common];
        }
        [comm PostToServerStream:params actionName:action postUrl:self.reloadDataUrl];
        curTransCount++;
//    }
}
-(void)postToServer:(NSString *)action actionParams:(NSMutableDictionary *)params;//数据接口返回string
{
//    if ([self deviceNetWorkState]) {
        Communication *comm =[[Communication alloc]init];
        comm.delegate=self;
        [comm getWorkModeState:Product];
        
        if (params==nil) {
            params=[[NSMutableDictionary alloc]init];
            [params setObject:@"zh_CN" forKey:@"_locale"];
        }
        
        NSString *url;
        
        url = [NSString stringWithFormat:@"%@://%@/%@",[Context sharedInstance].server_backend_ssl? @"https":@"http",[Context sharedInstance].server_backend_name,SERVER_BACKEND_CONTEXT];
        
        [self showMask:nil maskMessage:@"请稍候..." maskType:Common];
        [comm PostToServer:params actionName:action postUrl:url];
        curTransCount++;
//    }
    
}
-(void)postToServer:(NSString *)action actionParams:(NSMutableDictionary *)params method:(NSString*)method returnBlock:(RetrunData)_returnData111;
{
    
    if ([action isEqualToString:@""]||action == nil) {
        return;
    }
    
    [MobileBankSession sharedInstance].IsVxData = NO;
    isPostSuccess = YES;
    NSLog(@"%@",params);
    
    //显示遮罩
    if (![action isEqualToString:@"ClientVersionQry.do"]&&![action isEqualToString:@"CheckVersion.do"]&&![action isEqualToString:@"GenTimeStamp.do"]&&![action isEqualToString:@"SessionInit.do"]&&![action isEqualToString:@"StartPageLoad.do"]) {
        [self showMask:nil maskMessage:@"请稍候..." maskType:Common];//Common  -->  typedef enum{Common=0}maskType;
    }
    
//    if ([action isEqualToString:@"CheckVersion.do"] ||[self deviceNetWorkState]) {
        Communication *comm =[[Communication alloc]init];
        comm.delegate=self;
        [comm getWorkModeState:Product];//set才对
        
        NSString * actionString;
        
        actionString =[NSString stringWithFormat:@"%@",action];
        NSString*_locsleStr = @"zh_CN";
        [params setObject:_locsleStr forKey:@"_locale"];
        [params setObject:@"9999" forKey:@"BankId"];
        
    NSString *jsonStr = [Context jsonStrFromDic:params];
        [params removeAllObjects];
        [params setObject:[CommonFunc base64StringFromTextDES:jsonStr] forKey:@"key"];
        
        [comm PostToServer:params actionName:actionString method:method returnBlock:^(NSDictionary *data) {
            curTransCount = 0;
            isPostSuccess = YES;
            [self hideMask];
            
            if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
                _returnData111(data);
            }else{
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[data objectForKey:@"jsonError"] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//                alert.tag = 321;
                [alert show];
                return ;
            }
        }];
        
        curTransCount++;
//    }
    
}
//原生调用这个方法  因为需要加密，所以进行了改造
-(void)postToServer:(NSString *)action actionParams:(NSMutableDictionary *)params method:(NSString*)method
{
    
    if ([action isEqualToString:@""]||action == nil) {
        return;
    }

    
    if ([action isEqualToString:@"SessionInit.do"]||[action isEqualToString:@"GonggaoContent.do"]||[action isEqualToString:@"IconZipInfoQry.do"]||[action isEqualToString:@"PuserLogAdd.do"]) {
        int a = [self deviceNetWorkState];
        if (a==0) {
            UIAlertView *all = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无法链接到互联网，请检查您的网络设置" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            all.tag = 600;
            [all show];
            return;
        }
        
    }

    
    [MobileBankSession sharedInstance].IsVxData = NO;
    isPostSuccess = NO;
        DebugLog(@"%@",params);
    
    //显示遮罩
    if (![action isEqualToString:@"ClientVersionQry.do"]&&![action isEqualToString:@"CheckVersion.do"]&&![action isEqualToString:@"GenTimeStamp.do"]&&![action isEqualToString:@"SessionInit.do"]&&![action isEqualToString:@"AdvertContent.do"]&&![action isEqualToString:@"QueryAdvertInfo.do"]&&![action isEqualToString:@"GonggaoContent.do"]&&![action isEqualToString:@"StartPageLoad.do"]) {
        [self showMask:nil maskMessage:@"请稍候..." maskType:Common];//Common  -->  typedef enum{Common=0}maskType;
    }
    
//    if ([action isEqualToString:@"CheckVersion.do"] ||[self deviceNetWorkState]) {
        Communication *comm =[[Communication alloc]init];
        comm.delegate=self;
        [comm getWorkModeState:Product];//set才对
        
        NSString * actionString;
        
        actionString =[NSString stringWithFormat:@"%@",action];
        NSString*_locsleStr = @"zh_CN";
        [params setObject:_locsleStr forKey:@"_locale"];
        [params setObject:@"9999" forKey:@"BankId"];
        
//        NSString*jsonStr = [params JSONString];
    NSString *jsonStr = [Context jsonStrFromDic:params];
        [params removeAllObjects];
        [params setObject:[CommonFunc base64StringFromTextDES:jsonStr] forKey:@"key"];
        [comm PostToServer:params actionName:actionString method:method];
        
        
        curTransCount++;
//    }
    
}

//vx调用这个方法
-(void)postToServer:(NSString *)action actionParams:(NSMutableDictionary *)params method:(NSString*)method IsVx:(BOOL)isVx
{
    
    if ([action isEqualToString:@""]||action == nil) {
        return;
    }
    
    [MobileBankSession sharedInstance].IsVxData = YES;
    isPostSuccess = NO;
    if (IsPrintfUserInfo) {
        DebugLog(@"VX-------%@",params);
    }
    
    //显示遮罩
    if (![action isEqualToString:@"ClientVersionQry.do"]&&![action isEqualToString:@"CheckVersion.do"]&&![action isEqualToString:@"StartPageLoad.do"]) {
        [self showMask:nil maskMessage:@"请稍候..." maskType:Common];//Common  -->  typedef enum{Common=0}maskType;
    }
    
//    if ([action isEqualToString:@"CheckVersion.do"] ||[self deviceNetWorkState]) {
        Communication *comm =[[Communication alloc]init];
        comm.delegate=self;
        [comm getWorkModeState:Product];//set才对
        
        NSString * actionString;
        
        actionString =[NSString stringWithFormat:@"%@",action];
        NSString*_locsleStr = @"zh_CN";
        [params setObject:_locsleStr forKey:@"_locale"];
        [params setObject:@"9999" forKey:@"BankId"];
        
//        NSString*jsonStr = [params JSONString];
    NSString *jsonStr = [Context jsonStrFromDic:params];
        [params removeAllObjects];
        [params setObject:[CommonFunc base64StringFromTextDES:jsonStr] forKey:@"key"];
        
        [comm PostToServer:params actionName:actionString method:method];
        
        curTransCount++;
//    }
}

- (id)initWithTrans:(NSString*)trans args:(NSMutableDictionary*)args;
{
    self=[super init];
    if (self) {
        [self postToServer:trans actionParams:args];
    }
    return self;
}
- (id)initWithTrans:(NSString *)trans;{
    
    return  [self initWithTrans:trans args:nil];
}

-(BOOL)loginState;//登录状态
{
    return isLogin;
}
-(NSString *)getLastErrorMessage;//错误信息
{
    return nil;
}

-(void)getLoginPage:(NSString *)name Password:(NSString *)password
{
    //    NSMutableDictionary*initDic=[NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"name", password,@"password",nil];
    times=2;
    
    //[self postToServer:@"Login.txt" actionParams:initDic];
    
    //暂时改为从本地Bundle读取。
    NSData *menuJsonData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"menu"ofType:@"txt"]];
    DebugLog(@"%@",[[NSBundle mainBundle] pathForResource:@"menu"ofType:@"txt"]);
    
    NSError *error = nil;
    NSDictionary *menuDict = [NSJSONSerialization JSONObjectWithData:menuJsonData options:0 error:&error];
    if(error){
        DebugLog(@"Menu JSON Parsing Error: %@", error);
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"菜单JSON解析出错" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [self getReturnDataFromServer:menuDict withActionName:@"Login.txt"];
}

#pragma mark AlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 321) {    //点击提示更新的取消键
        if (buttonIndex==0) {
            alertView.hidden = YES;
            
            //权限池
            self.AuthorityList=[returnUpdateDic objectForKey:@"AuthorityList"];
            //菜单数组
            self.MenuArray=[returnUpdateDic objectForKey:@"DisplayList"];
            
//            if ([self.delegate respondsToSelector:@selector(getReturnData:WithActionName:)]){
                //mobileSessionDelegate
                [self.delegate getReturnData:returnUpdateDic WithActionName:@"SessionInit.do"];
                [self hideMask];
                return;
//            }
            
        }else{                  //点击提示更新的确定键
            NSString* myAppID = @"1060969147";
                NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/chang-shu-nong-shang-yin-xing/id%@?l=zh&ls=1&mt=8",myAppID];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                
            //权限池
            self.AuthorityList=[returnUpdateDic objectForKey:@"AuthorityList"];
            //菜单数组
            self.MenuArray=[returnUpdateDic objectForKey:@"DisplayList"];
            
//            if ([self.delegate respondsToSelector:@selector(getReturnData:WithActionName:)]){
                //mobileSessionDelegate
                [self.delegate getReturnData:returnUpdateDic WithActionName:@"SessionInit.do"];
                [self hideMask];
                return;
//            }
        }
    }
    if (alertView.tag == 322) {
        NSString* myAppID = @"1060969147";
        
        if (buttonIndex ==1) {
            NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/chang-shu-nong-shang-yin-xing/id%@?l=zh&ls=1&mt=8",myAppID];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
        else if (buttonIndex==0) {
            exit(0);
        }
    }
    if (alertView.tag == 777||alertView.tag == 788) {
    [MobileBankSession sharedInstance].shoudanLoginMessageString = @"";
        if (buttonIndex==0) {
            KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
            password = [keychin objectForKey:(__bridge id)kSecValueData];
            if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码
//                //时间过期提示
//                [self postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {//[Context getNSUserDefaultskeyStr:@"LastLoginTime"]
//                    if ([self last:[Context getNSUserDefaultskeyStr:@"LastLoginTime"] now:[data objectForKey:@"_sysDate"]]>30*24) {
//                        
//                        [GesturePasswordController clear];
//                        //                            [Context setNSUserDefaults:@"yes" keyStr:@"isFirstLogin"];
//                        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手势密码过期，请使用其他方式登录" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//                        alert.tag = 123;
//                        [alert show];
//                        
//                    }else{
                [self hideMask];
                timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loopAction) userInfo:nil repeats:NO];

            }else{
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                self.isNativeLogin = YES;
                _isExitnegative = YES;
                if (alertView.tag ==777) {
                    [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
                }else if (alertView.tag ==788)
                {
                    [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
                }
            }
            return;
        }
    }
    if (alertView.tag ==600) {//没有网络，退出
        if (buttonIndex==0) {
            exit(0);
        }
    }
    if (alertView.tag ==123) {
        if (buttonIndex ==0) {
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        }
    }
    if(alertView.tag == 344){//md5错误    https证书错误
        exit(0);
    }
    if (alertView.tag == 388) {
        exit(0);
    }
    
    if (buttonIndex == 0 && alertView.tag == 111113) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"rightViewRequestValicode" object:nil];
        return;
    }
    
    if (buttonIndex == 0 && alertView.tag == 100000) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"rightViewRequestValicode" object:nil];
    }
    
    if (buttonIndex == 0 && alertView.tag == 111111) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loggout" object:nil];
        
        return;
    }
    
    if (buttonIndex == 0 && alertView.tag == 111112) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loggoutAndPushToBinding" object:nil];
        return;
    }
    
    
    if ([PROGESS_WINDOW viewWithTag:HUD_TAG]!=nil)
        [self hideMask];
    
    //两个按钮的自己处理回调方法
    if(alertView.tag==CONFIRM_TAG)
    {
        if([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
        {
            if(buttonIndex==0)
            {
                [self.delegate alertView:alertView clickedButtonAtIndex:0];
            }else{
                [self.delegate alertView:alertView clickedButtonAtIndex:1];
            }
        }
    }
    else if(alertView.tag==ALERT_TAG){
        
        if ([returnCode isEqualToString:@"uibs_login_be_force_out"]
            || [returnCode isEqualToString:@"role.invalid_user"]
            || [returnCode isEqualToString:@"role.invalid_bankid"]
            || [returnCode isEqualToString:@"invalid_bankid"]
            || [returnCode isEqualToString:@"uibs.both_user_and_bankid_is_null"])
        {
            //uibs_login_be_force_out,当前已经有一个相同的用户处于登陆状态，故您已被系统强制签退
            //role.invalid_user,会话已超时
            //invalid_bankid,会话已超时
            //uibs.both_user_and_bankid_is_null,会话已超时
            
            UIViewController *viewController = nil;
            if([self.delegate isKindOfClass:[UIViewController class]])
            {
                viewController = (UIViewController*)self.delegate;
            }
            else if([self.delegate isKindOfClass:[UIView class]])//主要是MobileBankWeb
            {
                viewController = [self getViewController:[(UIView*)self.delegate nextResponder]];
            }
            
            if(viewController!=nil && viewController.navigationController!=nil)
            {
                DebugLog(@"#######-----pre pop ---1");
                [viewController.navigationController popToRootViewControllerAnimated:NO];
                DebugLog(@"#######-----popToRoot ---1");
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
            }
            else if(viewController!=nil && viewController.navigationController==nil)
            {
                UINavigationController *rootNavigation = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
                DebugLog(@"#######-----pre pop ---2");
                [rootNavigation popToRootViewControllerAnimated:NO];
                DebugLog(@"#######-----popToRoot ---2");
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
            }
            
            //清空web内容
            if([WebViewController isSharedInstanceExist]){
                [[WebViewController sharedInstance] clearWebContent];
            }
        }
        //        else if([returnCode isEqualToString:@"uibs.security_input_timeout"])
        //        {
        //            //密码超时,重新获取密码控件加密用的时间戳
        //            [self postToServer:@"getTimestamp.do" actionParams:nil method:@"POST"];
        //        }
        
        returnCode = @"";
        
    }else if(alertView.tag == UPDATE_TAG){
        if (buttonIndex==0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.upgradeurl]];
            exit(0);//更新，程序退出
        }
    }
    else if(alertView.tag == UPDATE_TAG2){
        if (buttonIndex==0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.upgradeurl]];
            exit(0);//更新，程序退出
        }else if (buttonIndex==1) {
            exit(0);//不更新，程序退出
        }
    }
    else if(alertView.tag == CHECKVERSION_FAIL_TAG)
    {
        if (buttonIndex==0) {
            exit(0);//程序退出
        }else if (buttonIndex==1){
            //重新发从服务器获取菜单的交易
            [self getConfigMenuFromServer];
        }
    }
    else if(alertView.tag == SIGNATURE_VERIFY_FAIL_TAG)
    {
        if (buttonIndex==0) {
            exit(0);//程序退出
        }
    }
    
}

-(void)loopAction
{
    [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
    [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];

    loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
    [loginAlertView show];

}
-(void)gestureOtherWay:(CustomAlertView *)alert
{
    self.isLogin = NO;
    [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
}
-(void)gestureExit:(CustomAlertView *)alert
{
    self.isOpenUrlBack = NO;
    self.isLogin = NO;
    [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
    [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
    [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
}

#pragma mark ---------Gesturedelegation------------
- (BOOL)verification:(NSString *)result{
    if ([result isEqualToString:password]) {
        [loginAlertView.gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [loginAlertView.gesturePasswordView.state setText:@"输入正确"];
        
        loginAlertView.hidden = YES;
        _isExitnegative = YES;
        NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
        [postDic setObject:@"2" forKey:@"LoginType"];  //1 手机号登录  2 手势登录  3 信用卡登录
        [postDic setObject:[Context getNSUserDefaultskeyStr:@"userID"] forKey:@"LoginId"];
        [postDic setObject:[[UIDevice currentDevice] systemName] forKey:@"DeviceInfo"];
        [postDic setObject:@"ios" forKey:@"DeviceOS"];
        
        NSString* machineCode;
        if (IOS7_OR_LATER) {
            machineCode = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }else {
            machineCode = [CSIIConfigDeviceInfo getDeviceID];
        }
        
        [postDic setObject:machineCode forKey:@"DeviceCode"];
//        [MobileBankSession sharedInstance].delegate  = self;
        [self postToServer:@"login.do" actionParams:postDic method:@"POST"];
        
        
        return YES;
    }
    
    if (result.length<4) {
        [loginAlertView.gesturePasswordView.tentacleView enterArgin];
        [loginAlertView.gesturePasswordView.state setTextColor:[UIColor redColor]];
        [loginAlertView.gesturePasswordView.state setText:@"最小长度为4，请重新输入"];
        return NO;
    }
    
    int Gesturecount = [[Context getNSUserDefaultskeyStr:@"Gesturecount"] intValue];
    Gesturecount++;
    if (Gesturecount<5) {
        [loginAlertView.gesturePasswordView.tentacleView enterArgin];
        [Context setNSUserDefaults:[NSString stringWithFormat:@"%d",Gesturecount] keyStr:@"Gesturecount"];
        [loginAlertView.gesturePasswordView.state setTextColor:[UIColor redColor]];
        [loginAlertView.gesturePasswordView.state setText:[NSString stringWithFormat:@"手势密码错误%d次，还剩%d次",Gesturecount,5-Gesturecount]];
    }else if (Gesturecount==5){
        loginAlertView.hidden = YES;
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您已输错5次，请使用手机号登录，如想继续使用手势密码，请登录成功后自行设置" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        alert.tag = 123;
        [alert show];
        [GesturePasswordController clear];
        [Context setNSUserDefaults:@"0" keyStr:@"Gesturecount"];
    }
    
    return NO;
}


#pragma mark CommunicationDelegate 方法

-(void)getReturnDataFromServer:(id )data withActionName:(NSString*)action
{
    if ([action isEqualToString:@"QueryLYBCustInfo.do"]) {
        NSLog(@"了一包的%@",data);
    }
    
//    if ([data isKindOfClass:[NSDictionary class]]) {
//        if ([data objectForKey:@"jsonError"] != nil) {
//            NSString*msg = [data objectForKey:@"jsonError"];
//            if ([msg hasPrefix:@"com.csii"]) {
//                msg = @"系统内部错误";
//                
//                NSLog(@"有com.csii1111");
//                
//                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
//                [alert show];
//                
//                curTransCount=0;
//                [self hideMask];
////                return;
//            }
//        }
//    }
    
    isPostSuccess = YES;
    
    if(curTransCount>0)
        curTransCount--;
    if ([action isEqualToString:@"GonggaoContent.do"]) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            //            NSMutableArray*array = [data objectForKey:@"Content"];
            [CSIIMenuViewController sharedInstance].publicArray = [data objectForKey:@"Content"];
            [CSIIMenuViewController sharedInstance].isLoadPubview = YES;
        }else if ([data objectForKey:@"jsonError"] != nil) {
            NSString*msg = [data objectForKey:@"jsonError"];
            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
            [alert show];
        }
        curTransCount = 0;
        [self hideMask];
        return;
        
    }
    if ([action isEqualToString:@"IconZipInfoQry.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
        NSLog(@"yyyyyyyy%@",data);
        //记住换肤
        NSString *skinString = [Context getNSUserDefaultskeyStr:@"skin"];
        if (skinString.length==0||[skinString  isEqualToString:@""]||[skinString isEqualToString:@"101"]||[skinString isEqualToString:@"102"]||[skinString isEqualToString:@"103"]) {
            self.changeSkinColor = @"skyblue";
        }
        else self.changeSkinColor = skinString;
        NSArray *array = [NSArray arrayWithObjects:[data objectForKey:@"List"], nil];
        if (array.count>0) {
            [Context setNSUserDefaults:[[array[0] lastObject] objectForKey:@"UpdateTime"] keyStr:[NSString stringWithFormat:@"%@SkinUpdateTime",self.changeSkinColor]];

            for (int i=0; i<[array[0] count]; i++) {
                //            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                //            [dic setObject:[array[0][i]objectForKey:@"IconZipSeq"] forKey:@"IconZipSeq"];
                //            [[MobileBankSession sharedInstance]postToServerStream:@"IconZipQry.do" actionParams:dic];
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/IconZipQry.do?IconZipSeq=%@",SERVER_BACKEND_URL,SERVER_BACKEND_CONTEXT,[array[0][i]objectForKey:@"IconZipSeq"]]];
                NSData *data22 = [NSData dataWithContentsOfURL:url];
//                NSLog(@"tttttttt%@",data22);
                NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
                NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
                NSFileManager *fm = [[NSFileManager alloc] init];

                [fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/book",ourDocumentPath] withIntermediateDirectories:NO attributes:nil error:nil];

                NSString *unZipPath = [NSString stringWithFormat:@"%@/book",ourDocumentPath];
                //            [data22 writeToFile:unZipPath atomically:YES];
                [data22 writeToFile:[NSString stringWithFormat:@"%@/%@.zip",unZipPath,[array[0][i]objectForKey:@"IconZipName"]] options:NSDataWritingFileProtectionNone error:nil];

                NSString *bookPath = [NSString stringWithFormat:@"%@/%@.zip",unZipPath,[array[0][i]objectForKey:@"IconZipName"]];
//                NSString *bookPath22 = [NSString stringWithFormat:@"%@/%@",unZipPath,[array[0][i]objectForKey:@"IconZipName"]];
                
//                NSArray *arr = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@",unZipPath]];
//                NSLog(@"2222%@",arr);
                ZipArchive *zipArchive = [[ZipArchive alloc] init];
                // 判断解压文件是否可以打开
                if([zipArchive UnzipOpenFile:bookPath])
                {
                    // 解压缩到指定路径
                    [zipArchive UnzipFileTo:[NSString stringWithFormat:@"%@/%@",unZipPath,self.changeSkinColor] overWrite:YES];
                    NSLog(@"文件解压缩成功");
//                    BOOL bb = [fm moveItemAtPath:bookPath22 toPath:[NSString stringWithFormat:@"%@/blue%@",unZipPath,[array[0][i]objectForKey:@"IconZipName"]] error:nil];
//                    if (bb) {
//                        NSLog(@"移动成功");
//                    }
                }
                else
                    NSLog(@"文件无法打开，无法解压缩");
                
//                NSArray *arr2 = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@",unZipPath]];
//                NSLog(@"3333%@",arr2);
////
//                NSArray *arr3 = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@/%@",unZipPath,self.changeSkinColor]];
//                
//                NSLog(@"4444%@",arr3);
            }
            
        }
//        NSFileManager *fm = [[NSFileManager alloc]init];
//        NSString *unZipPath = [Context unZipPath];
//        NSArray *arr3 = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@/%@",unZipPath,self.changeSkinColor]];
//        NSLog(@"4444%@",arr3);
    }
    }
    if (_isExitnegative) {
//        [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
//        [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
        _isExitnegative = NO;
//        [[LoginViewController sharedInstance]getReturnData:data WithActionName:action];
        if ([action isEqualToString:@"login.do"]) {
            if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
                self.Userinfo = [[NSMutableDictionary alloc]initWithDictionary:data];
                self.isLogin = YES;
                [[CSIIMenuViewController sharedInstance]createNavigationUI];
                if ([[data objectForKey:@"IsBind"] isEqualToString:@"N"]) {
                    BindingEquipmentViewController *bindViewController = [[BindingEquipmentViewController alloc]init];
                    bindViewController.telephoneNum = [data objectForKey:@"MobileNo"];
                    [[CSIIMenuViewController sharedInstance].navigationController pushViewController:bindViewController animated:YES];
                    if (self.isNativeLogin) {
                        [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                        self.isNativeLogin = NO;
                    }
                    return;
                }
                //现在是跳到VX界面
                if (self.toPassiveActionId.length>0) {
                    [[WebViewController sharedInstance] setActionId:self.toPassiveActionId actionName:self.toPassiveActionName prdId:self.toPassiveActionPrdId Id:self.toPassiveActionToId];
                    [[CSIIMenuViewController sharedInstance].navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
                    if (self.isNativeLogin) {
                      [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                        self.isNativeLogin = NO;
                    }

                    self.toPassiveActionId = @"";
                    self.toPassiveActionName = @"";
                    self.toPassiveActionPrdId = @"";
                    self.toPassiveActionToId = @"";
                }
//                原生界面
              else  if ([MobileBankSession sharedInstance].toPassiveControllerString!=nil) {
                    CSIISuperViewController *vc = [[NSClassFromString([MobileBankSession sharedInstance].toPassiveControllerString)alloc]init];
                [[CSIIMenuViewController sharedInstance].navigationController pushViewController:vc animated:YES];
                  
                  if (self.isNativeLogin) {
                        [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                      self.isNativeLogin = NO;
                   }
                  
                  self.toPassiveControllerString = @"";
                }
              else{
                  [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
                  [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
                  [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
              }
                curTransCount=0;
                [self hideMask];
            }
        }
        return;
    }

    if (self.IsVxData) {
        
        if ([data objectForKey:@"jsonError"] != nil) {
            curTransCount = 0;
            _isExitnegative = NO;
            NSString*msg = [data objectForKey:@"jsonError"];
            if ([msg hasPrefix:@"com.csii"]) {
                msg = @"系统繁忙，请稍后再试";
                NSLog(@"有com.csii2222");

                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
                [alert show];
                [self hideMask];
                return;
            }

        if ([[data objectForKey:@"_RejCode"] isEqualToString:@"777777"]||[[data objectForKey:@"_RejCode"] isEqualToString:@"888888"]) {  //777777签退
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
                alert.tag = 788;
                self.Userinfo =nil;
            [alert show];

//            //    清除浏览器的缓存
//            NSHTTPCookie *cookie;
//            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//            for (cookie in [storage cookies])
//            {
//                [storage deleteCookie:cookie];
//            }

            [MobileBankSession sharedInstance].isLogin = NO;
            [[CSIIMenuViewController sharedInstance]createNavigationUI];
               [self hideMask];
               return;

            }
        }
        
        [self.delegate getReturnData:data WithActionName:action];
        [self hideMask];
        return;
    }
    
    if ([action isEqualToString:@"ClientVersionQry.do"]) {
        //        Certification = eaa8b2065312a50dab43567d58575e036a9def61;    //CA证书指纹
        //        Fingerprint = "<null>";                                     //安卓数字签名
        //        ForceUpdate = 1;                                           //是否强制更新  0-yes    1- no
        //        VersionId = 1;                                              //版本号
        //        VersionURL = "http://zhongyuanbank.com";
        //        "_RejCode" = 000000;
        //        interpolatedFlag = 1;                                     //MD5校验   0-no    1-yes
        if ([[data objectForKey:@"_RejCode"] isEqualToString:@"000000"]) {
            _VersionURL = [data objectForKey:@"VersionURL"];
            
            if([[data objectForKey:@"interpolatedFlag"]isEqualToString:@"0"]){   //MD5校验
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"应用程序异常，请重新下载客户端" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                alert.tag = 344;
                [alert show];
                return;
            }
            NSString*HttphostSha1Str = [[NSUserDefaults standardUserDefaults]objectForKey:@"sha1String"];     //访问的CA证书指纹
            NSString*LocahostSha1Str = [[NSUserDefaults standardUserDefaults]objectForKey:@"LocaSha1Str"];    //本地保存的CA证书指纹
            
            
            NSRange rang = NSMakeRange(1, HttphostSha1Str.length-2);         //保证格式一致 去掉<>
            HttphostSha1Str = [HttphostSha1Str substringWithRange:rang];
            
            NSString*httpsShaStr = [data objectForKey:@"Certification"];                                      //交易返回的CA证书指纹
            
            
            BOOL result = [LocahostSha1Str compare:httpsShaStr options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedSame;
            BOOL result1 = [HttphostSha1Str compare:httpsShaStr options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedSame;
            BOOL result2 = [HttphostSha1Str compare:LocahostSha1Str options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedSame;
            
            
            if(!result){   //https证书校验
                
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"服务器证书异常，请确认网络是否安全" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                alert.tag = 344;
                [alert show];
                return;
            }
            
            if(!result1){   //https证书校验
                
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"服务器证书异常，请确认网络是否安全" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                alert.tag = 344;
                [alert show];
                return;
            }
            
            if(!result2){   //https证书校验
                
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"服务器证书异常，请确认网络是否安全" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                alert.tag = 344;
                [alert show];
                return;
            }
        }
    }
    
    
    if (data==nil)
    {
        [self hideMask];
        [self showAlert:@"提示" alertMessages:@"服务器返回数据为空" alertType:Alert];
        return;
    }
    
#ifdef INNER_SERVER
    
    if ([data isKindOfClass:[NSData class]]) {
        
        self.returnData=data;
        //DebugLog(@"ReturnDataFromServer : %@",data);
        if([action isEqualToString:@"GenTokenImg.do"]||[action isEqualToString:@"AdvertContent.do"]||[action isEqualToString:@"StartPageLoad.do"])
        {
            //获取验证码图片流
            if ([self.delegate respondsToSelector:@selector(getReturnData:WithActionName:)]){
                [self.delegate getReturnData:data WithActionName:action];
            }
            [self hideMask];
            return;
        }
        else
        {
            [data writeToFile:SPLASH_SCREEN_PATH(self.reloadDataFileName) atomically:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"MarketingData" object:self userInfo:nil];
        }
        
    }
    
    if ([data isKindOfClass:[NSString class]]) {
        if (IsPrintfUserInfo) {
            DebugLog(@"ReturnDataFromServer : %@",data);
        }
    }
    else if ([data isKindOfClass:[NSArray class]]) {
        if (IsPrintfUserInfo) {
            DebugLog(@"ReturnDataFromServer : %@",data);
        }
    }
    else if ([data isKindOfClass:[NSDictionary class]]) {
        if (IsPrintfUserInfo) {
            DebugLog(@"#####action : %@",action);
            DebugLog(@"#####ReturnDataFromServer:\n%@",data);
        }
        
        //返回web数据,vx页面html数据
        if ([data objectForKey:@"WebData"]) {
            //此时, self.delegate 是 MobileBankWeb,
            //action是类似"samples/htmls/BankInnerTransfer/BankInnerTransfer.html"
            if ([self.delegate respondsToSelector:@selector(getReturnData:WithActionName:)]){
                [self.delegate getReturnData:data WithActionName:action];
            }
            
            DebugLog(@"##### Web send data to javaScript end!!! html数据接收完成");
            //若要让vx页面自己关闭遮罩，请注释掉下面这行代码。在此不主动关闭遮罩，由vx自己关闭，这样能解决刚进入vx页面时，会显示多次遮罩的问题。
            [self hideMask];
            return;
        }
        
        self.returnDictionary=data;
    }
    
    [self hideMask];
    
#else
    if ([data isKindOfClass:[NSData class]]) {
        
        self.returnData=data;
//        DebugLog(@"ReturnDataFromServer : %@",data);
        if([action isEqualToString:@"GenTokenImg.do"]||[action isEqualToString:@"AdvertContent.do"]||[action isEqualToString:@"StartPageLoad.do"]||[action isEqualToString:@"SkinIconZipQry.do"])
        {
            //获取验证码图片流
            if ([self.delegate respondsToSelector:@selector(getReturnData:WithActionName:)]){
                [self.delegate getReturnData:data WithActionName:action];
            }
            [self hideMask];
            return;
        }
        else
        {
            [data writeToFile:SPLASH_SCREEN_PATH(self.reloadDataFileName) atomically:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"MarketingData" object:self userInfo:nil];
        }
        
    }
    else if ([data isKindOfClass:[NSString class]]) {
            DebugLog(@"ReturnDataFromServer : %@",data);
    }
    else if ([data isKindOfClass:[NSArray class]]) {
            DebugLog(@"ReturnDataFromServer : %@",data);
    }
    else if ([data isKindOfClass:[NSDictionary class]]) {
            DebugLog(@"#####action : %@",action);
            DebugLog(@"#####ReturnDataFromServer:\n%@",data);
        
        
        //返回web数据,vx页面html数据
        if ([data objectForKey:@"WebData"]) {
            //此时, self.delegate 是 MobileBankWeb,
            //            action是类似"samples/htmls/BankInnerTransfer/BankInnerTransfer.html"
            if ([self.delegate respondsToSelector:@selector(getReturnData:WithActionName:)]){
                [self.delegate getReturnData:data WithActionName:action];
            }
            
            DebugLog(@"##### Web send data to javaScript end!!! html数据接收完成");
            //若要让vx页面自己关闭遮罩，请注释掉下面这行代码。在此不主动关闭遮罩，由vx自己关闭，这样能解决刚进入vx页面时，会显示多次遮罩的问题。
            //[self hideMask];
            return;
        }
        
        self.returnDictionary=data;
        
        
        if ([action hasSuffix:@".do"]) {
            /*原生交易处理*/
            //
            if ([data objectForKey:@"jsonError"] != nil) {
                _isExitnegative = NO;
                NSString*msg = [data objectForKey:@"jsonError"];
//                if ([msg hasPrefix:@"com.csii"]) {
//                    msg = @"系统内部错误";
//                    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
//                    [alert show];
//                    curTransCount=0;
//                    [self hideMask];
////                    return;
//                }
                [MobileBankSession sharedInstance].tokenNameStr = [data objectForKey:@"_tokenName"];      //报错后给防重码重新赋值
//                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"错误信息！" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
//                [alert show];
                
                if ([[data objectForKey:@"_RejCode"] isEqualToString:@"777777"]||[[data objectForKey:@"_RejCode"] isEqualToString:@"888888"]) {  //777777签退
                    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
                    alert.tag = 777;
                    self.Userinfo = nil;
                    [alert show];
                    [MobileBankSession sharedInstance].isLogin = NO;
                    [[CSIIMenuViewController sharedInstance]createNavigationUI];
                   curTransCount = 0;
                    self.toPassiveActionId = @"";
                    self.toPassiveActionName = @"";
                    self.toPassiveActionPrdId = @"";
                    self.toPassiveActionToId = @"";
//                    //    清除浏览器的缓存
//                    NSHTTPCookie *cookie;
//                    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//                    for (cookie in [storage cookies])
//                    {
//                        [storage deleteCookie:cookie];
//                    }

                   [self hideMask];
                   return;
                }
               else{
                   if ([msg hasPrefix:@"com.csii"]) {
                       NSLog(@"有com.csii3333");
                       msg = @"系统繁忙，请稍后再试";
                       
                   }
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"错误信息！" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
                [alert show];
                   curTransCount = 0;
                   [self hideMask];
//                   return;
               }
//                [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
//                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                
                if ([action isEqualToString:@"GenTokenImg.do"]) {
                    return;
                }
                //                    return;     //报错不返回到原页面
            }
            
            if([action isEqualToString:@"SessionInit.do"]){
                
                if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
                    self.setMenuArray = [[NSMutableArray alloc]init];
                    returnUpdateDic = [[NSDictionary alloc]init];
                    returnUpdateDic = data;
                    self.setMenuArray = [data objectForKey:@"PSetList"];   //存储返回的设置菜单  登录成功页面的菜单
                    
                    NSMutableDictionary*updateDic = [[NSMutableDictionary alloc]initWithDictionary:[data objectForKey:@"UpdateInfo"]];                       //版本信息
                    
                    NSString*infoMsg = [updateDic objectForKey:@"UpdateHint"];   //更新的提示内容
                    
                    if ([[updateDic objectForKey:@"UpdateMode"]isEqualToString:@"0"]) { //不需要更新
                        
                        
                    }else if ([[updateDic objectForKey:@"UpdateMode"]isEqualToString:@"1"]){//提示更新
                        
                        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:infoMsg delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"现在就去", nil];
                        alert.tag = 321;
                        [alert show];
                        return;
                        
                    }else{                                                                 //强制更新
                        
                        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:infoMsg delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"前往更新", nil];
                        alert.tag = 322;
                        [alert show];
                        return;
                        
                    }
                    
                    //权限池
                    self.AuthorityList=[self.returnDictionary objectForKey:@"AuthorityList"];
                    //菜单数组
                    self.MenuArray=[self.returnDictionary objectForKey:@"DisplayList"];
                    
//                    if ([self.delegate respondsToSelector:@selector(getReturnData:WithActionName:)]){
//                        //mobileSessionDelegate
////                        [self.delegate getReturnData:self.MenuArray WithActionName:action];
//                        [self hideMask];
//                        return;
//                    }
                }else{
                    return;
                }
            }
            
            
            [self.delegate getReturnData:data WithActionName:action];
            [self hideMask];
            return;
        }
        
    }
    [self hideMask]; //待页面处理完返回的数据再把遮罩去掉
    
#endif
}


//#pragma mark MobileBankWebDelegate

-(NSTimeInterval)getTimeStapOffSet;//计算时间差
{
    DebugLog(@"self.timeOffset ： %f",self.timeOffset);
    return self.timeOffset;
}

-(int)last:(NSString*)lastTimer now:(NSString*)nowTime;{//返回时间间隔  小时
    
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    //    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate*lastDate = [inputFormatter dateFromString:lastTimer];
    NSLog(@"lastDate= %@", lastDate);
    
    
    NSDate*nowDate = [inputFormatter dateFromString:nowTime];
    NSLog(@"nowDate= %@", nowDate);
    
    NSTimeInterval timeBetween = [nowDate timeIntervalSinceDate:lastDate];
    
    int days=((int)timeBetween)/(3600*24);
    int hours = days*24;
    hours=((int)timeBetween)%(3600*24)/3600+hours;
    
    NSString *dateContent=[[NSString alloc] initWithFormat:@"：%i小时",hours];
    
    NSLog(@"时间间隔为********%@",dateContent);
    
    return hours;
}


-(id)getViewController:(UIResponder*)responder{
    
    UIResponder* res = [[UIResponder alloc]init];
    res = [responder nextResponder];
    while (res) {
        if ([res isKindOfClass:[UIViewController class]]) {
            return res;
        }
        else
            [self getViewController:res];
    }
    return nil;
}

-(NSString*)newSHA1String:(const char*)bytes Datalength:(size_t)length//(const char *bytes, size_t length) {
{
    uint8_t md[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(bytes, length, md);
    
    size_t buffer_size = ((sizeof(md) * 3 + 2) / 2);
    
    char *buffer =  (char *)malloc(buffer_size);
    
    int len = b64_ntop(md, CC_SHA1_DIGEST_LENGTH, buffer, buffer_size);
    if (len == -1) {
        free(buffer);
        return nil;
    } else{
        return [[NSString alloc] initWithBytesNoCopy:buffer length:len encoding:NSASCIIStringEncoding freeWhenDone:YES];
    }
}

b64_ntop(u_char const *src, size_t srclength, char *target, size_t targsize)
{
    size_t datalength = 0;
    u_char input[3];
    u_char output[4];
    u_int i;
    
    while (2 < srclength) {
        input[0] = *src++;
        input[1] = *src++;
        input[2] = *src++;
        srclength -= 3;
        
        output[0] = input[0] >> 2;
        output[1] = ((input[0] & 0x03) << 4) + (input[1] >> 4);
        output[2] = ((input[1] & 0x0f) << 2) + (input[2] >> 6);
        output[3] = input[2] & 0x3f;
        
        if (datalength + 4 > targsize)
            return (-1);
        target[datalength++] = Base64[output[0]];
        target[datalength++] = Base64[output[1]];
        target[datalength++] = Base64[output[2]];
        target[datalength++] = Base64[output[3]];
    }
    
    /* Now we worry about padding. */
    if (0 != srclength) {
        /* Get what's left. */
        input[0] = input[1] = input[2] = '\0';
        for (i = 0; i < srclength; i++)
            input[i] = *src++;
        
        output[0] = input[0] >> 2;
        output[1] = ((input[0] & 0x03) << 4) + (input[1] >> 4);
        output[2] = ((input[1] & 0x0f) << 2) + (input[2] >> 6);
        
        if (datalength + 4 > targsize)
            return (-1);
        target[datalength++] = Base64[output[0]];
        target[datalength++] = Base64[output[1]];
        if (srclength == 1)
            target[datalength++] = Pad64;
        else
            target[datalength++] = Base64[output[2]];
        target[datalength++] = Pad64;
    }
    if (datalength >= targsize)
        return (-1);
    target[datalength] = '\0';	/* Returned value doesn't count \0. */
    return ((int)datalength);
}
@end