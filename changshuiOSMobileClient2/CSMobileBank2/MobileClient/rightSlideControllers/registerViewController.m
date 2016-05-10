//
//  registerViewController.m
//  MobileClient
//
//  Created by 郭晓新 on 15-4-27.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "registerViewController.h"
#import "CSIIUtility.h"
#import "SMSCodeButton.h"
#import "singleCheckButtonView.h"
#import "registerConfirmViewController.h"
#import "keyboardencrypt.h"
#import "ShaHaiView.h"
#import "shahaiKeyBoard.h"
#import "LabelButton.h"
#import "agreementViewController.h"
@interface registerViewController ()<SingleBtnDelegate,LWYPickerViewDelegate,MobileSessionDelegate>{

    NSString* timeString;
    NSArray* _leftTexts;
    NSArray* _rightTFs;
    UITableView* _tableView;
    UITextField* _message;
    
    LWYTextField*userNameTF;
    singleCheckButtonView*sexCheck;
    LWYTextField*IdTypeTF;
    NSArray*IdTypeArr;
    LWYTextField*IdNumTF;
    LWYTextField*phoneTF;
    LWYTextField*AcNoTF;
    UITextField*PasswordTF;
    
    SMSCodeButton* _smsButton;
    NSString*SexStr;
    shahaiKeyBoard * _shahaiKeyBoardReg;
    NSString *_string1;
    int passlen;                           //存储密码长度
    int indexPathRow;                     //存储下拉框的indexPath.row
    NSString*SerialNoStr;                 //存储短信验证码返回的序号
    NSArray*typeArray;
    LabelButton *agreeBtn;
    UIButton *jiejiCardBtn;
    UIButton *xinyongCardBtn;
    UIView *view11;
    UIView *view22;
}



@end

@implementation registerViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _leftTexts = @[@"姓名：",@"证件类型：",@"证件号码：",@"手机号：",@"手机动态码：",@"卡折",@"借记卡/存折：",@"卡/折密码："];
    indexPathRow = 0;
    
    SexStr = @"M";
    SerialNoStr = @"";
    
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
    [self passWordWith:@"20142301020304"];
    [self.view sendSubviewToBack:_tableView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown) name:UIKeyboardWillHideNotification object:nil];
}
//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if (textField.tag ==101) {
////        [_shahaiKeyBoard show1:_shahaiKeyBoard.myKeyboardView];
//        [self keyboardUp];
//    }
//}

-(shahaiKeyBoard *)passWordWith:(NSString *)time
{
    _shahaiKeyBoardReg = nil;
    _shahaiKeyBoardReg=[[shahaiKeyBoard alloc]init];
    _shahaiKeyBoardReg.time = time;
    //键盘类型为枚举类型，有全键盘，纯数字键盘，
    _shahaiKeyBoardReg.keyboardtyp=KeyBoardTypeNumber;
    _shahaiKeyBoardReg.randomLetter=0;
    _shahaiKeyBoardReg.randomNumber=1;
    _shahaiKeyBoardReg.randomSpecial=1;
    _shahaiKeyBoardReg.maxLen=6;
    _shahaiKeyBoardReg.minLen=1;
    _shahaiKeyBoardReg.encrypt=0;
    _shahaiKeyBoardReg.needHighlighted=1;
    //把当前的textfield传入沙海键盘，当沙海键盘弹出时，系统键盘自动收回
    [_shahaiKeyBoardReg addTextfield:[NSArray arrayWithObjects:userNameTF,IdTypeTF,IdNumTF,phoneTF,AcNoTF,_message, nil]];
    //先设置参数，然后再初始化沙海键盘方法 如果不设置为默认BOOl=0
    [_shahaiKeyBoardReg initShahaiKeboard];
    //    [self.view addSubview:_shahaiKeyBoard.myKeyboardView];
    UIWindow *ww = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
    [ww addSubview:_shahaiKeyBoardReg.myKeyboardView];
    
    //输入回调 如果加密传回为* 不加密传回原文
    [_shahaiKeyBoardReg.myKeyboardView cilck:^(NSInteger length, NSString *value) {
        PasswordTF.text=_shahaiKeyBoardReg.myKeyboardView.password;
    }];
    
    //点击删除回调 length=0为长安清空 1为单个删除
    [ _shahaiKeyBoardReg.myKeyboardView cancle:^(NSInteger length, NSString *value) {
        if (length==0) {
            PasswordTF.text=@"";
        }
        else{
            PasswordTF.text=[PasswordTF.text substringToIndex:length];
        }
    }];
    
    //点击确定回调 加密传回经过沙海加密库加密后的密文和原文长度，不加密传回原文和原文长度
    [_shahaiKeyBoardReg.myKeyboardView returnKey:^(NSInteger length, NSString *value) {
        
        if ([value isEqualToString:@"-4001"]) {
            passlen = length;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            _tableView.frame = CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5);
            [UIView commitAnimations];
        
        }else{
            
            _string1=[NSString stringWithString:value];
            passlen = (int)length;
//            NSLog(@"密码是=%@\n长度为=%ld",_string1,(long)length);
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            _tableView.frame = CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5);
            [UIView commitAnimations];
            [PasswordTF resignFirstResponder];
        }
    }];
    
    return _shahaiKeyBoardReg;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag ==101) {
        [shahaiKeyBoard dissMiss:_shahaiKeyBoardReg.myKeyboardView];
        textField.text = @"";
        [_shahaiKeyBoardReg show1:_shahaiKeyBoardReg.myKeyboardView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        _tableView.frame = CGRectMake(10, self.view.frame.size.height==480?-150:-190, ScreenWidth-20, ScreenHeight-72-10-44+5);
        [UIView commitAnimations];
        
        //获取时间戳
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
//            DebugLog(@"data ：%@",data);
//            NSLog(@"时间戳: %@",[data objectForKey:@"_sysDate"]);
            _shahaiKeyBoardReg.myKeyboardView.time = [data objectForKey:@"_sysDate"];

        }];
        return NO;
    }else{
        
        [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoardReg.myKeyboardView];
        return YES;
    }
    
}

