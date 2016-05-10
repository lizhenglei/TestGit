//
//  BindingEquipmentViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/6/18.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "BindingEquipmentViewController.h"
#import "SMSCodeButton.h"
#import "XHDrawerController.h"
#import "CSIIConfigDeviceInfo.h"
#import "LogoutViewController.h"

#import "CSIIMenuViewController.h"

@interface BindingEquipmentViewController ()<UITextFieldDelegate,CustomAlertViewDelegate,UIAlertViewDelegate>
{
    UITextField *textNumberField;
    NSString *SerialNoStr;
}
@end

@implementation BindingEquipmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShowbottomMenus = NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5)];
    [self.view addSubview:bgView];
    SerialNoStr = @"";
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 80, 55)];
    nameLabel.text = @"手机动态码:";
    nameLabel.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:nameLabel];
    textNumberField = [[UITextField alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x+nameLabel.frame.size.width+5, 10, (ScreenWidth-20)/2, 55)];
    textNumberField.placeholder = @"请输入手机动态码";
    textNumberField.delegate =self;
    textNumberField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textNumberField.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:textNumberField];
    
    SMSCodeButton *button = [[SMSCodeButton alloc]initWithFrame:CGRectMake(ScreenWidth-20-90, 22.5, 90, 30)];
    button.phoneNumber = self.telephoneNum;
    button.actionName = @"设备绑定";
    [bgView addSubview:button];
    
    UIButton *confirmBtn =[[UIButton alloc]initWithFrame:CGRectMake(10, 75, ScreenWidth-20-20, 40)];
    [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    confirmBtn.layer.cornerRadius = 3;
    confirmBtn.layer.masksToBounds = YES;
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtn) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setBackgroundColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f]];
    [bgView addSubview:confirmBtn];
    
    
    UIImageView *hintsView = [self addDefaultHints:@"1、请输入您的通知手机收到的6位动态码，并按“确认”键提交，绑定后仅能在本设备上登录，如需更换设备登录，需重新绑定。\n2、如果在1分钟内未收到动态码，请点击“点击重发”键，要求系统重新发送一次动态码。\n3、短信发送受到运营网络的影响，在某些时段可能有些延迟，敬请谅解!" FromY:125 FromX:10];
    [self.view addSubview:hintsView];
    
}

-(void)confirmBtn
{
    
    [self.view endEditing:YES];
    NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
    [postDic setObject:self.telephoneNum forKey:@"LoginId"];
    [postDic setObject:[[UIDevice currentDevice] systemName] forKey:@"DeviceInfo"];
    [postDic setObject:@"ios" forKey:@"DeviceOS"];
    
    if (textNumberField.text.length ==6) {
        [self.view endEditing:YES];
        NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
        [postDic setObject:self.telephoneNum forKey:@"LoginId"];
        [postDic setObject:[[UIDevice currentDevice] systemName] forKey:@"DeviceInfo"];
        [postDic setObject:@"ios" forKey:@"DeviceOS"];
        
        NSString* machineCode;
        if (IOS7_OR_LATER) {
            machineCode = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }else {
            machineCode = [CSIIConfigDeviceInfo getDeviceID];
        }
        [postDic setObject:machineCode forKey:@"DeviceCode"];
        [postDic setObject:textNumberField.text forKey:@"SmsCode"];
        [postDic setObject:SerialNoStr forKey:@"SerialNo"];
        
        [MobileBankSession sharedInstance].delegate =self;
        [[MobileBankSession sharedInstance]postToServer:@"MachineBinding.do" actionParams:postDic method:@"POST"];
    }
    else{
        ShowAlertView(@"提示", @"手机动态码应为6位数字", nil, @"确认", nil);
    }
}
-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    if ([action isEqualToString:@"MachineBinding.do"]) {
        
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            
            [MobileBankSession sharedInstance].isLogin = YES;
//         if ([[Context getNSUserDefaultskeyStr:@"isFirstLogin"]isEqualToString:@""]||[Context getNSUserDefaultskeyStr:@"isFirstLogin"]==nil) {
                UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备绑定成功" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                alertView.tag = 300;
                [Context setNSUserDefaults:@"no" keyStr:@"isFirstLogin"];
                [alertView show];
//                return;
            
//            }else{
//                
//                [self.navigationController popViewControllerAnimated:YES];
//                [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
//            }
        }
        else{
            [MobileBankSession sharedInstance].isLogin = NO;
//            UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:[data objectForKey:@"jsonError"] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//            [alertView show];
        }
    }
    else if ([action isEqualToString:@"GenTokenNameV1.do"]){
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            SerialNoStr = [data objectForKey:@"SerialNo"];
        }else{
            
        }
    }else{//返回退出登录
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            [MobileBankSession sharedInstance].isLogin = NO;
            [MobileBankSession sharedInstance].Userinfo = nil;
            [[CSIIMenuViewController sharedInstance]viewWillAppear:YES];
            [[CSIIMenuViewController sharedInstance].navigationController popViewControllerAnimated:YES];
            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            
        }else{
            
        }
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //    alertView.hidden = YES;
    if (alertView.tag == 300) {
        if (buttonIndex == 0) {  
//            [self performSelector:@selector(gotoSetGesture) withObject:nil afterDelay:0.9];
            [self.navigationController popViewControllerAnimated:YES];
            [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
            
        }
//        else{                   //不设置手势密码
//            [self.navigationController popViewControllerAnimated:YES];
//            [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
//        }
    }
}
-(void)gotoSetGesture{
    
    CustomAlertView* gestureView = [[CustomAlertView alloc]initReSetGesturePass:self];
    [gestureView show];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.rightButton.hidden = YES;
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"设备绑定";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)leftButtonAction:(id)sender{
    [MobileBankSession sharedInstance].delegate =self;
    [[MobileBankSession sharedInstance]postToServer:@"logout.do" actionParams:nil method:@"POST"];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *real = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return real.length<7;
}


@end
