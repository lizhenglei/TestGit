//
//  PiontStoreViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/7/20.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "PiontStoreViewController.h"
#import "CSIIMenuViewController.h"
#import "CommonFunc.h"

#import "CSIIShareHandle.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import "CSIISinaAuthorViewController.h"
#import "CSIISinaContentController.h"

#import "XHDrawerController.h"


@interface PiontStoreViewController ()<UIWebViewDelegate,CSIIShareViewDelegate,ShareHandleTencentDelegate>
{
    UIWebView *webView;
    NSArray *_buttonArray;
    NSString *keyString;//秘钥
    
    NSString *extraLinkShareTitle;//分享有两处，一处是右上角，一处是页面内
    NSString *extraLinkShareText;
    NSString *extraLinkShareUrl;
}
@end

@implementation PiontStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShowbottomMenus = NO;
    if (![self.webShareUrl isEqual:[NSNull null]]) {//有分享的链接就显示分享的按钮
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setBackgroundImage:IMAGE(@"page_share") forState:UIControlStateNormal];
        [rightButton setBackgroundImage:IMAGE(@"page_share") forState:UIControlStateHighlighted];
        
        [rightButton addTarget:self action:@selector(rightButtonActionShare) forControlEvents:UIControlEventTouchUpInside];
        rightButton.frame = CGRectMake(280+22 ,5 ,80/2 ,80/2 );
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44 - 10-10)];
    webView.delegate= self;
    self.view.backgroundColor = [UIColor clearColor];
    NSString *urlString;
    
    urlString = self.webViewUrl;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:15.0f];
//    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
    
//    NSString *dataString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//    [webViewController loadHTMLString:dataString baseURL:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getDataPhoneNum) name:@"_GetData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goBackToRoot) name:@"goBack2Bank" object:nil];

}
+(PiontStoreViewController*)sharedInstance{
    static PiontStoreViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PiontStoreViewController alloc] init];
    });
    return sharedInstance;
}
-(void)goBackToRoot
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getDataPhoneNum
{//9030230003553452
    NSString *getPhoneNumStr;
    if ([MobileBankSession sharedInstance].isLogin) {
        NSString *NumKey = [NSString stringWithFormat:@"%@&%@",[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"],keyString];
        getPhoneNumStr = [NSString stringWithFormat:@"getDataFromIOS('%@')",NumKey];
        NSLog(@"手机号%@",getPhoneNumStr);
        NSLog(@"手机号和秘钥%@",NumKey);
    }
    else
    {
        getPhoneNumStr = [NSString stringWithFormat:@"getDataFromIOS('')"];
    }
    [webView stringByEvaluatingJavaScriptFromString:getPhoneNumStr];
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[MobileBankSession sharedInstance] showMask:nil maskMessage:@"请稍后..." maskType:Common];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[MobileBankSession sharedInstance] hideMask];
    
//    NSString *ss = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取当前页面的title

    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code]==101) {
        return;
    }
    if([error code] == NSURLErrorCancelled){
        //一个页面没有被完全加载之前收到下一个请求，此时迅速会出现此error=-999
        //此时可能已经加载完成，则忽略此error，继续进行加载。
        return;
    }

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求超时" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *urlString = [[request URL]absoluteString];
    NSLog(@"########$$%@",urlString);
    if ([urlString rangeOfString:@"_GetData"].length>0) {//收单传手机号
        NSArray *array = [urlString componentsSeparatedByString:@"_GetData_"];
        [MobileBankSession sharedInstance].delegate =self;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[array lastObject] forKey:@"ChannelSeq"];
        if ([MobileBankSession sharedInstance].isLogin == YES) {
            [dic setObject:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"] forKey:@"MobileNum"];
        }else
        {
            [dic setValue:@"" forKey:@"MobileNum"];
        }
        [[MobileBankSession sharedInstance]postToServer:@"queryKey.do" actionParams:dic method:@"POST"];
        return NO;
    }
    if ([urlString rangeOfString:@"goBack2Bank"].length>0) {
//        NSArray *array = [urlString componentsSeparatedByString:@"goBack2Bank"];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"goBack2Bank" object:nil userInfo:nil];
        return NO;
    }
    
    if ([urlString rangeOfString:@"doLogin"].length>0) {//调用原生登录
        NSLog(@"ttttvvvv");
        NSArray *array = [urlString componentsSeparatedByString:@"_doLogin_"];
        [MobileBankSession sharedInstance].shoudanLoginMessageString = [array lastObject];//保存订单的数据
        [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}
-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    if ([action isEqualToString:@"queryKey.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            keyString = [data objectForKey:@"Key"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"_GetData" object:nil userInfo:nil];
        }else{
        
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *titleName = nil;
    if (self.webViewName.length>8) {
        titleName = [self.webViewName substringToIndex:8];
        titleName = [titleName stringByAppendingString:@"..."];
    }else{
        titleName = self.webViewName;
    }
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = titleName;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
//    [webView removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)rightButtonActionShare
{
    
    extraLinkShareText = self.webShareText;
    extraLinkShareTitle = self.webShareTitle;
    extraLinkShareUrl = self.webShareUrl;

    [self extraShare];
}
-(void)extraShare
{
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
                WBMessageObject *messageObj = [handle messageToSinaShareNews:@"indentifier1" andTitle:extraLinkShareTitle Description:extraLinkShareText ImgSmall:[UIImage imageNamed:@"shareimage.png"] Url:extraLinkShareUrl];
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
            content.WebShareName = extraLinkShareTitle;
            content.WebShareText = extraLinkShareText;
            content.WebShareUrl = extraLinkShareUrl;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:content];
            [self presentViewController:nav animated:YES completion:nil];
            [CSIIShareView shareViewHide];
        }
        
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"1"]){
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            handle.WXScene = WXSceneSession;
            [handle messageToWeiXinNews:extraLinkShareTitle Description:extraLinkShareText content:nil Image:[UIImage imageNamed:@"shareimage.png"] URL:extraLinkShareUrl shareScene:WXSceneSession];
        }else{
            ShowAlertView(@"提示", @"您尚未安装微信客户端", nil, @"确认", nil);
        }
        
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"2"]){
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            handle.WXScene = WXSceneTimeline;
            [handle messageToWeiXinNews:extraLinkShareTitle Description:extraLinkShareText content:nil Image:[UIImage imageNamed:@"shareimage.png"] URL:extraLinkShareUrl shareScene:WXSceneTimeline];
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
    WBMessageObject *messageObj = [handle messageToSinaShareWords:extraLinkShareTitle andImg:[UIImage imageNamed:@"sns_icon_1.png"]];
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
    [handle messageToTencentNews:extraLinkShareTitle Description:extraLinkShareText URL:extraLinkShareUrl PreviewImgData:imageData];
}

- (void)TencentNotNetWork{
    
}

- (void)TencentLoginFaield:(NSString *)errInfo{
    
}

- (void)TencentDidLogout{
    
}

@end