-(void)keyboardUp
{
    [_shahaiKeyBoardReg show1:_shahaiKeyBoardReg.myKeyboardView];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3];
//    _tableView.frame =  CGRectMake(10, ScreenHeight==480?-180:-200, ScreenWidth-20, ScreenHeight-72-20-44+5);
//    [UIView commitAnimations];
}
-(void)keyboardDown
{
    [self.view endEditing:YES];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3];
//    _tableView.frame = CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-20-44+5);
//    [UIView commitAnimations];
//    [shahaiKeyBoard dissMiss:_shahaiKeyBoard.myKeyboardView];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"自助注册";

//    PasswordTF.text = @"";
//    _string1 = @"";
    
    if ([[Context getNSUserDefaultskeyStr:@"agreeProtocol"]isEqualToString:@"Agree"]) {
        agreeBtn.selected = YES;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _leftTexts.count;
}

-(void)selectCard:(UIButton *)sender
{

    if (sender.selected == YES) {
        return;
    }
    if (sender.tag == 601) {//借记卡
        _leftTexts = @[@"姓名：",@"证件类型：",@"证件号码：",@"手机号：",@"手机动态码：",@"卡折",@"借记卡/存折：",@"卡/折密码："];
        AcNoTF.placeholder = @"请输入借记卡/存折";
        PasswordTF.placeholder = @"请输入您的卡/折密码";

        view11.backgroundColor = [UIColor greenColor];
        jiejiCardBtn.selected = YES;
        xinyongCardBtn.selected = NO;
        view22.backgroundColor = [UIColor whiteColor];
    }else if(sender.tag ==602)//信用卡
    {
        _leftTexts = @[@"姓名：",@"证件类型：",@"证件号码：",@"手机号：",@"手机动态码：",@"卡折",@"IC信用卡：",@"查询密码："];
        AcNoTF.placeholder = @"请输入信用卡";
        PasswordTF.placeholder = @"请输入您的信用卡查询密码";

        jiejiCardBtn.selected = NO;
        xinyongCardBtn.selected = YES;
        view22.backgroundColor = [UIColor greenColor];
        view11.backgroundColor = [UIColor whiteColor];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:6 inSection:0];
    NSIndexPath *indexPath22 = [NSIndexPath indexPathForRow:7 inSection:0];

    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,indexPath22, nil] withRowAnimation:UITableViewRowAnimationNone];
