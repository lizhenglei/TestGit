//
//  CSIIMenuListViewController.m
//  MobileClient
//
//  Created by shuangchun che on 13-7-24.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#import "CSIIMenuListViewController.h"
#import "CSIIMenuViewController.h"
#import "LWYGlobalVariable.h"
#import "XHDrawerController.h"
#import "KeychainItemWrapper.h"
#import "CSIIConfigDeviceInfo.h"
#import "JSONKit.h"
#import "UITableViewCell+Image.h"
#import "BindingEquipmentViewController.h"
//二维码
#import <ZXingWidgetController.h>

#import "QRCodeReader.h"

#import <Decoder.h>

#import <TwoDDecoderResult.h>

#import "PiontStoreViewController.h"
//功能页面
#import "BusinessCalendarViewController.h"
#import "GesturePasswordController.h"
#define bottomLabelColor [UIColor orangeColor]


@interface CSIIMenuListViewController ()<ZXingDelegate,UIImagePickerControllerDelegate,DecoderDelegate,UINavigationControllerDelegate>
{
    NSString * _actionId;//自己的actionid
    NSString * _actionName;//自己的actionName;
    NSArray *toMenuArray;//下级菜单
    NSString *toActionId;//下级actionid
    NSString *toActionName;//下级actionName
    NSString *toPrdId;//下级PrdId,同网银菜单中的PrdId一致
    NSString *toId;//下级Id,同网银菜单中的Id一致
    NSString *toClickable;//下级Clickable    判断是否可点击
    NSString *toIslogin;//下级Islogin        是否需要登录权限
    NSString *toRoleCtr;//下级RoleCtr        大众版或专业版
    UIButton *backButton;//返回按钮
    
    NSString *IdStr;         //如果调用的是同一交易  做判断
    
    //    UIImageView *reelbg;
    //    UIImageView *upReel;
    //    UIImageView *downReel;
    
    UIImageView *menuView;
    //    UILabel *titleLabel;
    NSArray *displayMenuArray;
    NSMutableDictionary* actionList;
    
    UIView *bottomMenuView;
    
    UIViewController *nativeVC;
//    CustomAlertView * alertLoginView;
    
    NSTimer *timer;
    NSString*timeString;
    
    UIImageView*selectedBG;
    int _selectedTag;
    int _selectedTag2;
    NSMutableArray *barButtonItemArray;
    NSString*timeStamp;
    
    NSString*password;
    UIImagePickerController *picker;
    ZXingWidgetController *ZXingController;
    
    int urlPathRow;
    
    
}
@end

@implementation CSIIMenuListViewController

@synthesize menuTable;
@synthesize rightBarItem;

-(id)initWithDisplayList:(NSArray*)dicList actionId:(NSString*)actionId actionName:(NSString *)actionName{
    if (self = [super init]) {
        displayMenuArray = [[NSArray alloc]initWithArray:dicList];
        _actionId = actionId;
        _actionName=actionName;
        self.view.userInteractionEnabled=YES;
        barButtonItemArray = [[NSMutableArray alloc]init];
        picker = [[UIImagePickerController alloc] init];

    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.backgroundView.frame = [CSIIUtility getRectAdd:self.backgroundView.frame x:0 y:-[Context navigationBarHeight] width:0 height:0];
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    
    menuTable = [[UITableView alloc]initWithFrame:CGRectMake(3, 3, self.view.bounds.size.width-6, self.view.bounds.size.height-105) style:UITableViewStylePlain];
    self.menuTable.backgroundView=nil;
    menuTable.scrollEnabled=YES;
    self.menuTable.backgroundColor=[UIColor clearColor];
    menuTable.delegate=self;
    menuTable.dataSource=self;
    menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    menuTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:menuTable];
}

+(CSIIMenuListViewController *)sharedInstance {
    static CSIIMenuListViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSIIMenuListViewController alloc] init];
    });
    return sharedInstance;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIView* view = [self.navigationController.navigationBar viewWithTag:5000];
    [view removeFromSuperview];
    
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = _actionName;
    NSLog(@"%@",[self.navigationController.navigationBar viewWithTag:99]);
    [MobileBankSession sharedInstance].delegate = self;
    self.navigationController.toolbarHidden = YES;
    [CSIIMenuViewController sharedInstance].navilogo.hidden = YES;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 会话模块--打开下级页面方式

