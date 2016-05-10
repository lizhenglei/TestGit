//
//  CommercialSearchViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/5/20.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "CommercialSearchViewController.h"
#import "MapDetailTableViewCell.h"
#import <MAMapKit/MAMapKit.h>
#import "CommercialViewController.h"

#import <CoreLocation/CoreLocation.h>
#import "WebViewController.h"
#define mapCellheight 90
#define kMaxLength 10//关键字搜索最多十个
@interface CommercialSearchViewController ()<CLLocationManagerDelegate,LWYPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    LWYTextField *selectCityField;//所在城市
    NSString *selectCityCode;
    LWYTextField *keyWordsField;//关键字
    LWYTextField *selectTypeField;//查询类型
    NSString *selectType;
    UITableView *_detailMessageTableView;
    UIButton *searchBtn;
    NSMutableArray *selectCities;
    NSString *BranchType;
    UIView *bgView;
    NSMutableArray *netWorkArray;
    CLLocationManager *lationManager;
    NSString *lon;
    NSString *lat;
    UIView *backView;
    UIButton *btn1;//网点查询
    UIView *bottomViewLine1;
    UIButton *btn2;//预约查询
    UIView *bottomViewLine2;
}
@end

@implementation CommercialSearchViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification"
                                                  object:keyWordsField];
        [MobileBankSession sharedInstance].isMapPosition = NO;
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectCities = [[NSMutableArray alloc]init];
    selectType = @"";
    self.view.userInteractionEnabled = YES;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
    backView = [[UIView alloc]initWithFrame:CGRectMake(10, 40, ScreenWidth-20, ScreenHeight-64-50)];
    [self.view addSubview:backView];
    bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth-20, ScreenHeight-64)];
    bgView.backgroundColor = [UIColor whiteColor];
    [backView addSubview:bgView];
    
    btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(10, 0, (self.view.frame.size.width-20)/2-1, 40);
    bottomViewLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, 38, self.view.frame.size.width/4-1, 2)];
    bottomViewLine1.backgroundColor = [UIColor colorWithRed:0.01f green:0.51f blue:1.00f alpha:1.00f];
    bottomViewLine1.center = CGPointMake(btn1.frame.size.width/2, 38);
    [btn1 addSubview:bottomViewLine1];
    [btn1 setTitle:@"网点查询" forState:UIControlStateNormal];
    btn1.tag = 1001;
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor colorWithRed:0.03f green:0.51f blue:0.96f alpha:1.00f]forState:UIControlStateSelected];
    btn1.selected = YES;
    btn1.backgroundColor = [UIColor whiteColor];
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-1, 5, 2, 30)];
    lineView.backgroundColor = [UIColor colorWithRed:0.93f green:0.93f blue:0.93f alpha:1.00f];
    [self.view addSubview:lineView];
    
    btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(self.view.frame.size.width/2+1, 0, (self.view.frame.size.width-20)/2-2, 40);
    [btn2 setTitle:@"我的预约" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn2.tag = 1002;
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor colorWithRed:0.03f green:0.51f blue:0.97f alpha:1.00f] forState:UIControlStateSelected];
    btn2.selected = NO;
    btn2.backgroundColor = [UIColor whiteColor];
    bottomViewLine2 = [[UIView alloc]initWithFrame:CGRectMake(0, 38, self.view.frame.size.width/4-1, 2)];
    bottomViewLine2.backgroundColor = [UIColor clearColor];
    bottomViewLine2.center = CGPointMake(btn2.frame.size.width/2, 38);
    [btn2 addSubview:bottomViewLine2];
    [self.view addSubview:btn2];
    
    
    lationManager = [[CLLocationManager alloc]init];//定位自己的经纬度
    lationManager.delegate =self;
    
    lationManager.desiredAccuracy = kCLLocationAccuracyBest;
    lationManager.distanceFilter = 500.0f; // distanceFilter是距离过滤器，为了减少对定位装置的轮询次数，位置的改变不会每次都去通知委托，而是在移动了足够的距离时才通知委托程序
    // 它的单位是米，这里设置为至少移动1000再通知委托处理更新;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [lationManager requestAlwaysAuthorization];//8.0以后的
        [lationManager requestWhenInUseAuthorization];
    }
    //    if([lationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
    //        [lationManager requestAlwaysAuthorization]; // 永久授权
    //        [lationManager requestWhenInUseAuthorization]; //使用中授权
    //    }
    
    [lationManager startUpdatingLocation];
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"NetPointCityQry.do" actionParams:nil method:@"POST"];
    
    //    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"120.772135",@"Lon",@"31.651212",@"Lat",@"",@"KeyWords",@"5000",@"Distance",@"1",@"Flag", nil];
    //
    //    [MobileBankSession sharedInstance].delegate = self;
    //    [[MobileBankSession sharedInstance]postToServer:@"NetPointQry.do" actionParams:dic method:@"POST"];
    
    
}
-(void)btnClick:(UIButton *)sender
{
    if (sender.tag==1001) {//网点查询
        [WebViewController sharedInstance].view.hidden=YES;
        sender.selected = YES;
        bottomViewLine1.backgroundColor = [UIColor colorWithRed:0.01f green:0.51f blue:1.00f alpha:1.00f];
        bottomViewLine2.backgroundColor = [UIColor clearColor];
        btn2.selected = NO;
    }else{
        sender.selected = YES;
        bottomViewLine2.backgroundColor = [UIColor colorWithRed:0.01f green:0.51f blue:1.00f alpha:1.00f];
        bottomViewLine1.backgroundColor = [UIColor clearColor];
        btn1.selected = NO;
        [[WebViewController sharedInstance].view removeFromSuperview];
        [WebViewController sharedInstance].view.hidden = NO;
        [[WebViewController sharedInstance] setActionId:@"MyOrder" actionName:nil prdId:nil Id:nil];
        [WebViewController sharedInstance].view.frame = CGRectMake(-10, -20, self.view.bounds.size.width, ScreenHeight - 64);
        [bgView addSubview:[WebViewController sharedInstance].view];
    }
}
#pragma CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *cl = [locations objectAtIndex:0];
    NSLog(@"纬度--%f",cl.coordinate.latitude);//纬度--31.651272
    NSLog(@"经度--%f",cl.coordinate.longitude);//经度--120.772112
    lon = [NSString stringWithFormat:@"%f",cl.coordinate.longitude];
    lat = [NSString stringWithFormat:@"%f",cl.coordinate.latitude];
    if (![MobileBankSession sharedInstance].isMapPosition) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:lon,@"Lon",lat,@"Lat",@"",@"KeyWords",@"5000",@"Distance",@"1",@"Flag", nil];
        
        [MobileBankSession sharedInstance].delegate = self;
        [[MobileBankSession sharedInstance]postToServer:@"NetPointQry.do" actionParams:dic method:@"POST"];
        [MobileBankSession sharedInstance].isMapPosition = YES;
    }
    
}