//    [_tableView reloadData];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView* backgroundView = nil;
        
        UIView*bg = [[UIView alloc]initWithFrame:CGRectMake(-10, 0, tableView.frame.size.width, CellHeight)];
        bg.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
        
        [cell.contentView addSubview:bg];
        
        if (indexPath.row==5) {
            jiejiCardBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 140, CellHeight)];
            jiejiCardBtn.selected = YES;
            jiejiCardBtn.tag = 601;
            jiejiCardBtn.backgroundColor = [UIColor clearColor];
            [jiejiCardBtn addTarget:self action:@selector(selectCard:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:jiejiCardBtn];

            view11 = [[UIView alloc]initWithFrame:CGRectMake(20, 15, 20, 20)];
            view11.backgroundColor = [UIColor greenColor];
            view11.userInteractionEnabled = NO;
            view11.layer.cornerRadius = 10;
            view11.layer.masksToBounds = YES;
            view11.layer.borderWidth = 5;
            view11.layer.borderColor = [UIColor grayColor].CGColor;
            [jiejiCardBtn addSubview:view11];

            UILabel *jiejiCardBtnLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, 100, CellHeight)];
            jiejiCardBtnLabel.text = @"借记卡/存折";
            jiejiCardBtnLabel.font = [UIFont systemFontOfSize:14];
            [jiejiCardBtn addSubview:jiejiCardBtnLabel];
            
            xinyongCardBtn = [[UIButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width/2+20, 0, 120, CellHeight)];
            xinyongCardBtn.backgroundColor = [UIColor clearColor];
            [xinyongCardBtn addTarget:self action:@selector(selectCard:) forControlEvents:UIControlEventTouchUpInside];
            xinyongCardBtn.tag = 602;
            xinyongCardBtn.selected = NO;
            [cell.contentView addSubview:xinyongCardBtn];

            view22 = [[UIView alloc]initWithFrame:CGRectMake(20, 15, 20, 20)];
            view22.backgroundColor = [UIColor whiteColor];
            view22.layer.cornerRadius = 10;
            view22.userInteractionEnabled = NO;
            view22.layer.masksToBounds = YES;
            view22.layer.borderWidth = 5;
            view22.layer.borderColor =[UIColor grayColor].CGColor;
            [xinyongCardBtn addSubview:view22];

            UILabel *xinyongCardBtnLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, 100, CellHeight)];
            xinyongCardBtnLabel.text = @"IC信用卡";
            xinyongCardBtnLabel.font = [UIFont systemFontOfSize:14];
            [xinyongCardBtn addSubview:xinyongCardBtnLabel];
            
        }
        else
        {
            UILabel*title = [[UILabel alloc]initWithFrame:CGRectMake(-5, 0, 110, CellHeight)];
            title.backgroundColor = [UIColor clearColor];
            title.text = _leftTexts[indexPath.row];
            title.font = [UIFont systemFontOfSize:14];
            title.lineBreakMode = NSLineBreakByWordWrapping;
            title.numberOfLines = 0;
            title.textAlignment = NSTextAlignmentRight;
            
            [cell.contentView addSubview:title];
            [cell.contentView addSubview:[_rightTFs objectAtIndex:indexPath.row]];
            cell.backgroundView = backgroundView;
        }
    
        if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 4) {         //短信验证码：
            [cell.contentView addSubview:_message];
            _smsButton = [[SMSCodeButton alloc]initWithFrame:CGRectMake(200, 13, 90, CellHeight-26)];
            _smsButton.phoneNumber = phoneTF.text;
            _smsButton.actionName = @"大众版注册";
            [cell.contentView addSubview:_smsButton];
        }
        
        UIView*line = [[UIView alloc]initWithFrame:CGRectMake(5, CellHeight-1, tableView.frame.size.width-10, 1)];
        line.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
        if (indexPath.row!=_leftTexts.count-1) {
            [cell.contentView addSubview:line];
        }
