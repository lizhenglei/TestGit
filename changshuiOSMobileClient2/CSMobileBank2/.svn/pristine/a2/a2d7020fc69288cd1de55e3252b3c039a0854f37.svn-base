//
//  CSIISinaAuthorViewController.m
//
//  Created by 胡中楷 on 14-11-1.
//  Copyright (c) 2014年 胡中楷. All rights reserved.
//

#import "CSIISinaAuthorViewController.h"
#import "CSIIShareHandle.h"

@interface CSIISinaAuthorViewController ()<WBHttpRequestDelegate>{
    UIWebView *_webView;//
    
    UIActivityIndicatorView *indicatorView;//活动指示器
    
    NSString *appRedirectURI;//回调地址
    
    NSDictionary *authParams;//请求参数
    
    NSString *requestUrl;//请求地址
    
    WBHttpRequest *authorRequest;//查询token请求
}

@end

@implementation CSIISinaAuthorViewController

#pragma mark - 初始化方法
- (id)initWithParms:(NSDictionary *)params andUrl:(NSString *)url{
    if ((self = [super init]))
    {
        self.title = @"分享到新浪微博";
        authParams = params;
        appRedirectURI = [authParams objectForKey:@"redirect_uri"];
        requestUrl = url;
        self.view.backgroundColor = [UIColor whiteColor];
        [self createViewForSinaAuthor];
    }
    return self;
}

- (void)createViewForSinaAuthor{
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                     UIActivityIndicatorViewStyleGray];
    indicatorView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:_webView];
    NSString *authPagePath = [self serializeURL:requestUrl
                                         params:authParams httpMethod:@"POST"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authPagePath]]];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(clickTopBtn:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    indicatorView.center = self.view.center;
    [indicatorView startAnimating];
    [self.view addSubview:indicatorView];
}

- (void)clickTopBtn:(UIBarButtonItem *) item{
    [authorRequest disconnect];//取消请求
    authorRequest.delegate = nil;//
    [self.delegate SinaAuthorViewUserCancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    NSLog(@"url = %@", url);
    NSString *siteRedirectURI = [NSString stringWithFormat:@"%@%@", kSinaWeiboSDKOAuth2APIDomain, appRedirectURI];
    if ([url hasPrefix:appRedirectURI] || [url hasPrefix:siteRedirectURI])
    {
        NSString *error_code = [self getParamValueFromUrl:url paramName:@"error_code"];
        if (error_code)
        {
            NSString *error = [self getParamValueFromUrl:url paramName:@"error"];
            NSString *error_uri = [self getParamValueFromUrl:url paramName:@"error_uri"];
            NSString *error_description = [self getParamValueFromUrl:url paramName:@"error_description"];
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       error, @"error",
                                       error_uri, @"error_uri",
                                       error_code, @"error_code",
                                       error_description, @"error_description", nil];
            
            [self.delegate SinaAuthorViewDidFailAndErrorInfo:errorInfo];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            NSString *code = [self getParamValueFromUrl:url paramName:@"code"];
            if (code)
            {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:code forKey:@"code"];
                [self selectSinaAccessToken:dict];
            }
        }
        return NO;
    }
    return YES;
}

#pragma mark -授权成功之后拿到code，通过code再查询token
- (void)selectSinaAccessToken:(NSDictionary *) authorCode{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          kSinaAppKey,@"client_id",
                          kSinaAppSecret,@"client_secret",
                          @"authorization_code",@"grant_type",
                          [authorCode objectForKey:@"code"],@"code",
                          kSinaRedirectURI,@"redirect_uri",
                          nil];
    //查询token信息
    authorRequest = [WBHttpRequest requestWithURL:kSinaWeiboWebAccessTokenURL httpMethod:@"POST" params:dict delegate:self withTag:@"selectAccessToken"];
}

#pragma mark - WBHTTPRequesDelegate
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error{
    if([request.tag isEqualToString:@"selectAccessToken"]){
        [self.delegate SinaAuthorViewDidFailAndErrorInfo:[NSDictionary dictionaryWithObject:@"授权失败" forKey:@"error"]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result{
    if([request.tag isEqualToString:@"selectAccessToken"]){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSArray *array = [result componentsSeparatedByString:@","];
        for (int i=0; i<array.count; i++) {
            NSString *tempStr = [array objectAtIndex:i];
            NSArray *tempArray = [tempStr componentsSeparatedByString:@":"];
            for (int j=0; j<tempArray.count; j++) {
                NSString *key = [tempArray objectAtIndex:0];
                key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                key = [key stringByReplacingOccurrencesOfString:@"{" withString:@""];
                NSString *value = [tempArray objectAtIndex:1];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                value = [value stringByReplacingOccurrencesOfString:@"}" withString:@""];
                [dict setObject:value forKey:key];
            }
        }
        NSRange range = [result rangeOfString:@"error"];
        if(range.location != NSNotFound){
            NSLog(@"___查询token失败。");
        }else{
            //储存授权之后拿到的token
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"uid"] forKey:@"sinaUserID"];
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"access_token"] forKey:@"sinaToken"];
            NSTimeInterval expires = [[dict objectForKey:@"expires_in"] doubleValue];
            NSDate *date = [[NSDate date] dateByAddingTimeInterval:expires];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"sinaTokenDate"];//计算出有效时间
        }
        [self.delegate SinaAuthorViewDidFinishAndAuthorInfo:dict];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)getParamValueFromUrl:(NSString*)url paramName:(NSString *)paramName
{
    if (![paramName hasSuffix:@"="])
    {
        paramName = [NSString stringWithFormat:@"%@=", paramName];
    }
    
    NSString * str = nil;
    NSRange start = [url rangeOfString:paramName];
    if (start.location != NSNotFound)
    {
        // confirm that the parameter is not a partial name match
        unichar c = '?';
        if (start.location != 0)
        {
            c = [url characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#')
        {
            NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location+start.length;
            str = end.location == NSNotFound ?
            [url substringFromIndex:offset] :
            [url substringWithRange:NSMakeRange(offset, end.location)];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return str;
}

- (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    NSURL* parsedURL = [NSURL URLWithString:baseURL];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator])
    {
        if (([[params objectForKey:key] isKindOfClass:[UIImage class]])
            ||([[params objectForKey:key] isKindOfClass:[NSData class]]))
        {
            if ([httpMethod isEqualToString:@"GET"])
            {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
        
        NSString* escaped_value =
        CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)[params objectForKey:key],NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
