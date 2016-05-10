//
//  CSIIMenuViewController.m
//  MobileClient
//
//  Created by wangfaguo on 13-7-17.
//  Copyright (c) 2013年 pro. All rights reserved.
//
#import "MobileBankSession.h"
#import "CSIIMenuViewController.h"
#import "CSIIMenuPaging.h"
#import "CSIIMenuListViewController.h"
#import "CSIIAddMenuViewController.h"
#import "DeviceInfo.h"
#import "Context.h"
#import "NSString+Substring.h"
#import "MarqueeLabel.h"
#import "UIGestureRecognizer+DraggingAdditions.h"
#import "XHDrawerController.h"
#import "SearchViewController.h"
#import "KeychainItemWrapper.h"
#import "CommercialSearchViewController.h"
#import "CSIIConfigDeviceInfo.h"
#import "BusinessCalendarViewController.h"
#import "BindingEquipmentViewController.h"
#import "myCommentViewController.h"
//二维码
#import <ZXingWidgetController.h>
#import "QRCodeReader.h"
#import <Decoder.h>
#import <TwoDDecoderResult.h>
#import "LoginViewController.h"
#import "CustomAlertView.h"
//原生页面
#import "CommercialViewController.h"
#import "PiontStoreViewController.h"
#import "MovieTicketsViewController.h"

#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "AdvertisementViewController.h"

#import "AppDelegate.h"

//书柜隔板之间上下间隔
//#define CLAPBOARD_VERTICAL 80
//#define  AdvertViewHeight_Iphone 140//iphone
//#define  AdvertViewHeight_Ipad 280//ipad

#import "JSONKit.h"

#import "GesturePasswordController.h"

#import "CSIIUIAsyncImageView.h"

#import "CSIIAdvertisementScrollView.h"

#define bottomLabelColor [UIColor orangeColor]

@interface CSIIMenuViewController ()<ZXingDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,DecoderDelegate,VerificationDelegate,CustomAlertViewDelegate>
{
    
    OpenMode _mode;//当前的mode
    
    UILabel *menuTitle;
    UIImageView *titlebg;
    
    NSMutableArray *menuArray;
    NSMutableArray *iconButtonArray;
    NSMutableArray *iconLabelArray;
    NSMutableArray *iconLightArray;
    
    NSArray* _defaultMenu;
    NSString* _favouriteKey;
    NSMutableArray* _favouriteMenu;
    
    UIScrollView*menuView;
    NSMutableDictionary *recevieData;
    NSMutableArray *displayArray;
    NSMutableDictionary* actionList;
    CSIIMenuPaging* paging;
    UIView *bottomMenuView;
    //NSMutableArray* favouriteArray;
    NSString *entryType;//类型
    BOOL isEdit;
    int currentPage;
    UIButton *doneButton;
    NSURL *url;
    NSString *transName;
    NSString *checkPrdId;
//    CustomAlertView *loginAlertView;
    //    NSMutableArray *barButtonItemArray;//底部toolbar的item
    UIViewController *nativeVC;
    BOOL isMachine;
    UIImage *changeValicodeBtnImage;
    
    BOOL _nextPage;
    
    NSUserDefaults *userDefault;
    BOOL footerViewFirstShow;
    NSString*IdPreAction;
    NSString*timeString;
    
    UIImageView*selectedBG;
    NSString*timeStamp;
    int theXBottomBtn;
    int deleteNumber;
    
    UIImagePickerController *picker;
    NSString * password;
    
    ZXingWidgetController*ZXingController;
    MarqueeLabel *adverLabel;   //公告的lab
    PublicContentView*pubView;//公告的类
    UIView*MarBg;
    UIImageView*PublicImg;
    
    UIButton *btn;
    NSMutableArray *detailArray;
    UIView *bgGongGaoview;
    UIView *_alertView;
    UILabel *_gonggaoTV;
    UILabel *titleLab;
    int clickNum;
    UIWindow *window;
    CSIIAdvertisementScrollView *advertiseScrollView;
    NSMutableArray*dataArray;
    UIView *guideBgView;
    UIViewController *bgViewController;//用于添加引导层和弹出公告的载体
    NSString*pushWebviewUrl;
    
}

@property(nonatomic,strong) UITableView *moreView;

@end


@implementation CSIIMenuViewController
@synthesize preBottomButtonActionId;
@synthesize isEdit;
@synthesize isloginActionSucceedBack;
@synthesize isClickMenuListTabMenuBack;
@synthesize rightBarItem;
@synthesize rightBarItemDone;

@synthesize currentActionId;
@synthesize nativeVC = nativeVC;

@synthesize toActionId;//下级actionid
@synthesize toActionName;//下级actionName
@synthesize toPrdId;//下级PrdId,同网银菜单中的PrdId一致
@synthesize toId;//下级Id,同网银菜单中的Id一致
@synthesize toClickable;
@synthesize toIslogin;
@synthesize toRoleCtr;
@synthesize toMenuArray;
@synthesize menuArrayIndex;
@synthesize menuSelectFlag;

- (id)init
{
    self = [super init];
    if (self) {
        [MobileBankSession sharedInstance].delegate = self;
        self.isloginActionSucceedBack = NO;
        self.isClickMenuListTabMenuBack = NO;
        currentActionId = ACTIONID_FOR_FINANCIALSERVICE; //设置程序启动后显示的首页对应的tab
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleLogout:) name:LOGOUT object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleFromVxSwitchToOtherMenuBranch:) name:@"FromWebSwitchToOtherMenuBranch" object:nil];
        
        menuArray = [[NSMutableArray alloc]initWithCapacity:3];
        //        barButtonItemArray = [[NSMutableArray alloc] init];
        detailArray = [[NSMutableArray alloc]init];
        picker = [[UIImagePickerController alloc] init];
        _publicArray = [[NSMutableArray alloc]init];
        dataArray = [[NSMutableArray alloc]init];
    }
    
    return self;
}

