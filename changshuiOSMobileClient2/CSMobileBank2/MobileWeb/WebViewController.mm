//
//  WebViewController.m
//  MobileBankWeb
//
//  Created by wangfaguo on 13-7-23.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import "WebViewController.h"
//#import "MobileBankWeb.h"
#import "CSIIUtility.h"
#import "MobileBankSession.h"
#import "Context.h"
#import "CommonFunc.h"
//#import "MobileClient-Prefix.pch"
#import "CSIIMenuViewController.h"

#import <TwoDDecoderResult.h>
#import "JSONKit.h"
#import "XHDrawerController.h"

#import "shahaiKeyBoard.h"

#import "AdvertisementViewController.h"
#import "KeychainItemWrapper.h"
#import "CustomAlertView.h"
#define IMAGE(image) [UIImage imageNamed:image]
//上卷轴与上方间隔
#define REEL_UP_VERTICAL 0//80
#define REEL_HEIGHT 40
//上卷轴与卷轴背景上下间隔
#define REEL_UP_BG_VERTICAL (-30)
//下卷轴与卷轴背景上下间隔
#define REEL_DOWN_BG_VERTICAL (-25)

#define REEL_BG_WIDTH 300

#define REEL_BG_HEIGHT 350

//卷轴背景与左边间隔
#define REEL_BG_LEVEL 10

static NSString *CSIICachingURLHeader = @"X-CSIICache";
static WebViewController *sharedInstance = nil;

@interface WebViewController ()<UIWebViewDelegate,MobileBankWebDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CustomAlertViewDelegate,UIGestureRecognizerDelegate>
{
    //UIImageView *upReel;
    //UIImageView *downReel;
    //UIImageView *reelbg;
    //UIButton *backButton;
    //UILabel *titleLabel ;
    //UIImageView *titleBG;
//    MobileBankWeb *_webView;
    NSString *_actionId;
    NSString *_actionName;
    NSString *_prdId;
    NSString *_Id;
    NSString *telString;
    UIButton * leftButton;
    UIButton * rightButton;
    CGRect webFrame;
    
    UIView *bottomMenuView;
    UIImageView*selectedBG;
    int _selectedTag;
    NSMutableArray *barButtonItemArray;
    UIImagePickerController *picker;
    
//    UISwipeGestureRecognizer*Swipe;
    
    UIView *guideBgView;//用于添加我的账户首次引导层
    UIViewController *bgViewController;//用于添加我的账户首次引导层
    NSString *password;
    
}

@end


@implementation WebViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        barButtonItemArray = [[NSMutableArray alloc]init];
        picker = [[UIImagePickerController alloc] init];
        
    }
    return self;
}

+(BOOL)isSharedInstanceExist
{
    if(sharedInstance!=nil)
        return YES;
    else
        return NO;
}

+(WebViewController*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebViewController alloc]init];
    });
    
    return sharedInstance;
}
-(BOOL)prefersStatusBarHidden
{
    return NO;
}
-(UIWebView *)startActionUrl:(NSString *)urlString WithFrame:(CGRect)rect{
    _webView=[[MobileBankWeb alloc]initWithFrame:rect];
    _webView.delegate = self;
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[self getStartWebUrl:urlString]]];
    [_webView loadRequest:request];
    return _webView;
}

-(void)startActionUrl:(NSString *)urlString{
    
    NSLog(@"f%@",urlString);
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[self getStartWebUrl:urlString]]];
    [_webView loadRequest:request];
    
}

-(NSString *)getStartWebUrl:(NSString *)url{
    if (!url) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查web启动url的值是否为空" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }else if ([url hasPrefix:@"http://"]|| [url hasPrefix:@"https://"]) {
        return url;
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"url格式有误，请检查url格式" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    return nil;
}

