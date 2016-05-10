//
//  ChangeLoginPasswordViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/5/20.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "ChangeLoginPasswordViewController.h"
#import "shahaiKeyBoard.h"
#import "ShaHaiView.h"
#import "keyboardencrypt.h"

@interface ChangeLoginPasswordViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>
{
    UITableView *_tableView;
    NSArray *_leftTexts;
    NSArray *_rightTFs;
    
    LWYTextField *oldPassWordTF;
    LWYTextField *loginPassWordTF;
    LWYTextField *confirmPassWordTF;
    
    NSString *_string1;                  //旧密码
    NSString *_string2;                   //新密码
    NSString *_string3;                  //确认密码
    
    NSString *_stringLength1;
    NSString *_stringLength2;
    NSString *_stringLength3;
    NSString*timeStamp;
    
    shahaiKeyBoard  * oldPassword;
    shahaiKeyBoard  * password;
    shahaiKeyBoard  * comfirmPassword;
    int textfiel;

}
@end

@implementation ChangeLoginPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _leftTexts = @[@"原登录密码:",@"新登录密码:",@"确认密码:"];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-20-44+5) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = YES;
    [self.view addSubview:_tableView];
    
    CGRect bigFrame = CGRectMake(_tableView.bounds.origin.x+5+80+10, 5, ScreenWidth-(_tableView.bounds.origin.x+5+80+10)-10, CellHeight-10);
    
    oldPassWordTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    oldPassWordTF.backgroundColor = [UIColor clearColor];
    oldPassWordTF.delegate = self;
    oldPassWordTF.tag = 9;
    oldPassWordTF.placeholder = @"请输入原登录密码";
    [self.inputControls addObject:oldPassWordTF];
    
    
    loginPassWordTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    loginPassWordTF.backgroundColor = [UIColor clearColor];
    loginPassWordTF.delegate = self;
    loginPassWordTF.tag = 10;
    loginPassWordTF.placeholder = @"请输入新登录密码";
    [self.inputControls addObject:loginPassWordTF];
    
    
    confirmPassWordTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    confirmPassWordTF.backgroundColor = [UIColor clearColor];
    confirmPassWordTF.delegate = self;
    confirmPassWordTF.tag = 11;
    confirmPassWordTF.placeholder = @"请输入确认密码";
    [self.inputControls addObject:confirmPassWordTF];
    _rightTFs = [@[oldPassWordTF,loginPassWordTF,confirmPassWordTF]mutableCopy];
    //密码控件初始化
    oldPassword = [self passWordWithTime2:@"11111111111111"];
    password = [self passWordWithTime:@"11111111111111"];
    comfirmPassword = [self passWordWithTime:@"11111111111111"];
    
    [self keyBoardReturn:oldPassword withTextFi:oldPassWordTF];
    [self keyBoardReturn:password withTextFi:loginPassWordTF];
    [self keyBoardReturn:comfirmPassword withTextFi:confirmPassWordTF];
    
}
-(shahaiKeyBoard *)passWordWithTime2:(NSString *)str2{
#pragma mark 沙海键盘
    
    shahaiKeyBoard  *_shahaiKeyBoard=[[shahaiKeyBoard alloc]init];
    //键盘类型为枚举类型，有全键盘，纯数字键盘，
    _shahaiKeyBoard.keyboardtyp=keyBoardTypeLetterAndNumber;
    _shahaiKeyBoard.showStyle =showStyleLetter;//默认数字键盘
    
    _shahaiKeyBoard.time=str2;
    _shahaiKeyBoard.randomLetter=0;
    _shahaiKeyBoard.randomNumber=1;
    _shahaiKeyBoard.randomSpecial=1;
//    _shahaiKeyBoard.maxLen=18;
//    _shahaiKeyBoard.minLen=5;
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
-(shahaiKeyBoard *)passWordWithTime:(NSString *)str{
#pragma mark 沙海键盘
    
    shahaiKeyBoard  *_shahaiKeyBoard=[[shahaiKeyBoard alloc]init];
    //键盘类型为枚举类型，有全键盘，纯数字键盘，
    _shahaiKeyBoard.keyboardtyp=keyBoardTypeLetterAndNumber;
    _shahaiKeyBoard.showStyle =showStyleLetter;//默认数字键盘

    _shahaiKeyBoard.time=str;
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
            
            textField.text=password.myKeyboardView.password;
            
        }else if(textField.tag == 11){
            
            textField.text=comfirmPassword.myKeyboardView.password;
            
        }else if (textField.tag == 9){
            
            textField.text=oldPassword.myKeyboardView.password;
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
    
    //点击确定回调 加密传回经过沙海加密库加密后的密文和原文长度，不加密传回原文和原文长度
    [keyBoard.myKeyboardView returnKey:^(NSInteger length, NSString *value) {
        if ([value isEqualToString:@"-4001"]) {
            
        }
        else{
            if (keyBoard == oldPassword){
                _string1 = [NSString stringWithString:value];
                _stringLength1 = [NSString stringWithFormat:@"%ld",(long)length];
                
                NSLog(@"旧密码是=%@\n长度为=%@",_string1,[NSString stringWithFormat:@"%ld",(long)length]);
            }
            else if (keyBoard == password) {
                _string2 =[NSString stringWithString:value];
                _stringLength2 = [NSString stringWithFormat:@"%ld",(long)length];
                
                NSLog(@"新密码是=%@\n长度为=%@",_string2,[NSString stringWithFormat:@"%ld",(long)length]);
            }
            else if (keyBoard == comfirmPassword){
                _string3 = [NSString stringWithString:value];
                _stringLength3 = [NSString stringWithFormat:@"%ld",(long)length];
                
                NSLog(@"确认密码是=%@\n长度为=%@",_string3,[NSString stringWithFormat:@"%ld",(long)length]);
            }
        }
        [textField resignFirstResponder];
    }];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.text = @"";
    
    if (textField.tag == 9){
        
        if (textfiel==2) {
            [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
            [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
        }
        if (textfiel==3) {
            [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
            [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        }
        
        textfiel=1;
        [self keyboarardup:oldPassword];
        
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            timeStamp = [data objectForKey:@"_sysDate"];
            DebugLog(@"data ：%@",data);
            DebugLog(@"时间戳: %@",timeStamp);
            oldPassword.myKeyboardView.time = timeStamp;
            
        }];
        
    }else if (textField.tag == 10) {
        
        if (textfiel==1) {
            [shahaiKeyBoard dissMisskeyboard:oldPassword.myKeyboardView];
            [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
        }
        
        if (textfiel==3) {
            [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
            [shahaiKeyBoard dissMisskeyboard:oldPassword.myKeyboardView];
        }
        
        textfiel=2;
        
        [self keyboarardup:password];
        
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            timeStamp = [data objectForKey:@"_sysDate"];
            DebugLog(@"data ：%@",data);
            NSLog(@"时间戳: %@",timeStamp);
            password.myKeyboardView.time = timeStamp;
            
        }];
    }
    else if (textField.tag == 11){
        
        
        if (textfiel==1) {
            [shahaiKeyBoard dissMisskeyboard:oldPassword.myKeyboardView];
            [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        }
        
        if (textfiel==2) {
            [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
            [shahaiKeyBoard dissMisskeyboard:oldPassword.myKeyboardView];
        }
        
        textfiel=3;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == loginPassWordTF) {
        NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return real.length < 19&&real.length>7;
    }
    else if (textField == confirmPassWordTF) {
        NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return real.length < 19&&real.length>7;
    }
    else {
        return YES;
    }
}

-(void)keyboarardup:(shahaiKeyBoard *)sender{
    NSLog(@"-------------%@",sender);
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
        
        UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(-10, 0, tableView.frame.size.width, CellHeight)];
        bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
        
        [cell.contentView addSubview:bg];
        
        UILabel*title = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 80, CellHeight)];
        title.backgroundColor = [UIColor clearColor];
        title.text = _leftTexts[indexPath.row];
        title.font = [UIFont systemFontOfSize:14];
        title.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
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
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    footer.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    return footer;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 90;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    footer.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
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
        [shahaiKeyBoard dissMisskeyboard:oldPassword.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
    }
    if (textfiel==2) {
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:oldPassword.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
    }
    
    if (textfiel==3) {
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:oldPassword.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
    }
    
    if ([_string1 isEqualToString:@""]||_string1 == nil) {
        ShowAlertView(@"提示", @"旧密码不能为空", nil, @"确认", nil);
        return;
    }
    
    if ([_string2 isEqualToString:@""]||_string2 == nil) {
        ShowAlertView(@"提示", @"新密码不能为空", nil, @"确认", nil);
        return;
    }
    
    if ([_string3 isEqualToString:@""]||_string3 == nil) {
        ShowAlertView(@"提示", @"确认密码不能为空", nil, @"确认", nil);
        return;
    }
    
    if (!(loginPassWordTF.text.length>7&&loginPassWordTF.text.length<19)) {
        ShowAlertView(@"提示", @"请输入8到18位密码", nil, @"确认", nil);
        return;
    }
    
    if (!(confirmPassWordTF.text.length>7&&confirmPassWordTF.text.length<19)) {
        ShowAlertView(@"提示", @"请输入8到18位密码", nil, @"确认", nil);
        return;
    }
    
    if (![_stringLength2 isEqualToString:_stringLength3]) {
        ShowAlertView(@"提示", @"两次输入的密码不一致", nil, @"确认", nil);
        return;
    }
    

    NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
    [postDic setObject:_string1 forKey:@"OldPassword"];
    [postDic setObject:_string2 forKey:@"LoginPassword"];
    [postDic setObject:_string3 forKey:@"LoginConfirmPassword"];
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"ModifyLoginPassword.do" actionParams:postDic method:@"POST"];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = @"登录密码修改";
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    
    if ([action isEqualToString:@"ModifyLoginPassword.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            
            UIAlertView *ale =[[UIAlertView alloc]initWithTitle:@"提示" message:@"登录密码修改成功，下次登录时生效" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            ale.tag = 101;
            [ale show];
            
        }else{
            
            oldPassWordTF.text = @"";
            loginPassWordTF.text = @"";
            confirmPassWordTF.text  = @"";
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
    [shahaiKeyBoard dissMisskeyboard:oldPassword.myKeyboardView];
    [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
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