+(CSIIMenuViewController*)sharedInstance{
    static CSIIMenuViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSIIMenuViewController alloc] init];
    });
    return sharedInstance;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    window = [[UIApplication sharedApplication].windows objectAtIndex:0];

    AppDelegate * appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];//展示极光推送的消息
    NSDictionary *pushMessage = appDelegate.remoteNotification;
    appDelegate.remoteNotification = nil;
    if ([pushMessage allKeys].count>0) {
        NSString *alertMessage = [[pushMessage objectForKey:@"aps"] objectForKey:@"alert"];
        if ([[pushMessage allKeys] containsObject:@"URL"]) {
            pushWebviewUrl = [pushMessage valueForKey:@"URL"];
            UIAlertView *alal = [[UIAlertView alloc]initWithTitle:@"提示" message:alertMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alal.tag = 1008;
            [alal show];
        }else
        {
            ShowAlertView(@"提示", alertMessage, nil, @"确定", nil);
        }
    }
    
    [self.view removeGestureRecognizer:self.Swipe];
    self.backgroundView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    self.backgroundView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    
    [MobileBankSession sharedInstance].menuViewSlectedTag = 0;
    
    [self initHeaderView];
    
    footerViewFirstShow = NO;
    self.isEdit = NO;
    
    iconButtonArray = [[NSMutableArray alloc]init];
    iconLabelArray = [[NSMutableArray alloc]init];
    iconLightArray =  [[NSMutableArray alloc]init];
    
    self.rightBarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBarItem.frame = CGRectMake(0 ,0 ,80/2 ,80/2 );
    self.rightBarItem.tag = 10;
    [self.rightBarItem setImage:[UIImage imageNamed:@"Navigation_isLogin.png"] forState:UIControlStateSelected];
    [self.rightBarItem setImage:[UIImage imageNamed:@"Navigation_login.png"] forState:UIControlStateNormal];
    [self.rightBarItem addTarget:self action:@selector(RightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightBarItemDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBarItemDone.frame = CGRectMake(0 ,0 ,80/2 ,80/2 );
    self.rightBarItemDone.tag = 11;
    self.rightBarItemDone.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.rightBarItemDone setTitle:@"完成" forState:UIControlStateNormal];
    [self.rightBarItemDone addTarget:self action:@selector(RightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.leftBarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftBarItem.frame = CGRectMake(0 ,0 ,80/2 ,80/2 );
    [self.leftBarItem setBackgroundImage:[UIImage imageNamed:@"Navigation_search.png"] forState:UIControlStateNormal];
    [self.leftBarItem setBackgroundImage:[UIImage imageNamed:@"Navigation_search.png"] forState:UIControlStateHighlighted];
    [self.leftBarItem addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView: self.leftBarItem];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self reLayoutView];
    
}

-(void)onReceiveMessage:(NSNotification *)note{
    
    NSMutableDictionary*data = [[NSMutableDictionary alloc]initWithDictionary:[note userInfo]];
    NSLog(@"接收到得推送消息数据：%@",data);
    
    ShowAlertView(@"提示", @"hehe", nil, @"确认", nil);
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.mobileBankSession.recentlyMenuGrade = 0;
    [self addbackgroundView];
    [super viewWillAppear:animated];
    
    NSString *logoName = nil;
    logoName = @"tittle_icon.png";
    _navilogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 81/2,64/2-5)];
    _navilogo.center = CGPointMake(ScreenWidth/2-55, 20);
    [_navilogo setImage:[UIImage imageNamed:logoName]];
    _navilogo.tag = 5000;
    [self.navigationController.navigationBar addSubview:_navilogo];

    [self createNavigationUI];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = @"常乐生活";
    
    [self.navigationController.navigationBar addSubview:_titleLab];
}
-(void)createNavigationUI
{
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView: self.rightBarItem];
    self.navigationItem.rightBarButtonItem = rightItem;
        if ([MobileBankSession sharedInstance].isLogin) {
        self.rightBarItem.selected = YES;
    }else{
        self.rightBarItem.selected = NO;
    }

}
#pragma mark - Private Method
- (void)initHeaderView
{

    
    self.pubView = [[PublicContentView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    self.pubView.contentArray = _publicArray;
    if (self.pubView.contentArray.count>0) {
        
        MarBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        MarBg.backgroundColor = [UIColor clearColor];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        view.backgroundColor = [UIColor blackColor];
        [MarBg addSubview:view];
        view.alpha = 0.6f;
        MarBg.userInteractionEnabled = YES;
        [self.view addSubview:MarBg];
        _isLoadPubview = YES;
        
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 120)];
        
        PublicImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 4, 26/2, 24/2)];
        PublicImg.backgroundColor = [UIColor clearColor];
        PublicImg.image = [UIImage imageNamed:@"Public.png"];
        [MarBg addSubview:PublicImg];
    }
    else{
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 120)];
    }
    
    advertiseScrollView = [[CSIIAdvertisementScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 120)];
    advertiseScrollView.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:advertiseScrollView];
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"QueryAdvertInfo.do" actionParams:nil method:@"POST"];
    [self.view addSubview:_headerView];
    
    [self addbackgroundView];
    
    self.pubView.userInteractionEnabled = YES;
    self.pubView.backgroundColor = [UIColor clearColor];
    [MarBg addSubview:self.pubView];
    [self.view bringSubviewToFront:MarBg];
    NSString*text = @"";
    
    for (int x=0; x<self.pubView.contentArray.count; x++) {
        
        text = [text stringByAppendingFormat:@"%@:%@              ",[self.pubView.contentArray[x]objectForKey:@"TITLE"],[self.pubView.contentArray[x]objectForKey:@"CONTENT"]];
        
        if ([[self.pubView.contentArray[x]objectForKey:@"ISURGENT"]isEqualToString:@"true"]) {    //紧急公告
            [detailArray addObject:self.pubView.contentArray[x]];
        }
    }
    bgViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

    if ([Context getNSUserDefaultskeyStr:@"firstMenuGuide"].length==0) {
        guideBgView = [[UIView alloc]initWithFrame:bgViewController.view.frame];
        UIImageView *guideImageView = [[UIImageView alloc]initWithFrame:guideBgView.frame];
        if (ScreenHeight==480) {
            guideImageView.image = [UIImage imageNamed:@"guideMenuImage960.png"];
        }else{
            guideImageView.image = [UIImage imageNamed:@"guideMenuImage1136.png"];
        }
        [guideBgView addSubview:guideImageView];
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeGuideView:)];
        [guideBgView addGestureRecognizer:tgr];
//        [bgViewController.view addSubview:guideBgView];//添加引导页
    }
    if (detailArray.count>0) {
        [self createGongGaoView];
    }
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth-280, ScreenHeight-72-280, 250, 250)];
    backgroundImageView.image = [UIImage imageNamed:@"watermark.png"];//水印
    backgroundImageView.userInteractionEnabled = YES;
    [self.view addSubview:backgroundImageView];
}
-(void)removeGuideView:(UITapGestureRecognizer *)tgr
{
    [Context setNSUserDefaults:@"isFirstMenuGuide" keyStr:@"firstMenuGuide"];
    [guideBgView removeFromSuperview];
}
-(void)reLayoutView{
    self.navigationController.navigationBarHidden=NO;
    self.leftButton.hidden = YES;
    
    if(self.isloginActionSucceedBack==YES && menuSelectFlag==ESelectMenu && toActionId!=nil && ![toActionId isEqualToString:ACTIONID_FOR_EXIT])
    {
        self.isloginActionSucceedBack = NO;
        menuSelectFlag = ESelectNone;
        
        [MobileBankSession sharedInstance].delegate = self;
        [[MobileBankSession sharedInstance] menuStartAction:[menuArray objectAtIndex:menuArrayIndex]];
        return;
    }
    else{
        self.isloginActionSucceedBack = NO;
        menuSelectFlag = ESelectNone;
    }
    
    
    if (self.isClickMenuListTabMenuBack==YES && [currentActionId isEqualToString:ACTIONID_FOR_MOBILEBANK] && [MobileBankSession sharedInstance].isLogin == NO)
    {
        menuSelectFlag = ESelectTabMenu;
        [MobileBankSession sharedInstance].delegate = self;
        [[MobileBankSession sharedInstance] menuStartAction:[displayArray objectAtIndex:1]];
        //        return;
    }
    else{
        self.isClickMenuListTabMenuBack = NO;
    }
    
    isEdit = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isEdit = NO;
    self.isLoadPubview = NO;
}


#pragma mark -
-(void)removeIconsAndLabels{
    
    [iconButtonArray removeAllObjects];
    [iconLabelArray removeAllObjects];
    [iconLightArray removeAllObjects];
    menuTitle.text = @"";
}

-(void)addbackgroundView{             //在这个方法里添加菜单
    
    [menuArray removeAllObjects];
    //菜单view
    if (menuView) {
        [menuView removeFromSuperview];
    }
    
    if (self.pubView.contentArray.count>0) {
            menuView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height-44-120-30-MAIN_MENU_BUTTON_HEIGHT)];
    }
    else{
        menuView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height-44-120-20-MAIN_MENU_BUTTON_HEIGHT)];
    }
//    menuView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height-44-120-20-MAIN_MENU_BUTTON_HEIGHT)];
    menuView.delegate = self;
    
    menuView.contentSize = CGSizeMake(ScreenWidth*4, [[UIScreen mainScreen] bounds].size.height-44-20-MAIN_MENU_BUTTON_HEIGHT-271/2);
    menuView.bounces = NO;
    menuView.backgroundColor = [UIColor clearColor];
    menuView.pagingEnabled = YES;
    menuView.showsHorizontalScrollIndicator = NO;
    menuView.showsVerticalScrollIndicator = NO;
    menuView.userInteractionEnabled = YES;
    [self.view addSubview:menuView];
    
    
    for (int x = 0; x<[displayArray count]; x++) {
        
        actionList = [displayArray objectAtIndex:x];
        
        self.currentActionId = [actionList objectForKey:MENU_ACTION_ID];
        
        NSArray* temp = [actionList objectForKey:MENU_LIST];
        NSMutableArray *muarray = [[NSMutableArray alloc]initWithArray:temp];
        
//        for (int i=0; i<muarray.count; i++) {
//            if ([[[muarray objectAtIndex:i]objectForKey:@"IsShow"]isEqualToString:@"false"]) {
//                [muarray removeObjectAtIndex:i];//删除需要隐藏的菜单
//            }
//        }
        
        if([[actionList objectForKey:MENU_ACTION_ID] isEqualToString:ACTIONID_FOR_MYFAVOURITE])
            if (x==0)
            {
                NSMutableArray *array = [[NSUserDefaults standardUserDefaults]objectForKey:kAddedMenu];
                
                for (int i=0; i<array.count; i++) {
                    [muarray insertObject:array[i] atIndex:muarray.count-1];
                }
            }
        
            for (int x = 0; x<muarray.count; x++) {
                if ([[[muarray objectAtIndex:x]objectForKey:MENU_ACTION_ID]isEqualToString:@"20000171"]) {
                    [muarray removeObjectAtIndex:x];//iOS删除IC卡圈存
                }
            }
        
        [menuArray addObject:muarray];
        
        if (self.pubView.contentArray.count>0) {
            paging = [[CSIIMenuPaging alloc]initWithFrame:CGRectMake(ScreenWidth*x, 0, menuView.frame.size.width, ScreenHeight-20-44-120-57-20) WithIconArray:[muarray mutableCopy] pageDelegate:self iconButtonArray:iconButtonArray iconLabelArray:iconLabelArray iconLightArray:iconLightArray];
        }
        else{
            paging = [[CSIIMenuPaging alloc]initWithFrame:CGRectMake(ScreenWidth*x, 0, menuView.frame.size.width, ScreenHeight-20-44-120-57) WithIconArray:[muarray mutableCopy] pageDelegate:self iconButtonArray:iconButtonArray iconLabelArray:iconLabelArray iconLightArray:iconLightArray];
        }
        paging.scrollView.scrollView.contentSize = CGSizeMake(ScreenWidth,((muarray.count-1)/4+1)*102);
        paging.scrollView.scrollView.pagingEnabled = NO;
        [menuView addSubview:paging];
        
    }

    int index = self.mobileBankSession.menuViewSlectedTag;
    menuView.contentOffset = CGPointMake(index * ScreenWidth, menuView.contentOffset.y);
    
}
-(void)displayMenu{
    
}