-(void)setActionId:(NSString *)actionId actionName:(NSString*)actionName prdId:(NSString*)prdId Id:(NSString*)Id
{
    
    [MobileBankSession sharedInstance].toPassiveActionId = actionId;
    [MobileBankSession sharedInstance].toPassiveActionName = actionName;
    [MobileBankSession sharedInstance].toPassiveActionPrdId = prdId;
    [MobileBankSession sharedInstance].toPassiveActionToId = Id;
    
    _actionId = actionId;
    _actionName = actionName;
    _prdId = prdId;
    _Id = Id;
}
-(void)removeGuideView:(UITapGestureRecognizer *)tgr
{
    [Context setNSUserDefaults:@"isFirstAcInfoGuide" keyStr:@"firstAcInfoGuide"];
    [guideBgView removeFromSuperview];
}
-(NSString *)getActionId{
    return _actionId;
}

-(NSString *)getSelfPrdId
{
    return _prdId;
}

-(NSString *)getPrdIdByActionId:(NSString*)actionId
{
    NSString* toPrdId = @"";
    
    if([actionId isEqualToString:_actionId])
        return _prdId;
    
    NSArray* menuArray = [MobileBankSession sharedInstance].MenuArray;
    
    if(menuArray==nil)
        return toPrdId;
    
    NSMutableArray *onlineMenuArr = [[NSMutableArray alloc]init];
    for (int i = 1; i<menuArray.count; i++)
    {
        [onlineMenuArr addObject:menuArray[i]];
    }
    
    
    NSMutableArray *actionIdBranch = [[NSMutableArray alloc] init];
    
    NSDictionary *returnMenuDict = [CSIIUtility findMenuByActionId:actionId OrByActionName:nil InMenuArray:onlineMenuArr ActionIdBranch:actionIdBranch];
    
    if(returnMenuDict != nil)
    {
        //找到前往的最终菜单
        toPrdId = [returnMenuDict objectForKey:MENU_PRD_ID];
    }
    
    return  toPrdId;
}

-(NSString *)getHintsByActionId:(NSString*)actionId
{
    NSString* toId = @"";
    
    if([actionId isEqualToString:_actionId])
    {
        toId = _Id;
    }
    else
    {
        NSArray* menuArray = [MobileBankSession sharedInstance].MenuArray;
        
        if(menuArray==nil)
            return @"";
        
        NSMutableArray *onlineMenuArr = [[NSMutableArray alloc]init];
        for (int i = 1; i<menuArray.count; i++)
        {
            [onlineMenuArr addObject:menuArray[i]];
        }
        
        
        NSMutableArray *actionIdBranch = [[NSMutableArray alloc] init];
        
        NSDictionary *returnMenuDict = [CSIIUtility findMenuByActionId:actionId OrByActionName:nil InMenuArray:onlineMenuArr ActionIdBranch:actionIdBranch];
        
        if(returnMenuDict != nil)
        {
            //找到前往的最终菜单
            toId = [returnMenuDict objectForKey:MENU_ID];
        }
        
    }
    
    NSArray *serverHintsArr = [CSIIUtility findPageHintsById:toId];
    
    if(serverHintsArr==nil)
        return @"";
    
    NSDictionary *dictData =[NSDictionary dictionaryWithObjectsAndKeys:serverHintsArr,@"hints", nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:0 error:&error];
    
    if(error){
        DebugLog(@"getHintsByActionId,JSON Parsing Error: %@", error);
        return @"";
    }
    
    NSString* jsonString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    //DebugLog(@"%@",jsonString);
    
    return jsonString;
}

-(void)onHideBackButton:(NSNotification *)note{
    leftButton.hidden = YES;
}

-(void)onShowBackButton:(NSNotification *)note{
    leftButton.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f];
    self.navigationController.navigationBarHidden = NO;
    
    NSLog(@"%@ new alloc, viewDidLoad", [self class]);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
