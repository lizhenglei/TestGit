//
//  ReSetPasswordViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/5/11.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "ReSetPasswordViewController.h"
#import "XHDrawerController.h"
#import "CSIIMenuViewController.h"
#import "ShaHaiView.h"
#import "shahaiKeyBoard.h"
#import "keyboardencrypt.h"

@interface ReSetPasswordViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView *_tableView;
    NSArray *_leftTexts;
    NSArray *_rightTFs;
    LWYTextField *loginPassWordTF;
    LWYTextField *confirmPassWordTF;
    
    NSString *_string1;
    NSString *_string2;
    NSString *_stringLength1;
    NSString *_stringLength2;
    NSString*timeStamp;
    
    shahaiKeyBoard  * password;
    shahaiKeyBoard  * comfirmPassword;
    
    int textfiel;
    
}
@end

@implementation ReSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _leftTexts = @[@"新密码:",@"确认密码:"];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-20-44+5) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = YES;
    [self.view addSubview:_tableView];
    
    CGRect bigFrame = CGRectMake(_tableView.bounds.origin.x+5+80+10, 5, ScreenWidth-(_tableView.bounds.origin.x+5+80+10)-10, CellHeight-10);
    
    loginPassWordTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    loginPassWordTF.backgroundColor = [UIColor clearColor];
    loginPassWordTF.delegate = self;
    loginPassWordTF.tag = 10;
    loginPassWordTF.placeholder = @"请输入新密码";
    [self.inputControls addObject:loginPassWordTF];
    
    
    confirmPassWordTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    confirmPassWordTF.backgroundColor = [UIColor clearColor];
    confirmPassWordTF.delegate = self;
    confirmPassWordTF.tag = 11;
    confirmPassWordTF.placeholder = @"再次输入新密码";
    [self.inputControls addObject:confirmPassWordTF];
    _rightTFs = [@[loginPassWordTF,confirmPassWordTF]mutableCopy];
    //密码控件初始化
    password = [self passWordWithTime:@"20150203020104"];
    comfirmPassword = [self passWordWithTime:@"20142021923090"];
    [self keyBoardReturn:password withTextFi:loginPassWordTF];
    [self keyBoardReturn:comfirmPassword withTextFi:confirmPassWordTF];
    
}

-(shahaiKeyBoard *)passWordWithTime:(NSString *)str{
#pragma mark 沙海键盘
    
    shahaiKeyBoard  *_shahaiKeyBoard=[[shahaiKeyBoard alloc]init];
    //键盘类型为枚举类型，有全键盘，纯数字键盘，
    _shahaiKeyBoard.keyboardtyp=keyBoardTypeLetterAndNumber;
    _shahaiKeyBoard.showStyle = showStyleLetter;
    _shahaiKeyBoard.time=str;
    _shahaiKeyBoard.randomLetter=0;
    _shahaiKeyBoard.randomNumber=1;
    _shahaiKeyBoard.randomSpecial=1;
    _shahaiKeyBoard.maxLen=18;
    _shahaiKeyBoard.minLen=6;
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
            
        }else{
            if (textField.tag == 10) {
                _string1 =[NSString stringWithString:value];
                _stringLength1 = [NSString stringWithFormat:@"%ld",(long)length];
                
            }
            else if (textField.tag == 11){
                _string2 = [NSString stringWithString:value];
                _stringLength2 = [NSString stringWithFormat:@"%ld",(long)length];
                                
            }
        }
        [textField resignFirstResponder];
        
    }];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.text = @"";
    if (textField.tag == 10){
        
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
        
        textfiel=1;
        
        [self keyboarardup:password];
        
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            timeStamp = [data objectForKey:@"_sysDate"];
            if (ISPRINTLOG) {
                NSLog(@"data ：%@",data);
            }
            NSLog(@"时间戳: %@",timeStamp);
            password.myKeyboardView.time = timeStamp;
            
        }];
        
    }else if (textField.tag == 11) {
        
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        
        textfiel=2;
        
        [self keyboarardup:comfirmPassword];
        
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            timeStamp = [data objectForKey:@"_sysDate"];
            if (ISPRINTLOG) {
                NSLog(@"data ：%@",data);
            }
            NSLog(@"时间戳: %@",timeStamp);
            comfirmPassword.myKeyboardView.time = timeStamp;
            
        }];
    }
    
    return NO;
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
    
    UIImageView *hintsView = [self addDefaultHints:@"1、建议登录的密码设置为英文字母和数字的组合，密码长度为8—18位。        \n2、新密码不能与原密码相同。\n3、新密码办理成功以后，下次登录手机银行请使用新密码。" FromY:50 FromX:0];
    [footer addSubview:hintsView];
    
    
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
    
    if (!(loginPassWordTF.text.length>7&&loginPassWordTF.text.length<19)) {
        ShowAlertView(@"提示", @"请输入8到18位密码", nil, @"确认", nil);
        return;
    }
    if (!(confirmPassWordTF.text.length>7&&confirmPassWordTF.text.length<19)) {
        ShowAlertView(@"提示", @"请输入8到18位密码", nil, @"确认", nil);
        return;
    }
    
    NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
    [postDic setObject:[self.postDic objectForKey:@"CifName"] forKey:@"CifName"];
    [postDic setObject:[self.postDic objectForKey:@"IdType"] forKey:@"IdType"];
    [postDic setObject:[self.postDic objectForKey:@"IdNo"] forKey:@"IdNo"];
    [postDic setObject:[self.postDic objectForKey:@"AcNo"] forKey:@"AcNo"];
    [postDic setObject:_string1 forKey:@"LoginPassword"];
    [postDic setObject:_string2 forKey:@"LoginConfirmPassword"];
    [postDic setObject:[self.postDic objectForKey:@"TrsPasswordV"] forKey:@"TrsPasswordV"];
    [postDic setObject:[self.postDic objectForKey:@"ValidateFlag"] forKey:@"ValidateFlag"];
    [postDic setObject:[MobileBankSession sharedInstance].tokenNameStr forKey:@"_tokenName"];
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"ForgetPassword.do" actionParams:postDic method:@"POST"];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex) {
        [[CSIIMenuViewController sharedInstance].navigationController popToRootViewControllerAnimated:YES];
        [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = @"找回密码";
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    
    if ([action isEqualToString:@"ForgetPassword.do"]) {
        
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            UIAlertView *ale =[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码重置成功，请使用新密码登录" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [ale show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            //            [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
        }else{
            loginPassWordTF.text = @"";
            confirmPassWordTF.text = @"";
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
    [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
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
