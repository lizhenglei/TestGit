//
//  CSIISuperViewController.m
//  MobileClient
//
//  Created by wangfaguo on 13-7-17.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#import "CSIISuperViewController.h"
#import "CSIITextField.h"
#import "LWYTextField.h"
#import "CommonFunc.h"
#import "CSIIMenuListViewController.h"
#import "CSIIMenuViewController.h"
//二维码
#import <ZXingWidgetController.h>
#import "AdvertisementViewController.h"
#import "QRCodeReader.h"

#import <Decoder.h>

#import <TwoDDecoderResult.h>
#import "JSONKit.h"
#import "XHDrawerController.h"

#import "CustomAlertView.h"

#import "KeychainItemWrapper.h"
#import "CSIIConfigDeviceInfo.h"
#import "GesturePasswordController.h"

#import "PiontStoreViewController.h"

#define ALERT_SAFE 1111
@interface CSIISuperViewController ()<CustomAlertViewDelegate,ZXingDelegate,UIImagePickerControllerDelegate,DecoderDelegate,UINavigationControllerDelegate,rightViewScrollwDelegete>
{
    
    UIImageView *backGroundImage;
    UITextField *curActiveTextField;
    NSInteger viewYOffset;
//    NSMutableArray *barButtonItemArray;//底部toolbar的item

    UIImageView *naviShadeIMGV;
    
    UIView *bottomMenuView;
    UIImageView*selectedBG;
    UIImagePickerController *picker;
    ZXingWidgetController *ZXingController;
//    CustomAlertView *loginAlertView;
    NSString *password;
}


@end

@implementation CSIISuperViewController
@synthesize leftButton;
@synthesize rightButton;
@synthesize inputControls;
//@synthesize relatedPageServerHints;
@synthesize hintsBackgroundView;
@synthesize backgroundView = backGroundImage;

- (id)init
{
    self = [super init];
    if (self) {
        self.changBackGround = NO;
        self.inputControls = [[NSMutableArray alloc]init];
        
        //提纲挈领，居高临下。
        self.mobileBankSession = [MobileBankSession sharedInstance];
        self.mobileBankSession.delegate = self;
        picker = [[UIImagePickerController alloc] init];
        _barButtonItemArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}

+ (CSIISuperViewController *)defaultController {
    static CSIISuperViewController *controller = nil;
    if (controller == nil) {
        controller = [[CSIISuperViewController alloc] init];
    }
    return controller;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mobileBankSession.delegate = self;
    self.isShowbottomMenus = YES;
    
    XHDrawerController *dd = [[XHDrawerController alloc]init];
    dd.delegete = [CSIISuperViewController defaultController];

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.navigationController.navigationBarHidden = NO;
    naviShadeIMGV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 12)];
    [self.view addSubview:naviShadeIMGV];

    self.view.frame = CGRectMake(0,0, ScreenWidth, ScreenHeight);
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    backGroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:backGroundImage];
    
    
    leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:IMAGE(@"Navigation_back") forState:UIControlStateNormal];
    [leftButton setBackgroundImage:IMAGE(@"Navigation_back") forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(10 ,5 ,80/2 ,80/2 );
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    leftButton.hidden = NO;
    
    rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setBackgroundImage:IMAGE(@"Navigation_goHeader") forState:UIControlStateNormal];
    [rightButton setBackgroundImage:IMAGE(@"Navigation_goHeader") forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(280+22 ,5 ,80/2 ,80/2 );
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    rightButton.hidden = NO;
    
    _Swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftButtonAction:)];
    _Swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:_Swipe];
    if (IOS7_OR_LATER)
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mobileBankSession hideMask];
    
    //下面这段代码是要隐藏navigationbar上得控件
    [CSIIMenuViewController sharedInstance].navilogo.alpha = 0;
    [CSIIMenuViewController sharedInstance].navilogo.hidden = YES;
    [CSIIMenuViewController sharedInstance].titleLab.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mobileBankSession.delegate =self;

    UIImage *image = nil;
    if (IOS7_OR_LATER) {
        image = [Context ImageName:@"Navigation_bg"];
    }else
        image = [Context ImageName:@"Navigation_bg_ios6"];

    
    UIImage*navName = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 120, 1) resizingMode:UIImageResizingModeStretch];
    
    [self.navigationController.navigationBar setBackgroundImage:navName forBarMetrics:UIBarMetricsDefault];
    
    if (self.isShowbottomMenus) {
        [self addBottomMenus];
    }
    //注册键盘WillShow通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
}

-(void)leftButtonAction:(id)sender{
    
    [MobileBankSession sharedInstance].menuViewSlectedTag = [MobileBankSession sharedInstance].menuViewMidTag;
    UIViewController *vc = [self.navigationController.viewControllers lastObject];
    if ([vc isKindOfClass:[CSIIMenuListViewController class]]) {
        self.mobileBankSession.recentlyMenuGrade -= 1;
        NSLog(@"recentlyMenuGrade = %i",self.mobileBankSession.recentlyMenuGrade );
    }
    [self.navigationController popViewControllerAnimated:YES];
    return;
}
-(void)rightButtonAction:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [MobileBankSession sharedInstance].menuViewSlectedTag = [MobileBankSession sharedInstance].menuViewMidTag;
    return;
}


