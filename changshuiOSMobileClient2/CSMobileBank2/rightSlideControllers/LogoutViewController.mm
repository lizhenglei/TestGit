//
//  LogoutViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/4/23.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "LogoutViewController.h"
#import "XHDrawerController.h"

#import "MySettingViewController.h"
#import "SkyManagerViewController.h"
#import "CommonFunc.h"

#import "WeiboSDK.h"
#import "CSIIShareHandle.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import "CSIISinaAuthorViewController.h"
#import "CSIISinaContentController.h"
#import "ServiceTelePhoneViewController.h"

#import "CSIIMenuViewController.h"

#import "myErWeiMaViewController.h"
#import "myCommentViewController.h"
//#import "QRCodeGenerator.h"

#import "QREncoder.h"
#import "DataMatrix.h"


@interface LogoutViewController ()<UIScrollViewDelegate,CSIIShareViewDelegate,WBHttpRequestDelegate,ShareHandleTencentDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MobileSessionDelegate>
{
    UIView *shareView;
    UILabel* titleLB;
    NSArray *_buttonArray;//
    UILabel*SecreNoticeLab;
    UISwipeGestureRecognizer *_swipRight;
    UIWindow *window;
    UIView *backView;
    UIImageView *logoImageView;
    UIButton*signUpBtn ;
}
@end
@implementation LogoutViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![MobileBankSession sharedInstance].isLogin) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }
    
    _swipRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRight:)];
    _swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:_swipRight];
    
    SecreNoticeLab.text = [NSString stringWithFormat:@"我的预留信息: %@",[[MobileBankSession sharedInstance].Userinfo objectForKey:@"SecreNotice"]];
    
    
    //头像显示住用户的二维码信息
    logoImageView=[[UIImageView alloc]init];
    logoImageView.image = nil;
    logoImageView.frame=CGRectMake(0,0, 100+10, 100+10);
    logoImageView.tag = 100;
    
    if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"] length]==0||[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"]isEqualToString:@""]) {
        logoImageView.backgroundColor = [UIColor grayColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        label.text = @"您尚未设置主账户，请先设置主账户";
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:13];
        [logoImageView addSubview:label];
    }else{
        NSString *userName = [[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserName"];
        NSString *acNo = [[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:userName,@"userName",acNo,@"cardNumber", nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dicString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *dicStringDES = [CommonFunc base64StringFromTextDES:dicString];
        UITapGestureRecognizer *logoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Tapclick:)];//给头像添加手势
        [logoImageView addGestureRecognizer:logoTap];
        logoImageView.backgroundColor = [UIColor clearColor];
        logoImageView.userInteractionEnabled = YES;
        
        
        int qrcodeImageDimension = 250;
        DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:dicStringDES];
        UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
        
        logoImageView.image = qrcodeImage;
        
        //        logoImageView.image = [QRCodeGenerator qrImageForString:dicStringDES imageSize:logoImageView.bounds.size.width];
    }
    
    [backView addSubview:logoImageView];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view removeGestureRecognizer:_swipRight];
    [logoImageView removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    UIView *swipView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    //    swipView.backgroundColor = [UIColor redColor];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CGFloat wight = 260;         //右边view的宽，计算坐标
    backView = [[UIView alloc]initWithFrame:CGRectMake(10, 55, 100+10, 100+30)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 113, 110, 15)];
    label.text = @"收款二维码";
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment  = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [backView addSubview:label];
    
    
    titleLB = [[UILabel alloc] initWithFrame:CGRectMake(backView.frame.origin.x+backView.frame.size.width+10, backView.frame.origin.y+15, 80, 20)];
    titleLB.text = [[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserName"];
    titleLB.textAlignment =  NSTextAlignmentLeft;
    titleLB.font =  [UIFont boldSystemFontOfSize:16.0f];
    titleLB.textColor = [UIColor whiteColor];
    titleLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLB];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(titleLB.frame.origin.x, titleLB.frame.origin.y+titleLB.frame.size.height+5, wight-titleLB.frame.origin.x-10, 0.5)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineView];
    
    signUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signUpBtn.frame = CGRectMake(wight-65, backView.frame.origin.y+15, 55, 20);
    [signUpBtn setBackgroundImage:[UIImage imageNamed:@"signUp"] forState:UIControlStateNormal];
    [signUpBtn setBackgroundImage:[UIImage imageNamed:@"signUp_sec"] forState:UIControlStateSelected];
    [signUpBtn addTarget:self action:@selector(signUpAction:) forControlEvents:UIControlEventTouchUpInside];
    signUpBtn.backgroundColor = [UIColor clearColor];
    if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"SignFlag"]isEqualToString:@"0"]) {
        signUpBtn.selected = NO;
    }
    else{
        signUpBtn.selected = YES;
    }
    [self.view addSubview:signUpBtn];
    
    UIButton*exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.frame = CGRectMake(wight-80, titleLB.frame.origin.y+titleLB.frame.size.height+40, 72, 18);
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"exitBtnImage"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitBtn];
    
    
    SecreNoticeLab = [[UILabel alloc] initWithFrame:CGRectMake(10,backView.frame.size.height+backView.frame.origin.y+5,250,20)];
    SecreNoticeLab.text = [NSString stringWithFormat:@"我的预留信息:%@",[[MobileBankSession sharedInstance].Userinfo objectForKey:@"SecreNotice"]];
    SecreNoticeLab.textAlignment =  NSTextAlignmentLeft;
    SecreNoticeLab.font =  [UIFont systemFontOfSize:12.0f];
    SecreNoticeLab.textColor = [UIColor whiteColor];
    SecreNoticeLab.backgroundColor = [UIColor clearColor];
    [self.view addSubview:SecreNoticeLab];
    
    UILabel*dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, SecreNoticeLab.frame.origin.y+SecreNoticeLab.frame.size.height+5, 250, 20)];
    dateTitle.text = [NSString stringWithFormat:@"上次登录时间: %@",[[MobileBankSession sharedInstance].Userinfo objectForKey:@"LastLoginTime"]];
    dateTitle.textAlignment =  NSTextAlignmentLeft;
    dateTitle.font =  [UIFont systemFontOfSize:12.0f];
    dateTitle.textColor = [UIColor whiteColor];
    dateTitle.backgroundColor = [UIColor clearColor];
    [self.view addSubview:dateTitle];
    
    UILabel *versionCode = [[UILabel alloc]initWithFrame:CGRectMake(260/2+20, self.view.frame.size.height-50, 80, 20)];
    versionCode.font = [UIFont systemFontOfSize:15];
    versionCode.text = [NSString stringWithFormat:@"        V%@",APP_VERSION_CODE];
    versionCode.textAlignment = NSTextAlignmentCenter;
    versionCode.textColor = [UIColor whiteColor];
    [self.view addSubview:versionCode];
    
    NSMutableArray*cellTitles = [[NSMutableArray alloc]init];          //@[@"我的设置",@"帮助中心",@"我要评价",@"关于我们",@"分享"];
    NSMutableArray*cellImgs = [[NSMutableArray alloc]init];               //@[@"logout_set",@"logout_help",@"logout_pingjia",@"logout_about",@"logout_share"];
    
    
    for (int x = 0; x<[MobileBankSession sharedInstance].setMenuArray.count; x++) {
        [cellTitles addObject:[[[MobileBankSession sharedInstance].setMenuArray objectAtIndex:x] objectForKey:@"ActionName"]];
        [cellImgs addObject:[[[MobileBankSession sharedInstance].setMenuArray objectAtIndex:x] objectForKey:@"ActionImage"]];
    }
    for (int x = 0; x<[MobileBankSession sharedInstance].setMenuArray.count; x++) {
        UIImageView*cellBackground = [[UIImageView alloc]initWithFrame:CGRectMake(wight/2-228/2, dateTitle.frame.origin.y+dateTitle.frame.size.height+15+x*(ScreenHeight==480?40:45), 228, 35)];
        cellBackground.backgroundColor = [UIColor clearColor];
        
        UIImageView*cellImg = [[UIImageView alloc]initWithFrame:CGRectMake(228/2-21/2-100/2, 40/2-21/2, 21, 21)];
        cellImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"logout_%@",[cellImgs objectAtIndex:x]]];
        [cellBackground addSubview:cellImg];
        
        UILabel*title = [[UILabel alloc]initWithFrame:CGRectMake(228/2-100/2+30, 40/2-25/2-1, 100, 25)];
        title.text = [cellTitles objectAtIndex:x];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:15];
        title.textColor = [UIColor whiteColor];
        [cellBackground addSubview:title];
        
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Tapclick:)];
        cellBackground.tag = x;
        [cellBackground addGestureRecognizer:tap];
        cellBackground.userInteractionEnabled = YES;
        [self.view addSubview:cellBackground];
        
    }
    
    
    // Do any additional setup after loading the view.
}

