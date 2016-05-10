//
//  MySettingViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/4/28.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "MySettingViewController.h"
#import "SkyManagerViewController.h"
#import "GesturepasswordSettingViewController.h"
#import "ChangeLoginPasswordViewController.h"
#import "WebViewController.h"
#import "CSIIMenuViewController.h"
#import "XHDrawerController.h"

#define checkImgFrame2 CGRectMake(20,7,30,30)//二级菜单图片
#define checkNameFrame2 CGRectMake(65,12,120,20)//二级菜单名字
#define cellHight2 44
@interface MySettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray*textArray;
    NSMutableArray *imgeArray;
}
@property(nonatomic,strong)UITableView*tableView;
@end

@implementation MySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    textArray = [[NSMutableArray alloc]init];//WithObjects:@"登录密码修改",@"限额查询",@"预留信息设置",@"手势密码设置",@"主题皮肤",@"安全认证方式设置",@"我的主账户设置", nil];
    imgeArray = [[NSMutableArray alloc]init];
    for (int x = 0; x<self.menuArray.count; x++) {
        [textArray addObject:[[self.menuArray objectAtIndex:x] objectForKey:@"ActionName"]];
        [imgeArray addObject:[[self.menuArray objectAtIndex:x] objectForKey:@"ActionImage"]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"我的设置";
    
    [_tableView removeFromSuperview];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-100) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return textArray.count;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [NSString stringWithFormat:@"Cell%ld%ld",(long)indexPath.row,(long)indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
        
        [cell.contentView addSubview:bg];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:checkNameFrame2];
        nameLabel.text = textArray[indexPath.row];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:nameLabel];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:checkImgFrame2];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",imgeArray[indexPath.row],[MobileBankSession sharedInstance].changeSkinType]];
        //我的设置图片换肤
        [cell.contentView addSubview:imageView];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView*line = [[UIView alloc]initWithFrame:CGRectMake(5, cellHight2-1, tableView.frame.size.width-10, 1)];
        line.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
        if (indexPath.row!=textArray.count-1) {
            [cell.contentView addSubview:line];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary*nextMenu = [self.menuArray objectAtIndex:indexPath.row];
    
    NSString* Clickable = [nextMenu objectForKey:@"Clickable"];
    NSString*RoleCtr = [nextMenu objectForKey:@"RoleCtr"];
    
    if(Clickable!=nil && [Clickable isEqualToString:@"false"]){
        
        ShowAlertView(@"提示", @"功能暂不可用", nil, @"确认", nil);
        return;
    }
    
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserType"]isEqualToString:@""]&&![RoleCtr isEqualToString:@""]) {    //P 大众版  T专业版    “”游客
        NSLog(@"无权限");
        ShowAlertView(@"提示", @"您无权限操作此功能，请到柜台开通专业版手机银行！", nil, @"确认", nil);
        return;
    }
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserType"]isEqualToString:@"P"]&&[RoleCtr isEqualToString:@"T"]) {    //P 大众版  T专业版    “”游客
        NSLog(@"无权限");
        ShowAlertView(@"提示", @"您无权限操作此功能，请到柜台开通专业版手机银行！", nil, @"确认", nil);
        return;
    }
    
    if ([MobileBankSession sharedInstance].Userinfo!=nil&&![[[MobileBankSession sharedInstance].Userinfo objectForKey:@"Security"]isEqualToString:@"05"]&&[RoleCtr isEqualToString:@"U"]) {    //P 大众版  T专业版    “”游客
        NSRange ran = NSMakeRange(4, 1);
        NSString *string = [[[MobileBankSession sharedInstance].Userinfo objectForKey:@"SecurityFlag"] substringWithRange:ran];
        if ([string isEqualToString:@"1"]) {//0000101000
            ShowAlertView(@"提示", @"当前认证方式是“动态码＋交易密码”方式，请切换到“音频Key”方式！", nil, @"确认", nil);
            return;
        }
        else{
            NSLog(@"无权限");
            ShowAlertView(@"提示", @"您无权限操作此功能，请到柜台开通音频Key！", nil, @"确认", nil);
            return;
        }
    }

    
    if (((NSArray*)[nextMenu objectForKey:@"MenuList"]).count>0) {
        
        NSLog(@"二级菜单");
        MySettingViewController*mySettingView = [[MySettingViewController alloc]init];
        mySettingView.menuArray = [[NSMutableArray alloc]initWithArray:[nextMenu objectForKey:@"MenuList"]];
        [self.navigationController pushViewController:mySettingView animated:NO];
        
    }else if([[nextMenu objectForKey:@"EntryType"] isEqualToString:@"web"]){
        
        [[WebViewController sharedInstance]setActionId:[nextMenu objectForKey:@"ActionId"] actionName:[nextMenu objectForKey:@"ActionName"] prdId:[nextMenu objectForKey:@"ActionId"] Id:[nextMenu objectForKey:@"ActionId"]];
        [MobileBankSession sharedInstance].toPassiveActionId = [nextMenu objectForKey:@"ActionId"];
        [MobileBankSession sharedInstance].toPassiveActionName = [nextMenu objectForKey:@"ActionName"];
        [MobileBankSession sharedInstance].toPassiveActionPrdId = [nextMenu objectForKey:@"ActionId"];
        [MobileBankSession sharedInstance].toPassiveActionToId = [nextMenu objectForKey:@"ActionId"];
        [self.navigationController pushViewController:[WebViewController sharedInstance] animated:NO];
        
    }else if ([[nextMenu objectForKey:@"EntryType"] isEqualToString:@"native"]){
        
        if ([[nextMenu objectForKey:@"ActionId"] isEqualToString:@"5000011"]) { //登录密码修改
            ChangeLoginPasswordViewController*vc = [[ChangeLoginPasswordViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([[nextMenu objectForKey:@"ActionId"] isEqualToString:@"5000012"]) {  //手势密码
            
            GesturepasswordSettingViewController*vc = [[GesturepasswordSettingViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([[nextMenu objectForKey:@"ActionId"] isEqualToString:@"50000013"]) {  //主题皮肤
            SkyManagerViewController*skyController = [[SkyManagerViewController alloc]init];
            [self.navigationController pushViewController:skyController animated:YES];
            
        }else{
            ShowAlertView(@"提示", @"功能完善", nil, @"确认", nil);
        }
        
    }else{
        ShowAlertView(@"提示", @"菜单有误", nil, @"确认", nil);
        return;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHight2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    return footer;
}

//-(void)leftButtonAction:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//    [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
//
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