#pragma mark - add Bottom Tab Menus
-(void)addBottomMenus{
    if (bottomMenuView) {
        [bottomMenuView removeFromSuperview];
        [_barButtonItemArray removeAllObjects];
    }
    bottomMenuView = [[UIView alloc] initWithFrame:CGRectMake(0,([[UIScreen mainScreen] bounds].size.height-44-30) - MAIN_MENU_BUTTON_HEIGHT/* - MAIN_MENU_LABEL_HEIGHT*/, self.view.frame.size.width, 72 /*+ MAIN_MENU_LABEL_HEIGHT*/)];
    bottomMenuView.backgroundColor = [UIColor clearColor];
     
    [self.view addSubview:bottomMenuView];
    UIImageView *bottomMenuBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, ScreenWidth, 72-10)];
    
    UIImage *BgImage = [Context ImageName:@"bottomMenuBg"];
    UIImage*BgImageName = [BgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 124, 1) resizingMode:UIImageResizingModeStretch];
    bottomMenuBg.backgroundColor = [UIColor colorWithPatternImage:BgImageName];

    [bottomMenuView addSubview:bottomMenuBg];
    
    NSMutableArray *bottomButtonRects = [[NSMutableArray alloc]init];
    
    //添加底部按钮
    for (int i=0; i<4; i++) {
        [bottomButtonRects addObject:NSStringFromCGRect(CGRectMake(MAIN_MENU_BUTTON_SPACE+i*(MAIN_MENU_BUTTON_WIDTH+MAIN_MENU_BUTTON_SPACE)+(i>=2?MAIN_MENU_BUTTON_WIDTH+10:0),bottomMenuView.frame.size.height - MAIN_MENU_BUTTON_HEIGHT-5/* - MAIN_MENU_LABEL_HEIGHT*/, MAIN_MENU_BUTTON_WIDTH, MAIN_MENU_BUTTON_HEIGHT))];
    }
    

    
    NSArray *skinTabImageArray = @[@"buttom_menu1_2",@"buttom_menu2_2",@"buttom_menu3_2",@"buttom_menu4_2"];

    //    扫一扫按钮
    _saoYisaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saoYisaoBtn.frame = CGRectMake(MAIN_MENU_BUTTON_SPACE+2*(MAIN_MENU_BUTTON_WIDTH+MAIN_MENU_BUTTON_SPACE-1), -bottomMenuView.frame.size.height+MAIN_MENU_CENTER_HEIGHT-5, MAIN_MENU_CENTER_WIDTH+2, MAIN_MENU_CENTER_HEIGHT-3);
    [_saoYisaoBtn setImage:[Context ImageName:@"buttom_menu_ios_center2"] forState:UIControlStateNormal];
    [_saoYisaoBtn setImage:[Context ImageName:@"buttom_menu_ios_center1"] forState:UIControlStateSelected];

    [bottomMenuView addSubview:_saoYisaoBtn];
    [_saoYisaoBtn addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _saoYisaoBtn.tag = 4;
    
    for (int i = 0; i < 4; i++)
    {
        // NSDictionary *dic = [displayArray objectAtIndex:i];
        UIButton *menuImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuImageButton setBackgroundColor:[UIColor greenColor]];
        UIImage*backImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",skinTabImageArray[i]]];
        UIImage*selectedBackImage = [Context ImageName:[NSString stringWithFormat:@"buttom_ios_menu%d",i+1]];
        
        [menuImageButton setImage:backImage forState:UIControlStateNormal];
        [menuImageButton setBackgroundColor:[UIColor clearColor]];
        [menuImageButton setImage:selectedBackImage forState:UIControlStateSelected];
        [menuImageButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_barButtonItemArray addObject:menuImageButton];
        menuImageButton.tag = i;
        
        menuImageButton.frame =  CGRectFromString([bottomButtonRects objectAtIndex:i]);
        CGRectFromString([bottomButtonRects objectAtIndex:i]);
        [bottomMenuView addSubview:menuImageButton];
        
        NSLog(@"%d",[MobileBankSession sharedInstance].menuViewSlectedTag);
        if (i==[MobileBankSession sharedInstance].menuViewSlectedTag)
        {
            menuImageButton.selected = YES;
//            _saoYisaoBtn.selected = NO;
        }
    }
    if ([MobileBankSession sharedInstance].menuViewSlectedTag==4) {
        _saoYisaoBtn.selected = YES;
    }
}

-(double )getCurrentTimeAc{
    
    NSTimeInterval firstTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    double a=firstTime;
    
    [[NSUserDefaults  standardUserDefaults] setObject:[NSNumber numberWithDouble:a] forKey:@"pTime"];
    
    return a;
}

