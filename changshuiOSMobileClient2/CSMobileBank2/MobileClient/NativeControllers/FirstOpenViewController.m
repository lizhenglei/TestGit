//
//  FirstOpenViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/6/16.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "FirstOpenViewController.h"
#import "Context.h"
@interface FirstOpenViewController ()<UIScrollViewDelegate>

@end

@implementation FirstOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView*scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -20, ScreenWidth, ScreenHeight+20)];
    scrollview.contentSize = CGSizeMake(4*ScreenWidth, ScreenHeight-20);
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.showsVerticalScrollIndicator = NO;
    scrollview.pagingEnabled = YES;
    [scrollview setBounces:NO]; //禁止回弹
    scrollview.delegate = self;
    
    UIButton*Start = [UIButton buttonWithType:UIButtonTypeCustom];
    [Start setBackgroundImage:[UIImage imageNamed:@"First_LoginBtn"] forState:UIControlStateNormal];
    Start.frame = CGRectMake(ScreenWidth/2-210/4, [Context iPhone4]?ScreenHeight-20-44-38:ScreenHeight-20-44-58, 210/2, 60/2);
    Start.backgroundColor = [UIColor clearColor];
    [Start addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    for (int x = 0; x < 4; x++) {
        UIImageView*imageview = [[UIImageView alloc]initWithFrame:CGRectMake(x*ScreenWidth, 0,ScreenWidth, ScreenHeight)];
        
        if (IOS8_OR_LATER) {
            imageview.image = [UIImage imageNamed:[NSString stringWithFormat:@"First2_%d",x]];
        }else{
            imageview.image = [UIImage imageNamed:[NSString stringWithFormat:@"First_%d",x]];
        }
        imageview.backgroundColor = [UIColor clearColor];
        imageview.userInteractionEnabled = YES;
        [scrollview addSubview:imageview];
        
        if (x==3) {
            [imageview addSubview:Start];
        }
    }
    [self.view addSubview:scrollview];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)startAction:(UIButton*)btn{
    
    [Context setNSUserDefaults:@"1" keyStr:@"isFirstOpenApp"];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
