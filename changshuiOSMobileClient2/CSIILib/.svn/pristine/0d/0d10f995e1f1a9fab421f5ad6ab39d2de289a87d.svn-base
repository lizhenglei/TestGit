//
//  MobileBankStartWeb.m
//  MobileBankWeb
//
//  Created by Yuxiang on 13-6-8.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import "MobileBankStartWeb.h"
#import "MobileBankWeb.h"

@implementation MobileBankStartWeb

-(UIWebView *)startActionUrl:(NSString *)urlString WithFrame:(CGRect)rect{
    MobileBankWeb *web=[[MobileBankWeb alloc]initWithFrame:rect];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[self getStartWebUrl:urlString]]];
    [web loadRequest:request];
    return web;
}


-(NSString *)getStartWebUrl:(NSString *)url
{
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


@end
