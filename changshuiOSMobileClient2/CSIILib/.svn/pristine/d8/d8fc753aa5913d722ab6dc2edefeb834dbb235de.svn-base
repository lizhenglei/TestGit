//
//  TransResultViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/5/6.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "TransResultViewController.h"
#import "CSIIMenuViewController.h"
#import "XHDrawerController.h"
@interface TransResultViewController ()

@end

@implementation TransResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leftButton.hidden = YES;
    [self.view removeGestureRecognizer:self.Swipe];
    
    UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(10, 20, ScreenWidth-20, 200)];
    bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    [self.view addSubview:bg];
    
    UIImage*image = [UIImage imageNamed:@"finish_logo"];
    UIImageView*successImg = [[UIImageView alloc]initWithFrame:CGRectMake((bg.frame.size.width-image.size.width)/2, 30, image.size.width, image.size.height)];
    successImg.image = image;
    successImg.backgroundColor = [UIColor clearColor];
    [bg addSubview:successImg];
    
    UILabel*successTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 30+image.size.height+5, bg.frame.size.width, 40)];
    successTitle.backgroundColor = [UIColor clearColor];
    successTitle.textAlignment = NSTextAlignmentCenter;
    successTitle.textColor = [UIColor colorWithRed:0.00f green:0.31f blue:0.59f alpha:1.00f];
    successTitle.font = [UIFont boldSystemFontOfSize:20];
    successTitle.text = @"注册成功";
    [bg addSubview:successTitle];
    
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(10, bg.frame.size.height+30, bg.frame.size.width, 40)];
    [button setBackgroundColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f]];
    [button setTitle:@"登录" forState:UIControlStateNormal];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(gotoLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // Do any additional setup after loading the view.
}

-(void)gotoLogin:(UIButton*)btn{
    [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:NO];
    [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
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