-(void)swipRight:(UISwipeGestureRecognizer *)sgr
{
    [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
}
-(void)Tapclick:(UITapGestureRecognizer*)tap
{
    if (tap.view.tag == 100) {
        NSLog(@"收款二维码");
        myErWeiMaViewController *mevc = [[myErWeiMaViewController alloc]init];
        [[CSIIMenuViewController sharedInstance].navigationController pushViewController:mevc animated:NO];
        [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        return;
    }
    
    
    NSMutableDictionary*nextMenu = [[MobileBankSession sharedInstance].setMenuArray objectAtIndex:tap.view.tag];
    
    NSString* Clickable = [nextMenu objectForKey:@"Clickable"];
    NSString*RoleCtr = [nextMenu objectForKey:@"RoleCtr"];
    
    if(Clickable!=nil && [Clickable isEqualToString:@"false"]){
        
        ShowAlertView(@"提示", @"功能暂不可用", nil, @"确认", nil);
        return;
    }
    
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserType"]isEqualToString:@""]&&![RoleCtr isEqualToString:@""]) {    //P 大众版  T专业版    “”游客
        NSLog(@"无权限");
        ShowAlertView(@"提示", @"您无权限操作此功能，请到柜台开通专业版手机银行！", nil, @"确认", nil);
        return;
    }
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserType"]isEqualToString:@"P"]&&[RoleCtr isEqualToString:@"T"]) {    //P 大众版  T专业版    “”游客
        NSLog(@"无权限");
        ShowAlertView(@"提示", @"您无权限操作此功能，请到柜台开通专业版手机银行！", nil, @"确认", nil);
        return;
    }
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&![[[MobileBankSession sharedInstance].Userinfo objectForKey:@"Security"]isEqualToString:@"05"]&&[RoleCtr isEqualToString:@"U"]) {    //P 大众版  T专业版    “”游客
        NSRange ran = NSMakeRange(4, 1);
        NSString *string = [[[MobileBankSession sharedInstance].Userinfo objectForKey:@"SecurityFlag"] substringWithRange:ran];
        if ([string isEqualToString:@"1"]) {//0000101000
            ShowAlertView(@"提示", @"当前认证方式是“动态码＋交易密码”方式，请切换到“音频Key”方式！", nil, @"确认", nil);
            return;
        }
        else{
            NSLog(@"无权限");
            ShowAlertView(@"提示", @"您无权限操作此功能，请到柜台开通音频Key！", nil, @"确认", nil);
            return;
        }
    }
    
    
    if (((NSArray*)[nextMenu objectForKey:@"MenuList"]).count>0) {
        
        NSLog(@"二级菜单");
        MySettingViewController*mySettingView = [[MySettingViewController alloc]init];
        mySettingView.menuArray = [[NSMutableArray alloc]initWithArray:[nextMenu objectForKey:@"MenuList"]];
        [[CSIIMenuViewController sharedInstance].navigationController pushViewController:mySettingView animated:NO];
        [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        
    }else if([[nextMenu objectForKey:@"EntryType"] isEqualToString:@"web"]){//帮助中心
        
        [[WebViewController sharedInstance]setActionId:[nextMenu objectForKey:@"ActionId"] actionName:[nextMenu objectForKey:@"ActionName"] prdId:[nextMenu objectForKey:@"ActionId"] Id:[nextMenu objectForKey:@"ActionId"]];
        [MobileBankSession sharedInstance].toPassiveActionId = [nextMenu objectForKey:@"ActionId"];
        [MobileBankSession sharedInstance].toPassiveActionName = [nextMenu objectForKey:@"ActionName"];
        [MobileBankSession sharedInstance].toPassiveActionPrdId = [nextMenu objectForKey:@"ActionId"];
        [MobileBankSession sharedInstance].toPassiveActionToId = [nextMenu objectForKey:@"ActionId"];
        
        [[CSIIMenuViewController sharedInstance].navigationController pushViewController:[WebViewController sharedInstance] animated:NO];
        [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        
    }else if ([[nextMenu objectForKey:@"EntryType"] isEqualToString:@"native"]){
        
        if ([[nextMenu objectForKey:@"ActionId"] isEqualToString:@"5000013"]) { //我要评价
            
            NSLog(@"我要评价");
            myCommentViewController *commentViewController = [[myCommentViewController alloc]init];
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:commentViewController animated:NO];
            [MobileBankSession sharedInstance].toPassiveControllerString = @"myCommentViewController";
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            
        }else if ([[nextMenu objectForKey:@"ActionId"] isEqualToString:@"5000014"]) {  //关于我们
            
            ServiceTelePhoneViewController*vc = [[ServiceTelePhoneViewController alloc]init];
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:vc animated:NO];
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            NSLog(@"关于我们");
            
        }else if ([[nextMenu objectForKey:@"ActionId"] isEqualToString:@"5000016"]) {  //分享
            
            NSLog(@"分享");
            NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"logout_weibo",@"img",
                                   @"新浪微博",@"title",
                                   @"0",@"flag",
                                   @"sina",@"subtitle",
                                   nil];
            NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"logout_weixin",@"img",
                                   @"微信好友",@"title",
                                   @"1",@"flag",
                                   @"weixinFriend",@"subtitle",
                                   nil];
            NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"logout_pengyouquan",@"img",
                                   @"微信朋友圈",@"title",
                                   @"2",@"flag",
                                   @"weixinCircle",@"subtitle",
                                   nil];
            NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"logout_qq",@"img",
                                   @"腾讯QQ",@"title",
                                   @"3",@"flag",
                                   @"qq",@"subtitle",
                                   nil];
            _buttonArray = [NSArray arrayWithObjects:dict1,dict2,dict3,dict4, nil];
            //初始化分享菜单，指定代理
            CSIIShareView *share = [CSIIShareView shareInstencesWithItems:_buttonArray];
            [CSIIShareView shareViewShow];
            share.delegate = self;
            
        }else{
            ShowAlertView(@"提示", @"功能完善", nil, @"确认", nil);
        }
        
    }else{
        ShowAlertView(@"提示", @"菜单有误", nil, @"确认", nil);
        return;
    }
}