//    }
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
    return 120;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    footer.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    UIImage* markImage = [UIImage imageNamed:@"Login_Remanber_close"];
    
    agreeBtn = [[LabelButton alloc]initWithFrame:CGRectMake(2,15, markImage.size.width+180, markImage.size.height)];
    agreeBtn.tag = 101;
    [agreeBtn setImage:markImage frame:CGRectMake(0, 0, markImage.size.width, markImage.size.height) forState:UIControlStateNormal];
    [agreeBtn setImage:[UIImage imageNamed:@"Login_Remanber_open"] forState:UIControlStateSelected];
    [agreeBtn addTarget:self action:@selector(toggleRemember:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:agreeBtn];
    
    UILabel *rememberLab = [[UILabel alloc]initWithFrame:CGRectMake(markImage.size.width+4, 13, 90, 20)];
    rememberLab.text = @"已阅读并同意";
    rememberLab.backgroundColor = [UIColor redColor];
    rememberLab.font = [UIFont systemFontOfSize:13];
    rememberLab.textColor = [UIColor blackColor];
    rememberLab.backgroundColor = [UIColor clearColor];
    [footer addSubview:rememberLab];
    UIButton *protocolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    protocolBtn.frame = CGRectMake(rememberLab.frame.size.width+rememberLab.frame.origin.x-8, 13, 200, 20);
    [protocolBtn setTitle:@"<<个人手机银行客户服务协议>>" forState:UIControlStateNormal];
    protocolBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [protocolBtn addTarget:self action:@selector(protocolBtn) forControlEvents:UIControlEventTouchUpInside];
    [protocolBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [footer addSubview:protocolBtn];
    if ([[Context getNSUserDefaultskeyStr:@"agreeProtocol"]isEqualToString:@"Agree"]) {
        agreeBtn.selected = YES;
    }

    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 50, footer.frame.size.width, 40)];
    [button setBackgroundColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f]];
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(buttonActionHandler:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:button];
    
       return footer;
}
-(void)toggleRemember:(id)sender{
    UIButton*btn = (UIButton*)sender;
    btn.selected = !btn.selected;
}
-(void)protocolBtn
{
    agreementViewController *avc = [[agreementViewController alloc]init];
    [self.navigationController pushViewController:avc animated:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _message) {
        NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return real.length < 7;
    }
    else if (textField == phoneTF) {
        NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
        _smsButton.phoneNumber = phoneTF.text;
        return real.length < 12;
    }
    else if (textField == IdNumTF) {
        NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return real.length < 19;
    }
    else if (textField == AcNoTF) {
        NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return real.length < 23;
    }
    else {
        return YES;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [super textFieldDidEndEditing:textField];
    if (textField == phoneTF) {
        if ([phoneTF validateTextFormat]) {
            _smsButton.phoneNumber = phoneTF.text;
        }else{
        
        }
    }else if(textField == IdNumTF){
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
    
    typeArray = @[@"身份证",@"军官证",@"户口薄",@"警官证",@"士兵证",@"护照",@"文职干部证",@"边民出入境通行证",@"外国人永久居留证",@"临时身份证",@"香港居民来往内地通行证",@"澳门居民来往内地通行证",@"台湾通行证或有效旅行证件",@"军官退休证",@"文职干部退休证",@"军事院校学员证",@"武警士兵证",@"武警文职干部证",@"武警军官退休证",@"武警文职干部退休证",@"其他（对私）"];
    IdTypeArr = @[@"01",@"02",@"03",@"04",@"05",@"06",@"08",@"09",@"10",@"11",@"17",@"18",@"19",@"24",@"25",@"26",@"31",@"33",@"34",@"35",@"49"];
    IdTypeTF = [[LWYTextField alloc]initPicerViewWithFrame:bigFrame picerDataArray:(NSMutableArray*)typeArray];
    IdTypeTF.backgroundColor = [UIColor clearColor];
    IdTypeTF.pickerViewDelegate = self;
    IdTypeTF.delegate = self;
    [self.inputControls addObject:IdTypeTF];

    IdNumTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    IdNumTF.backgroundColor = [UIColor clearColor];
    IdNumTF.delegate = self;
    IdNumTF.tag = 11;
    if (indexPathRow == 0) {
        IdNumTF.lwyType = LWYTextFieldType_IDNum;
    }else{
        IdNumTF.lwyType = LWYTextFieldType_None;
    }
    IdNumTF.placeholder = @"请输入证件号";
    [self.inputControls addObject:IdNumTF];

    phoneTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    phoneTF.backgroundColor = [UIColor clearColor];
    phoneTF.delegate = self;
    phoneTF.placeholder = @"请输入手机号";
    phoneTF.tag = 12;
    phoneTF.lwyType = LWYTextFieldType_Phone;
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.inputControls addObject:phoneTF];

    _message = [[LWYTextField alloc] initWithFrame:CGRectMake(_tableView.bounds.origin.x+5+80+10, 2, 105, CellHeight-4)];
    _message.placeholder = @"请输入动态码";
    _message.tag = 100;
    _message.keyboardType = UIKeyboardTypeNumberPad;
    _message.delegate = self;
    [self.inputControls addObject:_message];
    
    AcNoTF = [[LWYTextField alloc]initWithFrame:bigFrame];
    AcNoTF.backgroundColor = [UIColor clearColor];
    AcNoTF.delegate = self;
    AcNoTF.tag = 13;
    AcNoTF.placeholder = @"请输入借记卡/存折";
    AcNoTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.inputControls addObject:AcNoTF];

    PasswordTF = [[LWYTextField alloc]initWithFrame:CGRectMake(_tableView.bounds.origin.x+5+80+15, 5, ScreenWidth-(_tableView.bounds.origin.x+5+80+10)-20, CellHeight-10)];
    PasswordTF.backgroundColor = [UIColor clearColor];
    PasswordTF.tag = 101;
    PasswordTF.delegate = self;
    PasswordTF.font = [UIFont systemFontOfSize:14];
    PasswordTF.placeholder = @"请输入您的卡/折密码";
    [self.inputControls addObject:PasswordTF];
    
    
    _rightTFs = [@[userNameTF,IdTypeTF,IdNumTF,phoneTF,_message,AcNoTF,AcNoTF,PasswordTF] mutableCopy];
    NSArray*verTextField = [@[userNameTF,IdNumTF,phoneTF,_message,AcNoTF] mutableCopy];
    for (LWYTextField* textField in verTextField) {
        textField.MustInput = YES;//必输项
    } 
    
}