-(void)setMenuArray:(NSArray*)array{
 
    displayArray = [[NSMutableArray alloc]initWithArray:array];
}

-(NSArray*)getMenuArray{
    
    return displayArray;
}

-(void)setcurrentActionId:(NSString*)actionId
{
    currentActionId = actionId;
}
-(NSString*)getcurrentActionId
{
    return currentActionId;
}



#pragma mark - 会话模块--打开下级页面方式

-(void)OpenNextView:(OpenMode)mode{
    
    DebugLog(@"CSIIMenuViewController, OpenNextView, mode = %d",mode);
    _mode = mode;
    /*获取手势密码 判断是否为空*/
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];
    
    switch (mode) {
        case ENoAuthority:
        {
            if(![currentActionId isEqualToString:ACTIONID_FOR_MOBILEBANK]){
                self.preBottomButtonActionId = [NSString stringWithString:currentActionId];
                currentActionId = ACTIONID_FOR_MOBILEBANK;
            }
            if (menuSelectFlag == ESelectMenu) {
            }else if(menuSelectFlag == ESelectTabMenu){
                [self reLayoutView];
            }
        }
            break;
        case ENativeList:
        {
            if(menuSelectFlag==ESelectTabMenu)
            {
                //                [self removeIconsAndLabels];
                [self displayMenu];
                isEdit = NO;
            }
            else if (menuSelectFlag==ESelectMenu)
            {
                if (toMenuArray!=nil && toMenuArray.count>0)
                {
                    //有下一级菜单
                    CSIIMenuListViewController *vc = [[CSIIMenuListViewController alloc]initWithDisplayList:toMenuArray actionId:toActionId actionName:toActionName];
                    self.mobileBankSession.recentlyMenuGrade += 1;
                    vc.rightBarItem = self.rightBarItem;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            
            menuSelectFlag = ESelectNone;
        }
            break;
        case ENative:
        {
            if ([toIslogin isEqualToString:@"true"]&&[MobileBankSession sharedInstance].isLogin == NO) {
                //被动登录  手势或者手机号登录
                               if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码
                    //时间过期提示
                    [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {//[Context getNSUserDefaultskeyStr:@"LastLoginTime"]
                        if ([[MobileBankSession sharedInstance]last:[Context getNSUserDefaultskeyStr:@"LastLoginTime"] now:[data objectForKey:@"_sysDate"]]>30*24) {
                            
                            [GesturePasswordController clear];
                            //                            [Context setNSUserDefaults:@"yes" keyStr:@"isFirstLogin"];
                            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手势密码过期，请使用其他方式登录" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                            alert.tag = 123;
                            [alert show];
                            
                        }else{
                            self.loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                            [self.loginAlertView show];
                        }
                    }];
                    
                }else
                    [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                return;
            }
            
            if ([toActionId isEqualToString:@"20000121"]) {//二维码转账
                if (IOS7_OR_LATER) {//扫一扫
                    NSString *mediaType = AVMediaTypeVideo;
                    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                        ShowAlertView(@"提示", @"此应用没有权限来访问您的相机,请在设备的'设置-隐私-相机'中启用访问", nil, @"确认", nil);
                        return;
                    }
                }
                ZXingWidgetController *widController = [[ZXingWidgetController alloc]initWithDelegate:self showCancel:YES OneDMode:NO showLicense:NO];
                NSMutableSet *readers = [[NSMutableSet alloc] init];
                QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
                [readers addObject:qrcodeReader];
                widController.readers = readers;
                
                [self presentViewController:widController animated:NO completion:^{}];
                return;
            }

            
            nativeVC = [self getNativeViewControllerWithActionId:toActionId prdId:toPrdId Id:toId];

            if(nativeVC!=nil){
                
                NSString *postActionName = [[NSString alloc] init];
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                
                if ([toActionId isEqualToString:@"3000012"]) {     //网点查询
                    
                    CommercialSearchViewController*buss = (CommercialSearchViewController*)nativeVC;
                    [self.navigationController pushViewController:buss animated:YES];
                    return;
                }else if ([toActionId isEqualToString:@"20000172"]) {//金融日历
                    BusinessCalendarViewController*vc = [[BusinessCalendarViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                    [MobileBankSession sharedInstance].toPassiveControllerString = @"BusinessCalendarViewController";
                    return;
                }else if ([toActionId isEqualToString:@"5000013"])//我要吐槽
                {
                    myCommentViewController *comment = [[myCommentViewController alloc]init];
                    [self.navigationController pushViewController:comment animated:YES];
                    [MobileBankSession sharedInstance].toPassiveControllerString = @"myCommentViewController";

                    return;
                }
                self.mobileBankSession.delegate = self;
                [self.mobileBankSession postToServer:postActionName actionParams:param method:@"POST"];
                
                menuSelectFlag = ESelectNone;
            }
        }
            break;
        case EWeburl:
        {
                if ([toIslogin isEqualToString:@"true"]&&[MobileBankSession sharedInstance].isLogin == NO) {
                    //被动登录  手势或者手机号登录(表示进入需要登录的界面且还没有登录)
                    
                    if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码
                        //时间过期提示
                        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {//[Context getNSUserDefaultskeyStr:@"LastLoginTime"]
                            if ([[MobileBankSession sharedInstance]last:[Context getNSUserDefaultskeyStr:@"LastLoginTime"] now:[data objectForKey:@"_sysDate"]]>30*24) {
                                
                                [GesturePasswordController clear];
                                //                            [Context setNSUserDefaults:@"yes" keyStr:@"isFirstLogin"];
                                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手势密码过期，请使用其他方式登录" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                                alert.tag = 123;
                                [alert show];
                                
                            }else{
//                                loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                                self.loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                                 [self.loginAlertView show];
                            }
                        }];
                    }else{
                        [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                        [self gestureExit:nil];
                    }
                    
                    return;
                }
                
                if ([toIslogin isEqualToString:@"true"]&&[MobileBankSession sharedInstance].isLogin == YES) {
                    if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"] length]==0||[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"]isEqualToString:@""]) {
                        NSArray *AcArray = [[NSArray alloc]initWithArray:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"AcList"]];
                        for (int i=0; i<AcArray.count; i++) {
                            if (![[AcArray[i] objectForKey:@"AcType"]isEqualToString:@"4"]) {
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您尚未设置主账户，请先设置主账户" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                                alert.tag = 334;
                                [alert show];
                                return;
                            }
                        }

                    }
                }
                
                [[WebViewController sharedInstance] setActionId:toActionId actionName:toActionName prdId:toPrdId Id:toId];
                [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:NO];
//                [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:NO];
                
                [self.navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
                
                menuSelectFlag = ESelectNone;
            }
            break;
            
        case EDisabled:
        {
            ShowAlertView(@"提示", @"即将推出，敬请期待", nil, @"确认", nil);
        }
            break;
            
        case EOpenurl:
        {
            if ([toIslogin isEqualToString:@"true"]&&[MobileBankSession sharedInstance].isLogin == NO) {
                //被动登录  手势或者手机号登录(表示进入需要登录的界面且还没有登录)
                
                if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码
                    //时间过期提示
                    [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {//[Context getNSUserDefaultskeyStr:@"LastLoginTime"]
                        if ([[MobileBankSession sharedInstance]last:[Context getNSUserDefaultskeyStr:@"LastLoginTime"] now:[data objectForKey:@"_sysDate"]]>30*24) {
                            
                            [GesturePasswordController clear];
                            //                            [Context setNSUserDefaults:@"yes" keyStr:@"isFirstLogin"];
                            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手势密码过期，请使用其他方式登录" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                            alert.tag = 123;
                            [alert show];
                            
                        }else{
                            //                                loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                            self.loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                            [self.loginAlertView show];
                        }
                    }];
                }else
                    [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                [MobileBankSession sharedInstance].isOpenUrlBack=YES;
                return;
            }
            
            [MobileBankSession sharedInstance].delegate = self;
            [MobileBankSession sharedInstance].isOpenUrlBack =YES;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:toActionId forKey:@"ActionId"];
            if ([MobileBankSession sharedInstance].isLogin) {
                [dic setObject:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"] forKey:@"MobileNum"];
            }else
            {
                [dic setObject:@"" forKey:@"MobileNum"];
            }
            [[MobileBankSession sharedInstance]postToServer:@"MenuUrlQry.do" actionParams:dic method:@"POST"];
        }
            break;
        default:
            break;
    }
}