#endif
    
    
    //    leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [leftButton setBackgroundImage:IMAGE(@"Navigation_back") forState:UIControlStateNormal];
    //    [leftButton setBackgroundImage:IMAGE(@"Navigation_back") forState:UIControlStateHighlighted];
    //
    //
    //    [leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //    leftButton.frame = CGRectMake(10 ,5 ,46/2 ,46/2 );
    //    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    //    self.navigationItem.leftBarButtonItem = leftItem;
    //    leftButton.hidden = NO;
    //
    //    rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [rightButton setBackgroundImage:IMAGE(@"Navigation_goHeader") forState:UIControlStateNormal];
    //    [rightButton setBackgroundImage:IMAGE(@"Navigation_goHeader") forState:UIControlStateHighlighted];
    //
    //    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //    rightButton.frame = CGRectMake(280 ,5 ,46/2 ,46/2 );
    //
    //    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    //    self.navigationItem.rightBarButtonItem = rightItem;
    //    rightButton.hidden = NO;
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        webFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64 - 51);
    }
    else
#endif
        webFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44 - 51);
    
    _webView = [[MobileBankWeb alloc] initWithFrame:webFrame];
    // _webView.WebDelegate = self;
    _webView.delegate = self;
    _webView.userInteractionEnabled = YES;
    //    _webView.backgroundColor = [UIColor colorWithRed:(0xF7)/255.0 green:(0xF7)/255.0 blue:(0xF7)/255.0 alpha:1.0];/*[UIColor clearColor];*/
    [_webView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_webView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHideBackButton:) name:@"LocalAction_HideBackButton" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowBackButton:) name:@"LocalAction_ShowBackButton" object:nil];
//    [self.view removeGestureRecognizer:self.Swipe];

//    UIView *viewGes = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
//    viewGes.backgroundColor = [UIColor redColor];
//    viewGes.userInteractionEnabled = YES;
//    [self.view addSubview:viewGes];
//    Swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:viewGes action:@selector(leftButtonAction:)];
//    Swipe.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:Swipe];
//    [self.view bringSubviewToFront:viewGes];
    
//    [self.view removeGestureRecognizer:self.Swipe];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [super viewWillDisappear:animated];//若加上此句，在网店查询里进入预约再返回到主界面，logo图片会消失
    
    [_webView removeKeyboardNotification];
    [_webView.TransferTabelView removeFromSuperview];
  UIViewController *ViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIView *view = (UIView *)[ViewController.view viewWithTag:208];
    [view removeFromSuperview];
    [self clearWebContent];
    [MobileBankSession sharedInstance].UserAnalysisActionId = @"";
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    _webView.backgroundColor = [UIColor clearColor];
    
    
    self.navigationItem.hidesBackButton = YES;
    
    //页面title赋值
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = _actionName;
    
    leftButton.hidden = NO;
    //    backButton.hidden = YES;
    //    titleBG.hidden = YES;
    //    _webView.hidden = YES;
    
    /*
     reelbg.frame = CGRectMake(REEL_BG_LEVEL, REEL_UP_VERTICAL + REEL_HEIGHT +REEL_UP_BG_VERTICAL , REEL_BG_WIDTH, 0);
     
     downReel.frame = CGRectMake(0, REEL_UP_VERTICAL + REEL_HEIGHT  + REEL_UP_BG_VERTICAL, self.view.frame.size.width, REEL_HEIGHT);
     */
    
    
    //titleLabel.text = _actionName;
    //titleBG.hidden = NO;
    //backButton.hidden = NO;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    NSLog(@"%@, viewDidAppear",[self class]);
    
    self.navigationItem.hidesBackButton = YES;
    
    
    _webView.hidden = NO;
    [_webView registerKeyboardNotification];
    
    [[MobileBankSession sharedInstance] showMask:nil maskMessage:@"加载中..." maskType:Common];//显示等待遮罩层
    

    
    if (_actionId)
    {
#if (0)
        /* 以http://方式访问服务器(包括内部服务器)上的index.html
         */
        
        NSString *url;
        url = [NSString stringWithFormat:@"%@/%@/%@/index.html?page=%@",SERVER_BACKEND_URL,SERVER_BACKEND_CONTEXT,SERVER_BACKEND_PATH,_actionId];//_actionId
        
        DebugLog(@"url = %@",url);
//        url = http://10.44.51.1:19080/pmobile/samples/index.html?page=MyAcInfo
        [self startActionUrl:[self getStartWebUrl:url]];
        
#else
        /* 以file://方式访问本地index.html
         */
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"Web/pweb/samples"];
        NSString *encodePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        DebugLog(@"resource path_1111=========%@",resourcePath);