-(void)signUpAction:(UIButton *)sender{
    
    if (sender.selected == NO) {
        [MobileBankSession sharedInstance].delegate =self;
        [[MobileBankSession sharedInstance]postToServer:@"SignEveryDay.do" actionParams:nil method:@"POST"];
    }
    else{
        ShowAlertView(@"提示", @"您已签到过，不可重复签到", nil, @"确认", nil);
        return;
    }
}
-(void)exit:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"退出" message:@"\n亲，真的要走么？再看会儿吧" delegate:self cancelButtonTitle:@"再看看吧" otherButtonTitles:@"稍后再来", nil];
    alert.tag = 330;
    [alert show];
}

- (void)clickButton:(UIButton *)button withIndex:(NSInteger)index{
    //获取点击按钮的信息
    NSDictionary *dict = [_buttonArray objectAtIndex:index];
    NSLog(@"点击--->>>%@",[dict objectForKey:@"title"]);
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    if([[dict objectForKey:@"flag"] isEqualToString:@"0"]){
        //判断是否能用新浪客户端进行授权登录
        
        if([WeiboSDK isCanSSOInWeiboApp]){
            if(![CSIIShareHandle SinaWeiBoTokenIsInvalid]){
                CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
                //新闻信息
                WBMessageObject *messageObj = [handle messageToSinaShareNews:@"indentifier1" andTitle:@"常熟农商银行" Description:@"常熟农商银行新版手机银行，转账0手续费、更有精彩活动等您参与，速来下载吧！" ImgSmall:[UIImage imageNamed:@"shareimage.png"] Url:@"http://www.csrcbank.com/download.html"];
                //图文片信息
                //                WBMessageObject *messageObj = [handle messageToSinaShareWords:@"哈哈哈哈——————测试用得åå" andImg:[UIImage imageNamed:@"icon7"]];
                //文字信息
                //WBMessageObject *messageObj = [handle messageToSinaShareOnlyWords:@"仅仅是文字信息的发布。____测试。"];
                
                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObj authInfo:nil access_token:handle.SinaWBToken];
                [WeiboSDK sendRequest:request];
                
            }else{
                //通过新浪客户端做授权操作
                [handle SinaWeiBoLogin:nil];
                //[self sinaFinishLogin];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sinaFinishLogin) name:@"sinaClietFinishLogin" object:nil];
            }
        }
        else{
            //如不支持客户端分享，将使用自定义分享
            CSIISinaContentController *content = [[CSIISinaContentController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:content];
            [self presentViewController:nav animated:YES completion:nil];
            [CSIIShareView shareViewHide];
        }
        
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"1"]){
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            handle.WXScene = WXSceneSession;
            [handle messageToWeiXinNews:@"常熟农商银行" Description:@"常熟农商银行新版手机银行，转账0手续费、更有精彩活动等您参与，速来下载吧！" content:nil Image:[UIImage imageNamed:@"shareimage.png"] URL:@"http://www.csrcbank.com/download.html" shareScene:WXSceneSession];
        }else{
            ShowAlertView(@"提示", @"您尚未安装微信客户端", nil, @"确认", nil);
        }
        
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"2"]){
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            handle.WXScene = WXSceneTimeline;
            [handle messageToWeiXinNews:@"常熟农商银行新版手机银行，转账0手续费、更有精彩活动等您参与，速来下载吧！" Description:@"常熟农商银行新版手机银行，转账0手续费、更有精彩活动等您参与，速来下载吧！" content:nil Image:[UIImage imageNamed:@"shareimage.png"] URL:@"http://www.csrcbank.com/download.html" shareScene:WXSceneTimeline];
        }else{
            ShowAlertView(@"提示", @"您尚未安装微信客户端", nil, @"确认", nil);
        }
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"3"]){
        if ([QQApi isQQInstalled]) {
            if(![CSIIShareHandle TencentTokenIsInvalid]){
                [self TencentLoginSuccess];
            }else{
                [self TencentLoginSuccess];
                //授权
                //handle.tencentDelegate = self;
                //[handle TencentLogin];//腾讯登陆
            }
            
        }else{
            ShowAlertView(@"提示", @"您尚未安装腾讯QQ客户端", nil, @"确认", nil);
        }
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"4"]){
        handle.WXScene = WXSceneTimeline;
        [handle showSMSPicker:self];
    }
}

