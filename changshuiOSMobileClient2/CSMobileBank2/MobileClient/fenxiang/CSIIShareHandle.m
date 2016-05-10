//
//  CSIIShareHandle.m
//
//  Created by 胡中楷 on 14-11-1.
//  Copyright (c) 2014年 胡中楷. All rights reserved.
//

#import "CSIIShareHandle.h"

#import "AppDelegate.h"


static CSIIShareHandle *handleInstance;

@implementation CSIIShareHandle
@synthesize SinaWBToken;
@synthesize itemFlag;
@synthesize TCAuthor;
@synthesize TCaccessToken;

+(id)ShareHandleInstance{
    if(handleInstance == nil){
        handleInstance = [[CSIIShareHandle alloc] init];
        handleInstance.itemFlag = @"";
        handleInstance.SinaWBToken = @"";
    }
    return handleInstance;
}

+ (BOOL)ShareIsNeedAuthor:(NSString *) shareSubtitle{
    if([shareSubtitle isEqualToString:@"sina"]){
        return YES;
    }else if ([shareSubtitle isEqualToString:@"qq"]){
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)ShareSearchIsFinishAuthor:(NSString *) shareSubtitle{
    if([shareSubtitle isEqualToString:@"sina"]){
        return ![self SinaWeiBoTokenIsInvalid];
    }else if ([shareSubtitle isEqualToString:@"qq"]){
        return ![self TencentTokenIsInvalid];
    }else{
        return NO;
    }
}

///////////////////////////////////////短信分享//////////////////////////////////

#pragma mark - 短信功能
-(void)showSMSPicker:(UIViewController *) ViewController{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil) {
        // Check whether the current device is configured for sending SMS messages
        if ([messageClass canSendText]) {
            [CSIIShareView shareViewHide];//隐藏分享视图
            [self displaySMSComposerSheet:ViewController];
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示信息" message:@"该设备不支持短信功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示信息" message:@"iOS版本过低,iOS4.0以上才支持程序内发送短信" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)displaySMSComposerSheet:(UIViewController *) controller
{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    NSString *smsBody =[NSString stringWithFormat:@"我分享了文件给您，地址是%@",@"http://www.baidu.com"] ;
    picker.body = smsBody;
    [controller presentViewController:picker animated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString *string = @"";
    if(result == MessageComposeResultCancelled){
        string = [string stringByAppendingString:@"用户取消操作"];
    }else if (result == MessageComposeResultSent){
        string = [string stringByAppendingString:@"发送成功"];
    }else if (result == MessageComposeResultFailed){
        string = [string stringByAppendingString:@"短信发送失败"];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alert show];
    }
    
    NSLog(@"短信处理结果_____%@",string);
    [controller dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////微信分享///////////////////////////////////////

#pragma mark - WXAPIDelegate
//onReq是微信终端向第三方程序发起请求，要求第三方程序响应。
//第三方程序响应完后必须调用sendRsp返回。
//在调用sendRsp返回时，会切回到微信终端程序界面。
- (void)onReq:(BaseReq *)req{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, (int)msg.thumbData.length];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}
//如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。
//sendReq请求调用后，会切到微信终端程序界面。
- (void)onResp:(BaseResp *)resp{
    //NSLog(@"________发送消息完成，收到回调。");
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"分享结果"];
        NSString *strMsg = @"";
        if(resp.errCode == 0){
            strMsg = @"分享成功";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
        }else if(resp.errCode != -2){
            strMsg = @"网络异常，如正在进行交易，请稍后核实交易状态，避免重复交易";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

////////////////////////////////////////////腾讯QQ登录授权////////////////////////////////////

- (void)TencentLogin{
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_INFO,
                            nil];
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    [handle.TCAuthor authorize:permissions inSafari:NO];
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin{
    NSLog(@"登陆成功\n____token:%@\n____有效期:%@\n____唯一标识:%@\n____AppKey:%@\n____回调地址:%@\n____本地标识:%@\n",TCAuthor.accessToken,TCAuthor.expirationDate,TCAuthor.openId,TCAuthor.appId,TCAuthor.redirectURI,TCAuthor.localAppId);
    [[NSUserDefaults standardUserDefaults] setObject:TCAuthor.accessToken forKey:@"TCtoken"];
    [[NSUserDefaults standardUserDefaults] setObject:TCAuthor.expirationDate forKey:@"TCdate"];
    [[NSUserDefaults standardUserDefaults] setObject:TCAuthor.openId forKey:@"TCopenID"];
    
    if([self.tencentDelegate performSelector:@selector(TencentLoginSuccess)]){
        [self.tencentDelegate TencentLoginSuccess];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    if(cancelled){
        [self.tencentDelegate TencentLoginFaield:@"用户取消登录操作"];
    }else{
        [self.tencentDelegate TencentLoginFaield:@"登录失败"];
    }
}

- (void)tencentDidNotNetWork{
    [self.tencentDelegate TencentNotNetWork];
}

- (void)tencentDidLogout{
    NSLog(@"____登出。");
    [self.tencentDelegate TencentDidLogout];
}

///////////////////////////////////////////////新浪分享///////////////////////////////////////

//登录
- (void)SinaWeiBoLogin:(id<CSIISinaAuthorViewControllerDelegate>) sinaLoginDelegate{
    //判断需要在哪一个平台上授权
    if([WeiboSDK isCanSSOInWeiboApp]){
        WBAuthorizeRequest *authorRequest = [WBAuthorizeRequest request];
        authorRequest.scope = @"all";
        authorRequest.redirectURI = kSinaRedirectURI;
        //是否是用户手动授权
        if(sinaLoginDelegate != nil){
            authorRequest.userInfo = [NSDictionary dictionaryWithObject:@"YES" forKey:@"handAuthorization"];
        }
        [WeiboSDK sendRequest:authorRequest];
    }else{
        //如不支持客户端授权，将使用自定义授权界面
        NSDictionary *authorInfo = [handleInstance SinaParamsWithKey:kSinaAppKey redirectUrl:kSinaRedirectURI andScope:@"all" State:@"0" DisplayType:@"mobile" forceLogin:NO Language:@""];
        CSIISinaAuthorViewController *author = [[CSIISinaAuthorViewController alloc] initWithParms:authorInfo andUrl:kSinaWeiboWebAuthURL];
        author.delegate = sinaLoginDelegate;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:author];
        UINavigationController *navv = (UINavigationController *)((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
        if(navv.viewControllers != nil){
            [CSIIShareView shareViewHide];
            [[navv.viewControllers objectAtIndex:0] presentModalViewController:nav animated:YES];
        }
    }
}

#pragma mark - SINADelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    NSLog(@"__________收到新浪客户端请求。");
    //提供分享信息给新浪客户端
    WBProvideMessageForWeiboResponse *response11 = [WBProvideMessageForWeiboResponse responseWithMessage:[handleInstance messageToSinaShareOnlyWords:@"常熟农商银行__咱家里的银行。"]];
    
    if ([WeiboSDK sendResponse:response11])
    {
        NSLog(@"_________哈哈哈");
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *errorString = @"";
        if(response.statusCode == WeiboSDKResponseStatusCodeSuccess){
            errorString = @"分享成功";
            WBAuthorizeResponse *res = ((WBSendMessageToWeiboResponse *)response).authResponse;
            //判断用户是否在分享过程中做了授权操作
            if(res){
                CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
                [[NSUserDefaults standardUserDefaults] setObject:res.userID forKey:@"sinaUserID"];
                [[NSUserDefaults standardUserDefaults] setObject:res.accessToken forKey:@"sinaToken"];
                [[NSUserDefaults standardUserDefaults] setObject:res.expirationDate forKey:@"sinaTokenDate"];
                handle.SinaWBToken = res.accessToken;
                handle.SinaWBTokenDate = res.expirationDate;
                handle.SinaWBUserID = res.userID;
            }
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
            errorString = @"取消";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeSentFail){
            errorString = @"发送失败";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeAuthDeny){
            errorString = @"授权失败";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancelInstall){
            errorString = @"取消安装";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeShareInSDKFailed){
            errorString = @"分享失败";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUnsupport){
            errorString = @"不支持";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUnknown){
            errorString = @"网络异常，如正在进行交易，请稍后核实交易状态，避免重复交易";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *errorString = @"";
        if(response.statusCode == WeiboSDKResponseStatusCodeSuccess){
            errorString = @"成功";
            //存储认证成功之后的token信息
            WBAuthorizeResponse *res = (WBAuthorizeResponse *)response;
            [[NSUserDefaults standardUserDefaults] setObject:res.userID forKey:@"sinaUserID"];
            [[NSUserDefaults standardUserDefaults] setObject:res.accessToken forKey:@"sinaToken"];
            [[NSUserDefaults standardUserDefaults] setObject:res.expirationDate forKey:@"sinaTokenDate"];
            CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
            handle.SinaWBToken = res.accessToken;
            handle.SinaWBTokenDate = res.expirationDate;
            handle.SinaWBUserID = res.userID;
            //判断用户是否是手动授权
            if(response.requestUserInfo == nil && ![[response.userInfo objectForKey:@"handAuthorization"] isEqualToString:@"YES"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sinaClietFinishLogin" object:nil];
            }
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
            errorString = @"取消";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeSentFail){
            errorString = @"发送失败";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeAuthDeny){
            errorString = @"授权失败";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancelInstall){
            errorString = @"取消安装";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeShareInSDKFailed){
            errorString = @"分享失败";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUnsupport){
            errorString = @"不支持";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUnknown){
            errorString = @"网络异常，如正在进行交易，请稍后核实交易状态，避免重复交易";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - 新浪登出代理
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"________响应。");
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result{
    NSLog(@"________完成。");
    if([request.tag isEqualToString:@"userLogout"]){
        NSLog(@"_____用户登出交易成功。");
    }else if ([request.tag isEqualToString:@"sendMessage"]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"分享成功" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"________error is %@",error);
}

/************************************腾讯QQ*********************************/
+ (BOOL)TencentTokenIsInvalid{
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    handle.TCaccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"TCtoken"];
    handle.TCexpirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"TCdate"];
    handle.TCopenID = [[NSUserDefaults standardUserDefaults] objectForKey:@"TCopenID"];
    NSDate *date = [NSDate date];
    NSComparisonResult result = [date compare:handle.TCexpirationDate];
    //比较有效期
    if(handle.TCaccessToken && handle.TCaccessToken.length > 0 && result == NSOrderedAscending){
        return NO;
    }else{
        return YES;
    }
}

/************************************QQ/微信*********************************/

- (void)messageToWeiXinNews:(NSString *)title Description:(NSString *)description content:(NSString *)content Image:(UIImage *)img URL:(NSString *)url shareScene:(int)Scene{
    WXMediaMessage *message = [WXMediaMessage message];//微信分享图片和链接
    if (Scene==WXSceneTimeline) {
        message.title = [NSString stringWithFormat:@"%@\n%@",title,description];
    }else{
    message.title = title;
    message.description = description;
    }
    [message setThumbImage:img];
    
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    message.mediaObject = ext;
    
    SendMessageToWXReq* rep = [[SendMessageToWXReq alloc] init];
    rep.message = message;
    rep.bText = NO;
    rep.scene = Scene;
    [WXApi sendReq:rep];
}
- (void)messageToWeiXinNews:(NSString *)title Description:(NSString *)description content:(NSString *)content  URL:(NSString *)url shareScene:(int)Scene{
    WXMediaMessage *message = [WXMediaMessage message];//微信分享文字和链接
   
    message.title = title;
    message.description = description;
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    message.mediaObject = ext;
    
    SendMessageToWXReq* rep = [[SendMessageToWXReq alloc] init];
    rep.message = message;
    rep.bText = YES;
    rep.scene = Scene;
    [WXApi sendReq:rep];
}
- (void)messageToWeiXinNews:(NSString *)title Description:(NSString *)description content:(NSString *)content Image:(UIImage *)img shareScene:(int)Scene{//微信分享图片
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:img];
    
    WXImageObject *ext = [WXImageObject object];
    NSData *imgData = UIImagePNGRepresentation(img);
    ext.imageData = imgData;
    message.mediaObject = ext;
    
    SendMessageToWXReq* rep = [[SendMessageToWXReq alloc] init];
    rep.message = message;
    rep.bText = NO;
    rep.scene = Scene;
    [WXApi sendReq:rep];
}



- (void)messageToTencentNews:(NSString *)title Description:(NSString *)description URL:(NSString *)url PreviewImgData:(NSData *) imgData//qq分享图片和链接
{
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:url]
                                title:title
                                description:description
                                previewImageData:imgData];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    //将内容分享到qq
    //QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    //将内容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    if(sent == EQQAPISENDSUCESS){
        NSLog(@"_____分享成功。");
    }
}

- (void)messageToTencentNews:(NSString *)title Description:(NSString *)description PreviewImgData:(NSData *) imgData
{//qq分享图片
    QQApiImageObject *newsObj = [QQApiImageObject objectWithData:imgData
                                               previewImageData:imgData
                                                          title:title
                                                    description:description];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    //将内容分享到qq
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    
    //将内容分享到qzone
//    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    if(sent == EQQAPISENDSUCESS){
        NSLog(@"_____分享成功。");
    }

}



/************************************新浪微博*********************************/
//判断新浪微博的token是否有效
+ (BOOL)SinaWeiBoTokenIsInvalid{
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    handle.SinaWBToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"sinaToken"];
    handle.SinaWBUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"sinaUserID"];
    handle.SinaWBTokenDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"sinaTokenDate"];
    NSDate *date = [NSDate date];
    NSComparisonResult result = [date compare:handle.SinaWBTokenDate];
    //比较有效期
    if(handle.SinaWBToken && (handle.SinaWBToken.length > 0 && result == NSOrderedAscending)){
        return NO;
    }else{
        return YES;
    }
}

