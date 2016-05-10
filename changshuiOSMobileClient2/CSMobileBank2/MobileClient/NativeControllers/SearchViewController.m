//
//  SearchViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/4/23.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "SearchViewController.h"
#import "CSIIMenuPaging.h"
#import "CSIIMenuViewController.h"
@interface SearchViewController ()<UITextFieldDelegate>
{
    CSIIMenuPaging*paging;
    NSMutableArray*menuListArray;        //存放所有的二级菜单
    NSMutableArray*menuArray;               //存放所有的一级菜单
    UILabel*resultLab;
    
    NSMutableArray*searchMenuArray;         //存放搜索出来的菜单
    UIButton *backGroundBtn;
    
    NSMutableArray*HotArray;             //存放热门搜索菜单
    UIScrollView *bgScrollView;
}
@end

@implementation SearchViewController
@synthesize searchTextfield;
@synthesize searchBtn;
@synthesize displayMenuArray;

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    searchTextfield = [[UITextField alloc]initWithFrame:CGRectMake(ScreenWidth/2-100, 7, 150, 28)];
    searchTextfield.backgroundColor = [UIColor whiteColor];
    searchTextfield.keyboardType = UIKeyboardTypeWebSearch;
    searchTextfield.layer.cornerRadius = 3;
    searchTextfield.layer.masksToBounds = YES;
    searchTextfield.delegate = self;
    //    searchTextfield.keyboardType
    [self.navigationController.navigationBar addSubview:searchTextfield];
    HotArray = [[NSMutableArray alloc]init];
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"CommentMenu.do" actionParams:nil method:@"POST"];
    
    searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(ScreenWidth/2+50-6, 7, 60, 28);
    searchBtn.layer.cornerRadius = 3;
    searchBtn.layer.masksToBounds = YES;
    searchBtn.backgroundColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f];
    [searchBtn addTarget:self action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:searchBtn];
    
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 30, ScreenHeight==480?160:220,ScreenHeight==480?160:220)];
    backgroundImageView.image = [UIImage imageNamed:@"watermark"];//水印
    backgroundImageView.userInteractionEnabled = YES;
    [bgScrollView addSubview:backgroundImageView];

    
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    backGroundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backGroundBtn.frame = self.view.bounds;
    [backGroundBtn addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backGroundBtn];
}
-(void)hideKeyboard
{
    [searchTextfield resignFirstResponder];
    [backGroundBtn removeFromSuperview];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    if (textField==searchTextfield) {
        [self searchBtnAction];
    }
    return YES;
}
-(void)createDownBtn
{
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,ScreenHeight==480?190:250, ScreenWidth-20, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.00f];
    [bgScrollView addSubview:lineView];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, lineView.frame.origin.y+10, 200, 20)];
    titleLabel.text = @"也许您需要查找：";
    titleLabel.textColor = [UIColor colorWithRed:0.35f green:0.35f blue:0.35f alpha:1.00f];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [bgScrollView addSubview:titleLabel];
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(10, titleLabel.frame.origin.y+20, ScreenWidth-20, 120)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    for (int i=0; i<HotArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:[UIColor colorWithRed:0.35f green:0.35f blue:0.35f alpha:1.00f] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(downBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.textAlignment = NSTextAlignmentLeft;
        btn.frame = CGRectMake(10+i%2*(ScreenWidth-40)/2, 10+i/2*40, (ScreenWidth-40)/2, 30);
        [btn setTitle:[HotArray[i] objectForKey:MENU_ACTION_NAME] forState:UIControlStateNormal];
        if (i>=0&&i<=3) {
            UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(10, btn.frame.origin.y+30, ScreenWidth-40, 0.5)];
            lineView2.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
            [backgroundView addSubview:lineView2];
        }
       
        [backgroundView addSubview:btn];
    }
    [bgScrollView addSubview:backgroundView];
}

