//
//  ReFindPasswordViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/5/11.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "ReFindPasswordViewController.h"
#import "keyboardencrypt.h"
#import "shahaiKeyBoard.h"
#import "ShaHaiView.h"
#import "ReSetPasswordViewController.h"
#import "XHDrawerController.h"
@interface ReFindPasswordViewController ()<LWYPickerViewDelegate,MobileSessionDelegate>

{
    NSString* timeString;
    NSArray* _leftTexts;
    NSArray* _rightTFs;
    UITableView* _tableView;
    UITextField* _message;
    
    LWYTextField*userNameTF;
    LWYTextField*IdTypeTF;
    LWYTextField*IdNumTF;
    LWYTextField*phoneTF;
    LWYTextField*AcNoTF;
    UITextField*PasswordTF;
    
    shahaiKeyBoard * _shahaiKeyBoard;
    NSString *_string1;
    int passlen;                           //存储密码长度
    int indexPathRow;                     //存储下拉框的indexPath.row
    NSArray *IdTypeArr;
}

@end

@implementation ReFindPasswordViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PasswordTF.text = @"";
    _string1 = @"";
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"找回密码";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    indexPathRow = 0;
    _leftTexts = @[@"姓名：",@"证件类型：",@"证件号码：",@"借记卡/存折：",@"卡/折密码："];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-20-44+5) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = YES;
    [self.view addSubview:_tableView];
    
    self.mobileBankSession.delegate = self;
    
    [self initElementLayout];
    
    //密码控件初始化  此时的时间戳写死，密码控件初始化时需要用到   在show方法里重新赋值
    [self passWordWith:@"20150203020103"];
}

-(shahaiKeyBoard *)passWordWith:(NSString *)time
{
    _shahaiKeyBoard = nil;
    _shahaiKeyBoard=[[shahaiKeyBoard alloc]init];
    _shahaiKeyBoard.time = time;
    //键盘类型为枚举类型，有全键盘，纯数字键盘，
    _shahaiKeyBoard.keyboardtyp=KeyBoardTypeNumber;
//    _shahaiKeyBoard.showStyle =showStyleNumber;//默认数字键盘
    _shahaiKeyBoard.randomLetter=0;
    _shahaiKeyBoard.randomNumber=1;
    _shahaiKeyBoard.randomSpecial=1;
    _shahaiKeyBoard.maxLen=6;
    _shahaiKeyBoard.minLen=1;
    _shahaiKeyBoard.encrypt=0;
    _shahaiKeyBoard.needHighlighted=1;
    //把当前的textfield传入沙海键盘，当沙海键盘弹出时，系统键盘自动收回
    [_shahaiKeyBoard addTextfield:[NSArray arrayWithObjects: userNameTF,IdTypeTF,IdNumTF,phoneTF,AcNoTF, nil]];
    //先设置参数，然后再初始化沙海键盘方法 如果不设置为默认BOOl=0
    [_shahaiKeyBoard initShahaiKeboard];
    //    [self.view addSubview:_shahaiKeyBoard.myKeyboardView];
    UIWindow *ww = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
    [ww addSubview:_shahaiKeyBoard.myKeyboardView];
    
    //输入回调 如果加密传回为* 不加密传回原文
    [_shahaiKeyBoard.myKeyboardView cilck:^(NSInteger length, NSString *value) {
        PasswordTF.text=_shahaiKeyBoard.myKeyboardView.password;
    }];
    
    //点击删除回调 length=0为长安清空 1为单个删除
    [ _shahaiKeyBoard.myKeyboardView cancle:^(NSInteger length, NSString *value) {
        if (length==0) {
            PasswordTF.text=@"";
        }
        else{
            PasswordTF.text=[PasswordTF.text substringToIndex:length];
        }
    }];
    
    //点击确定回调 加密传回经过沙海加密库加密后的密文和原文长度，不加密传回原文和原文长度
    [_shahaiKeyBoard.myKeyboardView returnKey:^(NSInteger length, NSString *value) {
        
        if ([value isEqualToString:@"-4001"]) {
            passlen = length;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            _tableView.frame = CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5);
            [UIView commitAnimations];
        }else{
            _string1=[NSString stringWithString:value];
            passlen = (int)length;
            NSLog(@"密码是=%@\n长度为=%ld",_string1,(long)length);
            [PasswordTF resignFirstResponder];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            _tableView.frame = CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5);
            [UIView commitAnimations];
        }
    }];
    
    return _shahaiKeyBoard;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag ==101) {
        [shahaiKeyBoard dissMiss:_shahaiKeyBoard.myKeyboardView];
        textField.text = @"";
        [_shahaiKeyBoard show1:_shahaiKeyBoard.myKeyboardView];
//        _shahaiKeyBoard.keyboardtyp=keyBoardTypeLetterAndNumber;
        //获取时间戳
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            if (ISPRINTLOG) {
                NSLog(@"data ：%@",data);
            }
            NSLog(@"时间戳: %@",[data objectForKey:@"_sysDate"]);
            _shahaiKeyBoard.myKeyboardView.time = [data objectForKey:@"_sysDate"];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.1];
            _tableView.frame = CGRectMake(10, -80, ScreenWidth-20, ScreenHeight-72-10-44+5);
            [UIView commitAnimations];
        }];
        return NO;
    }else{
        
        [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
        return YES;
    }
}

