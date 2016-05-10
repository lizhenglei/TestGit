//
//  registerConfirmViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/5/6.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "registerConfirmViewController.h"
#import "TransResultViewController.h"
#import "SMSCodeButton.h"
#import "keyboardencrypt.h"
#import "shahaiKeyBoard.h"
#import "ShaHaiView.h"
@interface registerConfirmViewController ()<UITableViewDataSource,UITableViewDelegate,MobileSessionDelegate>
{
    NSArray*_leftTexts;
    NSArray*_rightTexts;
    UITableView*_tableView;
    LWYTextField *_firstPasswordTF;
    LWYTextField *_againPasswordTF;
    
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

@implementation registerConfirmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isJiejiCard) {
        _leftTexts = @[@"姓名：",@"证件类型：",@"证件号码：",@"手机号：",@"借记卡/存折号：",@"登录密码：",@"确认密码："];
    }else
        _leftTexts = @[@"姓名：",@"证件类型：",@"证件号码：",@"手机号：",@"IC信用卡：",@"登录密码：",@"确认密码："];
    _rightTexts = @[[self.DataDict objectForKey:@"CifName"],[self.DataDict objectForKey:@"IdTypeName"],[self.DataDict objectForKey:@"IdNo"],[self.DataDict objectForKey:@"MobilePhone"],[self.DataDict objectForKey:@"AcNo"]];//@"郭晓新",@"身份证",@"152327199408092810",@"186117237271",@"6229 8828 1882 332"];
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = YES;
    [self.view addSubview:_tableView];
    
    self.mobileBankSession.delegate = self;
    
    [self initElementLayout];
    
    //密码控件初始化
    password = [self passWordWithTime:@"20150203020104"];
    comfirmPassword = [self passWordWithTime:@"20142021923093"];
    
    [self keyBoardReturn:password withTextFi:_firstPasswordTF];
    [self keyBoardReturn:comfirmPassword withTextFi:_againPasswordTF];

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
                
                NSLog(@"密码是=%@\n长度为=%@",_string1,[NSString stringWithFormat:@"%ld",(long)length]);
//                [UIView beginAnimations:nil context:nil];
//                [UIView setAnimationDuration:0.3];
//                _tableView.frame = CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5);
//                [UIView commitAnimations];

            }
            else if (textField.tag == 11){
                _string2 = [NSString stringWithString:value];
                _stringLength2 = [NSString stringWithFormat:@"%ld",(long)length];
                
                NSLog(@"密码是=%@\n长度为=%@",_string2,[NSString stringWithFormat:@"%ld",(long)length]);
//                [UIView beginAnimations:nil context:nil];
//                [UIView setAnimationDuration:0.3];
//                _tableView.frame = CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5);
//                [UIView commitAnimations];

            }
            
            [textField resignFirstResponder];
        }
    }];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.text = @"";
    if (textField.tag == 10){
        
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
        
        textfiel=1;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        _tableView.frame = CGRectMake(10, self.view.frame.size.height==480?-150:-190, ScreenWidth-20, ScreenHeight-72-10-44+5);
        [UIView commitAnimations];

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
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        _tableView.frame = CGRectMake(10, self.view.frame.size.height==480?-150:-180, ScreenWidth-20, ScreenHeight-72-10-44+5);
        [UIView commitAnimations];

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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
    [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"自助注册";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _leftTexts.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView* backgroundView = nil;
        
        UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, CellHeight)];
        bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
        
        [cell.contentView addSubview:bg];
        
        UILabel*title = [[UILabel alloc]initWithFrame:CGRectMake(-5, 0, 110, CellHeight)];
        title.backgroundColor = [UIColor clearColor];
        title.text = _leftTexts[indexPath.row];
        title.font = [UIFont systemFontOfSize:14];
        title.lineBreakMode = NSLineBreakByWordWrapping;
        title.numberOfLines = 0;
        title.textAlignment = NSTextAlignmentRight;
        
        CGRect bigFrame = CGRectMake(_tableView.bounds.origin.x+5+80+10, 5, ScreenWidth-(_tableView.bounds.origin.x+5+80+10)-30, CellHeight-10);
        
        [cell.contentView addSubview:title];
        if (indexPath.row<_rightTexts.count) {
            
            UILabel*rightTitle = [[UILabel alloc]initWithFrame:bigFrame];
            rightTitle.backgroundColor = [UIColor clearColor];
            rightTitle.text = _rightTexts[indexPath.row];
            rightTitle.font = [UIFont systemFontOfSize:14];
            rightTitle.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
            rightTitle.numberOfLines = 0;
            rightTitle.textAlignment = NSTextAlignmentLeft;
            
            [cell.contentView addSubview:rightTitle];
        }
        cell.backgroundView = backgroundView;
        
        UIView*line = [[UIView alloc]initWithFrame:CGRectMake(5, CellHeight-1, tableView.frame.size.width-10, 1)];
        line.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
        if (indexPath.row!=_leftTexts.count-1) {
            [cell.contentView addSubview:line];
        }
        if(indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-2)
        {
            [cell.contentView addSubview:_firstPasswordTF];
        }
        if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
            [cell.contentView addSubview:_againPasswordTF];
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
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, footer.frame.size.width, 40)];
    [button setBackgroundColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f]];
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(buttonActionHandler:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:button];
    
    return footer;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