-(void)bottomButtonAction:(UIButton *)sender
{
    // 移动选中视图的位置
    [UIView beginAnimations:nil context:NULL];
    selectedBG.frame = CGRectMake(80 * sender.tag, 0, 80, 49);
    [UIView commitAnimations];
    
    if (sender.tag ==4) {
        double firstAction=[[[NSUserDefaults standardUserDefaults]objectForKey:@"pTime"]doubleValue];
        double seconed=[self getCurrentTimeAc];
        double offset=seconed-firstAction;
        
        DebugLog(@"%f %f %f",firstAction,seconed,offset);
        if (offset<1000 && offset!=0) {//解决连续点击菜单多次弹出手势密码的bug
            return;
        }

        
        if ([MobileBankSession sharedInstance].menuViewSlectedTag==4) {
            [MobileBankSession sharedInstance].menuViewMidTag = 1;
        }else
        [MobileBankSession sharedInstance].menuViewMidTag = [MobileBankSession sharedInstance].menuViewSlectedTag;
        [MobileBankSession sharedInstance].menuViewSlectedTag = (int)sender.tag;
        [CSIIMenuViewController sharedInstance].toIslogin = @"true";
        [CSIIMenuViewController sharedInstance].toClickable = @"true";
        [CSIIMenuViewController sharedInstance].toActionId = @"MyAcInfo";
        [CSIIMenuViewController sharedInstance].toActionName = @"我的账户";

//        if ([MobileBankSession sharedInstance].isLogin) {
//            if ([MobileBankSession sharedInstance].menuViewSlectedTag==4) {
//                UIViewController* viewController = [self getViewController:[[WebViewController sharedInstance].webView nextResponder]];
//                
//                UINavigationController *navigationController = nil;
//                if(viewController!=nil && viewController.navigationController!=nil)
//                {
//                    navigationController = viewController.navigationController;
//                }
//                else if(viewController!=nil && viewController.navigationController==nil)
//                {
//                    UINavigationController *rootNavigation = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
//                    navigationController = rootNavigation;
//                }
//                NSArray* controllers = navigationController.viewControllers;
//                
//                for (UIViewController* controller in controllers) {
//                    if (controller.class == WebViewController.class) {
//                        [controller removeFromParentViewController];
//                    }
//                }
//                [[WebViewController sharedInstance]setActionId:@"MyAcInfo" actionName:@"我的账户" prdId:nil Id:nil];
//                [navigationController pushViewController:[WebViewController sharedInstance] animated:NO];
//                return;
//        }

//        }
        for(UIView *view in bottomMenuView.subviews)
        {
            if([view isKindOfClass:[UIButton class]] && (UIButton*)view != sender)
            {
                ((UIButton*)view).selected = NO;
            }
        }

        _saoYisaoBtn.selected = YES;
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:@"MyAcInfo" forKey:MENU_ACTION_ID];
        [dic setObject:@"我的账户" forKey:MENU_ACTION_NAME];
        [dic setObject:@"true" forKey:MENU_ACTION_CLICKABLE];
        [dic setObject:@"true" forKey:MENU_ACTION_ISLOGIN];
        [dic setObject:@"web" forKey:@"EntryType"];
        [dic setObject:@"P" forKey:MENU_ACTION_ROLECTR];
        [MobileBankSession sharedInstance].delegate = [CSIIMenuViewController sharedInstance];
        [MobileBankSession sharedInstance].isPassiveLoginDelegate = [CSIIMenuViewController sharedInstance];
        [[MobileBankSession sharedInstance] menuStartAction:dic];
        [MobileBankSession sharedInstance].menuViewSlectedTag = (int)sender.tag;

    }
    else{
        [MobileBankSession sharedInstance].menuViewSlectedTag = (int)sender.tag;
        [MobileBankSession sharedInstance].menuViewMidTag = (int)sender.tag;
        [self.navigationController popToRootViewControllerAnimated:NO];

    }
    sender.selected = YES;
    for(UIView *view in bottomMenuView.subviews)
    {
        if([view isKindOfClass:[UIButton class]] && (UIButton*)view != sender)
        {
            ((UIButton*)view).selected = NO;
        }
    }
}
#pragma mark get navigationcontroller
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