//-(void)keyboardUp
//{
//    [_shahaiKeyBoard show1:_shahaiKeyBoard.myKeyboardView];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3];
//    _tableView.frame =  CGRectMake(10, -200, ScreenWidth-20, ScreenHeight-72-20-44+5);
//    [UIView commitAnimations];
//}
//-(void)keyboardDown
//{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3];
//    [shahaiKeyBoard dissMiss:_shahaiKeyBoard.myKeyboardView];
//    _tableView.frame = CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-20-44+5);
//    [UIView commitAnimations];
//}

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
        
        UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(-10, 0, tableView.frame.size.width, CellHeight)];
        bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
        
        [cell.contentView addSubview:bg];
        
        UILabel*title = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, CellHeight)];
        title.backgroundColor = [UIColor clearColor];
        title.text = _leftTexts[indexPath.row];
        title.font = [UIFont systemFontOfSize:14];
        title.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
        //        title.numberOfLines = 0;
        title.textAlignment = NSTextAlignmentRight;
        
        [cell.contentView addSubview:title];
        [cell.contentView addSubview:[_rightTFs objectAtIndex:indexPath.row]];
        cell.backgroundView = backgroundView;
        
        UIView*line = [[UIView alloc]initWithFrame:CGRectMake(5, CellHeight-1, tableView.frame.size.width-10, 1)];
        line.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
        if (indexPath.row!=_leftTexts.count-1) {
            [cell.contentView addSubview:line];
        }
        
        //        if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {         //短信验证码：
        //            _smsButton = [[SMSCodeButton alloc]initWithFrame:CGRectMake(240, 7, 75, cell.frame.size.height-14)];
        //            [cell.contentView addSubview:_smsButton];
        //        }
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
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    footer.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
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
    if (textField == AcNoTF) {
        NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return real.length < 23;
    }
    else if (textField == IdNumTF) {
        NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return real.length < 19;
    }
    else {
        return YES;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [super textFieldDidEndEditing:textField];
    if(textField == IdNumTF){
        if ([IdNumTF validateTextFormat]) {
        }else{
        }
    }
}