-(void) buttonActionHandler:(id) sender{
    
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoardReg.myKeyboardView];
    _tableView.frame = CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-20-44+5);
    
    NSArray*verTextField = [@[userNameTF,IdNumTF,phoneTF,_message,AcNoTF] mutableCopy];
    for (LWYTextField* textField in verTextField) {
        if ([textField validateTextFormat]) {//验证手机号，证件号等
            
        }else{
            return;
        }
    }
    //借记卡》16位，信用卡-16位
    if (xinyongCardBtn.selected) {
        if (AcNoTF.text.length!=16) {
            ShowAlertView(@"提示", @"请输入正确的信用卡卡号", nil, @"确定", nil);
            return;
        }
    }else
    {
        if (AcNoTF.text.length<16||AcNoTF.text.length==16) {
            ShowAlertView(@"提示", @"请输入正确的借记卡/卡折号", nil, @"确定", nil);
            return;
        }
    }
    
    if ([_string1 isEqualToString:@""]||_string1 == nil) {
        ShowAlertView(@"提示", @"密码不能为空", nil, @"确认", nil);
        return;
    }
    
    if (passlen<6) {
        ShowAlertView(@"提示", @"卡/折密码为6位数字", nil, @"确认", nil);
        return;
    }

    NSLog(@"%@",[IdNumTF.text substringWithRange:NSMakeRange(IdNumTF.text.length-2, 1)]);
    
    if ([[IdTypeArr objectAtIndex:indexPathRow]isEqualToString:@"01"]) {
        if ([[IdNumTF.text substringWithRange:NSMakeRange(IdNumTF.text.length-2, 1)] intValue]%2==0) {
           SexStr = @"F";
        }else{
           SexStr = @"M";
        }
    }else{
        SexStr = @"M";
    }
    
    
    if (!agreeBtn.selected) {
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请阅读并同意个人手机银行客户服务协议" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    
    NSMutableDictionary*postDic = [[NSMutableDictionary alloc]init];
    [postDic setObject:userNameTF.text forKey:@"CifName"];
    [postDic setObject:SexStr forKey:@"Sex"];
    [postDic setObject:[IdTypeArr objectAtIndex:indexPathRow] forKey:@"IdType"];
    [postDic setObject:IdNumTF.text forKey:@"IdNo"];
    [postDic setObject:phoneTF.text forKey:@"MobilePhone"];
    [postDic setObject:AcNoTF.text forKey:@"AcNo"];
    [postDic setObject:_string1 forKey:@"TrsPassword"];
    [postDic setObject:SerialNoStr forKey:@"SerialNo"];
    [postDic setObject:_message.text forKey:@"SmsCode"];
    [postDic setObject:@"Y" forKey:@"ValidateFlag"];        //服务端保存密码，下个交易会用到

    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"RegisterInfoConfirm.do" actionParams:postDic method:@"POST"];
    
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{
    if ([action isEqualToString:@"RegisterInfoConfirm.do"]) {
        
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            [MobileBankSession sharedInstance].tokenNameStr = [data objectForKey:@"_tokenName"];
            registerConfirmViewController*vc = [[registerConfirmViewController alloc]init];
            if (jiejiCardBtn.selected == YES) {
                vc.isJiejiCard = YES;
            }else
                vc.isJiejiCard = NO;
            vc.DataDict = [[NSMutableDictionary alloc]initWithDictionary:data];
            [vc.DataDict setObject:[typeArray objectAtIndex:indexPathRow]  forKey:@"IdTypeName"];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            PasswordTF.text = @"";
        }
    }
    
    if ([action isEqualToString:@"GenTokenNameV1.do"]){
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            SerialNoStr = [data objectForKey:@"SerialNo"];
        }
    }
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
    if (alertView.tag == 10000) {
        [_smsButton stopClock];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoardReg.myKeyboardView];
    [Context setNSUserDefaults:@"noAgree" keyStr:@"agreeProtocol"];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoardReg.myKeyboardView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _tableView.frame = CGRectMake(10, 0, ScreenWidth-20, ScreenHeight-72-10-44+5);
    [UIView commitAnimations];
   
}
@end