#pragma mark - 使用新浪客户端登录授权的通知
- (void)sinaFinishLogin{
    [self performSelector:@selector(sendSinaMessage) withObject:nil afterDelay:1.5];
}

- (void)sendSinaMessage{
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    WBMessageObject *messageObj = [handle messageToSinaShareWords:@"常熟农商银行-" andImg:[UIImage imageNamed:@"sns_icon_1.png"]];
    //文字信息
    //WBMessageObject *messageObj = [handle messageToSinaShareOnlyWords:@"仅仅是文字信息的发布。____测试。"];
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObj authInfo:nil access_token:handle.SinaWBToken];
    [WeiboSDK sendRequest:request];
}

#pragma mark - QQ好友分享，实现回调方便在第一次授权之后自动跳转到分享界面
- (void)TencentLoginSuccess{
    UIImage *image = [UIImage imageNamed:@"shareimage"];
    NSData *imageData = UIImagePNGRepresentation(image);
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    [handle messageToTencentNews:@"常熟农商银行" Description:@"常熟农商银行新版手机银行，转账0手续费、更有精彩活动等您参与，速来下载吧！" URL:@"http://www.csrcbank.com/download.html" PreviewImgData:imageData];
}

- (void)TencentNotNetWork{
    
}

- (void)TencentLoginFaield:(NSString *)errInfo{
    
}

