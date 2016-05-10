//
//  MovieTicketsViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/8/12.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "MovieTicketsViewController.h"

@interface MovieTicketsViewController ()<UIWebViewDelegate>

@end

@implementation MovieTicketsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIWebView *webViewController = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44 - 60)];
    webViewController.delegate = self;
    self.view.backgroundColor = [UIColor clearColor];
    NSString *urlString = @"http://crcb.ikdy.com.cn";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:15.0f];
    [webViewController loadRequest:request];
    [self.view addSubview:webViewController];
    
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[MobileBankSession sharedInstance] showMask:nil maskMessage:@"请稍后..." maskType:Common];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
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
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = self.webViewName;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