-(void)OpenNextView:(OpenMode)mode{
    DebugLog(@"CSIIMenuListViewController, OpenNextView, mode = %d",mode);
    
    /*获取手势密码 判断是否为空*/
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];
    
    switch (mode) {
        case ENoAuthority:
        {
            
        }
            break;
        case ENativeList:
        {
            if (toMenuArray!=nil && ((NSArray*)toMenuArray).count>0)
            {
                //有下一级菜单
                CSIIMenuListViewController *vc = [[CSIIMenuListViewController alloc]initWithDisplayList:toMenuArray actionId:toActionId actionName:toActionName];
                vc.rightBarItem = self.rightBarItem;
                self.mobileBankSession.recentlyMenuGrade += 1;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }
            break;
        case ENative:
        {
//            [MobileBankSession sharedInstance].isLogin = YES;    //测试用
            if ([toIslogin isEqualToString:@"true"]&&[MobileBankSession sharedInstance].isLogin == NO) {
                //被动登录  手势或者手机号登录
                
                if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码且设置过手势密码
                    //时间过期提示
                    [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {//[Context getNSUserDefaultskeyStr:@"LastLoginTime"]
                        if ([[MobileBankSession sharedInstance]last:[Context getNSUserDefaultskeyStr:@"LastLoginTime"] now:[data objectForKey:@"_sysDate"]]>30*24) {
                            
                            [GesturePasswordController clear];
//                            [Context setNSUserDefaults:@"yes" keyStr:@"isFirstLogin"];
                            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手势密码过期，请使用其他方式登录" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                            alert.tag = 123;
                            [alert show];
                            
                        }else{
                            self.loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                            [self.loginAlertView show];
                        }
                    }];
                }else
                    [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                return;
            }
            if ([toActionId isEqualToString:@"20000121"]) {//二维码转账
                if (IOS7_OR_LATER) {//扫一扫
                    NSString *mediaType = AVMediaTypeVideo;
                    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                        ShowAlertView(@"提示", @"此应用没有权限来访问您的相机,请在设备的'设置-隐私-相机'中启用访问", nil, @"确认", nil);
                        return;
                    }
                }
                ZXingWidgetController *widController = [[ZXingWidgetController alloc]initWithDelegate:self showCancel:YES OneDMode:NO showLicense:NO];
                NSMutableSet *readers = [[NSMutableSet alloc] init];
                QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
                [readers addObject:qrcodeReader];
                widController.readers = readers;
                
                [self presentViewController:widController animated:NO completion:^{}];
                return;
            }

            nativeVC = [[CSIIMenuViewController sharedInstance] getNativeViewControllerWithActionId:toActionId prdId:toPrdId Id:toId];
            self.mobileBankSession.delegate = self;
            if(nativeVC!=nil){
                NSString *postActionName = [[NSString alloc] init];
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                IdStr = @"";
                
                //                if ([toActionId isEqualToString:@"AccountQry"]) {   //账户查询
                //                    postActionName = @"ActViewFroBalPre.do";
                //
                //                }
                if ([toActionId isEqualToString:@"20000172"]) {
                    BusinessCalendarViewController*vc = [[BusinessCalendarViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                    return;
                }
               else if ([toActionId isEqualToString:@"SigningAgreement"]) {
                    [self.navigationController pushViewController: nativeVC animated:YES];
                    return ;
                }
                else
                {
                    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示！" message:@"功能完善中" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                self.mobileBankSession.delegate = self;
                [self.mobileBankSession postToServer:postActionName actionParams:param method:@"POST"];
                
                //                menuSelectFlag = ESelectNone;
            }
        }
            break;
        case EWeburl:
        {
//            [MobileBankSession sharedInstance].isLogin = YES;    //测试用
            if ([toIslogin isEqualToString:@"true"]&&[MobileBankSession sharedInstance].isLogin == NO) {
                //被动登录  手势或者手机号登录
                
                if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码且设置过手势密码
                    //时间过期提示
                    [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {//[Context getNSUserDefaultskeyStr:@"LastLoginTime"]
                        if ([[MobileBankSession sharedInstance]last:[Context getNSUserDefaultskeyStr:@"LastLoginTime"] now:[data objectForKey:@"_sysDate"]]>30*24) {
                            
                            [GesturePasswordController clear];
//                            [Context setNSUserDefaults:@"yes" keyStr:@"isFirstLogin"];
                            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手势密码过期，请使用其他方式登录" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                            alert.tag = 123;
                            [alert show];
                            
                        }else{
                            self.loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                            [self.loginAlertView show];
                        }
                    }];
                }else
                    [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                return;
            }
            
            if ([toIslogin isEqualToString:@"true"]&&[MobileBankSession sharedInstance].isLogin == YES) {
                if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"] length]==0||[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"]isEqualToString:@""]) {
                    
                    NSArray *AcArray = [[NSArray alloc]initWithArray:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"AcList"]];
                    for (int i=0; i<AcArray.count; i++) {
                        if (![[AcArray[i] objectForKey:@"AcType"]isEqualToString:@"4"]) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您尚未设置主账户，请先设置主账户" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                            alert.tag = 334;
                            [alert show];
                            return;
                        }
                    }
                }
            }
            
            [[WebViewController sharedInstance] setActionId:toActionId actionName:toActionName prdId:toPrdId Id:toId];
            [self.navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
            
        }
           break;
            
        case EDisabled:
        {
           ShowAlertView(@"提示", @"即将推出，敬请期待", nil, @"确认", nil);
        }
            break;
        case EOpenurl:
        {
            if ([toIslogin isEqualToString:@"true"]&&[MobileBankSession sharedInstance].isLogin == NO) {
                //被动登录  手势或者手机号登录(表示进入需要登录的界面且还没有登录)
                
                if (password!=nil&&![password isEqualToString:@""]) { //开启手势密码
                    //时间过期提示
                    [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {//[Context getNSUserDefaultskeyStr:@"LastLoginTime"]
                        if ([[MobileBankSession sharedInstance]last:[Context getNSUserDefaultskeyStr:@"LastLoginTime"] now:[data objectForKey:@"_sysDate"]]>30*24) {
                            
                            [GesturePasswordController clear];
                            //                            [Context setNSUserDefaults:@"yes" keyStr:@"isFirstLogin"];
                            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"手势密码过期，请使用其他方式登录" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                            alert.tag = 123;
                            [alert show];
                            
                        }else{
                            //                                loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                            self.loginAlertView = [[CustomAlertView alloc]initGesturePass:self];
                            [self.loginAlertView show];
                        }
                    }];
                }else
                    [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                [MobileBankSession sharedInstance].isOpenUrlBack=YES;
                return;
            }
            
            [MobileBankSession sharedInstance].delegate = self;
            [MobileBankSession sharedInstance].isOpenUrlBack =YES;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:toActionId forKey:@"ActionId"];
            
            [[MobileBankSession sharedInstance]postToServer:@"MenuUrlQry.do" actionParams:dic method:@"POST"];
        }
            
            break;
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 123) {
        [MobileBankSession sharedInstance].isPassiveLogin = YES;
        [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
    }
    if (alertView.tag ==334) {
        if (buttonIndex==0) {//主账户设置
            [[WebViewController sharedInstance]setActionId:@"PAccountSet" actionName:@"我的主账户设置" prdId:@"PAccountSet" Id:@"PAccountSet"];
//            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
        }
    }
    if (alertView.tag==801) {
        if (buttonIndex==0) {
            [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
            [[WebViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil] ;
        }

    }
}

#pragma - mark UITableView 相关方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [displayMenuArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(IPHONE)
        return cellHight;
    else
        return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *CellIdentifier=[NSString stringWithFormat:@"%ld %ld",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        //cell背景
        
        UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, cellHight)];
        bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
        
        [cell.contentView addSubview:bg];
        
        NSString* imageName = [displayMenuArray[indexPath.row] objectForKey:MENU_ACTION_IMAGE];

        [cell setText:[displayMenuArray[indexPath.row] objectForKey:MENU_ACTION_NAME] withImage:imageName needArrow:YES];
        UIView*line = [[UIView alloc]initWithFrame:CGRectMake(5, cellHight-1, tableView.frame.size.width-10, 1)];
        line.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
        if (indexPath.row!=displayMenuArray.count-1) {
            [cell.contentView addSubview:line];
        }
        
        if ([[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST]!=nil
            && ((NSArray*)[[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST]).count>0)//说明有下一级菜单,加上右剪头
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.mobileBankSession.isMenuListViewController = YES;
    toMenuArray = [[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST];
    toId = [[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_ID];
    toActionId = [self getActionId:indexPath.row array:displayMenuArray];
    
    [MobileBankSession sharedInstance].UserAnalysisActionId = toActionId;//行为轨迹分析
    
    toActionName = [self getActionName:indexPath.row array:displayMenuArray];
    toPrdId = [self getPrdId:indexPath.row array:displayMenuArray];
    toClickable = [self getClickable:indexPath.row array:displayMenuArray];
    toIslogin = [self getIsLogin:indexPath.row array:displayMenuArray];
    toRoleCtr = [self getRoleCtr:indexPath.row array:displayMenuArray];
    urlPathRow = indexPath.row;
    self.mobileBankSession.delegate = self;
    [MobileBankSession sharedInstance].isPassiveLoginDelegate = self;
    [self.mobileBankSession menuStartAction:[displayMenuArray objectAtIndex:indexPath.row]];
    
}

#pragma mark ---------Gesturedelegation------------
- (BOOL)verification:(NSString *)result{
    /*获取手势密码 判断是否为空*/
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];

    if ([result isEqualToString:password]) {
        [self.loginAlertView.gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [self.loginAlertView.gesturePasswordView.state setText:@"输入正确"];
        
        self.loginAlertView.hidden = YES;
        
                NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
                [postDic setObject:@"2" forKey:@"LoginType"];  //1 手机号登录  2 手势登录  3 信用卡登录
                [postDic setObject:[Context getNSUserDefaultskeyStr:@"userID"] forKey:@"LoginId"];
                [postDic setObject:[[UIDevice currentDevice] systemName] forKey:@"DeviceInfo"];
                [postDic setObject:@"ios" forKey:@"DeviceOS"];
                
                NSString* machineCode;
                if (IOS7_OR_LATER) {
                    machineCode = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                }else {
                    machineCode = [CSIIConfigDeviceInfo getDeviceID];
                }
                
                [postDic setObject:machineCode forKey:@"DeviceCode"];
                [MobileBankSession sharedInstance].delegate  = self;
                [[MobileBankSession sharedInstance]postToServer:@"login.do" actionParams:postDic method:@"POST"];
        return YES;
    }
    
    if (result.length<4) {
        [self.loginAlertView.gesturePasswordView.tentacleView enterArgin];
        [self.loginAlertView.gesturePasswordView.state setTextColor:[UIColor redColor]];
        [self.loginAlertView.gesturePasswordView.state setText:@"最小长度为4，请重新输入"];
        return NO;
    }
    
    int Gesturecount = [[Context getNSUserDefaultskeyStr:@"Gesturecount"] intValue];
    Gesturecount++;
    if (Gesturecount<5) {
        
        [self.loginAlertView.gesturePasswordView.tentacleView enterArgin];

        [Context setNSUserDefaults:[NSString stringWithFormat:@"%d",Gesturecount] keyStr:@"Gesturecount"];
        [self.loginAlertView.gesturePasswordView.state setTextColor:[UIColor redColor]];
        [self.loginAlertView.gesturePasswordView.state setText:[NSString stringWithFormat:@"手势密码错误%d次，还剩%d次",Gesturecount,5-Gesturecount]];
    }else if (Gesturecount==5){
        self.loginAlertView.hidden = YES;
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您已输错5次，请使用手机号登录，如想继续使用手势密码，请登录成功后自行设置" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        alert.tag = 123;
        [alert show];
        [GesturePasswordController clear];
        [Context setNSUserDefaults:@"0" keyStr:@"Gesturecount"];
    }
    return NO;
}


#pragma mark - -

-(NSString*)getActionName:(NSInteger)index array:(NSArray*)array{
    
    NSString*  actionName = [[array objectAtIndex:index] objectForKey:MENU_ACTION_NAME];
    NSLog(@"menu list, actionname = %@",actionName);
    if (actionName) {
        return actionName;
    }
    return nil;
}

-(NSString*)getActionId:(NSInteger)index array:(NSArray*)array{
    NSString* actionId = [[array objectAtIndex:index] objectForKey:MENU_ACTION_ID];
    NSLog(@"menu list, actionid = %@",actionId);
    if (actionId) {
        return actionId;
    }
    return nil;
}

-(NSString*)getClickable:(NSInteger)index array:(NSArray*)array{
    NSString* clickable = [[array objectAtIndex:index] objectForKey:MENU_ACTION_CLICKABLE];
    NSLog(@"clickable = %@",clickable);
    if (clickable) {
        return clickable;
    }
    return nil;
}

-(NSString*)getIsLogin:(NSInteger)index array:(NSArray*)array{
    NSString* IsLogin = [[array objectAtIndex:index] objectForKey:MENU_ACTION_ISLOGIN];
    NSLog(@"IsLogin = %@",IsLogin);
    if (IsLogin) {
        return IsLogin;
    }
    return nil;
}

-(NSString*)getRoleCtr:(NSInteger)index array:(NSArray*)array{
    NSString* RoleCtr = [[array objectAtIndex:index] objectForKey:MENU_ACTION_ROLECTR];
    NSLog(@"clickable = %@",RoleCtr);
    if (RoleCtr) {
        return RoleCtr;
    }
    return nil;
}


-(NSString*)getPrdId:(NSInteger)index array:(NSArray*)array{
    NSString* prdId = [[array objectAtIndex:index] objectForKey:MENU_PRD_ID];
    NSLog(@"menu list, prdId = %@",prdId);
    if (prdId) {
        return prdId;
    }
    return nil;
}

-(void)backButtonAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}
#pragma mark - MobileSessionDelegate 方法

-(void)getReturnData:(id)data WithActionName:(NSString *)action{//62d45347 ffd9>
    
    if ([action isEqualToString:@"login.do"]) {
        if ([[data objectForKey:@"_RejCode"] isEqualToString:@"000000"]) {
            [self.loginAlertView hideAlertView];
            [[CSIIMenuViewController sharedInstance]createNavigationUI];
            [Context setNSUserDefaults:@"0" keyStr:@"Gesturecount"];
            [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
                [Context setNSUserDefaults:[data objectForKey:@"_sysDate"] keyStr:@"LastLoginTime"];
            }];
            
//            if ([[data objectForKey:@"IsBind"] isEqualToString:@"N"]) {
//                BindingEquipmentViewController *bindViewController = [[BindingEquipmentViewController alloc]init];
//                bindViewController.telephoneNum = [data objectForKey:@"MobileNo"];
//                [[CSIIMenuViewController sharedInstance].navigationController pushViewController:bindViewController animated:YES];
//                return;
//            }
            
            self.mobileBankSession.isLogin = YES;
            self.mobileBankSession.delegate = self;
            [[CSIIMenuViewController sharedInstance] getReturnData:data WithActionName:action];
        }
    }
    else if ([action isEqualToString:@"MenuUrlQry.do"])
    {
        //            if ([toActionId isEqualToString:@"PPiontStore"]) {//粒金商城，里面还要判断是否登录
        if ([MobileBankSession sharedInstance].isOpenUrlBack==NO) {
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        }
        
        PiontStoreViewController *storeViewController = [[PiontStoreViewController alloc]init];
        storeViewController.webViewName = [displayMenuArray[urlPathRow] objectForKey:@"ActionName"];
//        storeViewController.adverWeb = NO;
        storeViewController.webShareText = [data objectForKey:@"ShareText"];
        storeViewController.webShareUrl = [data objectForKey:@"ShareUrl"];
        storeViewController.webViewUrl = [data objectForKey:@"Url"];
        [self.navigationController pushViewController:storeViewController animated:YES];
        [MobileBankSession sharedInstance].isOpenUrlBack = NO;
        
        //            }
        //            else{
        //            AdvertisementViewController *ad = [[AdvertisementViewController alloc]init];
        //            ad.webUrl = [data objectForKey:@"Url"];
        //            ad.webTitleName = [menuArray[self.mobileBankSession.menuViewSlectedTag][menuArrayIndex] objectForKey:@"ActionName"];
        //                [self.navigationController pushViewController:ad animated:YES];
        //            }
    }

}

@end