- (void)TencentDidLogout{
    
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    if ([action isEqualToString:@"logout.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"erWeiMa"];
            //    清除浏览器的缓存
            NSHTTPCookie *cookie;
            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (cookie in [storage cookies])
            {
                [storage deleteCookie:cookie];
            }

            [MobileBankSession sharedInstance].isLogin = NO;
            [MobileBankSession sharedInstance].Userinfo = nil;
            [MobileBankSession sharedInstance].isExitnegative = NO;;
            [self.navigationController popToRootViewControllerAnimated:YES];
            [[CSIIMenuViewController sharedInstance]viewWillAppear:YES];
        }
    }
    else if ([action isEqualToString:@"SignEveryDay.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            signUpBtn.selected = YES;
            //            PlayRewards = 0;//等于0不可抽奖
            //            SeriesSignDay = 1;
            //            "_RejCode" = 000000;
            if ([[data objectForKey:@"PlayRewards"]isEqualToString:@"1"]) {
                
                if ([[data objectForKey:@"GameType"] isEqualToString:@"0"]) {//大转盘抽奖
                    [[WebViewController sharedInstance]setActionId:@"LotteryDraw" actionName:@"大转盘" prdId:@"LotteryDraw" Id:@"LotteryDraw"];
                    
                }else if ([[data objectForKey:@"GameType"] isEqualToString:@"1"])//砸金蛋抽奖
                {
                
                }else if ([[data objectForKey:@"GameType"] isEqualToString:@"2"])//刮刮乐抽奖
                {
                    [[WebViewController sharedInstance]setActionId:@"GuaGuaLe" actionName:@"刮刮乐" prdId:@"GuaGuaLe" Id:@"GuaGuaLe"];

                }else if ([[data objectForKey:@"GameType"] isEqualToString:@"3"])//摇一摇抽奖
                {
                    [[WebViewController sharedInstance]setActionId:@"YaoYiYao" actionName:@"摇一摇" prdId:@"YaoYiYao" Id:@"YaoYiYao"];
                }
                [[CSIIMenuViewController sharedInstance].navigationController pushViewController:[WebViewController sharedInstance] animated:NO];
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                return;
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"您已成功签到%@天,连续%@天签到可获得一次抽奖机会",[data objectForKey:@"SeriesSignDay"],[data objectForKey:@"Day"]] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else{
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==334) {
        if (buttonIndex==0) {
            [[WebViewController sharedInstance]setActionId:@"PAccountSet" actionName:@"我的主账户设置" prdId:@"PAccountSet" Id:@"PAccountSet"];
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
        }
    }
    if (alertView.tag ==330) {
        if (buttonIndex==1) {
            [MobileBankSession sharedInstance].delegate = self;
            [[MobileBankSession sharedInstance] postToServer:@"logout.do" actionParams:nil method:@"POST"];
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:@"sinaFinishLogin"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