-(void)downBtn:(UIButton *)sender
{
//    self.mobileBankSession.isMenuListViewController = NO;
    double firstAction=[[[NSUserDefaults standardUserDefaults]objectForKey:@"popTime"]doubleValue];
    double seconed=[self getCurrentTime];
    double offset=seconed-firstAction;
    
    DebugLog(@"%f %f %f",firstAction,seconed,offset);
    if (offset<1000 && offset!=0) {//解决连续点击菜单多次弹出手势密码的bug
        return;
    }

    
    [CSIIMenuViewController sharedInstance].menuSelectFlag = ESelectMenu;
    [CSIIMenuViewController sharedInstance].toClickable = [[HotArray objectAtIndex:sender.tag] objectForKey:MENU_ACTION_CLICKABLE];
    [CSIIMenuViewController sharedInstance].toIslogin = [[HotArray objectAtIndex:sender.tag] objectForKey:MENU_ACTION_ISLOGIN];
    [CSIIMenuViewController sharedInstance].toRoleCtr = [[HotArray objectAtIndex:sender.tag] objectForKey:MENU_ACTION_ROLECTR];
    [CSIIMenuViewController sharedInstance].toActionId = [[HotArray objectAtIndex:sender.tag] objectForKey:MENU_ACTION_ID];
    [CSIIMenuViewController sharedInstance].toActionName = [[HotArray objectAtIndex:sender.tag] objectForKey:MENU_ACTION_NAME];
    [CSIIMenuViewController sharedInstance].toPrdId = [[HotArray objectAtIndex:sender.tag] objectForKey:MENU_PRD_ID];
    [CSIIMenuViewController sharedInstance].toId = [[HotArray objectAtIndex:sender.tag] objectForKey:MENU_ID];
    [CSIIMenuViewController sharedInstance].toMenuArray = [[HotArray objectAtIndex:sender.tag] objectForKey:MENU_LIST];
    [CSIIMenuViewController sharedInstance].menuArrayIndex = sender.tag;

    [MobileBankSession sharedInstance].delegate = [CSIIMenuViewController sharedInstance];
    [MobileBankSession sharedInstance].isPassiveLoginDelegate = [CSIIMenuViewController sharedInstance];
    [[MobileBankSession sharedInstance] menuStartAction:[HotArray objectAtIndex:sender.tag]];
}
-(double )getCurrentTime{
    
    NSTimeInterval firstTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    double a=firstTime;
    
    [[NSUserDefaults  standardUserDefaults] setObject:[NSNumber numberWithDouble:a] forKey:@"popTime"];
    
    return a;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-78-64)];
    bgScrollView.contentSize = CGSizeMake(ScreenWidth-20, 160+ScreenHeight==480?160:220);
    bgScrollView.bounces = NO;
    bgScrollView.showsVerticalScrollIndicator = NO;
    bgScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgScrollView];
    
    menuArray = [[NSMutableArray alloc]init];
    menuListArray = [[NSMutableArray alloc]init];
    
    for (int x=0; x<displayMenuArray.count-1; x++) {      //去掉我的最爱菜单内容
        [menuArray addObject:[displayMenuArray[x+1]objectForKey:MENU_LIST]];      //menuArray为所有一级菜单
    }
    
    for (int x=0; x<menuArray.count; x++) {
        for (int j=0; j<((NSArray*)menuArray[x]).count; j++) {
            if (((NSMutableArray*)([menuArray[x][j] objectForKey:MENU_LIST])).count>0) {     //有二级菜单的时候
                [menuListArray addObject:[menuArray[x][j]objectForKey:MENU_LIST]];
            }
        }
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    self.searchTextfield.hidden = YES;
    self.searchBtn.hidden = YES;
    [self.searchTextfield resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == searchTextfield) {
        
        return YES;
    }
    return YES;
}



