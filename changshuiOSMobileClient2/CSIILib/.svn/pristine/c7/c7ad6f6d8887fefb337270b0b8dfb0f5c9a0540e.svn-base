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
    bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-64-50)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
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
    
    
    MAMapView *map = [[MAMapView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.view addSubview:map];
    map.showsUserLocation = YES;
    
    NSLog(@"%f",map.userLocation.coordinate.latitude);
    NSLog(@"%f",map.userLocation.coordinate.longitude);

//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"120.772135",@"Lon",@"31.651212",@"Lat",@"",@"KeyWords",@"5000",@"Distance",@"1",@"Flag", nil];
//    
//    [MobileBankSession sharedInstance].delegate = self;
//    [[MobileBankSession sharedInstance]postToServer:@"NetPointQry.do" actionParams:dic method:@"POST"];
    
    
}
#pragma CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *cl = [locations objectAtIndex:0];
    NSLog(@"纬度--%f",cl.coordinate.latitude);//纬度--31.651272
    NSLog(@"经度--%f",cl.coordinate.longitude);//经度--120.772112
    NSString *lon = [NSString stringWithFormat:@"%f",cl.coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",cl.coordinate.latitude];
    if (![MobileBankSession sharedInstance].isMapPosition) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:lon,@"Lon",lat,@"Lat",@"",@"KeyWords",@"5000",@"Distance",@"1",@"Flag", nil];

        [MobileBankSession sharedInstance].delegate = self;
        [[MobileBankSession sharedInstance]postToServer:@"NetPointQry.do" actionParams:dic method:@"POST"];

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
                keyWordsField = [[LWYTextField alloc]initWithFrame:CGRectMake(80, 5+i%3*45, ScreenWidth-100, 29)];
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
    [searchBtn setBackgroundColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f]];
    [searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:searchBtn];
}
-(void)createNetWorkUI
{
    [_detailMessageTableView removeFromSuperview];
    _detailMessageTableView = [[UITableView alloc]initWithFrame:CGRectMake(5,searchBtn.frame.origin.y+searchBtn.frame.size.height+5 , ScreenWidth-30, ScreenHeight-72-searchBtn.frame.size.height-searchBtn.frame.origin.y-64)];
    _detailMessageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _detailMessageTableView.delegate =self;
    _detailMessageTableView.dataSource =self;
    [bgView addSubview:_detailMessageTableView];
}
-(void)searchBtnClick
{
    [self.view endEditing:YES];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:selectType,@"BranchType",selectCityCode,@"CityCode",keyWordsField.text,@"KeyWords",@"2",@"Flag", nil];
    [[MobileBankSession sharedInstance]postToServer:@"NetPointQry.do" actionParams:dic method:@"POST"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
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
        
        UIButton *telephone = [UIButton buttonWithType:UIButtonTypeCustom];
        telephone.frame = CGRectMake(cell.contentView.frame.size.width/2+40, cell.view.frame.origin.y+3, 100, 30);
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 19, 19)];
        UILabel *telephoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 45, 30)];
        telephoneLabel.text = @"电话";
        telephoneLabel.font = [UIFont systemFontOfSize:15];
        [telephone addSubview:telephoneLabel];
        NSString *telephoneNumber = [netWorkArray [indexPath.section]objectForKey:@"Telephone"];
        
        if (telephoneNumber.length==0) {
            imageView2.image = [UIImage imageNamed:@"telephone2"];
            telephone.enabled = NO;
        }else{
            imageView2.image = [UIImage imageNamed:@"telephone"];
        }
        [telephone addSubview:imageView2];
        telephone.tag = indexPath.section+200;
        [telephone addTarget:self action:@selector(callTelephone:) forControlEvents:UIControlEventTouchUpInside];
        [telephone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell.contentView addSubview:telephone];
        NSString *nameString = nil;
        nameString = [netWorkArray[indexPath.section] objectForKey:@"BranchName"];
        
        if ([[netWorkArray[indexPath.section]objectForKey:@"BranchType"] isEqualToString:@"1"]) {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@%@",nameString,@"(网点)"];
        }
        if ([[netWorkArray[indexPath.section]objectForKey:@"BranchType"] isEqualToString:@"2"]){
            cell.nameLabel.text = [NSString stringWithFormat:@"%@%@",nameString,@"(ATM)"];
        }
        NSString *distanceString = [[netWorkArray objectAtIndex:indexPath.section] objectForKey:@"Distance"];
        if (distanceString.length==0) {
            cell.distanceLabel.text = @"未知";
        }else{
            CGFloat ff = [distanceString floatValue]/1000;
            cell.distanceLabel.text = [NSString stringWithFormat:@"%.1fKm",ff];
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
        dis = [NSString stringWithFormat:@"%.1f",ff];
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = @"网点查询";
    //    [self createUI];
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
    if ([action isEqualToString:@"NetPointQry.do"])
    {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]){
            NSLog(@"%@",data);
            netWorkArray = [[NSMutableArray alloc]initWithArray:[data objectForKey:@"List"]];
            
            if (netWorkArray.count==0) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有您所要查询的网点" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
