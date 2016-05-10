//
//  FirstChangePasswordViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/5/13.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "FirstChangePasswordViewController.h"
#import "XHDrawerController.h"
#import "keyboardencrypt.h"
#import "ShaHaiView.h"
#import "shahaiKeyBoard.h"
#import "CSIIConfigDeviceInfo.h"
#import "GesturepasswordSettingViewController.h"
@interface FirstChangePasswordViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,MobileSessionDelegate,CustomAlertViewDelegate>
{
    UITableView *_tableView;
    NSArray *_leftTexts;
    NSArray *_rightTFs;
    UITextField *loginPassWord;
    UITextField *confirmPassWord;
    
//    shahaiKeyBoard * _shahaiKeyBoard;
    NSString *_string1;
    NSString *_string2;
    NSString *_stringLength1;
    NSString *_stringLength2;
    NSString*timeStamp;
    
    shahaiKeyBoard  * password;
    shahaiKeyBoard  * comfirmPassword;
    BOOL loginSuccess;
    int textfiel;

}
@end

@implementation FirstChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _leftTexts = @[@"新密码：",@"确认密码："];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-20-44+5) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = YES;
    [self.view addSubview:_tableView];
    
    CGRect bigFrame = CGRectMake(_tableView.bounds.origin.x+5+80+10, 5, ScreenWidth-(_tableView.bounds.origin.x+5+80+10)-10, CellHeight-10);
    
    loginPassWord = [[LWYTextField alloc]initWithFrame:bigFrame];
    loginPassWord.backgroundColor = [UIColor clearColor];
    loginPassWord.delegate = self;
    loginPassWord.tag = 10;
    loginPassWord.placeholder = @"请输入密码";
    [self.inputControls addObject:loginPassWord];
    
    
    confirmPassWord = [[LWYTextField alloc]initWithFrame:bigFrame];
    confirmPassWord.backgroundColor = [UIColor clearColor];
    confirmPassWord.delegate = self;
    confirmPassWord.tag = 11;
    confirmPassWord.placeholder = @"请输入确认密码";
    [self.inputControls addObject:confirmPassWord];
    _rightTFs = [@[loginPassWord,confirmPassWord]mutableCopy];
    
   password = [self passWordWithTime:@"20310230123021"];
   comfirmPassword = [self passWordWithTime:@"20140201020302"];
    
    [self keyBoardReturn:password withTextFi:loginPassWord];
    [self keyBoardReturn:comfirmPassword withTextFi:confirmPassWord];


//
}