//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    NSLog(@"Location error!");
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定位失败,请手动搜索" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
//}

-(void)createUI
{
    NSArray *titleTextArray = @[@"选择城市:",@"关键字:",@"查询类型:"];
    NSArray *searchTypeArray = @[@"全部",@"网点",@"ATM"];
    NSMutableArray *citeArr = [[NSMutableArray alloc]init];
    keyWordsField = [[LWYTextField alloc]init];
    keyWordsField.placeholder = @"最多输入10个字";
    for (int i=0; i<3; i++) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 8+i%3*40, 70, 30)];
        titleLabel.text = [titleTextArray objectAtIndex:i];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:titleLabel];
        if (i==0) {
            for (int i=0; i<selectCities.count; i++) {
                [citeArr addObject:[selectCities [i]objectForKey:@"CityName"]];
            }
            selectCityField = [[LWYTextField alloc]initPicerViewWithFrame:CGRectMake(80, 8+i%3*45, ScreenWidth-100, 29) picerDataArray:citeArr];
            [bgView addSubview:selectCityField];
            selectCityField.pickerViewDelegate = self;
            selectCityField.tag = 1;
            [self.inputControls addObject:selectCityField];
        }else{
            if (i==1) {
                keyWordsField.frame = CGRectMake(80, 5+i%3*45, ScreenWidth-100, 29);
                [bgView addSubview:keyWordsField];
                
                keyWordsField.tag = 2;
                keyWordsField.delegate = self;
                [self.inputControls addObject:keyWordsField];
            }
            if (i==2) {
                selectTypeField = [[LWYTextField alloc]initPicerViewWithFrame:CGRectMake(80, i%3*45-1, ScreenWidth-100, 29) picerDataArray:(NSMutableArray *)searchTypeArray];
                [bgView addSubview:selectTypeField];
                selectTypeField.pickerViewDelegate = self;
                selectTypeField.tag = 3;
                [self.inputControls addObject:selectTypeField];
            }
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(5,5+i%3*40-2, ScreenWidth-30, 0.5)];
            view.backgroundColor = [UIColor grayColor];
            [bgView addSubview:view];
        }
    }
    searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(5, 5+3*40+2, ScreenWidth-30, 30);
    [searchBtn setTitle:@"查询" forState:UIControlStateNormal];
    searchBtn.layer.cornerRadius = 3;
    searchBtn.layer.masksToBounds = YES;
    [searchBtn setBackgroundColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f]];
    [searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:searchBtn];
}
-(void)createNetWorkUI
{
    [_detailMessageTableView removeFromSuperview];
    _detailMessageTableView = [[UITableView alloc]initWithFrame:CGRectMake(5,searchBtn.frame.origin.y+searchBtn.frame.size.height+5 , ScreenWidth-30, ScreenHeight-72-searchBtn.frame.size.height-searchBtn.frame.origin.y-64-40)];
    _detailMessageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _detailMessageTableView.delegate =self;
    _detailMessageTableView.dataSource =self;
    [bgView addSubview:_detailMessageTableView];
    [bgView sendSubviewToBack:_detailMessageTableView];
}
-(void)searchBtnClick
{
    [self.view endEditing:YES];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:lon,@"Lon",lat,@"Lat",selectType,@"BranchType",selectCityCode,@"CityCode",keyWordsField.text,@"KeyWords",@"2",@"Flag", nil];
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"NetPointQry.do" actionParams:dic method:@"POST"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    footer.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
    return footer;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return netWorkArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return mapCellheight;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"Section%ldCell%ld",(long)indexPath.section,(long)indexPath.row];
    //    NSString *cellID = @"cell";
    MapDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell = [[MapDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        UIButton *telephoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *telephoneNumber = [netWorkArray [indexPath.section]objectForKey:@"Telephone"];
        
        telephoneBtn.frame = CGRectMake(cell.view.frame.size.width-90, 5, 20, 20);
        [telephoneBtn setImage:[UIImage imageNamed:@"telephone"] forState:UIControlStateNormal];
        [telephoneBtn setImage:[UIImage imageNamed:@"telephone2"] forState:UIControlStateSelected];
        if (telephoneNumber.length>0) {
            telephoneBtn.selected = NO;
            telephoneBtn.enabled = YES;
        }else{
            telephoneBtn.selected = YES;
            telephoneBtn.enabled = NO;
        }
        telephoneBtn.tag = indexPath.section+200;
        [telephoneBtn addTarget:self action:@selector(callTelephone:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:telephoneBtn];
        
        
        UIButton *daoHhangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        daoHhangBtn.frame = CGRectMake(cell.contentView.frame.size.width/2-120, cell.view.frame.origin.y+3, 70, 30);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 3, 23, 23)];
        imageView.image = [UIImage imageNamed:@"navi_icon"];
        [daoHhangBtn addSubview:imageView];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 45, 30)];
        label.text = @"地图";
        [daoHhangBtn addSubview:label];
        label.font = [UIFont systemFontOfSize:15];
        daoHhangBtn.tag = indexPath.section+100;
        [daoHhangBtn addTarget:self action:@selector(daoHang:) forControlEvents:UIControlEventTouchUpInside];
        [daoHhangBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell.contentView addSubview:daoHhangBtn];
        
        UIButton *appointmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        appointmentBtn.frame = CGRectMake(cell.contentView.frame.size.width/2+40, cell.view.frame.origin.y+3, 100, 30);
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 19, 19)];
        imageView2.image = [UIImage imageNamed:@"yuyue"];
        UILabel *telephoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 45, 30)];
        telephoneLabel.text = @"预约";
        telephoneLabel.font = [UIFont systemFontOfSize:15];
        [appointmentBtn addSubview:telephoneLabel];
        [appointmentBtn addSubview:imageView2];
        appointmentBtn.tag = indexPath.section+200;
        [appointmentBtn addTarget:self action:@selector(appointmentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [appointmentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell.contentView addSubview:appointmentBtn];
        NSString *nameString = nil;
        nameString = [netWorkArray[indexPath.section] objectForKey:@"BranchName"];
        
        if ([[netWorkArray[indexPath.section]objectForKey:@"BranchType"] isEqualToString:@"1"]) {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@%@",nameString,@"(网点)"];
        }
        if ([[netWorkArray[indexPath.section]objectForKey:@"BranchType"] isEqualToString:@"2"]){
            cell.nameLabel.text = [NSString stringWithFormat:@"%@%@",nameString,@"(ATM)"];
        }
        
        if ([[netWorkArray[indexPath.section]objectForKey:@"flag"]isEqualToString:@"1"]) {
            appointmentBtn.enabled = YES;//可预约
        }else
        {
            appointmentBtn.enabled = NO;//不可预约
            telephoneLabel.textColor = [UIColor grayColor];
            telephoneLabel.alpha = 0.8f;
        }
        
        
        NSString *distanceString = [[netWorkArray objectAtIndex:indexPath.section] objectForKey:@"Distance"];
        if (distanceString.length==0) {
            cell.distanceLabel.text = @"未知";
        }else{
            CGFloat ff = [distanceString floatValue]/1000;
            cell.distanceLabel.text = [NSString stringWithFormat:@"%.2fkm",ff];
        }
        cell.locationLabel.text = [netWorkArray [indexPath.section]objectForKey:@"Address"];
        cell.contentView.layer.borderColor = [[UIColor grayColor]CGColor];
        cell.contentView.layer.borderWidth = 0.5f;
        cell.contentView.layer.cornerRadius = 5;
        cell.contentView.layer.masksToBounds = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
-(void)daoHang:(UIButton *)sender
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSString stringWithFormat:@"%@",[netWorkArray[sender.tag-100]objectForKey:@"Lat"]] forKey:@"Latitude"];
    [dic setObject:[NSString stringWithFormat:@"%@",[netWorkArray[sender.tag -100]objectForKey:@"Lon"]] forKey:@"Longitude"];
    [dic setObject:[netWorkArray[sender.tag-100]objectForKey:@"BranchName"] forKey:@"LocationName"];
    [dic setObject:[netWorkArray[sender.tag-100]objectForKey:@"Address"] forKey:@"LocationPlace"];
    [dic setObject:[netWorkArray[sender.tag-100]objectForKey:@"Telephone"] forKey:@"Telephone"];
    [dic setObject:[netWorkArray[sender.tag-100]objectForKey:@"BranchType"] forKey:@"BranchType"];
    NSString *dis = nil;
    if (((NSString *)[netWorkArray[sender.tag - 100] objectForKey:@"Distance"]).length==0) {
        dis = @"未知";
    }else{
        CGFloat ff = [[netWorkArray[sender.tag - 100] objectForKey:@"Distance"] floatValue]/1000;
        dis = [NSString stringWithFormat:@"%.2f",ff];
    }
    [dic setObject:dis forKey:@"Distance"];
    
    CommercialViewController *cvc = [[CommercialViewController alloc]initWithDetailMessage:dic];
    [self.navigationController pushViewController:cvc animated:YES];
}
-(void)callTelephone:(UIButton *)sender
{
    NSString *numberString = [netWorkArray[sender.tag-200]objectForKey:@"Telephone"];
    [self makeACall:numberString];
}
- (void) makeACall:(NSString *)phoneNum {//打电话，先弹框再打电话
    NSString *num = [[NSString alloc] initWithFormat:@"telprompt:%@",phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
}
-(void)appointmentBtnClick:(UIButton *)sender
{
    NSLog(@"%@",[netWorkArray[sender.tag-200]objectForKey:@"BranchName"]);
    NSString *branchId = [netWorkArray[sender.tag-200]objectForKey:@"BranchId"];
    NSString *branceName = [netWorkArray[sender.tag-200]objectForKey:@"BranchName"];
    
    [MobileBankSession sharedInstance].yuYueBranchId = branchId;
    [MobileBankSession sharedInstance].yuYueBranchName = branceName;
    
    btn2.selected = YES;
    bottomViewLine2.backgroundColor = [UIColor colorWithRed:0.01f green:0.51f blue:1.00f alpha:1.00f];
    bottomViewLine1.backgroundColor = [UIColor clearColor];
    btn1.selected = NO;
    [[WebViewController sharedInstance].view removeFromSuperview];
    [WebViewController sharedInstance].view.hidden = NO;
    [[WebViewController sharedInstance] setActionId:@"OnLineOrder" actionName:nil prdId:nil Id:nil];
    [WebViewController sharedInstance].view.frame = CGRectMake(-10, 0, self.view.bounds.size.width, ScreenHeight - 64);
    [bgView addSubview:[WebViewController sharedInstance].view];
    [bgView sendSubviewToBack:_detailMessageTableView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = @"网点查询";
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [WebViewController sharedInstance].view.hidden = NO;
    
}
-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    if ([action isEqualToString:@"NetPointCityQry.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]){
            selectCities = [data objectForKey:@"List"];
            selectCityCode = [selectCities[0]objectForKey:@"CityCode"];
            [self createUI];
        }else{
            
        }
    }
    else if ([action isEqualToString:@"NetPointQry.do"])
    {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]){
            NSLog(@"%@",data);
            netWorkArray = [[NSMutableArray alloc]initWithArray:[data objectForKey:@"List"]];
            
            if (netWorkArray.count==0) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有查询到相关信息" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert show];
                //          return;
            }
            else{
                //利用数组的sortedArrayUsingComparator调用 NSComparator ，obj1和obj2指的数组中的对象,排序
                NSComparator cmptr = ^(id obj1, id obj2){
                    if ([[obj1 objectForKey:@"Distance"]floatValue] > [[obj2 objectForKey:@"Distance"]floatValue]) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    
                    if ([[obj1 objectForKey:@"Distance"]floatValue] < [[obj2 objectForKey:@"Distance"]floatValue]) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                };
                
                NSArray*sortArray = [[NSArray alloc]initWithArray:netWorkArray];
                
                //第一种排序
                netWorkArray = (NSMutableArray*)[sortArray sortedArrayUsingComparator:cmptr];
            }
            
            [self createNetWorkUI];
        }
        else{
            
        }
    }
}
-(void) myPickerView:(LWYTextField *)pickerView DidSlecetedAtRow:(int) row
{
    if (pickerView.tag==1) {
        selectCityCode = [selectCities[row]objectForKey:@"CityCode"];
    }else if (pickerView.tag ==3)
    {
        if (row==0) {
            selectType = @"";
        }else{
            selectType = [NSString stringWithFormat:@"%d",row];
        }
    }
}
-(void)textFiledEditChanged:(NSNotification *)obj{//限制搜索关键字个数10个
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

@end