//        resource path_1111=========/var/mobile/Containers/Bundle/Application/05386B59-EF0E-4EB2-895C-296D087B4DF4/MobileClient.app/Web/pweb/samples/index.html
//      encodePath ==  /var/mobile/Containers/Bundle/Application/05386B59-EF0E-4EB2-895C-296D087B4DF4/MobileClient.app/Web/pweb/samples/index.html

        NSString* urlStr = [NSString stringWithFormat:@"file://%@",encodePath];
        NSURL *url = [NSURL URLWithString:urlStr];
        DebugLog(@"url 111= %@ ",url);
//        url 111= file:///var/mobile/Containers/Bundle/Application/05386B59-EF0E-4EB2-895C-296D087B4DF4/MobileClient.app/Web/pweb/samples/index.html
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
        [_webView loadRequest:request];
        
#endif
    }
    if ([_actionId isEqualToString:@"MyAcInfo"]) {//我的账户添加引导层
        bgViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        if ([Context getNSUserDefaultskeyStr:@"firstAcInfoGuide"].length==0) {
            guideBgView = [[UIView alloc]initWithFrame:bgViewController.view.frame];
            UIImageView *guideImageView = [[UIImageView alloc]initWithFrame:guideBgView.frame];
            if (ScreenHeight==480) {
                guideImageView.image = [UIImage imageNamed:@"guideAcInfoImage960"];
            }else{
                guideImageView.image = [UIImage imageNamed:@"guideAcInfoImage1136"];
            }
            [guideBgView addSubview:guideImageView];
            UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeGuideView:)];
            [guideBgView addGestureRecognizer:tgr];
//            [bgViewController.view addSubview:guideBgView];//添加引导页
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==100 && buttonIndex==1) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",telString]]];
    }
    if (alertView.tag ==801) {
        if (buttonIndex==0) {
            [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
            [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil] ;
        }
    }
}