-(shahaiKeyBoard *)passWordWithTime:(NSString *)str{
#pragma mark 沙海键盘
    
    shahaiKeyBoard  *_shahaiKeyBoard=[[shahaiKeyBoard alloc]init];
    //键盘类型为枚举类型，有全键盘，纯数字键盘，
    _shahaiKeyBoard.keyboardtyp=keyBoardTypeLetterAndNumber;
    _shahaiKeyBoard.showStyle = showStyleLetter;
     _shahaiKeyBoard.time=str;
//    _shahaiKeyBoard.DeveloperMode = 1;//为1时显示密码

    _shahaiKeyBoard.randomLetter=0;
    _shahaiKeyBoard.randomNumber=1;
    _shahaiKeyBoard.randomSpecial=1;
    _shahaiKeyBoard.maxLen=18;
    _shahaiKeyBoard.minLen=5;
    _shahaiKeyBoard.encrypt=0;
    _shahaiKeyBoard.needHighlighted=1;
    //把当前的textfield传入沙海键盘，当沙海键盘弹出时，系统键盘自动收回
    //    [_shahaiKeyBoard addTextfield:[NSArray arrayWithObjects:loginPassWord,verificationTF, nil]];
    //先设置参数，然后再初始化沙海键盘方法 如果不设置为默认BOOl=0
    [_shahaiKeyBoard initShahaiKeboard];
//    [self.view addSubview:_shahaiKeyBoard.myKeyboardView];
    UIWindow *ww = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
    [ww addSubview:_shahaiKeyBoard.myKeyboardView];

    return _shahaiKeyBoard;
}
-(void)keyBoardReturn:(shahaiKeyBoard *)keyBoard withTextFi:(UITextField *)textField{
    //输入回调 如果加密传回为* 不加密传回原文
    [keyBoard.myKeyboardView cilck:^(NSInteger length, NSString *value) {
        if (textField.tag == 10) {
            
            loginPassWord.text=password.myKeyboardView.password;

        }else if(textField.tag == 11){
            
            confirmPassWord.text=comfirmPassword.myKeyboardView.password;
        }
    }];
    
    //点击删除回调 length=0为长安清空 1为单个删除
    [ keyBoard.myKeyboardView cancle:^(NSInteger length, NSString *value) {
        if (length==0) {
            textField.text=@"";
        }
        else{
            textField.text=[textField.text substringToIndex:length];
        }
    }];
    
    //点击确认回调 加密传回经过沙海加密库加密后的密文和原文长度，不加密传回原文和原文长度
    [keyBoard.myKeyboardView returnKey:^(NSInteger length, NSString *value) {
        if ([value isEqualToString:@"-4001"]) {
            
        }else{
            if (textField.tag == 10) {
                _string1 =[NSString stringWithString:value];
                _stringLength1 = [NSString stringWithFormat:@"%ld",(long)length];
                
                NSLog(@"密码是=%@\n长度为=%@",_string1,[NSString stringWithFormat:@"%ld",(long)length]);
                
            }
            else if (textField.tag == 11){
                _string2 = [NSString stringWithString:value];
                _stringLength2 = [NSString stringWithFormat:@"%ld",(long)length];
                
                NSLog(@"密码是=%@\n长度为=%@",_string2,[NSString stringWithFormat:@"%ld",(long)length]);
                
            }}
        
        [textField resignFirstResponder];
        
    }];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.text = @"";

    if (textField.tag == 10){
        
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
//        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        textfiel=1;
        
        [self keyboarardup:password];
        
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            timeStamp = [data objectForKey:@"_sysDate"];
            DebugLog(@"data ：%@",data);
            NSLog(@"时间戳: %@",timeStamp);
            password.myKeyboardView.time = timeStamp;
            
        }];
        
    }else if (textField.tag == 11) {
        
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        
        textfiel=2;
        
        [self keyboarardup:comfirmPassword];
        
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            timeStamp = [data objectForKey:@"_sysDate"];
            DebugLog(@"data ：%@",data);
            NSLog(@"时间戳: %@",timeStamp);
            comfirmPassword.myKeyboardView.time = timeStamp;
            
        }];
    }
    

    return NO;
}


