//
//  GesturepasswordSettingViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/5/11.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "GesturepasswordSettingViewController.h"
#import "singleCheckButtonView.h"
#import "CustomAlertView.h"
#import "FirstChangePasswordViewController.h"
#import "GesturePasswordController.h"
#import "KeychainItemWrapper.h"
@interface GesturepasswordSettingViewController ()<UITableViewDataSource,UITableViewDelegate,SingleBtnDelegate,CustomAlertViewDelegate>
{
    UITableView*_tableView;
    NSArray*textArray;
    NSArray*rightArray;
    UISwitch*GestureSwit;
    CustomAlertView*gestureView;
}
@end

@implementation GesturepasswordSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    textArray = @[@"手势密码状态:",@"重置手势密码"];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];

    CGRect bigFrame = CGRectMake(255.f, 12.0f, 100.0f, 28.0f);
    
    GestureSwit = [[UISwitch alloc] initWithFrame:bigFrame];
    /*获取手势密码 判断是否为空*/
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    NSString* password = [keychin objectForKey:(__bridge id)kSecValueData];
    
    GestureSwit.on = password==nil||[password isEqualToString:@""]? NO:YES;//设置初始值
    [GestureSwit addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

}

-(void)initSwitch{
    
    /*获取手势密码 判断是否为空*/
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    NSString* password = [keychin objectForKey:(__bridge id)kSecValueData];
    GestureSwit.on = password==nil||[password isEqualToString:@""]? NO:YES;//设置初始值
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"手势密码设置";
}

-(void) switchAction:(id)sender
{
    UISwitch*swit = (UISwitch*)sender;
    if (swit.on == YES) {
        gestureView = [[CustomAlertView alloc]initReSetGesturePass:self];
        gestureView.customDelegate = self;
        [gestureView show];
    }else
        [GesturePasswordController clear];
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    NSString* password = [keychin objectForKey:(__bridge id)kSecValueData];
    GestureSwit.on = password==nil||[password isEqualToString:@""]? NO:YES;//设置初始值
    return password==nil||[password isEqualToString:@""]? 1:textArray.count;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, CellHeight)];
        bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
        
        [cell.contentView addSubview:bg];
        
        UILabel*title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, CellHeight)];
        title.backgroundColor = [UIColor clearColor];
        title.text = textArray[indexPath.row];
        title.font = [UIFont systemFontOfSize:14];
        title.lineBreakMode = NSLineBreakByCharWrapping;
        title.numberOfLines = 0;
        title.textAlignment = NSTextAlignmentRight;

        [cell.contentView addSubview:title];
        if (indexPath.row == 0) {
            [cell.contentView addSubview:GestureSwit];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
//        if (indexPath.row==1) {
//            if (GestureSwit.on == NO) {
//            }else{
//                title.textColor = [UIColor grayColor];
//            }
//        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIView*line = [[UIView alloc]initWithFrame:CGRectMake(5, CellHeight-1, tableView.frame.size.width-10, 1)];
        line.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
        if (indexPath.row!=textArray.count-1) {
            [cell.contentView addSubview:line];
        }
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row==1) {
        if (GestureSwit.on == NO) {
            
        }else{
            gestureView = [[CustomAlertView alloc]initReSetGesturePass:self];
            gestureView.customDelegate = self;
            [gestureView show];
        }
    }
}

#pragma mark ------GestureHidden--------
-(void)gestureExit:(CustomAlertView *)alert{
    [self initSwitch];
}

-(void)verGestureSucess:(CustomAlertView *)alert{
    [_tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CellHeight;
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

-(void)reGespasAction:(UIButton*)btn{

}

-(void)leftButtonAction:(id)sender{
    
//    UIViewController *vc = [self.navigationController.viewControllers lastObject];
//    if ([vc isKindOfClass:[FirstChangePasswordViewController class]]) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else
        [super leftButtonAction:sender];
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
