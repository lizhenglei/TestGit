//
//  LoginViewController.m
//  MobileClient
//
//  Created by LZL on 15/4/22.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "LoginViewController.h"
#import "LWYTextField.h"
#import "LabelButton.h"
#import "LogoutViewController.h"
#import "ReFindPasswordViewController.h"
#import "CSIIConfigDeviceInfo.h"
//#import "MobileBankSession.h"
#import "APService.h"
#define LOGINBTN_TAG 100
#define REGISTERBTN_TAG 102
#define REPASSWORDBTN_TAG 103

#pragma 沙海
#import "keyboardencrypt.h"
#import "shahaiKeyBoard.h"
#import "ShaHaiView.h"
#import "CustomAlertView.h"
#import "BindingEquipmentViewController.h"

#import "CSIIMenuViewController.h"
#import "XHDrawerController.h"
#import "registerViewController.h"
#import "SingleClass.h"
#import "FirstChangePasswordViewController.h"
#import "GesturepasswordSettingViewController.h"
#import "KeychainItemWrapper.h"
#import "GesturePasswordController.h"
//13812868281   111111
//18675595324   111111
//18611743075   111111
@interface LoginViewController ()<UITextFieldDelegate,MobileSessionDelegate,CustomAlertViewDelegate>
{
    UILabel*titleLB;
    UITextField*userNameTF;
    UITextField*passwordTF;
    UITextField*verificationTF;
    
    UILabel*verTitle;
    UIButton*repasswordBtn;
    UIButton*loginBtn;
    UIButton*registerBtn;
    UIButton*verBtn;
    LabelButton*rememberButton;
    
    shahaiKeyBoard * _shahaiKeyBoard;
    NSString *_string1;
    NSString *_string2;
    UIView *_view;
    
    NSString*timeStamp;
    NSString*userNameStr;
    UISwipeGestureRecognizer *_swipRight;
}
@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    if ([MobileBankSession sharedInstance].isLogin) {
        
        if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"] length]==0||[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"]isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您尚未设置主账户，请先设置主账户" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            alert.tag = 334;
            [alert show];
        }
        LogoutViewController*logoutViewController = [[LogoutViewController alloc]init];
        [self.navigationController pushViewController:logoutViewController animated:NO];
        return;
    }
    
    [MobileBankSession sharedInstance].isRightViewControllerDone = YES;
    [super viewWillAppear:animated];
    
    if ([[Context getNSUserDefaultskeyStr:@"isRemember"]isEqualToString:@"on"]) {
        NSString *userID = [Context getNSUserDefaultskeyStr:@"userID"];
        rememberButton.selected = YES;
        if(userID!=nil||![userID isEqualToString:@""]){
            userNameTF.text = [NSString stringWithFormat:@"%@****%@",[userID substringWithRange:NSMakeRange(0, 3)],[userID substringWithRange:NSMakeRange(7, 4)]];
            userNameStr = userID;
        }else{
            userNameTF.text = @"";
            userNameStr = @"";
        }
    }else{
        userNameTF.text = @"";
    }
    
    passwordTF.text = @"";
    _string1 = @"";
    _string2 = @"";
    
}