//仅仅是文字信息
- (WBMessageObject *)messageToSinaShareOnlyWords:(NSString *)content{
    WBMessageObject *message = [WBMessageObject message];
    message.text = content;
    return message;
}
//文字和链接
- (WBMessageObject *)messageToSinaShareOnlyWords:(NSString *)content andUrl:(NSString *)url{
    WBMessageObject *message = [WBMessageObject message];
    message.text = content;
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.webpageUrl = url;
    return message;
}
//文字和图片的信息
- (WBMessageObject *)messageToSinaShareWords:(NSString *)content andImg:(UIImage *)image{
    WBMessageObject *message = [WBMessageObject message];
    message.text = content;
    WBImageObject *img = [WBImageObject object];
    img.imageData = UIImagePNGRepresentation(image);
    message.imageObject = img;
    return message;
}

//新闻信息
- (WBMessageObject *)messageToSinaShareNews:(NSString *)ID andTitle:(NSString *)title Description:(NSString *)description ImgSmall:(UIImage *)img Url:(NSString *)url{
    WBMessageObject *message = [WBMessageObject message];
    message.text = title;
//    UIImagePNGRepresentation(img);
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = ID;
    webpage.title = title;
    webpage.description = description;
    webpage.thumbnailData = UIImagePNGRepresentation(img);
    webpage.webpageUrl = url;
    
    message.mediaObject = webpage;
    return message;
}

//新浪授权参数
- (NSDictionary *)SinaParamsWithKey:(NSString *)Appkey redirectUrl:(NSString *)url andScope:(NSString *)scope State:(NSString *)state DisplayType:(NSString *)type forceLogin:(BOOL)value Language:(NSString *)language{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(Appkey){[dict setObject:Appkey forKey:@"client_id"];}
    if(url){[dict setObject:url forKey:@"redirect_uri"];}
    if(scope){[dict setObject:scope forKey:@"scope"];}
    if(state){[dict setObject:state forKey:@"state"];}
    if(type){[dict setObject:type forKey:@"display"];}
    if(value){[dict setObject:@"true" forKey:@"forcelogin"];}
    else{[dict setObject:@"false" forKey:@"forcelogin"];}
    if(language){[dict setObject:language forKey:@"language"];}
    return dict;
}

@end