#pragma mark - add Bottom Tab Menus


-(void)addButtonAction:(id)sender
{
    NSLog(@"添加按钮Menu的实现");
    if (self.isEdit) {
        return;
    }
    NSMutableArray*tempArray = [NSMutableArray arrayWithArray:displayArray];
    [tempArray removeObjectAtIndex:0];
    NSMutableArray *array11 = [[NSMutableArray alloc]init];
    for(int i=0;i<tempArray.count;i++)
    {
        if ([[tempArray objectAtIndex:i] objectForKey:MENU_LIST]!=nil
            && ((NSArray*)[[tempArray objectAtIndex:i] objectForKey:MENU_LIST]).count>0)//说明有下一级菜单
        {
            //            [array11 addObject:[[tempArray objectAtIndex:i] objectForKey:MENU_LIST]];
            [array11 addObjectsFromArray:[[tempArray objectAtIndex:i] objectForKey:MENU_LIST]];
            
        }
    }
    CSIIAddMenuViewController *addController = [[CSIIAddMenuViewController alloc]initWithDisplayList:array11];
    addController.firstMenuDic = displayArray[0];
    [self.navigationController pushViewController:addController animated:YES];
}

#pragma mark - bottom Button action Tab菜单按钮动作
-(void)bottomButtonAction:(UIButton *)sender
{
    if (sender.tag==1002) {
        sender.tag = [MobileBankSession sharedInstance].menuViewMidTag;
        for(UIView *view in self.barButtonItemArray)
        {
            if([view isKindOfClass:[UIButton class]] && (UIButton*)view != sender)
            {
                if (((UIButton*)view).tag==sender.tag) {
                    ((UIButton*)view).selected = YES;
                    self.saoYisaoBtn.selected = NO;
                };
            }
        }
        return;
    }
    //    theXBottomBtn = sender.tag;
    
    // 移动选中视图的位置
    if (sender.tag>=2&&sender.tag<4) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        selectedBG.frame = CGRectMake(64 * (sender.tag+1), 0, 64, 40);
        menuView.contentOffset = CGPointMake(ScreenWidth* (sender.tag), 0);
        [UIView commitAnimations];
        
        //选中按钮的标示
        [MobileBankSession sharedInstance].menuViewSlectedTag = (int)sender.tag;
        [MobileBankSession sharedInstance].menuViewMidTag = (int)sender.tag;
        sender.selected = YES;
        
        for(UIView *view in self.barButtonItemArray)
        {
            if([view isKindOfClass:[UIButton class]] && (UIButton*)view != sender)
            {
                ((UIButton*)view).selected = NO;
                self.saoYisaoBtn.selected = NO;
            }
        }
    }else if (sender.tag==4)
    {
        if (self.isEdit) {
            return;
        }
        
        double firstAction=[[[NSUserDefaults standardUserDefaults]objectForKey:@"popTime"]doubleValue];
        double seconed=[self getCurrentTime];
        double offset=seconed-firstAction;
        
        DebugLog(@"%f %f %f",firstAction,seconed,offset);
        if (offset<1000 && offset!=0) {//解决连续点击菜单多次弹出手势密码的bug
            return;
        }

        
        [MobileBankSession sharedInstance].menuViewMidTag = [MobileBankSession sharedInstance].menuViewSlectedTag;
        [MobileBankSession sharedInstance].menuViewSlectedTag = (int)sender.tag;

//        NSString* Clickable = [menuDictionary objectForKey:@"Clickable"];
//        NSArray* menuList = [menuDictionary objectForKey:@"MenuList"];
//        NSString* entryType = [menuDictionary objectForKey:@"EntryType"];
//        NSString*RoleCtr = [menuDictionary objectForKey:@"RoleCtr"];
        
        for(UIView *view in self.barButtonItemArray)
        {
            if([view isKindOfClass:[UIButton class]] && (UIButton*)view != sender)
            {
                ((UIButton*)view).selected = NO;
            }
        }
//        sender.selected = YES;
        toClickable = @"true";
        toIslogin = @"true";
        toActionId = @"MyAcInfo";
        toActionName = @"我的账户";
        [MobileBankSession sharedInstance].UserAnalysisActionId = toActionId;//行为轨迹分析
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:@"MyAcInfo" forKey:MENU_ACTION_ID];
        [dic setObject:@"我的账户" forKey:MENU_ACTION_NAME];
        [dic setObject:@"true" forKey:MENU_ACTION_CLICKABLE];
        [dic setObject:@"true" forKey:MENU_ACTION_ISLOGIN];
        [dic setObject:@"web" forKey:@"EntryType"];
        [dic setObject:@"P" forKey:MENU_ACTION_ROLECTR];
        [MobileBankSession sharedInstance].delegate = self;
        [MobileBankSession sharedInstance].isPassiveLoginDelegate = self;
        [[MobileBankSession sharedInstance] menuStartAction:dic];
//        for(UIView *view in self.barButtonItemArray)
//        {
//            if ([view isKindOfClass:[UIButton class]]) {
//                ((UIButton*)view).selected = NO;
//            }
//        }
//        sender.selected = YES;
////
//        return;
        sender.selected = YES;
        
        for(UIView *view in self.barButtonItemArray)
        {
            if([view isKindOfClass:[UIButton class]] && (UIButton*)view != sender)
            {
                ((UIButton*)view).selected = NO;
            }
        }
    }
    else
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        selectedBG.frame = CGRectMake(64 * sender.tag, 0, 64, 40);
        menuView.contentOffset = CGPointMake(ScreenWidth* sender.tag, 0);
        [UIView commitAnimations];
        
        //选中按钮的标示
        [MobileBankSession sharedInstance].menuViewSlectedTag = (int)sender.tag;
        [MobileBankSession sharedInstance].menuViewMidTag = (int)sender.tag;
        
        sender.selected = YES;
        
        for(UIView *view in self.barButtonItemArray)
        {
            if([view isKindOfClass:[UIButton class]] && (UIButton*)view != sender)
            {
                ((UIButton*)view).selected = NO;
                self.saoYisaoBtn.selected = NO;
            }
        }
    }
    
    //  NSString *curActionId = [self getActionId:sender.tag array:displayArray];
    
    
}



- (void)leftButtonAction:(id)sender
{
    
    double firstAction=[[[NSUserDefaults standardUserDefaults]objectForKey:@"popTime"]doubleValue];
    double seconed=[self getCurrentTime];
    double offset=seconed-firstAction;
    DebugLog(@"%f %f %f",firstAction,seconed,offset);
    if (offset<1000 && offset!=0) {//解决连续点击菜单多次弹出手势密码的bug
        return;
    }
    SearchViewController*search = [[SearchViewController alloc]init];
    [MobileBankSession sharedInstance].toPassiveControllerString = @"SearchViewController";
    search.displayMenuArray = displayArray;
    [self.navigationController pushViewController:search animated:YES];
}

- (void)RightButtonAction:(UIButton *)sender {
    if (sender.tag == 10) {//登录
        [MobileBankSession sharedInstance].isPassiveLogin = NO;
        [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
    }
    else if (sender.tag == 11){
        self.isEdit = NO;//完成
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView: self.rightBarItem];
        self.navigationItem.rightBarButtonItem = rightItem;
        [self addbackgroundView];
        self.leftBarItem.hidden = NO;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == menuView) {
        self.saoYisaoBtn.selected = NO;
        NSInteger index = menuView.contentOffset.x / menuView.frame.size.width;
        //选中按钮的标示
        [MobileBankSession sharedInstance].menuViewSlectedTag = (int)index;
        [MobileBankSession sharedInstance].menuViewMidTag = (int)index;

        NSInteger i = 0;
        for (UIButton* button in self.barButtonItemArray) {
            button.selected = i==index;
            i++;
        }
        
        // 移动选中视图的位置
        //        [UIView beginAnimations:nil context:NULL];
        //        selectedBG.frame = CGRectMake(80 * index, 0, 80, 51);
        //        [UIView commitAnimations];
        
    }
}

- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index {
    return UIViewContentModeScaleAspectFill;
}
-(double )getCurrentTime{
    
    NSTimeInterval firstTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    double a=firstTime;
    
    [[NSUserDefaults  standardUserDefaults] setObject:[NSNumber numberWithDouble:a] forKey:@"popTime"];
    
    return a;
}