#pragma mark - UIWebViewDelegate
//截取通知
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ([[[request URL]scheme] isEqualToString:@"tel"]) {
        NSRange rangeTel= [[[request URL] absoluteString] rangeOfString:@"tel:"];
        telString=[[[request URL] absoluteString] substringFromIndex:rangeTel.length+rangeTel.location];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:telString message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
        alert.tag=100;
        [alert show];
    }
        DebugLog(@"###shouldStartLoadWithRequest, URL地址: %@\n",[[request URL] absoluteString]);
    
    if([[[request URL] absoluteString] isEqualToString:@"about:blank"])
        return YES;
    if (([[[request URL]scheme] isEqualToString:@"http"] || [[[request URL]scheme] isEqualToString:@"https"] ||[[[request URL]scheme]isEqualToString:@"file"])
        &&  [request valueForHTTPHeaderField:CSIICachingURLHeader] == nil
        &&  [[[request URL] absoluteString] rangeOfString:@".apple.com"].location == NSNotFound) {
        NSString * url = [[request URL] absoluteString];
        //Process Local Actions
        if([url rangeOfString:@"LocalActions/"].length >0)
        {
            NSString *filePath = [url substringFromIndex:[url rangeOfString:@"LocalActions/"].location];
            NSString * actname = [filePath stringByReplacingOccurrencesOfString:@"LocalActions/" withString:@"LocalAction_"];
            NSArray *array=[NSArray array];
            array= [actname componentsSeparatedByString:@"___"];
            
            if(array.count==1){//不包含三条下划线，正常状态
                DebugLog(@"Posting Notification: %@", actname);
                [[NSNotificationCenter defaultCenter] postNotificationName:actname object:nil];
            }else if(array.count==2){//包含三条下划线,一个参数
                NSString *stringindex=[array objectAtIndex:1];  //userInfo
                actname=[array objectAtIndex:0]; //NotificationName
                DebugLog(@"Posting Notification: %@", actname);
                [[NSNotificationCenter defaultCenter] postNotificationName:actname object:nil userInfo:[[NSDictionary alloc]initWithObjectsAndKeys:stringindex,@"index", nil]];
            }else if (array.count==3) {//两个参数
                NSString *stringindex=[array objectAtIndex:1];
                NSString *stringStart=[array objectAtIndex:2];
                actname=[array objectAtIndex:0]; //NotificationName
                DebugLog(@"Posting Notification: %@", actname);
                [[NSNotificationCenter defaultCenter] postNotificationName:actname object:nil userInfo:[[NSDictionary alloc]initWithObjectsAndKeys:stringindex,@"index",stringStart,@"start", nil]];
            }
        }
        
        return YES;
    }
    NSLog(@"------>>>>return no");
    return  NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    //修改服务器页面的meta的值
    
    //    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, maximum-scale=1\"", webView.frame.size.width];
    [_webView stringByEvaluatingJavaScriptFromString:meta];
    
    //
    [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='inherit';"];
    [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='auto';"];//此处代码禁止webview的文本复制

    //webView加载后一直显示空白的话，超时自动隐藏等待遮罩层
    //webView加载成功的话，不用在此隐藏等待遮罩层，等vx发HideMask消息时再隐藏
    
    [[MobileBankSession sharedInstance] hideMask];//隐藏等待遮罩层
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([error code] == NSURLErrorCancelled){
        //一个页面没有被完全加载之前收到下一个请求，此时迅速会出现此error=-999
        //此时可能已经加载完成，则忽略此error，继续进行加载。
        return;
    }
    
    [[MobileBankSession sharedInstance] hideMask];//隐藏等待遮罩层
    
    NSLog(@"失败加载的链接%@",webView.request.URL);
    
    DebugLog(@"webView didFailLoadWithError:");
    DebugLog(@"error code = %ld",(long)[error code]);
    DebugLog(@"domain = %@",[error domain]);
    DebugLog(@"userInfo = %@",[error userInfo]);
    DebugLog(@"FailureReason = %@",[error localizedFailureReason]);
    DebugLog(@"Description = %@",[error localizedDescription]);
    DebugLog(@"RecoverySuggestion = %@",[error localizedRecoverySuggestion]);
    DebugLog(@"helpAnchor = %@",[error helpAnchor]);
    
//    NSString *msg = [NSString stringWithFormat:@"web加载失败,原因:%@",[error localizedDescription]];
    NSString *msg = @"网络异常，如正在进行交易，请稍后核实交易状态，避免重复交易";
    [[[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil] show];
    
    if ([Context iPhone5]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}

#pragma mark - Button Action
-(void)hideBackButton{
    leftButton.hidden = YES;
}

-(void)leftButtonAction:(id)sender{
    //    [self.delegate webViewHomeButtonAction];
    [_webView.datePickerTF resignFirstResponder];
    _webView.isYaoYiYao = NO;
    NSLog(@"goback");
    [MobileBankSession sharedInstance].menuViewSlectedTag = [MobileBankSession sharedInstance].menuViewMidTag;
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.goBack()"];
    NSString *back = [_webView stringByEvaluatingJavaScriptFromString:resultString];
    [shahaiKeyBoard dissMiss:_webView.shahaiKeyBoard.myKeyboardView];
    _webView.frame = webFrame;
    _webView.ZZview.hidden = YES;
    if ([back isEqualToString:@"true"])
    {
        
    }
    else
    {
        if ([_actionId isEqualToString:@"EwmTransfer"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)rightButtonAction:(id)sender{
    
    [_webView.datePickerTF resignFirstResponder];
    [shahaiKeyBoard dissMiss:_webView.shahaiKeyBoard.myKeyboardView];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [MobileBankSession sharedInstance].menuViewSlectedTag = [MobileBankSession sharedInstance].menuViewMidTag;

}

#pragma mark - 清空web内容
-(void)clearWebContent
{    
    [_webView clearWebContent];
}

@end
