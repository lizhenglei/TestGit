//
//  agreementViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/5/6.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "agreementViewController.h"
#import "LabelButton.h"
#import "registerViewController.h"
@interface agreementViewController ()<MobileSessionDelegate>
{
    UITextView*Content;
    UILabel*titleLab;
    UIWebView*webview;
}
@end

@implementation agreementViewController
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"自助注册协议";

    NSMutableDictionary*dic = [[NSMutableDictionary alloc]init];
    [dic setObject:@"01" forKey:@"TreatyType"];
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"TreatyContent.do" actionParams:dic method:@"POST"];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Context setNSUserDefaults:@"noAgree" keyStr:@"agreeProtocol"];
    
    UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(15, 10, ScreenWidth-30, ScreenHeight-64-72-80)];
//    bg.layer.cornerRadius = 5.0f;
    bg.layer.masksToBounds =  YES;
    bg.layer.borderWidth = 1.0f;
    bg.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0.86 alpha:1.0] CGColor];
    bg.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.98 alpha:0.7];
    [self.view addSubview:bg];
    
//    titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bg.frame.size.width, 30)];
//    titleLab.backgroundColor = [UIColor clearColor];
//    titleLab.textAlignment = NSTextAlignmentCenter;
//    [bg addSubview:titleLab];
    
    webview = [[UIWebView alloc]initWithFrame:CGRectMake(10, 10, bg.frame.size.width-20, bg.frame.size.height-20)];
    webview.backgroundColor = [UIColor clearColor];
    [webview setOpaque:NO];
    [bg addSubview:webview];
    
    
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(15, ScreenHeight-72-64-60, bg.frame.size.width, 40)];
    [button setBackgroundColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f]];
    [button setTitle:@"同意" forState:UIControlStateNormal];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(buttonActionHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)buttonActionHandler:(UIButton*)btn{
    [Context setNSUserDefaults:@"Agree" keyStr:@"agreeProtocol"];
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{

    if ([action isEqualToString:@"TreatyContent.do"]){
        
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            
//            titleLab.text = [data objectForKey:@"Title"];
            NSString*str = [data objectForKey:@"Content"];
            [webview loadHTMLString:str baseURL:nil];
//            Content.text = str=nil?@"":str;
        }
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