+(LoginViewController*)sharedInstance{
    static LoginViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoginViewController alloc] init];
    });
    return sharedInstance;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _swipRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRight:)];
    _swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:_swipRight];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _string1 = [[NSString alloc]init];
    _string2 = [[NSString alloc]init];
    
    [SingleClass shareClass].inputControls = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    XHDrawerController *cc = [[XHDrawerController alloc]init];
    
    //    CSIIMenuViewController *cc = [[CSIIMenuViewController alloc]init];
    UIView *vv = [[UIView alloc]initWithFrame:CGRectMake(280, 0, 400, 480)];
    vv.backgroundColor = [UIColor redColor];
    [cc.view addSubview:vv];
    CGFloat wight = 260;         //右边view的宽，计算坐标
    
    UIImage *logoImage=[UIImage imageNamed:@"login_logo"];
    UIImageView *logoImageView=[[UIImageView alloc]initWithImage:logoImage];
    logoImageView.frame=CGRectMake(wight/2.0-logoImage.size.width/1.5/2.0,35, logoImage.size.width/1.5, logoImage.size.height/1.5);
    [self.view addSubview:logoImageView];
    
    titleLB = [[UILabel alloc] initWithFrame:CGRectMake(wight/2-150/2, logoImageView.frame.origin.y+logoImageView.frame.size.height+10, 150, 20)];
    titleLB.text = @"常乐生活 妙趣无穷";
    titleLB.textAlignment =  NSTextAlignmentCenter;
    titleLB.font =  [UIFont boldSystemFontOfSize:17.0f];
    titleLB.textColor = [UIColor whiteColor];
    titleLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLB];
    
    
    UILabel*userTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, titleLB.frame.origin.y+titleLB.frame.size.height+10, 100, 20)];
    userTitle.text = @"手机号";
    userTitle.font = [UIFont systemFontOfSize:14];
    userTitle.backgroundColor = [UIColor clearColor];
    userTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:userTitle];
    
    userNameTF = [[UITextField alloc] initWithFrame:CGRectMake(30, userTitle.frame.origin.y+userTitle.frame.size.height+5, 200, 30)];
    userNameTF.delegate = self;
    userNameTF.tag = 100;
    userNameTF.layer.cornerRadius = 3;
    userNameTF.layer.masksToBounds = YES;
    userNameTF.placeholder = @"请输入手机号";
    userNameTF.font = [UIFont systemFontOfSize:12.0];
    userNameTF.backgroundColor = [UIColor whiteColor];
    userNameTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:userNameTF];
    
    
    UILabel*passTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, userNameTF.frame.origin.y+userNameTF.frame.size.height+10, 100, 20)];
    passTitle.text = @"登录密码";
    passTitle.font = [UIFont systemFontOfSize:14];
    passTitle.backgroundColor = [UIColor clearColor];
    passTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:passTitle];
    
    
    passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(30, passTitle.frame.origin.y+passTitle.frame.size.height+5, 200, 30)];
    passwordTF.placeholder = @"请输入登录密码";
    passwordTF.tag = 101;
    passwordTF.layer.cornerRadius = 3;
    passwordTF.layer.masksToBounds = YES;
    passwordTF.inputView = [[UIView alloc]initWithFrame:CGRectZero];
    passwordTF.delegate =self;
    passwordTF.userInteractionEnabled = YES;
    passwordTF.font = [UIFont systemFontOfSize:12.0];
    passwordTF.backgroundColor = [UIColor whiteColor];
    //    [[SingleClass shareClass].inputControls addObject:passwordTF];
    [self.view addSubview:passwordTF];
    
    verTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, passwordTF.frame.origin.y+passwordTF.frame.size.height+10, 100, 20)];
    verTitle.text = @"验证码";
    verTitle.font = [UIFont systemFontOfSize:14];
    verTitle.hidden = YES;
    verTitle.backgroundColor = [UIColor clearColor];
    verTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:verTitle];
    
    verificationTF = [[LWYTextField alloc] initWithFrame:CGRectMake(30, verTitle.frame.origin.y+verTitle.frame.size.height+5, 200, 30)];
    verificationTF.placeholder = @"请输入验证码";
    verificationTF.tag = 202;
    verificationTF.delegate =self;
    verificationTF.hidden = YES;
    verificationTF.font = [UIFont systemFontOfSize:12.0];
    verificationTF.keyboardType = UIKeyboardTypeNumberPad;
    [[SingleClass shareClass].inputControls addObject:verificationTF];
    verificationTF.backgroundColor = [UIColor whiteColor];
    
    verBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    verBtn.frame = CGRectMake(155, 5, 40, 20);
    verBtn.backgroundColor = [UIColor grayColor];
    [verBtn setTitle:@"点击加载" forState:UIControlStateNormal];
    verBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [verBtn addTarget:self action:@selector(verBtnaction:) forControlEvents:UIControlEventTouchUpInside];
    [verificationTF addSubview:verBtn];
    [self.view addSubview:verificationTF];
    
    //记住手机号码
    UIImage* markImage = [UIImage imageNamed:@"Login_Remanber_close"];
    rememberButton = [[LabelButton alloc]initWithFrame:CGRectMake(30,passwordTF.frame.origin.y+passwordTF.frame.size.height+(40-35/2)/2+3, markImage.size.width+90, markImage.size.height)];
    rememberButton.tag = 101;
    [rememberButton setImage:markImage frame:CGRectMake(0, 0, markImage.size.width, markImage.size.height) forState:UIControlStateNormal];
    [rememberButton setImage:[UIImage imageNamed:@"Login_Remanber_open"] forState:UIControlStateSelected];
    [rememberButton addTarget:self action:@selector(toggleRemember:) forControlEvents:UIControlEventTouchUpInside];
    rememberButton.selected = YES;//默认记住用户名
    UILabel *rememberLab = [[UILabel alloc]initWithFrame:CGRectMake(markImage.size.width+3, -3, 80, 20)];
    rememberLab.text = @"记住手机号";
    rememberLab.backgroundColor = [UIColor redColor];
    rememberLab.font = [UIFont systemFontOfSize:14];
    rememberLab.textColor = [UIColor whiteColor];
    rememberLab.backgroundColor = [UIColor clearColor];
    rememberLab.adjustsFontSizeToFitWidth=YES;
    //        rememberLab.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:rememberButton];
    [rememberButton addSubview:rememberLab];
    
    repasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    repasswordBtn.backgroundColor = [UIColor clearColor];
    repasswordBtn.frame = CGRectMake(160,passwordTF.frame.origin.y+passwordTF.frame.size.height+(40-35/2)/2, 80, 20);
    [repasswordBtn setTitle:@"找回密码" forState:UIControlStateNormal];
    [repasswordBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    repasswordBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    repasswordBtn.tag = REPASSWORDBTN_TAG;
    [self.view addSubview:repasswordBtn];
    
    loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(wight/2-200/2, passwordTF.frame.origin.y+passwordTF.frame.size.height+40, 200, 35);
    
    loginBtn.backgroundColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.00f alpha:1.00f];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.layer.cornerRadius = 3;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    loginBtn.tag = LOGINBTN_TAG;
    [loginBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(wight/2-200/2, loginBtn.frame.origin.y+loginBtn.frame.size.height+10, 200, 35);
    registerBtn.backgroundColor = [UIColor colorWithRed:0.00f green:0.52f blue:0.99f alpha:1.00f];
    [registerBtn setTitle:@"自助注册" forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    registerBtn.layer.cornerRadius = 3;
    registerBtn.layer.masksToBounds = YES;
    registerBtn.tag = REGISTERBTN_TAG;
    [registerBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    self.inputControls = [SingleClass shareClass].inputControls;
    
    UILabel *versionCode = [[UILabel alloc]initWithFrame:CGRectMake(260/2+20, self.view.frame.size.height-50, 80, 20)];//显示版本号
    versionCode.font = [UIFont systemFontOfSize:15];
    versionCode.text = [NSString stringWithFormat:@"        V%@",APP_VERSION_CODE];
    versionCode.textAlignment = NSTextAlignmentCenter;
    versionCode.textColor = [UIColor whiteColor];
    [self.view addSubview:versionCode];
    
    //密码控件初始化  此时的时间戳写死，密码控件初始化时需要用到   在show方法里重新赋值
    [self passWordWith:@"20150203020103"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    [MobileBankSession sharedInstance].isRightViewControllerDone = NO;
    
    if (userNameTF!=nil) {
        [userNameTF resignFirstResponder];
    }
    
    if (passwordTF!=nil) {
        [passwordTF resignFirstResponder];
    }
    [verificationTF resignFirstResponder];
    
    [self.view removeGestureRecognizer:_swipRight];
    
}
-(void)swipRight:(UISwipeGestureRecognizer *)sgr
{
    [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:^(BOOL finished) {
        
    }];
}
-(void)buttonAction:(id)sender{
    NSLog(@"点击按钮");
    UIButton*btn = (UIButton*)sender;
    switch (btn.tag) {
        case LOGINBTN_TAG:
        {
            [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
            
            if ([_string1 isEqualToString:@""]||_string1 == nil) {
                ShowAlertView(@"提示", @"密码不能为空", nil, @"确认", nil);
                return;
            }
            if (!(passwordTF.text.length>5&&passwordTF.text.length<19)) {
                ShowAlertView(@"提示", @"请输入6到18位密码", nil, @"确认", nil);
                return;
            }
            
            NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
            [postDic setObject:@"1" forKey:@"LoginType"];  //1 手机号登录  2 手势登录  3 信用卡登录
            [postDic setObject:[[Context getNSUserDefaultskeyStr:@"isRemember"]isEqualToString:@"on"]?[userNameStr isEqualToString:@""]?userNameTF.text:userNameStr:userNameTF.text forKey:@"LoginId"];
            [postDic setObject:_string1 forKey:@"LoginPassword"];
            [postDic setObject:[[UIDevice currentDevice] systemName] forKey:@"DeviceInfo"];
            [postDic setObject:@"ios" forKey:@"DeviceOS"];
            
            NSString* machineCode;
            if (IOS7_OR_LATER) {
                machineCode = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            }else {
                machineCode = [CSIIConfigDeviceInfo getDeviceID];
            }
            
            [postDic setObject:machineCode forKey:@"DeviceCode"];
            
            if (verificationTF.text == nil) {
                verificationTF.text = @"";
            }
            
            if (verificationTF.hidden == NO) {
                if ([verificationTF.text isEqualToString:@""]||verificationTF.text == nil) {
                    ShowAlertView(@"提示", @"验证码不能为空", nil, @"确认", nil);
                    return;
                }
                [postDic setObject:verificationTF.text forKey:@"_vTokenName"];
            }
            //发送登陆交易
            [MobileBankSession sharedInstance].delegate = self;
            [[MobileBankSession sharedInstance] postToServer:@"login.do" actionParams:postDic method:@"POST"];
            
            NSLog(@"denglu");
            //            LogoutViewController*logoutViewController = [[LogoutViewController alloc]init];
            //            [self.navigationController pushViewController:logoutViewController animated:NO];
            
        }
            break;
        case REPASSWORDBTN_TAG:
        {
            ReFindPasswordViewController *reFindPassWord = [[ReFindPasswordViewController alloc]init];
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:reFindPassWord animated:NO];
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        }
            
            break;
        case REGISTERBTN_TAG:
        {
            registerViewController*agree = [[registerViewController alloc]init];
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:agree animated:NO];
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        }
            
            break;
        default:
            break;
    }
    
}

-(void)verBtnaction:(UIButton*)btn{
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance] postToServerStream:@"GenTokenImg.do" actionParams:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
}
-(void)toggleRemember:(id)sender{
    rememberButton.selected = !rememberButton.selected;
    NSLog(@"点击记住用户名按钮");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect;
    
    rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    textField.highlighted = NO;
    return YES;
}
-(shahaiKeyBoard *)passWordWith:(NSString *)time
{
    _shahaiKeyBoard = nil;
    _shahaiKeyBoard=[[shahaiKeyBoard alloc]init];
    _shahaiKeyBoard.time = time;
    //键盘类型为枚举类型，有全键盘，纯数字键盘，
    _shahaiKeyBoard.keyboardtyp=keyBoardTypeLetterAndNumber;
    _shahaiKeyBoard.showStyle = showStyleNumber;//默认数字键盘
    _shahaiKeyBoard.randomLetter=0;
    _shahaiKeyBoard.randomNumber=1;
    _shahaiKeyBoard.maxLen=18;
    _shahaiKeyBoard.minLen=1;
    _shahaiKeyBoard.encrypt=0;
    _shahaiKeyBoard.needHighlighted=1;
    //把当前的textfield传入沙海键盘，当沙海键盘弹出时，系统键盘自动收回
    [_shahaiKeyBoard addTextfield:[NSArray arrayWithObjects:userNameTF,verificationTF, nil]];
    //先设置参数，然后再初始化沙海键盘方法 如果不设置为默认BOOl=0
    [_shahaiKeyBoard initShahaiKeboard];
    //    [self.view addSubview:_shahaiKeyBoard.myKeyboardView];
    UIWindow *ww = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
    [ww addSubview:_shahaiKeyBoard.myKeyboardView];
    
    //输入回调 如果加密传回为* 不加密传回原文
    [_shahaiKeyBoard.myKeyboardView cilck:^(NSInteger length, NSString *value) {
        passwordTF.text=_shahaiKeyBoard.myKeyboardView.password;
    }];
    
    //点击删除回调 length=0为长安清空 1为单个删除
    [ _shahaiKeyBoard.myKeyboardView cancle:^(NSInteger length, NSString *value) {
        if (length==0) {
            passwordTF.text=@"";
        }
        else{
            passwordTF.text=[passwordTF.text substringToIndex:length];
        }
    }];
    
    //点击确认回调 加密传回经过沙海加密库加密后的密文和原文长度，不加密传回原文和原文长度
    [_shahaiKeyBoard.myKeyboardView returnKey:^(NSInteger length, NSString *value) {
        
        if ([value isEqualToString:@"-4001"]) {
            
        }else{
            _string1=[NSString stringWithString:value];
            _string2=[NSString stringWithFormat:@"%ld",(long)length];
            //            NSLog(@"密码是=%@\n长度为=%ld",_string1,(long)length);
            
            if (verificationTF.hidden) {
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.2];
                self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                [UIView commitAnimations];
                
            }
        }
        [passwordTF resignFirstResponder];
    }];
    
    return _shahaiKeyBoard;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    self.view.frame = CGRectMake(0, ScreenHeight==480?-100:-20, ScreenWidth, ScreenHeight);
    [UIView commitAnimations];
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
    _shahaiKeyBoard.showStyle = showStyleNumber;
    if (textField == userNameTF) {
        
        userNameStr = @"";
        userNameTF.text = @"";
//        [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
        return YES;
        
    }else if (textField.tag ==101) {
        
//        [shahaiKeyBoard dissMiss:_shahaiKeyBoard.myKeyboardView];
        textField.text = @"";
        [_shahaiKeyBoard show1:_shahaiKeyBoard.myKeyboardView];
        //获取时间戳
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            timeStamp = [data objectForKey:@"_sysDate"];
            //        DebugLog(@"data ：%@",data);
            //        NSLog(@"时间戳: %@",timeStamp);
            _shahaiKeyBoard.myKeyboardView.time = timeStamp;
            
        }];
        return NO;
    }else{
        
        [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
        return YES;
    }
}