#pragma 二维码扫描成功
-(void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    NSString *resultDES = [CommonFunc textFromBase64StringDES:result];
  
    if ([result hasPrefix:@"http"]) {
       AdvertisementViewController  *adverController = [[AdvertisementViewController alloc]init];
        adverController.webUrl = result;
        adverController.webTitleName = @"常乐生活";
//        adverController.adverWeb = YES;
        [self.navigationController pushViewController:adverController animated:YES];
    }
    else if ([resultDES isEqualToString:@""])
    {
        ShowAlertView(@"提示", @"请扫描常熟农商银行的二维码图片", nil, @"确认", nil);
    }
    else{
        
        NSMutableDictionary*PayeeInfo = [[NSMutableDictionary alloc]initWithDictionary:[Context jsonDicFromString:resultDES]];
            NSLog(@"PayeeInfo***********%@",PayeeInfo);
        [MobileBankSession sharedInstance].userInfoDict = [[NSMutableDictionary alloc]initWithDictionary:PayeeInfo];

        
        if (![MobileBankSession sharedInstance].isLogin) {
            /*获取手势密码 判断是否为空*/
            KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
            password = [keychin objectForKey:(__bridge id)kSecValueData];
            if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码
                [MobileBankSession sharedInstance].isSaoYiSao = YES;
                self.loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                [self.loginAlertView show];
                return;
            }else{
                [MobileBankSession sharedInstance].isSaoYiSao = YES;
                [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil] ;
                return;
            }
        }
        
        if ([[PayeeInfo objectForKey:@"userName"] length]>0&&[[PayeeInfo objectForKey:@"cardNumber"] length]>0) {
            
            if ([MobileBankSession sharedInstance].Userinfo!=nil&&[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserType"]isEqualToString:@"P"]) {    //P 大众版  T专业版    “”游客
                NSLog(@"无权限");
                ShowAlertView(@"提示", @"您是大众版用户不能使用此功能，请通过网银或柜面升级为专业版！", nil, @"确认", nil);
                return;
            }
            
            [[WebViewController sharedInstance]setActionId:@"EwmTransfer" actionName:@"二维码转账" prdId:@"EwmTransfer" Id:@"EwmTransfer"];
            [self.navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请扫描常熟农商银行的二维码图片" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}
//取消
-(void)zxingControllerDidCancel:(ZXingWidgetController *)controllerr and:(int)num
{
    if (num==100) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (num==101)//回到主页
    {
        [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];

    }
    else if (num == 102)
    {
        picker.allowsEditing = YES;
        picker.delegate=self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        [self viewDidAppear:YES];
        [controllerr.overlayView removeFromSuperview];

        [self performSelector:@selector(yanshi) withObject:nil afterDelay:0.0];//使用延时

//        [self dismissViewControllerAnimated:YES completion:nil];
        
//        [self presentViewController:picker animated:YES completion:^{}];
    }
    else{
        [MobileBankSession sharedInstance].menuViewSlectedTag = num;
//        [self viewWillAppear:YES];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    ZXingController = controllerr;
    [self performSelector:@selector(perstopCapture:) withObject:nil afterDelay:0.1];//使用延时
}

-(void)perstopCapture:(id)sender
{
    [ZXingController.overlayView removeFromSuperview];
    [ZXingController stopCapture];
//    [ZXingController.naviImageView removeFromSuperview];
    [ZXingController dismissViewControllerAnimated:NO completion:nil];
}
-(void)yanshi
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self presentViewController:picker animated:NO completion:nil];
    }];
    }
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self dismissViewControllerAnimated:NO completion:^{[self decodeImage:image];}];
}
#pragma mark--读取
- (void)decodeImage:(UIImage *)image
{
    NSMutableSet *qrReader = [[NSMutableSet alloc] init];
    QRCodeReader *qrcoderReader = [[QRCodeReader alloc] init];
    [qrReader addObject:qrcoderReader];
    
    Decoder *decoder = [[Decoder alloc] init];
    decoder.delegate = self;
    decoder.readers = qrReader;
    [decoder decodeImage:image];
}
#pragma mark - DecoderDelegate

- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result
{
    NSString *dicStringDES = [CommonFunc textFromBase64StringDES:result.text];
    if ([result.text hasPrefix:@"http"]) {
        AdvertisementViewController *adverController = [[AdvertisementViewController alloc]init];
        adverController.webUrl = dicStringDES;
        adverController.webTitleName = @"常乐生活";
//        adverController.adverWeb = YES;
        [self.navigationController pushViewController:adverController animated:YES];
    }else{
        
    NSMutableDictionary*PayeeInfo = [[NSMutableDictionary alloc]initWithDictionary:[Context jsonDicFromString:dicStringDES]];
    NSLog(@"PayeeInfo***********%@",PayeeInfo);
        [MobileBankSession sharedInstance].userInfoDict = [[NSMutableDictionary alloc]initWithDictionary:PayeeInfo];

        
        if (![MobileBankSession sharedInstance].isLogin) {
            /*获取手势密码 判断是否为空*/
            KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
            password = [keychin objectForKey:(__bridge id)kSecValueData];
            if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码
                [MobileBankSession sharedInstance].isSaoYiSao = YES;
                self.loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                [self.loginAlertView show];
                return;
            }else{
//                [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
                [MobileBankSession sharedInstance].isSaoYiSao = YES;
                [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil] ;
                return;
                
            }
        }
        
        
        if ([[PayeeInfo objectForKey:@"userName"] length]>0&&[[PayeeInfo objectForKey:@"cardNumber"] length]>0) {
            
            if ([MobileBankSession sharedInstance].Userinfo!=nil&&[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserType"]isEqualToString:@"P"]) {    //P 大众版  T专业版    “”游客
                NSLog(@"无权限");
                ShowAlertView(@"提示", @"您是大众版用户不能使用此功能，请通过网银或柜面升级为专业版！", nil, @"确认", nil);
                return;
            }
            
            
            
            [[WebViewController sharedInstance]setActionId:@"EwmTransfer" actionName:@"二维码转账" prdId:@"EwmTransfer" Id:@"EwmTransfer"];
            [self.navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请扫描常熟农商银行的二维码图片" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
        }

    }
}

- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason
{
    UIAlertView *lert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您选择的不是常熟农商银行二维码" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [lert show];
}

#pragma mark - 温馨提示

//设置页面温馨提示
//-(void)setMenuRelatedPageServerHints:(NSArray*)hints
//{
//    //DebugLog(@"%@,settMenuRelatedPageHints,\n %@",[self class], hints);
//    self.relatedPageServerHints = hints;
//}

-(NSString*)getSinglePageServerHintsWithPageNo:(NSInteger)pageNo
{
    if(pageNo<1)
        return nil;
    //    [NSMutableArray]
    NSMutableString *singlePageHints = [[NSMutableString alloc] initWithString:@""];
    
    //if( self.relatedPageServerHints!=nil && [self.relatedPageServerHints isKindOfClass:[NSArray class]] && [self.relatedPageServerHints count]>=pageNo )
    if( [Context sharedInstance].curNativeRelatedPageServerHints!=nil && [[Context sharedInstance].curNativeRelatedPageServerHints isKindOfClass:[NSArray class]] && [[Context sharedInstance].curNativeRelatedPageServerHints count]>=pageNo )
    {
        //NSArray *singlePageHintsArr = [self.relatedPageServerHints objectAtIndex:pageNo-1];
        NSArray *singlePageHintsArr = [[Context sharedInstance].curNativeRelatedPageServerHints objectAtIndex:pageNo-1];
        
        if(singlePageHintsArr!=nil && [singlePageHintsArr isKindOfClass:[NSArray class]] && [singlePageHintsArr count]>0 )
        {
            for(int i=0; i<[singlePageHintsArr count]; i++)
            {
                if(i == 0)
                    [singlePageHints appendString:[singlePageHintsArr objectAtIndex:i]];
                else
                    [singlePageHints appendString:[NSString stringWithFormat:@"\n%@",[singlePageHintsArr objectAtIndex:i]]];
            }
        }
    }
    
    return singlePageHints;
}

-(UIImageView*)addServerHintsByPageNo:(NSUInteger)pageNo FromY:(CGFloat)y
{
    NSString *serverHints = [self getSinglePageServerHintsWithPageNo:pageNo];
    if(serverHints==nil || [serverHints isEqualToString:@""])
        return nil;
    UIImageView *hintsBackground = [self addHints:serverHints FromY:y FromX:10];
    return hintsBackground;
}

-(UIImageView*)addDefaultHints:(NSString*)defaultHints FromY:(CGFloat)y FromX:(CGFloat)x
{
    if(defaultHints == nil || [defaultHints isEqualToString:@""])
        return nil;
    UIImageView *hintsBackground = [self addHints:defaultHints FromY:y FromX:x];
    return hintsBackground;
}

-(UIImageView*)addHints:(NSString*)hints FromY:(CGFloat)y FromX:(CGFloat)x
{
    UIImageView *hintsBackground = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, self.view.bounds.size.width-20, 80)];
    hintsBackground.backgroundColor = [UIColor clearColor];
    if(IPHONE){
        hintsBackground.image = [UIImage imageNamed:@"温馨提示框"];
    }
    UIImageView *tsImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 8, 16, 16)];
    tsImageView.image = [UIImage imageNamed:@"ts"];
    [hintsBackground addSubview:tsImageView];
    UILabel* hintsHeadLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 7, 70, 16)];
    hintsHeadLabel.backgroundColor = [UIColor clearColor];
    hintsHeadLabel.font = [UIFont systemFontOfSize:13];
    hintsHeadLabel.textColor = [UIColor colorWithRed:0.95f green:0.52f blue:0.00f alpha:1.00f];
    hintsHeadLabel.contentMode = UIViewContentModeTopLeft;
    hintsHeadLabel.text = @"温馨提示";
    [hintsBackground addSubview:hintsHeadLabel];
    
    CGFloat textviewY = hintsHeadLabel.frame.origin.y+hintsHeadLabel.frame.size.height;
    UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(5, textviewY, hintsBackground.frame.size.width-10, hintsBackground.frame.size.height-textviewY-5)];
    textview.backgroundColor = [UIColor clearColor];
    
    textview.userInteractionEnabled = NO;
    [textview setTextAlignment:NSTextAlignmentLeft];//设置此属性，会使ios7以下UITextField有内上边距
    //[textview setContentInset:UIEdgeInsetsMake(1, 0, 5, 0)];//设置内边距,不起作用
    [hintsBackground addSubview:textview];
    textview.textColor = [UIColor colorWithRed:0.40f green:0.40f blue:0.40f alpha:1.00f];
    textview.text = hints;
    
    //计算textview内容总高度
    textview.font = [UIFont systemFontOfSize:13];
    
    CGSize newSize = [textview.text sizeWithFont:textview.font constrainedToSize:CGSizeMake(textview.contentSize.width,MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat hOffset = (newSize.height+16) - textview.frame.size.height;
    //改变textview高度
    textview.frame = CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, textview.frame.size.height+hOffset);
    //改变hintsBackground高度
    hintsBackground.frame =CGRectMake(hintsBackground.frame.origin.x, hintsBackground.frame.origin.y, hintsBackground.frame.size.width, hintsBackground.frame.size.height+hOffset);
    
    return hintsBackground;
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

/*限制使用滚轮禁止编辑*/
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([[textField inputView] class] == [UIPickerView class]){
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //CGRect frame = textField.frame;  110618    6229 7600 4070 1017 548
    //NSLog(@"frame : %f",self.view.frame.size.height);
    
    //iPad键盘高度: portrait  264(英文) 264+54=318（中文拼音）  landscape  352
    //iPhone键盘高度: Portrait  216(英文) 216+36=252（中文拼音）216(中文手写)   Landscape  140
    
    //NSString *inputMode =[[UITextInputMode currentInputMode] primaryLanguage];
    //NSLog(@"textFieldDidBeginEditing, 输入法：%@",inputMode);
    //
    //    if([[textField inputView] class] == [UIPickerView class]){
    //        textField.enabled = NO;
    //    }
    
    curActiveTextField = textField;
    textField.highlighted = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    curActiveTextField = nil;
    viewYOffset = 0;
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        rect = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
    else
#endif
    {
        rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    textField.highlighted = NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    curActiveTextField = nil;
    viewYOffset = 0;
//        NSTimeInterval animationDuration = 0.30f;
//        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//        [UIView setAnimationDuration:animationDuration];
    CGRect rect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        rect = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
    else
#endif
    {
        rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.view.frame = rect;
//        [UIView commitAnimations];
    [textField resignFirstResponder];
    textField.highlighted = NO;
}

#pragma mark -

-(NSInteger)calculateViewYOffset:(UITextField*)textField
{
    if(textField == nil)
        return 0;
    
    NSInteger yOffset = 0;
    
    CGRect rectInScreen = [textField convertRect:textField.bounds toView:nil];
    
    int iCSIIUIToolbarHeight = 0;//前一项，后一项按钮工具栏高度
    if([textField isKindOfClass:[CSIITextField class]] ||[textField isKindOfClass:[LWYTextField class]])//[textField isKindOfClass:[PowerEnterUITextField class]] ||
        iCSIIUIToolbarHeight = 44;
    
    NSInteger chineseToolBarHeight = 40; //中文选字框高度
    NSString *inputMode =[[UITextInputMode currentInputMode] primaryLanguage];
    
    if (inputMode!=nil && ([inputMode isEqualToString:@"zh-Hans"]||[inputMode isEqualToString:@"zh-Hant"]))
        // &&![textField isKindOfClass:[PowerEnterUITextField class]]
    {
        if(IPHONE)
            chineseToolBarHeight = 36;
        else
            chineseToolBarHeight = 54;
    }
    
    if(IPHONE)
    {
        yOffset = (rectInScreen.origin.y + rectInScreen.size.height + 5) - ([[UIScreen mainScreen] bounds].size.height - 216.0f - iCSIIUIToolbarHeight - chineseToolBarHeight);
    }
    else
    {
        yOffset = (rectInScreen.origin.y + rectInScreen.size.height + 5) - ([[UIScreen mainScreen] bounds].size.height - 264.0f - iCSIIUIToolbarHeight - chineseToolBarHeight);
    }
    
    //yOffset > 0 表示键盘挡住输入框,重合yOffset个像素
    //yOffset <= 0 表示键盘没挡住输入框,相距yOffset个像素
    
    return yOffset;
}

#pragma mark - =====Keyboard Notification======
-(void)keyboardWillShow:(NSNotification*)notification
{
    //NSString *inputMode=[[UITextInputMode currentInputMode] primaryLanguage];
    //NSLog(@"keyboardWillShow, 输入法：%@",inputMode);
    
    if(viewYOffset >= 0 && curActiveTextField!=nil)
    {
        //需要计算View偏移量
        int yOffset = (int)[self calculateViewYOffset:curActiveTextField];
        viewYOffset = viewYOffset + yOffset;
        
        //        NSTimeInterval animationDuration = 0.30f;
        //        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        //        [UIView setAnimationDuration:animationDuration];
        
        if(viewYOffset > 0)
        {
            CGRect rect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            if (IOS7_OR_LATER)
            {
                rect = CGRectMake(0.0f, 64.0f-viewYOffset,self.view.frame.size.width,self.view.frame.size.height);
            }
            else
#endif
            {
                rect = CGRectMake(0.0f, -viewYOffset,self.view.frame.size.width,self.view.frame.size.height);
            }
            self.view.frame = rect;
            
        }else
        {
            viewYOffset = 0;
            CGRect rect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            if (IOS7_OR_LATER)
            {
                rect = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
            }
            else
#endif
            {
                rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
            }
            self.view.frame = rect;
        }
        //        [UIView commitAnimations];
    }
    
}
#pragma mark - 验证textfield数据格式

-(BOOL)validateTextFormat{
    
    for (int i = 0 ; i < [self.inputControls count]; i ++ ) {
        
        if (![(LWYTextField *)[self.inputControls objectAtIndex:i] validateTextFormat]) {
            return NO;
        }
        
    }
    
    return YES;
    
}

- (NSDate *)formateStrToDate:(NSString *)str{
    NSString* string = [[NSString alloc] initWithString:str];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init] ;
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSDate* inputDate = [inputFormatter dateFromString:string];
    NSLog(@"date = %@", inputDate);
    return inputDate;
}


- (NSString *)showHorizontal:(NSString *)str{
    if (str == nil||[str isEqualToString:@""]) {
        return @"-";
    }else{
        return str;
    }
}

//textfield显示小数点  但是没有元
-(NSString *)splitByRmb:(NSString *)moneyStr{
    NSString *money =  [self splitMoneyStr:moneyStr];
    NSArray *arr = [money componentsSeparatedByString:@"元"];
    return [arr objectAtIndex:0];
}


#pragma mark - 逗号拆分金额
-(NSString *)splitMoneyStr:(NSString *)moneyStr{//
    if (moneyStr == nil ||[moneyStr isEqualToString:@""]) {
        return @"";
    }
    
    if ([moneyStr isEqualToString:@".00"]||[moneyStr isEqualToString:@"0"]||[moneyStr isEqualToString:@"0.0"]||[moneyStr isEqualToString:@"0.00"]||[moneyStr isEqualToString:@".0"]) {
        return @"0.00元";
    }
    
    if ([moneyStr hasPrefix:@"."]) {
        if (moneyStr.length<=2) {
            return [NSString stringWithFormat:@"0%@0元",moneyStr];
        }else
            return [NSString stringWithFormat:@"0.%@元",[moneyStr substringWithRange:NSMakeRange(1, 2)]];
    }
    
    if ([moneyStr hasSuffix:@"元"]) {
        moneyStr = [[moneyStr componentsSeparatedByString:@"元"] objectAtIndex:0];
    }
    
    
    BOOL isBigThanZero = YES;
    if ([moneyStr hasPrefix:@"-"]) {
        isBigThanZero = NO;
        moneyStr = [moneyStr substringFromIndex:1];
    }
    
    NSArray *splitByDot = [[NSArray alloc] init];
    splitByDot = [moneyStr componentsSeparatedByString:@"."];
    
    //小数点 lastStr
    NSString *lastStr = [[NSString alloc] init];
    if (splitByDot.count>1) {
        lastStr = [splitByDot objectAtIndex:1];
    }
    if (lastStr.length>=2) {
        lastStr = [lastStr substringWithRange:NSMakeRange(0, 2)];
    }else if(lastStr.length == 1){
        lastStr = [lastStr stringByAppendingString:@"0"];
    }else{
        lastStr = @".00";
    }
    
    NSString *preDotStr = [splitByDot objectAtIndex:0];//.之前的数字
    if (preDotStr.length<=3) {    //点之前的数字位数小于等于三时不需要加逗号，直接返回
        
        if ([[splitByDot objectAtIndex:0] isEqualToString:@"0"]) {
            return [[preDotStr stringByAppendingString:[NSString stringWithFormat:@".%@",lastStr]] stringByAppendingString:@"元"];
        }
        
        if (isBigThanZero == YES) {
            if (splitByDot.count>1) {
                return [[preDotStr stringByAppendingString:[NSString stringWithFormat:@".%@",lastStr]] stringByAppendingString:@"元"];
            }else{
                return [preDotStr stringByAppendingString:@".00元"];
            }
        }else {
            if (splitByDot.count>1) {
                return [[NSString stringWithFormat:@"-%@",[splitByDot objectAtIndex:0]] stringByAppendingString:[NSString stringWithFormat:@".%@元",lastStr]];
                
            }
            return [[NSString stringWithFormat:@"-%@",[splitByDot objectAtIndex:0]] stringByAppendingString:@".00元"];
        }
    }
    
    //拆分加“,”
    NSMutableArray *subMoneyArr = [[NSMutableArray alloc] init];
    if (preDotStr.length%3==0) {
        for (int i = 0; i<preDotStr.length/3; i++) {
            NSString *s = [preDotStr substringWithRange:NSMakeRange(preDotStr.length-(i+1)*3,3)];
            [subMoneyArr addObject:s];
        }
    }else{
        for (int i = 0; i<preDotStr.length/3+1; i++) {
            NSString *s = @"";
            if (i == preDotStr.length/3) {
                s = [preDotStr substringWithRange:NSMakeRange(0,preDotStr.length%3)];
            }else{
                s = [preDotStr substringWithRange:NSMakeRange(preDotStr.length-(i+1)*3,3)];
            }
            [subMoneyArr addObject:s];
        }
    }
    NSString *str = @"";
    for (int i = 0; i<subMoneyArr.count; i++) {
        str = [NSString stringWithFormat:@"%@%@,",str,[subMoneyArr objectAtIndex:subMoneyArr.count-i-1]];
    }
    
    //最后拼接在一起
    NSMutableString *moneyAppendDot = [[NSMutableString alloc] init];
    if (isBigThanZero == YES) {
        if (splitByDot.count>1) {
            moneyAppendDot = [NSMutableString stringWithFormat:@"%@.%@元",[str substringToIndex:str.length-1],lastStr];
        }else{
            moneyAppendDot = [NSMutableString stringWithFormat:@"%@.00元",[str substringToIndex:str.length-1]];
        }
        
    }else {
        if (splitByDot.count>1) {
            moneyAppendDot = [NSMutableString stringWithFormat:@"-%@.%@元",[str substringToIndex:str.length-1],lastStr];
            
        }else{
            moneyAppendDot = [NSMutableString stringWithFormat:@"-%@.00元",[str substringToIndex:str.length-1]];
            
        }
    }
    
    
    return moneyAppendDot;
}


//name ***
- (NSString *)showStrInName:(NSString *)nameStr{
    if (nameStr == nil || [nameStr isEqualToString:@""]) {
        return nil;
    }
    NSMutableString *str = [[NSMutableString alloc] initWithString:nameStr];
    NSString *replaceStr = [[NSString alloc] init];
    
    for (int i = 0; i < nameStr.length-1; i++) {
        replaceStr = [NSString stringWithFormat:@"%@*",replaceStr];
    }
    [str replaceCharactersInRange:NSMakeRange(0, nameStr.length-1) withString:replaceStr];
    return str;
}
//转换成NSDate
-(NSString *) formateDate:(NSDate *) date{
    if (date) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];//用[NSDate date]可以获取系统当前时间
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        return currentDateStr;
    }
    return @"";
}
#pragma mark ---------Gesturedelegation------------
- (BOOL)verification:(NSString *)result{
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
        [MobileBankSession sharedInstance].delegate  = [CSIIMenuViewController sharedInstance];
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
-(void)gestureExit:(CustomAlertView *)alert
{
    [MobileBankSession sharedInstance].isOpenUrlBack = NO;
    [MobileBankSession sharedInstance].menuViewSlectedTag = [MobileBankSession sharedInstance].menuViewMidTag;
    _saoYisaoBtn.selected = NO;
    for(UIView *view in bottomMenuView.subviews)
    {
        if([view isKindOfClass:[UIButton class]])
        {
            ((UIButton*)view).selected = NO;
            if (((UIButton *)view).tag ==[MobileBankSession sharedInstance].menuViewMidTag) {
                ((UIButton *)view).selected = YES;
            }
        }
       
    }
}
-(void)gestureOtherWay:(CustomAlertView *)alert
{
//    [self gestureExit:alert];
    [MobileBankSession sharedInstance].menuViewSlectedTag = [MobileBankSession sharedInstance].menuViewMidTag;
    _saoYisaoBtn.selected = NO;
    for(UIView *view in bottomMenuView.subviews)
    {
        if([view isKindOfClass:[UIButton class]])
        {
            ((UIButton*)view).selected = NO;
            if (((UIButton *)view).tag ==[MobileBankSession sharedInstance].menuViewMidTag) {
                ((UIButton *)view).selected = YES;
            }
        }
        
    }

}

#pragma mark - CustomAlertViewDelegate登陆方法
-(void) toggleRemember:(id) sender{
    
}
-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    [[CSIIMenuViewController sharedInstance]getReturnData:data WithActionName:action];
}
- (void) selfAssisstantLinkBtnPressedWithinAlertView:(CustomAlertView *)alert{
    //    [self selfAssistanLink];
    [alert hideAlertView];
}