#pragma mark - menu button action 菜单按钮动作
-(void)menuButtonAction:(UIButton*)button{
    DebugLog(@"menuButtonAction");
    self.mobileBankSession.isMenuListViewController = NO;
    
    if (self.isEdit) {
        return;
    }
    double firstAction=[[[NSUserDefaults standardUserDefaults]objectForKey:@"popTime"]doubleValue];
    double seconed=[self getCurrentTime];
    double offset=seconed-firstAction;
    
    DebugLog(@"%f %f %f",firstAction,seconed,offset);
    if (offset<1000 && offset!=0) {//解决连续点击菜单多次弹出手势密码的bug
        return;
    }
    NSInteger index = self.mobileBankSession.menuViewSlectedTag ;
    
    menuSelectFlag = ESelectMenu;
    toActionId = [self getActionId:button.tag array:menuArray[index]];
    [MobileBankSession sharedInstance].UserAnalysisActionId = toActionId;//行为轨迹分析

    toClickable = [self getClickable:button.tag array:menuArray[index]];
    toIslogin = [self getIsLogin:button.tag array:menuArray[index]];
    toRoleCtr = [self getRoleCtr:button.tag array:menuArray[index]];
    toActionName = [self getActionName:button.tag array:menuArray[index]];
    toPrdId = [self getPrdId:button.tag array:menuArray[index]];
    toId = [[menuArray[index] objectAtIndex:button.tag] objectForKey:MENU_ID];
    toMenuArray = [[menuArray[index] objectAtIndex:button.tag] objectForKey:MENU_LIST];
    
    menuArrayIndex = button.tag;
    
    if([toActionId isEqualToString:ACTIONID_FOR_EXIT])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否退出登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = 888;
        [alertView show];
    }else
    {
        [MobileBankSession sharedInstance].delegate = self;
        [MobileBankSession sharedInstance].isPassiveLoginDelegate = self;
        [[MobileBankSession sharedInstance] menuStartAction:[menuArray[index] objectAtIndex:button.tag]];
    }
    
}




//长按删除手势
-(void)longPressDelete:(UILongPressGestureRecognizer *)lpgr
{
    for (int i=0; i<4; i++) {
        if (lpgr.view.tag == i) {
            return;
        }
    }
    if (lpgr.state ==UIGestureRecognizerStateBegan) {
        [self showEditButton];
        self.leftBarItem.hidden = YES;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView: self.rightBarItemDone];
        self.navigationItem.rightBarButtonItem = rightItem;
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 123) {
        [MobileBankSession sharedInstance].isPassiveLogin = YES;
        [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
    }
    if (alertView.tag ==334) {
        if (buttonIndex==0) {//主账户设置
            [[WebViewController sharedInstance]setActionId:@"PAccountSet" actionName:@"我的主账户设置" prdId:@"PAccountSet" Id:@"PAccountSet"];
            //            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
        }
    }
    if (alertView.tag==801) {
        if (buttonIndex==0) {
            [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil] ;
        }
    }
    if (alertView.tag ==1008) {
        if (buttonIndex==1) {
            AdvertisementViewController *pushController = [[AdvertisementViewController alloc]init];
            pushController.webTitleName = @"常熟农商银行";
            pushController.webUrl = pushWebviewUrl;
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:pushController animated:YES];
        }
    }
}
-(NSString*)getActionName:(NSInteger)index array:(NSArray*)array{
    
    NSString*  actionName = [[array objectAtIndex:index] objectForKey:MENU_ACTION_NAME];
    NSLog(@"actionname = %@",actionName);
    if (actionName) {
        return actionName;
    }
    return nil;
}

-(NSString*)getActionId:(NSInteger)index array:(NSArray*)array{
    NSString* actionId = [[array objectAtIndex:index] objectForKey:MENU_ACTION_ID];
    NSLog(@"actionid = %@",actionId);
    if (actionId) {
        return actionId;
    }
    return nil;
}

-(NSString*)getClickable:(NSInteger)index array:(NSArray*)array{
    NSString* clickable = [[array objectAtIndex:index] objectForKey:MENU_ACTION_CLICKABLE];
    NSLog(@"clickable = %@",clickable);
    if (clickable) {
        return clickable;
    }
    return nil;
}

-(NSString*)getIsLogin:(NSInteger)index array:(NSArray*)array{
    NSString* IsLogin = [[array objectAtIndex:index] objectForKey:MENU_ACTION_ISLOGIN];
    NSLog(@"IsLogin = %@",IsLogin);
    if (IsLogin) {
        return IsLogin;
    }
    return nil;
}

-(NSString*)getRoleCtr:(NSInteger)index array:(NSArray*)array{
    NSString* RoleCtr = [[array objectAtIndex:index] objectForKey:MENU_ACTION_ROLECTR];
    NSLog(@"clickable = %@",RoleCtr);
    if (RoleCtr) {
        return RoleCtr;
    }
    return nil;
}

-(NSString*)getPrdId:(NSInteger)index array:(NSArray*)array{
    NSString* prdId = [[array objectAtIndex:index] objectForKey:MENU_PRD_ID];
    NSLog(@"prdId = %@",prdId);
    if (prdId) {
        return prdId;
    }
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isMyFavoriteFixedMenu:(NSDictionary *)menuDic
{
    //    NSArray *myFavoriteMenuArr = [[displayArray objectAtIndex:2] objectForKey:MENU_LIST];
    
    NSArray *myFavoriteMenuArr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddedMenu];
    
    for(int i=0; i<myFavoriteMenuArr.count;i++)
    {
        if([[menuDic objectForKey:MENU_ACTION_NAME] isEqualToString:[[myFavoriteMenuArr objectAtIndex:i] objectForKey:MENU_ACTION_NAME]])
        {
            return  YES;
        }
    }
    
    return NO;
}

-(void)delAddedMenu:(NSDictionary *)menuDic
{
    
    NSMutableArray *addedMenuArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kAddedMenu]];
    
    for(int i=0; i<addedMenuArray.count;i++)
    {
        if([[menuDic objectForKey:MENU_ACTION_NAME] isEqualToString:[[addedMenuArray objectAtIndex:i] objectForKey:MENU_ACTION_NAME]])
        {
            [addedMenuArray removeObjectAtIndex:i];
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:addedMenuArray forKey:kAddedMenu];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)showEditButton
{
    self.isEdit = YES;
    
    [self addbackgroundView];
    
    //    for (int i = 0; i<((NSArray*)[menuArray objectAtIndex:0]).count; i++) {
    //
    //        if([self isMyFavoriteFixedMenu:[[menuArray objectAtIndex:0] objectAtIndex:i]] == YES)
    //        {
    ////            paging.delButton.hidden = NO;
    //        }
    //    }
}

- (void)delButtonAction:(UIButton*)sender{
    
    [UIView animateWithDuration:0.1 animations:^{
        sender.superview.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [self delAddedMenu:[menuArray[0] objectAtIndex:sender.tag]];;
        
        NSArray *addedMenuArr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddedMenu];
        if (addedMenuArr.count==0) {
            [doneButton removeFromSuperview];
            doneButton = nil;
            self.isEdit = NO;
            [self addbackgroundView];
            return ;
        }
        if (self.isEdit) {
            [self showEditButton];
        }
        
    }];
    
}

-(void)compareWithOnlineMenu:(NSArray*)onlineMenuArr addedMenu:(NSMutableArray*)addedMenuArr foundMenu:(NSMutableArray*)foundMenuArr savedMenuCount:(const NSInteger)savedMenuCount
{
    for (int i = 0; i<onlineMenuArr.count; i++)
    {
        if ([onlineMenuArr[i] objectForKey:MENU_LIST]!=nil
            && ((NSArray*)[onlineMenuArr[i] objectForKey:MENU_LIST]).count>0)
        {
            //有下一级菜单
            [self compareWithOnlineMenu:[onlineMenuArr[i] objectForKey:MENU_LIST] addedMenu:addedMenuArr foundMenu:foundMenuArr savedMenuCount:savedMenuCount];
            
            if (foundMenuArr.count == savedMenuCount)
                return;
        }
        else
        {
            for(int k=0; k<addedMenuArr.count; k++)
            {
                if([(NSDictionary*)onlineMenuArr[i] isEqualToDictionary:(NSDictionary*)addedMenuArr[k]])
                {
                    [foundMenuArr addObject:addedMenuArr[k]];
                    [addedMenuArr removeObjectAtIndex:k];
                    break;
                }
            }
            
            //保存的添加菜单都找到了，比较到此提前结束
            if (foundMenuArr.count == savedMenuCount)
                return;
        }
    }
    
}

#pragma mark - 私人订制
- (NSMutableArray *)getUserFavouriteMenu {
    return [[NSUserDefaults standardUserDefaults] objectForKey:_favouriteKey];
}