-(void) initElementLayout{
    
    CGRect bigFrame = CGRectMake(_tableView.bounds.origin.x+5+80+10, 5, ScreenWidth-(_tableView.bounds.origin.x+5+80+10)-20, CellHeight-10);
    
    userNameTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    userNameTF.backgroundColor = [UIColor clearColor];
    userNameTF.delegate = self;
    userNameTF.tag = 10;
    userNameTF.placeholder = @"请输入姓名";
    [self.inputControls addObject:userNameTF];
    
    NSArray*typeArray = @[@"身份证",@"军官证",@"户口薄",@"警官证",@"士兵证",@"护照",@"文职干部证",@"边民出入境通行证",@"外国人永久居留证",@"临时身份证",@"香港居民来往内地通行证",@"澳门居民来往内地通行证",@"台湾通行证或有效旅行证件",@"军官退休证",@"文职干部退休证",@"军事院校学员证",@"武警士兵证",@"武警文职干部证",@"武警军官退休证",@"武警文职干部退休证",@"其他（对私）"];
    IdTypeArr = @[@"01",@"02",@"03",@"04",@"05",@"06",@"08",@"09",@"10",@"11",@"17",@"18",@"19",@"24",@"25",@"26",@"31",@"33",@"34",@"35",@"49"];
    IdTypeTF = [[LWYTextField alloc]initPicerViewWithFrame:bigFrame picerDataArray:(NSMutableArray*)typeArray];
    IdTypeTF.backgroundColor = [UIColor clearColor];
    IdTypeTF.pickerViewDelegate = self;
    IdTypeTF.delegate = self;
    [self.inputControls addObject:IdTypeTF];
    
    IdNumTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    IdNumTF.backgroundColor = [UIColor clearColor];
    IdNumTF.delegate = self;
    if (indexPathRow == 0) {
        IdNumTF.lwyType = LWYTextFieldType_IDNum;
    }else{
        IdNumTF.lwyType = LWYTextFieldType_None;
    }
    IdNumTF.tag = 11;
    IdNumTF.placeholder = @"请输入证件号";
    [self.inputControls addObject:IdNumTF];
    
    AcNoTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    AcNoTF.backgroundColor = [UIColor clearColor];
    AcNoTF.delegate = self;
    AcNoTF.tag = 13;
    AcNoTF.placeholder = @"请输入借记卡/存折";
    [self.inputControls addObject:AcNoTF];
    
    PasswordTF = [[LWYTextField alloc]initWithFrame:CGRectMake(_tableView.bounds.origin.x+5+80+15, 5, ScreenWidth-(_tableView.bounds.origin.x+5+80+10)-20, CellHeight-10)];
    PasswordTF.backgroundColor = [UIColor clearColor];
    PasswordTF.tag = 101;
    PasswordTF.delegate = self;
    PasswordTF.font = [UIFont systemFontOfSize:14];
    PasswordTF.placeholder = @"请输入卡折密码";
    [self.inputControls addObject:PasswordTF];
    
    _rightTFs = [@[userNameTF,IdTypeTF,IdNumTF,AcNoTF,PasswordTF] mutableCopy];
    
    NSArray*verTextField = [@[userNameTF,IdNumTF,AcNoTF] mutableCopy];
    for (LWYTextField* textField in verTextField) {
        textField.MustInput = YES;
    }
    
}

-(void) buttonActionHandler:(id) sender{
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
    _tableView.frame = CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-20-44+5);
    
    NSArray*verTextField = [@[userNameTF,IdNumTF,AcNoTF] mutableCopy];
    for (LWYTextField* textField in verTextField) {
        if ([textField validateTextFormat]) {
            
        }else{
            return;
        }
    }
    
    if ([_string1 isEqualToString:@""]||_string1 == nil) {
//        ShowAlertView(@"提示", @"密码不能为空", nil, @"确定", nil);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"\n密码不能为空" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
        return;
    }
    
    if (passlen<6) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"\n卡/折密码为6位数字" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
//        ShowAlertView(@"提示", @"卡/折密码为6位数字", nil, @"确定", nil);
        return;
    }
    
    NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
    [postDic setObject:userNameTF.text forKey:@"CifName"];
    [postDic setObject:[IdTypeArr objectAtIndex:indexPathRow] forKey:@"IdType"];
    [postDic setObject:IdNumTF.text forKey:@"IdNo"];
    [postDic setObject:AcNoTF.text forKey:@"AcNo"];
    [postDic setObject:_string1 forKey:@"TrsPassword"];
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"ForgetPasswordConfirm.do" actionParams:postDic method:@"POST"];
}

#pragma mark  ------lwyDelegate--------
-(void) myPickerView:(LWYTextField *)pickerView DidSlecetedAtRow:(int) row{
    NSLog(@"%@",pickerView.text);
    if (row == 0) {
        IdNumTF.lwyType = LWYTextFieldType_IDNum;
    }else{
        IdNumTF.lwyType = LWYTextFieldType_None;
    }
    indexPathRow = row;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 103) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if(alertView.tag == 101){
        if (buttonIndex==0) {
            alertView.hidden = YES;
            self.mobileBankSession.delegate = self;
            [self.mobileBankSession postToServer:@"TimestampJson.do" actionParams:nil method:@"POST"];
            
        }else{
            
            alertView.hidden = YES;
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [shahaiKeyBoard dissMiss:_shahaiKeyBoard.myKeyboardView];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
    _tableView.frame = CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-20-44+5);
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    
    if ([action isEqualToString:@"ForgetPasswordConfirm.do"]) {
        
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            [MobileBankSession sharedInstance].tokenNameStr = [data objectForKey:@"_tokenName"];
            ReSetPasswordViewController*vc = [[ReSetPasswordViewController alloc]init];
            vc.postDic = [[NSMutableDictionary alloc]initWithDictionary:data];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            PasswordTF.text = @"";
        }
        
    }
}

@end