- (void) resetPasswordBtnPressedWithinAlertView:(CustomAlertView *)alert{
    
    [alert hideAlertView];
}
-(BOOL)prefersStatusBarHidden
{
    return NO;
}
//-(void) setBackGround{
//    UIImage *backGround ;
//    
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"skinSelect"] isEqualToString:@"0"]) {
//        backGround  = [UIImage imageNamed:@"background.png"];
//        
//    }else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"skinSelect"] isEqualToString:@"1"]){
//        backGround  = [UIImage imageNamed:@"background.png"];
//        
//    }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"skinSelect"] isEqualToString:@"2"]){
//        backGround  = [UIImage imageNamed:@"background.png"];
//        
//    }else {
//        backGround  = [UIImage imageNamed:@"background.png"];
//    }    CGRect rect = BGImageViewFrame;
//    rect.size.height = rect.size.height-44;
//    UIImageView *backGroundImage1 = [[UIImageView alloc] initWithFrame:rect];
//    //    backGroundImage.backgroundColor = [UIColor colorWithRed:(0xF7)/255.0 green:(0xF7)/255.0 blue:(0xF7)/255.0 alpha:1.0];
//    backGroundImage1.image = backGround;
//    [self.view addSubview:backGroundImage1];
//    
//    //    UIImageView *naviShadeIMGV1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 12)];
//    //    naviShadeIMGV1.image = [UIImage imageNamed:@"naviBGShade.png"];
//    //    [self.view addSubview:naviShadeIMGV1];
//}

@end