- (void)setUserFavouriteMenu:(NSArray *)menus {
    [[NSUserDefaults standardUserDefaults]setObject:menus forKey:_favouriteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addMenuItem {
    for (int i = 1; i < displayArray.count; i++) {
        NSArray* onelist = (displayArray[i])[@"MenuList"];
        for (int j = 0; j < onelist.count; j++) {
            NSArray* twoList = (onelist[j])[@"MenuList"];
            if (twoList.count < 1) {
                [self addMenuFromDict:onelist[j]];
            } else {
                for (int k = 0; k < twoList.count; k++) {
                    NSDictionary* twoDict = twoList[k];
                    [self addMenuFromDict:twoDict];
                }
            }
        }
    }
    [self.moreView reloadData];
}

- (void)addMenuFromDict:(NSDictionary *)item {
    NSString* title =  item[@"ActionImage"];
    if ([title isEqualToItem:_defaultMenu]) {
        [_favouriteMenu addObject:item];
    }
}

#pragma mark - NSNotification Handle
-(void) handleLogout:(NSNotification*) notification
{
    //清空web内容
    if([WebViewController isSharedInstanceExist]){
        [[WebViewController sharedInstance] clearWebContent];
    }
    
#ifdef INNER_SERVER
    [self logoutSuccess];
#else
    [[MobileBankSession sharedInstance] postToServer:@"logout.do" actionParams:nil method:@"POST"];
    [MobileBankSession sharedInstance].delegate = self;
#endif
}

-(void)logoutSuccess
{
    DebugLog(@"#######-----logoutSuccess");
    [MobileBankSession sharedInstance].isLogin = NO;
    displayArray = [[MobileBankSession sharedInstance].unloginMenuData objectForKey:@"DisplayList"];
    //清除登录账户相关信息
    [Context sharedInstance].menuInfo_UserInfo_Hints = nil;
    
    if(![currentActionId isEqualToString:ACTIONID_FOR_MOBILEBANK]){
        self.preBottomButtonActionId = [NSString stringWithString:currentActionId];
        currentActionId = ACTIONID_FOR_MOBILEBANK;
    }
    
    DebugLog(@"#######-----push CSIILoginViewController");
}

-(void)handleFromVxSwitchToOtherMenuBranch:(NSNotification*)notification
{
    NSString *menuName = [[notification userInfo] objectForKey:@"MenuName"];
    
    NSMutableArray *onlineMenuArr = [[NSMutableArray alloc]init];
    for (int i = 1; i<displayArray.count; i++)
    {
        [onlineMenuArr addObject:displayArray[i]];
    }
    
    NSMutableArray *actionIdBranch = [[NSMutableArray alloc] init];
    NSDictionary *menuDict = [CSIIUtility findMenuByActionId:nil OrByActionName:menuName InMenuArray:onlineMenuArr ActionIdBranch:actionIdBranch];
    
    if(menuDict != nil)
    {
        //找到前往的最终菜单
        menuSelectFlag = ESelectMenu;
        toActionId = [menuDict objectForKey:MENU_ACTION_ID];
        toActionName = menuName;
        toPrdId = [menuDict objectForKey:MENU_PRD_ID];
        toId = [menuDict objectForKey:MENU_ID];
        toMenuArray = [menuDict objectForKey:MENU_LIST];
        
        if(actionIdBranch.count>0)
        {
            NSString *curActionId = [actionIdBranch[0] objectForKey:MENU_ACTION_ID];//一级菜单
            
            if(![curActionId isEqualToString:currentActionId]){
                self.preBottomButtonActionId = [NSString stringWithString:currentActionId];
                currentActionId = curActionId;
            }
        }
        
        if([toActionId isEqualToString:ACTIONID_FOR_EXIT])
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否退出登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alertView.tag = 888;
            [alertView show];
        }
        else
        {
            if (actionIdBranch.count==3 && toMenuArray!=nil && toMenuArray.count>0)
            {
                NSDictionary *menuDict_2 = [CSIIUtility findMenuByActionId:[actionIdBranch[1] objectForKey:MENU_ACTION_ID] OrByActionName:nil InMenuArray:onlineMenuArr ActionIdBranch:[[NSMutableArray alloc] init]];
                
                CSIIMenuListViewController *vc = [[CSIIMenuListViewController alloc]initWithDisplayList:[menuDict_2 objectForKey:MENU_LIST] actionId:[menuDict_2 objectForKey:MENU_ACTION_ID] actionName:[menuDict_2 objectForKey:MENU_ACTION_NAME]];
                self.mobileBankSession.recentlyMenuGrade += 1;
                [self.navigationController pushViewController:vc animated:NO];
                
            }
            else if (actionIdBranch.count==4 && toMenuArray!=nil && toMenuArray.count>0)
            {
                NSDictionary *menuDict_2 = [CSIIUtility findMenuByActionId:[actionIdBranch[1] objectForKey:MENU_ACTION_ID] OrByActionName:nil InMenuArray:onlineMenuArr ActionIdBranch:[[NSMutableArray alloc] init]];
                
                CSIIMenuListViewController *vc = [[CSIIMenuListViewController alloc]initWithDisplayList:[menuDict_2 objectForKey:MENU_LIST] actionId:[menuDict_2 objectForKey:MENU_ACTION_ID] actionName:[menuDict_2 objectForKey:MENU_ACTION_NAME]];
                self.mobileBankSession.recentlyMenuGrade += 1;
                [self.navigationController pushViewController:vc animated:NO];
                
                ////////////////////////////////////
                
                NSDictionary *menuDict_3 = [CSIIUtility findMenuByActionId:[actionIdBranch[2] objectForKey:MENU_ACTION_ID] OrByActionName:nil InMenuArray:onlineMenuArr ActionIdBranch:[[NSMutableArray alloc] init]];
                
                vc = [[CSIIMenuListViewController alloc]initWithDisplayList:[menuDict_3 objectForKey:MENU_LIST] actionId:[menuDict_3 objectForKey:MENU_ACTION_ID] actionName:[menuDict_3 objectForKey:MENU_ACTION_NAME]];
                self.mobileBankSession.recentlyMenuGrade += 1;
                [self.navigationController pushViewController:vc animated:NO];
            }
            
            [self.mobileBankSession menuStartAction:menuDict];
        }
        
    }
    
}

-(void)switchCurrentTab:(NSString*)aToActionId
{
    NSMutableArray *onlineMenuArr = [[NSMutableArray alloc]init];
    for (int i = 1; i<displayArray.count; i++)
    {
        [onlineMenuArr addObject:displayArray[i]];
    }
    
    NSMutableArray *actionIdBranch = [[NSMutableArray alloc] init];
    NSDictionary *menuDict = [CSIIUtility findMenuByActionId:aToActionId OrByActionName:nil InMenuArray:onlineMenuArr ActionIdBranch:actionIdBranch];
    
    if(menuDict != nil)
    {
        //找到前往的最终菜单
        
        if(actionIdBranch.count>0)
        {
            NSString *curActionId = [actionIdBranch[0] objectForKey:MENU_ACTION_ID];//一级菜单
            
            if(![curActionId isEqualToString:currentActionId]){
                self.preBottomButtonActionId = [NSString stringWithString:currentActionId];
                currentActionId = curActionId;
            }
        }
    }
}

#pragma mark - 接口
-(void)serviceCheckWithPrdId:(NSString*)prdId
{
    [[MobileBankSession sharedInstance] postToServer:@"ServiceCheck.do" actionParams:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prdId,@"PrdId", nil] method:@"POST"];
    [MobileBankSession sharedInstance].delegate = self;
}

#pragma mark - 跳转到原生页面
-(UIViewController*)getNativeViewControllerWithActionId:(NSString*)actionId prdId:(NSString*)prdId Id:(NSString*)Id
{
    UIViewController *vc = nil;
    NSLog(@"actionId = %@", actionId);
    
    if ([actionId isEqualToString:@"3000012"]) {//营业网点自助银行查询
        
        vc = [[CommercialSearchViewController alloc] init];
    }else if ([actionId isEqualToString:@"20000172"]){
        vc = [[BusinessCalendarViewController alloc] init];
    }else if ([actionId isEqualToString:@"5000013"]){
        vc = [[myCommentViewController alloc]init];
    }
    
    return vc;
}

#pragma mark ---------Gesturedelegation------------
- (BOOL)verification:(NSString *)result{
    /*获取手势密码 判断是否为空*/
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];

    if ([result isEqualToString:password]) {
        [self.loginAlertView.gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [self.loginAlertView.gesturePasswordView.state setText:@"输入正确"];
        
        self.loginAlertView.hidden = YES;
        
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
        [MobileBankSession sharedInstance].delegate  = self;
        [[MobileBankSession sharedInstance]postToServer:@"login.do" actionParams:postDic method:@"POST"];
        
        
        return YES;
    }
    
    if (result.length<4) {
        [self.loginAlertView.gesturePasswordView.tentacleView enterArgin];
        [self.loginAlertView.gesturePasswordView.state setTextColor:[UIColor redColor]];
        [self.loginAlertView.gesturePasswordView.state setText:@"最小长度为4，请重新输入"];
        return NO;
    }
    
    int Gesturecount = [[Context getNSUserDefaultskeyStr:@"Gesturecount"] intValue];
    Gesturecount++;
    if (Gesturecount<5) {
        [self.loginAlertView.gesturePasswordView.tentacleView enterArgin];
        [Context setNSUserDefaults:[NSString stringWithFormat:@"%d",Gesturecount] keyStr:@"Gesturecount"];
        [self.loginAlertView.gesturePasswordView.state setTextColor:[UIColor redColor]];
        [self.loginAlertView.gesturePasswordView.state setText:[NSString stringWithFormat:@"手势密码错误%d次，还剩%d次",Gesturecount,5-Gesturecount]];
    }else if (Gesturecount==5){
        self.loginAlertView.hidden = YES;
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您已输错5次，请使用手机号登录，如想继续使用手势密码，请登录成功后自行设置" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        alert.tag = 123;
        [alert show];
        [GesturePasswordController clear];
        [Context setNSUserDefaults:@"0" keyStr:@"Gesturecount"];
    }
    
    return NO;
}