-(void)reloadSubviews:(BOOL)isShowVerificationTF{
    
    CGFloat wight = 260;         //右边view的宽，计算坐标
    
    verTitle.hidden = isShowVerificationTF;
    verificationTF.hidden = isShowVerificationTF;
    verificationTF.text = @"";
    UIImage* markImage = [UIImage imageNamed:@"Login_Remanber_close"];
    
    if (isShowVerificationTF) {
        rememberButton.frame = CGRectMake(30,passwordTF.frame.origin.y+passwordTF.frame.size.height+(40-35/2)/2, markImage.size.width+90, markImage.size.height);
        repasswordBtn.frame = CGRectMake(160,passwordTF.frame.origin.y+passwordTF.frame.size.height+(40-35/2)/2, 80, 20);
        loginBtn.frame = CGRectMake(wight/2-200/2, passwordTF.frame.origin.y+passwordTF.frame.size.height+40, 200, 35);
        registerBtn.frame = CGRectMake(wight/2-200/2, loginBtn.frame.origin.y+loginBtn.frame.size.height+10, 200, 35);
    }else{
        rememberButton.frame = CGRectMake(30,verificationTF.frame.origin.y+verificationTF.frame.size.height+(40-35/2)/2, markImage.size.width+90, markImage.size.height);
        repasswordBtn.frame = CGRectMake(160,verificationTF.frame.origin.y+verificationTF.frame.size.height+(40-35/2)/2, 80, 20);
        loginBtn.frame = CGRectMake(wight/2-200/2, verificationTF.frame.origin.y+verificationTF.frame.size.height+40, 200, 35);
        registerBtn.frame = CGRectMake(wight/2-200/2, loginBtn.frame.origin.y+loginBtn.frame.size.height+10, 200, 35);
    }
}

