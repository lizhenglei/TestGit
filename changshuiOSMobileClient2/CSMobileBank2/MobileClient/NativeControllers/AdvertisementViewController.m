//
//  AdvertisementViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/7/30.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "AdvertisementViewController.h"

@interface AdvertisementViewController ()<UIWebViewDelegate>

@end

@implementation AdvertisementViewController//精彩活动里的页面跳到此处

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShowbottomMenus = NO;
    
    UIWebView *webViewController = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    webViewController.delegate = self;
    self.view.backgroundColor = [UIColor clearColor];
    NSURL *url = [NSURL URLWithString:_webUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:15.0f];
    [webViewController loadRequest:request];
    [self.view addSubview:webViewController];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = self.webTitleName;
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[MobileBankSession sharedInstance] showMask:nil maskMessage:@"请稍后..." maskType:Common];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    if (self.webTitleName.length==0) {
        ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取当前页面的title

    }
    [[MobileBankSession sharedInstance] hideMask];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求超时" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