#pragma mark - CustomAlertViewDelegate登陆方法
-(void) toggleRemember:(id) sender{
    
}

- (void) selfAssisstantLinkBtnPressedWithinAlertView:(CustomAlertView *)alert{
    //    [self selfAssistanLink];
    [alert hideAlertView];
}

- (void) resetPasswordBtnPressedWithinAlertView:(CustomAlertView *)alert{
    
    [alert hideAlertView];
}

- (void) loginBtnPressedWithinAlertView:(CustomAlertView *)alert{
    
    if (alert.passwordTF!=nil) {
        [alert.passwordTF resignFirstResponder];
    }
    
    if (alert.userNameTF.text == nil || [alert.userNameTF.text isEqualToString:@""]) {
        UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手机号码不能为空" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (alert.userNameTF.text.length<11||alert.userNameTF.text.length>11) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手机号码为11位数字" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    self.mobileBankSession.delegate = self;
    [self.mobileBankSession postToServer:@"TimestampJson.do" actionParams:nil method:@"POST"];
}

#pragma mark - MobileSessionDelegate 方法
-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    
    if ([action isEqualToString:@"newjson.txt"])
    {
            DebugLog(@"---%@",data);
        displayArray = [[NSMutableArray alloc]initWithArray:(NSArray *)data];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"APPInitDataFinish" object:nil];
    }
    else if ([action isEqualToString:@"CheckVersion.do"]|| [action isEqualToString:@"CheckVersion3.do"]||[action isEqualToString:@"SessionInit.do"])
    {
            DebugLog(@"---%@",data);
        displayArray = [[NSMutableArray alloc]initWithArray:(NSArray *)data];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"APPInitDataFinish" object:nil];
    }
    else if ([action isEqualToString:@"QueryAdvertInfo.do"])
    {
        dataArray = [data objectForKey:@"AdvertMap"];
        if (dataArray.count>0) {  //图片个数不为空
            NSMutableArray *adArray = [[NSMutableArray alloc]init];
            for (int x = 0; x<dataArray.count; x++) {
                
                NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
                [postDic setObject:[dataArray[x] objectForKey:@"ADVERTSEQ"] forKey:@"AdvertSeq"];
                CSIIUIAsyncImageView *asyncImageView = [[CSIIUIAsyncImageView alloc]initWithTransaction:CGRectMake(0.0, 0.0, 320, 120)
                                                                                          transactionId:@"AdvertContent.do"
                                                                                               argument:postDic
                                                                                       defaultImageName:@"bannerDefault"];
                asyncImageView.tag = x+1;
                UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickLabelEnter:)];
                [asyncImageView addGestureRecognizer:tgr];
                asyncImageView.frame = CGRectMake(x*_headerView.frame.size.width, 0, _headerView.frame.size.width, 120);
                [adArray addObject:asyncImageView];
                NSLog(@"____%@",[dataArray[x]objectForKey:@"IMAGENAME"]);
            }
            advertiseScrollView.pages = adArray;
        }

    }
    else if ([(NSString *)[data objectForKey:@"_RejCode"] isEqualToString:@"000000"]) {
        
        if([action isEqualToString:@"login.do"]){//登陆成功
            
            if ([[data objectForKey:@"_RejCode"] isEqualToString:@"000000"]) {//登陆成功
                
                [self createNavigationUI];
                
                [Context setNSUserDefaults:@"0" keyStr:@"Gesturecount"];
                [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
                    [Context setNSUserDefaults:[data objectForKey:@"_sysDate"] keyStr:@"LastLoginTime"];
                }];
                [MobileBankSession sharedInstance].Userinfo = [[NSMutableDictionary alloc]initWithDictionary:data];
                
                if ([[data objectForKey:@"IsBind"] isEqualToString:@"N"]) {
                    BindingEquipmentViewController *bindViewController = [[BindingEquipmentViewController alloc]init];
                    bindViewController.telephoneNum = [data objectForKey:@"MobileNo"];
                    [[CSIIMenuViewController sharedInstance].navigationController pushViewController:bindViewController animated:YES];
                    return;
                }
                
                
                if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"] length]==0||[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"]isEqualToString:@""]) {
                    NSArray *AcArray = [[NSArray alloc]initWithArray:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"AcList"]];
                    for (int i=0; i<AcArray.count; i++) {
                        if (![[AcArray[i] objectForKey:@"AcType"]isEqualToString:@"4"]) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您尚未设置主账户，请先设置主账户" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                            alert.tag = 334;
                            [alert show];
                            return;
                        }
                    }

                }
                
                self.mobileBankSession.isLogin = YES;
                if ([MobileBankSession sharedInstance].isSaoYiSao ==YES) {
                    [[WebViewController sharedInstance]setActionId:@"EwmTransfer" actionName:@"二维码转账" prdId:@"EwmTransfer" Id:@"EwmTransfer"];
                    [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:NO];
                    [self.navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
                    [MobileBankSession sharedInstance].isSaoYiSao = NO;
                    return;
                }
                //被动登陆成功后继续接着访问
                [self.mobileBankSession menuStartAction:nil];
            }
        }
        else if ([action isEqualToString:@"MenuUrlQry.do"])
        {
//            if ([toActionId isEqualToString:@"PPiontStore"]) {//粒金商城，里面还要判断是否登录
            if ([MobileBankSession sharedInstance].isOpenUrlBack==NO) {
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            }

                PiontStoreViewController *storeViewController = [[PiontStoreViewController alloc]init];
                storeViewController.webViewName = [menuArray[self.mobileBankSession.menuViewSlectedTag][menuArrayIndex] objectForKey:@"ActionName"];
            NSLog(@"%@",menuArray[self.mobileBankSession.menuViewSlectedTag][menuArrayIndex]);
//            storeViewController.adverWeb = NO;
            NSString *weburl = [data objectForKey:@"Url"];
            if ([weburl rangeOfString:@"_merchantId"].length>0) {//拉卡拉
                NSString* machineCode;
                if (IOS7_OR_LATER) {
                    machineCode = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                }else {
                    machineCode = [CSIIConfigDeviceInfo getDeviceID];
                }
                NSString *lakalaStr = [data objectForKey:@"Url"];
                lakalaStr = [NSString stringWithFormat:@"%@&_platform=iOS&_osVersion=%@&_deviceModel=%@&_deviceNo=%@",lakalaStr,[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice] model],machineCode];
                storeViewController.webViewUrl = lakalaStr;
            }else
            {
                storeViewController.webViewUrl = [data objectForKey:@"Url"];
            }
            
            if ([[data objectForKey:@"ShareText"]isEqual:[NSNull null]]) {
                storeViewController.webShareText = @"欢迎使用常熟农商银行";
            }else
            storeViewController.webShareText = [data objectForKey:@"ShareText"];
            
            if ([[data objectForKey:@"ShareTitle"] isEqual:[NSNull null]]) {
                storeViewController.webShareTitle = @"常熟农商银行";
            }else
            storeViewController.webShareTitle = [data objectForKey:@"ShareTitle"];
            
            storeViewController.webShareUrl = [data objectForKey:@"ShareUrl"];
            [self.navigationController pushViewController:storeViewController animated:YES];
            [MobileBankSession sharedInstance].isOpenUrlBack = NO;
//            }
//            else{
//            AdvertisementViewController *ad = [[AdvertisementViewController alloc]init];
//            ad.webUrl = [data objectForKey:@"Url"];
//            ad.webTitleName = [menuArray[self.mobileBankSession.menuViewSlectedTag][menuArrayIndex] objectForKey:@"ActionName"];
//                [self.navigationController pushViewController:ad animated:YES];
//            }
        }
    }

}
-(void)clickLabelEnter:(UITapGestureRecognizer *)tap
{
    if (self.isEdit) {
        return;
    }
    AdvertisementViewController *pvc = [[AdvertisementViewController alloc]init];
//    pvc.adverWeb = YES;
    pvc.webUrl = [dataArray[tap.view.tag-1] objectForKey:@"URL"];
    pvc.webTitleName = [dataArray[tap.view.tag-1] objectForKey:@"IMAGENAME"];
    [self.navigationController pushViewController:pvc animated:YES];

}

-(void)createGongGaoView
{
    bgGongGaoview  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    bgGongGaoview.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideGongGao)];
    [bgGongGaoview addGestureRecognizer:tap];
    bgGongGaoview.alpha = 0.5f;