-(void)gotoSetGesture{
    CustomAlertView* gestureView = [[CustomAlertView alloc]initReSetGesturePass:self];
    [gestureView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //    alertView.hidden = YES;
    if (alertView.tag == 333) {
        if (buttonIndex == 0) {  //去设置手势密码
            //            GesturepasswordSettingViewController*vc = [[GesturepasswordSettingViewController alloc]init];
            //            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:vc animated:NO];
            //            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            
            [self performSelector:@selector(gotoSetGesture) withObject:nil afterDelay:0.9];
            
        }else{                   //不设置手势密码
            
            if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"] length]==0||[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"]isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您尚未设置主账户，请先设置主账户" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                alert.tag = 334;
                [alert show];
                return;
            }
            if ([MobileBankSession sharedInstance].isPassiveLogin) {
                [MobileBankSession sharedInstance].delegate = [CSIIMenuViewController sharedInstance];  //设置成那个
                [[MobileBankSession sharedInstance] menuStartAction:nil];
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            }
        }
    }
    if (alertView.tag ==334) {
        if (buttonIndex==0) {//主账户设置
            [[WebViewController sharedInstance]setActionId:@"PAccountSet" actionName:@"我的主账户设置" prdId:@"PAccountSet" Id:@"PAccountSet"];
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            [[CSIIMenuViewController sharedInstance].navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
        }
    }
}