-(void)searchBtnAction
{
    [backGroundBtn removeFromSuperview];
//    if (searchTextfield.text==nil||[searchTextfield.text isEqualToString:@""]) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入搜索关键字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }

    [resultLab removeFromSuperview];

    if (paging!=nil) {
        [paging removeFromSuperview];
    }
    
    [self.searchTextfield resignFirstResponder];
    
    NSMutableArray*array = [[NSMutableArray alloc]init];
    
    for (int x=0; x<menuArray.count; x++) {
        for (int j=0; j<((NSArray*)menuArray[x]).count; j++) {
            if ([[menuArray[x][j] objectForKey:MENU_ACTION_NAME] rangeOfString:searchTextfield.text].location != NSNotFound) {
                NSLog(@"str1包含str2");
                [array addObject:menuArray[x][j]];
            }else{
                NSLog(@"str1不包含str2");
            }
        }
    }
    
    for (int x=0; x<menuListArray.count; x++) {
        for (int j=0; j<((NSArray*)menuListArray[x]).count; j++) {
            if ([[menuListArray[x][j] objectForKey:MENU_ACTION_NAME] rangeOfString:searchTextfield.text].location != NSNotFound) {
                NSLog(@"str1包含str2");
                [array addObject:menuListArray[x][j]];
            }else{
                NSLog(@"str1不包含str2");
            }
        }
    }
    
    resultLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    resultLab.textColor = [UIColor colorWithRed:0.35f green:0.35f blue:0.35f alpha:1.00f];
    resultLab.backgroundColor = [UIColor clearColor];
    resultLab.font = [UIFont boldSystemFontOfSize:15];
    resultLab.text = [NSString stringWithFormat:@"    共找到%lu个相关交易：",(unsigned long)array.count];
    resultLab.textAlignment = NSTextAlignmentLeft;
    [bgScrollView addSubview:resultLab];
    
    searchMenuArray = [[NSMutableArray alloc]initWithArray:array];
    paging = [[CSIIMenuPaging alloc]initWithFrame:CGRectMake(0, 30, ScreenWidth,ScreenHeight==480?160:220) WithIconArray:[array mutableCopy] pageDelegate:self iconButtonArray:nil iconLabelArray:nil iconLightArray:nil];
    paging.scrollView.scrollView.contentSize = CGSizeMake(ScreenWidth,((searchMenuArray.count-1)/4+1)*102);
    paging.scrollView.scrollView.pagingEnabled = NO;
    paging.backgroundColor = [UIColor clearColor];
    [bgScrollView addSubview:paging];
    
}

#pragma mark - menu button action 菜单按钮动作
-(void)menuButtonAction:(UIButton*)button{
    double firstAction=[[[NSUserDefaults standardUserDefaults]objectForKey:@"popTime"]doubleValue];
    double seconed=[self getCurrentTime];
    double offset=seconed-firstAction;
    
    DebugLog(@"%f %f %f",firstAction,seconed,offset);
    if (offset<1000 && offset!=0) {//解决连续点击菜单多次弹出手势密码的bug
        return;
    }

    
    DebugLog(@"menuButtonAction");
    [MobileBankSession sharedInstance].isMenuListViewController = NO;
    
    [CSIIMenuViewController sharedInstance].menuSelectFlag = ESelectMenu;
    [CSIIMenuViewController sharedInstance].toClickable = [[searchMenuArray objectAtIndex:button.tag] objectForKey:MENU_ACTION_CLICKABLE];
    [CSIIMenuViewController sharedInstance].toIslogin = [[searchMenuArray objectAtIndex:button.tag] objectForKey:MENU_ACTION_ISLOGIN];
    [CSIIMenuViewController sharedInstance].toRoleCtr = [[searchMenuArray objectAtIndex:button.tag] objectForKey:MENU_ACTION_ROLECTR];
    [CSIIMenuViewController sharedInstance].toActionId = [[searchMenuArray objectAtIndex:button.tag] objectForKey:MENU_ACTION_ID];
    
    [MobileBankSession sharedInstance].UserAnalysisActionId = [CSIIMenuViewController sharedInstance].toActionId;//行为轨迹分析
    
    [CSIIMenuViewController sharedInstance].toActionName = [[searchMenuArray objectAtIndex:button.tag] objectForKey:MENU_ACTION_NAME];
    [CSIIMenuViewController sharedInstance].toPrdId = [[searchMenuArray objectAtIndex:button.tag] objectForKey:MENU_PRD_ID];
    [CSIIMenuViewController sharedInstance].toId = [[searchMenuArray objectAtIndex:button.tag] objectForKey:MENU_ID];
    [CSIIMenuViewController sharedInstance].toMenuArray = [[searchMenuArray objectAtIndex:button.tag] objectForKey:MENU_LIST];
    [CSIIMenuViewController sharedInstance].menuArrayIndex = button.tag;
    
    [MobileBankSession sharedInstance].delegate = [CSIIMenuViewController sharedInstance];
    [MobileBankSession sharedInstance].isPassiveLoginDelegate = [CSIIMenuViewController sharedInstance];
    [[MobileBankSession sharedInstance] menuStartAction:[searchMenuArray objectAtIndex:button.tag]];
    
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
        if ([action isEqualToString:@"CommentMenu.do"]) {
            HotArray = [data objectForKey:@"List"];
            
            [self createDownBtn];
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