//    window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [bgViewController.view addSubview:bgGongGaoview];
    
    //    [self.view addSubview:bgGongGaoview];
    CGSize wenziSize;
    NSString *gongGaoStr;
    if (![[detailArray[0] objectForKey:@"CONTENT"] isEqualToString:@""]) {
        gongGaoStr = [detailArray[0] objectForKey:@"CONTENT"];
        gongGaoStr = [gongGaoStr stringByAppendingString:@"\n"];
        wenziSize = [gongGaoStr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    _alertView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-140, (bgGongGaoview.frame.size.height-(wenziSize.height+65))/2, 280, wenziSize.height+85)];
    _alertView.tag = 444;
    _alertView.layer.cornerRadius = 8;
    _alertView.layer.masksToBounds = YES;
    _alertView.layer.borderWidth = 1;
    _alertView.layer.borderColor = [UIColor grayColor].CGColor;
    _alertView.backgroundColor = [UIColor whiteColor];
    
    titleLab = [[UILabel alloc]initWithFrame:CGRectMake(30, 10, _alertView.frame.size.width-70, 29)];
    titleLab.backgroundColor = [UIColor clearColor];
//    titleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    NSString *titStr = [detailArray[0] objectForKey:@"TITLE"];
    if (titStr.length>10) {
        titleLab.text = [titStr substringToIndex:10];
        titleLab.text = [titleLab.text stringByAppendingString:@"..."];
    }else
    titleLab.text = titStr;
    titleLab.font = [UIFont boldSystemFontOfSize:17];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [_alertView addSubview:titleLab];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(_alertView.frame.size.width-35, 15, 30, 30);
    [cancleBtn setImage:[UIImage imageNamed:@"cancleImage.png"] forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(hideGongGao) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:cancleBtn];
    
    _gonggaoTV = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, _alertView.frame.size.width-20, wenziSize.height)];
    _gonggaoTV.text = gongGaoStr;
    _gonggaoTV.numberOfLines=0;
    _gonggaoTV.font = [UIFont systemFontOfSize:14.0];
    _gonggaoTV.backgroundColor = [UIColor whiteColor];
    [_alertView addSubview:_gonggaoTV];
    
    clickNum=0;
    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, _alertView.frame.size.height-34, _alertView.frame.size.width, 1)];
    lineView2.backgroundColor = [UIColor grayColor];
    lineView2.alpha = 0.4f;
    lineView2.tag = 777;
    [_alertView addSubview:lineView2];
    
    UIButton *bottomButtom = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomButtom.frame = CGRectMake(_alertView.frame.size.width/2+40, _alertView.frame.size.height-35, 60, 35);
    bottomButtom.backgroundColor = [UIColor clearColor];
    bottomButtom.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    if (detailArray.count==1) {
        [bottomButtom setTitle:@"确认" forState:UIControlStateNormal];
        [bottomButtom addTarget:self action:@selector(hideGongGao) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [bottomButtom setTitle:@"下一页" forState:UIControlStateNormal];
        [bottomButtom addTarget:self action:@selector(nextOrLastBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    bottomButtom.tag = 1001;
    [bottomButtom setTitleColor:[UIColor colorWithRed:0.00f green:0.46f blue:1.00f alpha:1.00f] forState:UIControlStateNormal];
    [_alertView addSubview:bottomButtom];
    
    UIButton *topButton = [UIButton buttonWithType:UIButtonTypeCustom];
    topButton.frame = CGRectMake(_alertView.frame.size.width/2-100, _alertView.frame.size.height-35, 60, 35);
    topButton.backgroundColor = [UIColor clearColor];
    topButton.tag = 1000;
    [topButton setTitle:@"上一页" forState:UIControlStateNormal];
    topButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [topButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    topButton.enabled = NO;
    [topButton addTarget:self action:@selector(nextOrLastBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:topButton];
    
    UIView *lineView3 = [[UIView alloc]initWithFrame:CGRectMake(_alertView.frame.size.width/2-0.5, _alertView.frame.size.height-35, 1, 35)];
    lineView3.alpha = 0.4f;
    lineView3.tag = 778;
    lineView3.backgroundColor = [UIColor grayColor];
    [_alertView addSubview:lineView3];
    
//    [bgViewController.view addSubview:guideImageView];
    [bgViewController.view addSubview:_alertView];
    [bgViewController.view bringSubviewToFront:_alertView];
    [bgViewController.view sendSubviewToBack:menuView];
    
}
-(void)nextOrLastBtnPressed:(UIButton *)sender
{
    if (sender.tag == 1001) {
        clickNum++;
        if (clickNum==detailArray.count) {
            [self hideGongGao];
            return;
        }
        NSString *gongGaoStr = [detailArray[clickNum] objectForKey:@"CONTENT"];
        CGSize wenziSize;
       
        gongGaoStr = [gongGaoStr stringByAppendingString:@"\n"];
        wenziSize = [gongGaoStr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        _alertView.frame = CGRectMake(self.view.frame.size.width/2-140, (bgGongGaoview.frame.size.height-(wenziSize.height+65))/2, 280, wenziSize.height+85);
        if (clickNum==detailArray.count-1) {
            [sender setTitle:@"确认" forState:UIControlStateNormal];
            sender.frame = CGRectMake(_alertView.frame.size.width/2+40, _alertView.frame.size.height-35, 60, 35);
        }
       
        NSString *titStr = [detailArray[clickNum] objectForKey:@"TITLE"];
        if (titStr.length>10) {
            titleLab.text = [titStr substringToIndex:10];
            titleLab.text = [titleLab.text stringByAppendingString:@"..."];
        }else
        titleLab.text = titStr;
        
        sender.frame = CGRectMake(_alertView.frame.size.width/2+40, _alertView.frame.size.height-35, 60, 35);

        _gonggaoTV.frame = CGRectMake(10, 45, _alertView.frame.size.width-20, wenziSize.height);
        _gonggaoTV.text = gongGaoStr;

        
        UIButton *topButton = (UIButton *)[_alertView viewWithTag:1000];
        topButton.frame = CGRectMake(_alertView.frame.size.width/2-100, _alertView.frame.size.height-35, 60, 35);

        [topButton setTitleColor:[UIColor colorWithRed:0.00f green:0.46f blue:1.00f alpha:1.00f] forState:UIControlStateNormal];
        topButton.enabled = YES;
        
    }
    else{
        clickNum--;
        NSString *titStr = [detailArray[clickNum] objectForKey:@"TITLE"];
        
        if (titStr.length>10) {
            titleLab.text = [titStr substringToIndex:10];
            titleLab.text = [titleLab.text stringByAppendingString:@"..."];
        }else
        titleLab.text = titStr;
        
        NSString *gongGaoStr = [detailArray[clickNum] objectForKey:@"CONTENT"];
        gongGaoStr = [gongGaoStr stringByAppendingString:@"\n"];
        CGSize wenziSize;
        wenziSize = [gongGaoStr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];

        _alertView.frame = CGRectMake(self.view.frame.size.width/2-140, (bgGongGaoview.frame.size.height-(wenziSize.height+65))/2, 280, wenziSize.height+85);
        sender.frame = CGRectMake(_alertView.frame.size.width/2-100, _alertView.frame.size.height-35, 60, 35);

        _gonggaoTV.frame = CGRectMake(10, 45, _alertView.frame.size.width-20, wenziSize.height);
        _gonggaoTV.text = gongGaoStr;
        if (clickNum==0) {
            [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            sender.enabled = NO;
            if (detailArray.count>1) {
                UIButton *bottomBtn = (UIButton *)[_alertView viewWithTag:1001];
                bottomBtn.frame = CGRectMake(_alertView.frame.size.width/2+40, _alertView.frame.size.height-35, 60, 35);

                [bottomBtn setTitle:@"下一页" forState:UIControlStateNormal];
            }
        }else{
            [sender setTitleColor:[UIColor colorWithRed:0.00f green:0.46f blue:1.00f alpha:1.00f] forState:UIControlStateNormal];
            sender.enabled = YES;
            UIButton *bottomBtn = (UIButton *)[_alertView viewWithTag:1001];
            bottomBtn.frame = CGRectMake(_alertView.frame.size.width/2+40, _alertView.frame.size.height-35, 60, 35);

            [bottomBtn setTitle:@"下一页" forState:UIControlStateNormal];
        }
    }
    
    UIView *lineView2 = (UIView *)[_alertView viewWithTag:777];
    lineView2.frame = CGRectMake(0, _alertView.frame.size.height-34, _alertView.frame.size.width, 1);
    UIView *lineView3 = (UIView *)[_alertView viewWithTag:778];
    lineView3.frame = CGRectMake(_alertView.frame.size.width/2-0.5, _alertView.frame.size.height-35, 1, 35);
}
-(void)hideGongGao
{
    [bgGongGaoview removeFromSuperview];
    [_alertView removeFromSuperview];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)getDataFromeServer {
    
}

@end