-(void) initElementLayout{
    
//    CGRect bigFrame = CGRectMake(_tableView.bounds.origin.x+5+80+10, 5, ScreenWidth-(_tableView.bounds.origin.x+5+80+10)-10, CellHeight-10);
    
    _firstPasswordTF = [[LWYTextField alloc]initWithFrame:CGRectMake(100, 2, 130, CellHeight-4)];
    _firstPasswordTF.placeholder = @"请输入登录密码";
    _firstPasswordTF.tag = 10;
    _firstPasswordTF.delegate =self;
    [self.inputControls addObject:_firstPasswordTF];
    
    _againPasswordTF = [[LWYTextField alloc]initWithFrame:CGRectMake(100, 2, 130, CellHeight-4)];
    _againPasswordTF.placeholder = @"请输入确认密码";
    _againPasswordTF.tag = 11;
    _againPasswordTF.delegate =self;
    [self.inputControls addObject:_againPasswordTF];
    
//    _rightTFs = [@[userNameTF,sexCheck,IdTypeTF,IdNumTF,phoneTF,AcNoTF,PasswordTF] mutableCopy];
    //    for (LWYTextField* textField in inputControls) {
    //        textField.delegate = self;
    //    }
    
}

-(void)buttonActionHandler:(id) sender{
    
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
    if (!(_firstPasswordTF.text.length>7&&_firstPasswordTF.text.length<19)) {
        ShowAlertView(@"提示", @"请输入8到18位密码", nil, @"确认", nil);
        return;
    }
    if (!(_againPasswordTF.text.length>7&&_againPasswordTF.text.length<19)) {
        ShowAlertView(@"提示", @"请输入8到18位密码", nil, @"确认", nil);
        return;
    }

    NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
    [postDic setObject:[self.DataDict objectForKey:@"CifName"] forKey:@"CifName"];
    [postDic setObject:[self.DataDict objectForKey:@"Sex"] forKey:@"Sex"];
    [postDic setObject:[self.DataDict objectForKey:@"IdType"] forKey:@"IdType"];
    [postDic setObject:[self.DataDict objectForKey:@"IdNo"] forKey:@"IdNo"];
    [postDic setObject:[self.DataDict objectForKey:@"MobilePhone"] forKey:@"MobilePhone"];
    [postDic setObject:[self.DataDict objectForKey:@"AcNo"] forKey:@"AcNo"];
    [postDic setObject:[self.DataDict objectForKey:@"Alias"] forKey:@"Alias"];
    [postDic setObject:_string1 forKey:@"LoginPassword"];
    [postDic setObject:_string2 forKey:@"LoginConfirmPassword"];
    [postDic setObject:[self.DataDict objectForKey:@"TrsPasswordV"] forKey:@"TrsPasswordV"];
    [postDic setObject:[self.DataDict objectForKey:@"ValidateFlag"] forKey:@"ValidateFlag"];
    [postDic setObject:[MobileBankSession sharedInstance].tokenNameStr forKey:@"_tokenName"];
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"RegisterInfo.do" actionParams:postDic method:@"POST"];
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    if ([action isEqualToString:@"RegisterInfo.do"]) {
        
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            TransResultViewController*vc = [[TransResultViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
          _firstPasswordTF.text = @"";
          _againPasswordTF.text = @"";
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 103) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if(alertView.tag == 101){
        if (buttonIndex==0) {
        }else{
            
            alertView.hidden = YES;
        }
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    if (textfiel==1) {
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
    }
    if (textfiel==2) {
        [shahaiKeyBoard dissMisskeyboard:comfirmPassword.myKeyboardView];
        [shahaiKeyBoard dissMisskeyboard:password.myKeyboardView];
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _tableView.frame = CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-20-44+5);
    [UIView commitAnimations];
}
@end