-(void)JPushCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    
    if ([action isEqualToString:@"GenTokenImg.do"]) {
        UIImage *image = [UIImage imageWithData:data];
        [verBtn setImage:image forState:UIControlStateNormal];
        return;
    }
    
    if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
        
        
        if ([action isEqualToString:@"login.do"]) {
            
            [APService setAlias:[data objectForKey:@"CifNo"] callbackSelector:@selector(JPushCallback:) object:self]; //极光推送设置别名
            [MobileBankSession sharedInstance].Userinfo = [[NSMutableDictionary alloc]initWithDictionary:data];    //用户信息
                NSLog(@"这是用户信息%@",[MobileBankSession sharedInstance].Userinfo);
            [self reloadSubviews:YES];

            if (rememberButton.selected == YES) {
                [Context setNSUserDefaults:@"on" keyStr:@"isRemember"];
            }else{
                [Context setNSUserDefaults:@"off" keyStr:@"isRemember"];
            }
            
            if (![[userNameStr isEqualToString:@""]?userNameTF.text:userNameStr isEqualToString:[Context getNSUserDefaultskeyStr:@"userID"]]) {
                [GesturePasswordController clear];
                [Context setNSUserDefaults:@"" keyStr:@"isFirstLogin"];
                [Context setNSUserDefaults:userNameTF.text keyStr:@"userID"];
            }
            [Context setNSUserDefaults:@"0" keyStr:@"Gesturecount"];
            [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
                [Context setNSUserDefaults:timeStamp keyStr:@"LastLoginTime"];
            }];
            
            
            if ([[data objectForKey:@"IsBind"] isEqualToString:@"N"]) {
                BindingEquipmentViewController *bindViewController = [[BindingEquipmentViewController alloc]init];
                bindViewController.telephoneNum = [data objectForKey:@"MobileNo"];
                [[CSIIMenuViewController sharedInstance].navigationController pushViewController:bindViewController animated:YES];
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                return;
            }
            
            
            
            if ([[data objectForKey:@"Flag"]isEqualToString:@"0"]) {  //0:首次   1:非首次
                
                FirstChangePasswordViewController*vc = [[FirstChangePasswordViewController alloc]init];
                [[CSIIMenuViewController sharedInstance].navigationController pushViewController:vc animated:NO];
                vc.MobilePhoneNum = [[Context getNSUserDefaultskeyStr:@"isRemember"]isEqualToString:@"on"]?[userNameStr isEqualToString:@""]?userNameTF.text:userNameStr:userNameTF.text;
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                return;
            }
            
            [MobileBankSession sharedInstance].isLogin = YES;
            
            if ([[Context getNSUserDefaultskeyStr:@"isFirstLogin"]isEqualToString:@""]||[Context getNSUserDefaultskeyStr:@"isFirstLogin"]==nil) {
                UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否前去设置手势密码" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                alertView.tag = 333;
                [alertView show];
                [Context setNSUserDefaults:@"no" keyStr:@"isFirstLogin"];
                LogoutViewController*logoutViewController = [[LogoutViewController alloc]init];
                [self.navigationController pushViewController:logoutViewController animated:NO];
                return;
            }
            if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"] length]==0||[[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"]isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您尚未设置主账户，请先设置主账户" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                alert.tag = 334;
                [alert show];
                LogoutViewController*logoutViewController = [[LogoutViewController alloc]init];
                [self.navigationController pushViewController:logoutViewController animated:NO];
                return;
            }
            if ([MobileBankSession sharedInstance].isSaoYiSao ==YES) {
                [[WebViewController sharedInstance]setActionId:@"EwmTransfer" actionName:@"二维码转账" prdId:@"EwmTransfer" Id:@"EwmTransfer"];
//                [[WebViewController sharedInstance]setActionId:@"MyAcInfo" actionName:@"账户查询" prdId:@"MyAcInfo" Id:@"MyAcInfo"];
                [[CSIIMenuViewController sharedInstance].navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
                [MobileBankSession sharedInstance].isSaoYiSao = NO;
                [CSIISuperViewController defaultController].saoYisaoBtn.selected = YES;
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
                return;
            }

            if ([MobileBankSession sharedInstance].isPassiveLogin) {
                [MobileBankSession sharedInstance].delegate = (id)[MobileBankSession sharedInstance].isPassiveLoginDelegate;  //设置成被动登陆前的代理类
                [[MobileBankSession sharedInstance] menuStartAction:nil];
                [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            }
            
//            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            [[CSIIMenuViewController sharedInstance]createNavigationUI];//用于修改登录前后的右上角的登录状态
            LogoutViewController *log = [[LogoutViewController alloc]init];
            [self.navigationController pushViewController:log animated:NO];
            
        }
    }else{
        
        if ([action isEqualToString:@"login.do"]) {
            
            passwordTF.text = @"";
            
            [MobileBankSession sharedInstance].delegate = self;
            [[MobileBankSession sharedInstance] postToServerStream:@"GenTokenImg.do" actionParams:nil];
            
            [self reloadSubviews:NO];
        }
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [UIView commitAnimations];
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
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