-(void)keyboarardup:(shahaiKeyBoard *)sender{
    NSLog(@"-------------%@",sender);
//    sender.keyboardtyp=keyBoardTypeLetterAndNumber;
    sender.myKeyboardView.showStyle = showStyleLetter;
    [sender show1:sender.myKeyboardView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _leftTexts.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView* backgroundView = nil;
        
        UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, CellHeight)];
        bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
        
        [cell.contentView addSubview:bg];
        
        UILabel*title = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 80, CellHeight)];
        title.backgroundColor = [UIColor clearColor];
        title.text = _leftTexts[indexPath.row];
        title.font = [UIFont systemFontOfSize:14];
        title.lineBreakMode = NSLineBreakByWordWrapping;
        title.numberOfLines = 0;
        title.textAlignment = NSTextAlignmentRight;
        
        [cell.contentView addSubview:title];
        [cell.contentView addSubview:[_rightTFs objectAtIndex:indexPath.row]];
        cell.backgroundView = backgroundView;
        
        UIView*line = [[UIView alloc]initWithFrame:CGRectMake(5, CellHeight-1, tableView.frame.size.width-10, 1)];
        line.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
        if (indexPath.row!=_leftTexts.count-1) {
            [cell.contentView addSubview:line];
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 120;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, footer.frame.size.width, 40)];
    [button setBackgroundColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f]];
    [button setTitle:@"确认" forState:UIControlStateNormal];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(buttonActionHandler:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:button];
    
    UIImageView *hintsImageView = [self addDefaultHints:@"1、登录密码为8到18位数字、字母或数字加字母的组合；\n2、为了保护您的资金安全，请不要设置过于简单的密码，例如“111111”、“aaaaaaaa”等，或您的生日、手机号、账号、卡号的后几位。" FromY:button.frame.size.height+button.frame.origin.y+10 FromX:0];
    [footer addSubview:hintsImageView];
    
    return footer;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)buttonActionHandler:(UIButton *)sender
{
    
    if (textfiel==1) {
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
    }
    if (textfiel==2) {
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
    }
    
    

    if ([_string1 isEqualToString:@""]||_string1 == nil) {
        ShowAlertView(@"提示", @"新密码不能为空", nil, @"确认", nil);
        return;
    }
    
    if ([_string2 isEqualToString:@""]||_string2 == nil) {
        ShowAlertView(@"提示", @"确认密码不能为空", nil, @"确认", nil);
        return;
    }
    if (!(loginPassWord.text.length>7&&loginPassWord.text.length<19)) {
        ShowAlertView(@"提示", @"请输入8到18位密码", nil, @"确认", nil);
        return;
    }
    if (!(confirmPassWord.text.length>7&&confirmPassWord.text.length<19)) {
        ShowAlertView(@"提示", @"请输入8到18位密码", nil, @"确认", nil);
        return;
    }
    if (![_stringLength1 isEqualToString:_stringLength2]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"密码和确认密码不一致" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        return;
        
    }
    NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
    [postDic setObject:@"4" forKey:@"LoginType"];           //4  重置密码
    [postDic setObject:self.MobilePhoneNum forKey:@"LoginId"];
    [postDic setObject:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"CifNo"] forKey:@"CifNo"];
    [postDic setObject:_string1 forKey:@"ResetPassword"];
    [postDic setObject:_string2 forKey:@"ResetPasswordConfirm"];
    [postDic setObject:[[UIDevice currentDevice] systemName] forKey:@"DeviceInfo"];
    [postDic setObject:@"ios" forKey:@"DeviceOS"];
    
    NSString* machineCode;
    if (IOS7_OR_LATER) {
        machineCode = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }else {
        machineCode = [CSIIConfigDeviceInfo getDeviceID];
    }

    [postDic setObject:machineCode forKey:@"DeviceCode"];
    
    
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance] postToServer:@"login.do" actionParams:postDic method:@"POST"];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (buttonIndex==0) { //跳转手势密码设置
//        
//        [self performSelector:@selector(gotoSetGesture) withObject:nil afterDelay:0.9];
//
//    }else{                //取消
    if (buttonIndex ==0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
//    }
}

-(void)gotoSetGesture{
    
    CustomAlertView* gestureView = [[CustomAlertView alloc]initReSetGesturePass:self];
    gestureView.customDelegate = self;
    [gestureView show];
    
}

#pragma mark ------GestureHidden--------
-(void)gestureExit:(CustomAlertView *)alert{   //点击手势密码页面取消
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)verGestureSucess:(CustomAlertView *)alert{ //手势密码设置成功
   [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (!loginSuccess) {
        [MobileBankSession sharedInstance].Userinfo = nil;
        [MobileBankSession sharedInstance].isLogin = NO;

    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = @"重置密码";
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    
    if ([action isEqualToString:@"login.do"]) {
        if ([[data objectForKey:@"_RejCode"] isEqualToString:@"000000"]) {
            
            [MobileBankSession sharedInstance].Userinfo = [[NSMutableDictionary alloc]initWithDictionary:data];    //用户信息
            loginSuccess = YES;
            UIAlertView *ale =[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码重置成功" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [ale show];
            [Context setNSUserDefaults:@"no" keyStr:@"isFirstLogin"];
            [MobileBankSession sharedInstance].isLogin = YES;
            
            
        }else{
            
            loginPassWord.text = @"";
            confirmPassWord.text = @"";

        }
    }
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
