//
//  MobileBankWeb.m
//  MobileBankWeb
//
//  Created by Yuxiang on 13-5-15.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import "MobileBankWeb.h"
//#import "CLKeypad.h"
#import "JSONKit.h"
#import "CSIICachingURLProtocol.h"
#import "MobileBankWebTools.h"
#import "MobileBankCommcation.h"
#import "MobileBankSession.h"
#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"
#import "LWYTextField.h"
#import "LDKGloableVariable.h"
//#import "DoActionSheet.h"
#import "Communication.h"
#import "GlobalVariable.h"
#import "CommonFunc.h"
#pragma UKey
#import "FTUserProtocol.h"
#import "FTKeyInterface.h"

#import "AdvertisementViewController.h"
#import "PiontStoreViewController.h"

#import "SMSCodeButton.h"

#import "FMDatabase.h"

#import "CSIIShareView.h"
#import "CSIIShareHandle.h"

#import "CSIIMenuViewController.h"

#define ALERT_TOAST_TAG  9999
#define ALERT_CONFIRM_TAG  10000
#define ALERT_TAG  10001
#define PROGESS_WINDOW [[[UIApplication sharedApplication] windows] objectAtIndex:0]
#define ALERT_SAFE 1111

#define LEFT_WOOD_WIDTH 18
#define Right_WOOD_X 302

@interface MobileBankWeb()<MobileSessionDelegate,LWYPickerViewDelegate,FTKeyEventsDelegate,FTFunctionDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CustomAlertViewDelegate,CSIIShareViewDelegate>
{
    UIImageView *imageView1;
    CGRect rectOriginal;
    
    //    UIImageView *leftWood;
    //    UIImageView *rightWood;
    
    NSMutableArray *views;
    BOOL isWebHaveSubViews;
    BOOL isBackTran; //后退转场
    BOOL isForwordTran; //前进转场
    
    //NSTimer*timer;
    NSString* returnCode;
    NSString* temp_bitmap_index;
    BOOL isTransPasswordGetTimestamp;
    NSString*ChanllengeStr;
    
    NSString *_string1;
    NSString *_string2;
    
    int AlertTag;
    BOOL UKeyIsconnected;//音频KEY连接成功
    BOOL BKeyIscnnected;//蓝牙KEY连接成功
    
    UIAlertView*tipsAlert;
    CGRect webFrame;
    
    NSArray *transferName;
    NSMutableDictionary *erWeiMadic;
    UITextField *erWeiMaPassWord;
    NSString *passWordSecurity;//卡密
    UIViewController *bgViewController;
    NSMutableDictionary *erWeiMaConfirmMessage;
    UITextField *SMSField;
    NSString *SerialNoStr;
    BOOL VXOrNativePassWord;//判断是VX界面的密码还是原生的密码，NO为VX界面的密码
    NSString *certifyWays;//判断二维码付款的方式，有动态码，卡密加动态码，音频KEY
    UIButton *bgBtnview;
    UITextField *AutoKeyPassWord;//音频k密码
    UIView *rightGes;
    NSDictionary *yaoYiYaoDic;
    
    CustomAlertView *fenQiAlertView;//分期弹框
    CustomAlertView *copyCustomAlert;//我的奖品弹框，包含复制按钮
    
    FMDatabase *_dataBase;
    NSArray *_buttonArray;
    NSString *shareRedPocketString;//分享红包的链接
}

@property (nonatomic,retain)NSString *callbackAlert;
@property (nonatomic,retain)NSString *callbackResultYes;
@property (nonatomic,retain)NSString *callbackResultNo;
@property (nonatomic,retain)NSDictionary *parameterDic;
//@property (nonatomic,retain)CLKeypad *keypad;
@property (nonatomic,retain)UIView *numberKeyboardView;
@property (nonatomic,retain)MobileBankWebTools *webTools;

@end

@implementation MobileBankWeb
@synthesize callbackAlert;
@synthesize callbackResultNo;
@synthesize callbackResultYes;
@synthesize WebDelegate;
@synthesize parameterDic;
//@synthesize keypad;
@synthesize numberKeyboardView;
@synthesize webTools;


-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        rectOriginal = frame;
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        //注册监听事件  音频Key
        [FTKeyInterface FTSetKeyEventsDelegate:self];
        

        transferName = @[@"转账",@"转账金额：",@"卡密码：",@"手机动态码：",@"转账用途：",@"确认转账"];
        //用file://方式加载samples/index.html时，不需要注册CSIICachingURLProtocol
        //        [NSURLProtocol registerClass:[CSIICachingURLProtocol class]];
        
        self.opaque = NO;
        VXOrNativePassWord = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self doSetWebViewProperty:self];
        SerialNoStr = @"";
        erWeiMadic = [[NSMutableDictionary alloc]init];
        yaoYiYaoDic = [[NSDictionary alloc]init];
        webTools=[MobileBankWebTools sharedInstance];
        self.isYaoYiYao = NO;
        erWeiMaConfirmMessage = [[NSMutableDictionary alloc]init];
        _ZZview = [[UIView alloc]initWithFrame:self.bounds];
        _ZZview.backgroundColor = [UIColor blackColor];
        _ZZview.alpha = 0.03;
        _ZZview.hidden = YES;
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(passWordKeyBoardHidden:)];
        [_ZZview addGestureRecognizer:tap];
        [self addSubview:_ZZview];
        
        
        _string1 = @"";
        _string2 = @"";
        
        //webTools.taskInProgress = YES;
        //[webTools showIndicatorViewWithMessage:@"加载中..." andViews:PROGESS_WINDOW];
        //[[MobileBankSession sharedInstance] setMaskShowTimeOut:120]; //设置120秒后超时自动清除等待遮罩层。web页面加载正常的话，vx会在120秒内发送HideMask消息关闭遮罩。
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selfDisapper) name:@"WebView_Disapper" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPostToServer:) name:@"LocalAction_PostToServer" object:nil];
        
        //弹密码控件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAuthenticate:) name:@"LocalAction_Authenticate" object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAuthenticate:) name:@"LocalAction_Authenticatetoken" object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAuthenticate:) name:@"LocalAction_Authenticatemsg" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onToast:) name:@"LocalAction_Toast" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSetTitle:) name:@"LocalAction_SetTitle" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlert:) name:@"LocalAction_Alert" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfirm:) name:@"LocalAction_Confirm" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinishWeb:) name:@"LocalAction_FinishWeb" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinishWebMessage:) name:@"LocalAction_FinishWebWithMessage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGotoMenu:) name:@"LocalAction_GotoMenu" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCloseSplashScreen:) name:@"LocalAction_CloseSplashScreen" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowMask:) name:@"LocalAction_ShowMask" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHideMask:) name:@"LocalAction_HideMask" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHideBackButton:) name:@"LocalAction_HideBackButton" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendRequest:) name:@"LocalAction_SendRequest" object:nil];//js向web模块sendrequest
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartTransition:) name:@"LocalAction_StartTransition" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onForWardTransition:) name:@"LocalAction_ForWardTransition" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBackTransition:) name:@"LocalAction_BackTransition" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfirmPage:) name:@"LocalAction_ConfirmPage" object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeKeyboard:) name:@"LocalAction_ChangeKeyboard" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetActionId:) name:@"LocalAction_GetActionId" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetPrdId:) name:@"LocalAction_GetPrdId" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetHints:) name:@"LocalAction_GetHints" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetBitmapString:) name:@"LocalAction_GetBitmapString" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCloseConfirm:) name:@"LocalAction_CloseConfirm" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowPassword:) name:@"LocalAction_ShowPassword" object:nil]; //弹出密码键盘
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetErWeiMaInfo:) name:@"LocalAction_GetErWeiMaInfo" object:nil]; //二维码
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetAudioKeyDic:) name:@"LocalAction_GetSignData" object:nil]; //获取音频Key或蓝牙Key需要的信息
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetBlueToothKeyDic:) name:@"LocalAction_blueTooth" object:nil]; //连接蓝牙KEY

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClientState:) name:@"LocalAction_ClientState" object:nil]; //获取登录状态以及登录信息
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeClientInfo:) name:@"LocalAction_ChangeClientInfo" object:nil]; //更新登录信息
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetPhoneNumber:) name:@"LocalAction_GetPhoneNumber" object:nil]; //获取通讯录
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetPhoneNumberAndName:) name:@"LocalAction_GetPhoneNumberAndName" object:nil]; //从本地的类获取通讯录返回的信息
        
        //datePicker
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowDatePicker:) name:@"LocalAction_DatePicker" object:nil];//弹出选择日期滚筒
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetDateNum:) name:@"LocalAction_GetDatePickerString" object:nil];//日期控件的日期

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShakeMobile:) name:@"LocalAction_ShakeMobile" object:nil];//摇一摇
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlertKey:) name:@"LocalAction_alertK" object:nil];//摇一摇弹框

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetDiscountInfo:) name:@"LocalAction_OpenHTML" object:nil]; //优惠资讯
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetBusinessInfo:) name:@"LocalAction_onLoadURL" object:nil]; //票务合作
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetEwmTransferMessage:) name:@"LocalAction_ewmShow" object:nil]; //用于二维码转账弹框显示

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetImtMessage:) name:@"LocalAction_imtShow" object:nil]; //展示分期结果页面
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetRewardTransName:) name:@"LocalAction_getRewardTransName" object:nil]; //用于VX对签到抽奖的判断
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlertAllow:) name:@"LocalAction_alertAllow" object:nil]; //用于抽奖弹框中的抽奖码的复制
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetBranch:) name:@"LocalAction_getBranch" object:nil]; //预约
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ToShowRed:) name:@"LocalAction_toshowred" object:nil]; //红包分享
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ToGoYinLianInterface:) name:@"LocalAction_goOrderResult" object:nil]; //资金归集跳转到银联支付页面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ToGoBackVXInterface:) name:@"LocalAction_getFundCollectData" object:nil]; //资金归集银联返回到VX界面


        //Keyboard Number
        
//        CGRect keyboardFrame = CGRectMake(0, 44, 320, 296);
//        keypad = [[CLKeypad alloc] initWithFrame:keyboardFrame];
//        keypad.delegate = self;
//        numberKeyboardView = keypad;
        views = [NSMutableArray array];
        
        [self passWordWith:@"20150203020103"];
    }
    return self;
}
#pragma mark-onClientState
-(void)onClientState:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onClientStateOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}
-(void)onClientStateOnMain:(NSDictionary *)parm
{
    NSDictionary *dicData = [[NSMutableDictionary alloc ]initWithObjectsAndKeys:[NSNumber numberWithBool:[MobileBankSession sharedInstance].isLogin],@"isLogin",[MobileBankSession sharedInstance].Userinfo,@"Userinfo", nil];
//    DebugLog(@"dicData : %@",dicData);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicData options:0 error:nil];
    NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parm objectForKey:@"index"],newString];
    [self stringByEvaluatingJavaScriptFromString:resultString];
    
    
    
}

#pragma mark-onChangeClientInfo
-(void)onChangeClientInfo:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onChangeClientInfoOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}
-(void)onChangeClientInfoOnMain:(NSDictionary *)parm
{
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    NSDictionary* jsDic = [webTools jsonAnalysis:jsonData];
    for (NSString *str in [jsDic allKeys]) {
        [[MobileBankSession sharedInstance].Userinfo setValue:[jsDic objectForKey:str] forKey:str];
    }
}

#pragma mark ---onGetTXL
-(void)GetPhoneNumber:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(GetPhoneNumberOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)GetPhoneNumberOnMain:(NSDictionary *)parm{//获取通讯录
    
    parameterDic = [[NSMutableDictionary alloc]initWithDictionary:parm];
    CustomAlertView*customAlert = [[CustomAlertView alloc]initPhoneNumberWithDelegate:self];
    [customAlert show];
}

-(void)GetPhoneNumberAndName:(NSNotification *)note{
    
    if ([[note userInfo] objectForKey:@"phone"]!=nil&&((NSString*)[[note userInfo] objectForKey:@"phone"]).length>0) {
        
        NSString *nameSS = [[note userInfo] objectForKey:@"name"];
        nameSS = [nameSS stringByReplacingOccurrencesOfString:@" " withString:@""];
        nameSS = [nameSS stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        nameSS = [nameSS stringByReplacingOccurrencesOfString:@"+86" withString:@""];
        NSDictionary *dicData = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[note userInfo] objectForKey:@"phone"],@"PhoneNumber",nameSS,@"PhoneName", nil];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicData options:0 error:nil];
        NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],newString];
        [self stringByEvaluatingJavaScriptFromString:resultString];
    }
}

#pragma mark ----UKeyDelegate-------
//当 Ukey 连接时会调用此接口
-(void)FTDidDeviceConnected{
    UKeyIsconnected = YES;
//        ShowAlertView(@"提示", @"音频KEY已连接", nil, @"确认", nil);
//    NSInteger ret = [FTKeyInterface FTConnectBLEDevice:@"" timeout:10];
//    if(ret != FT_SUCCESS) {
//            ShowAlertView(@"提示", @"连接设备失败", nil, @"确认", nil);
//    }else{
//        BKeyIscnnected = YES;
//    }
}

// 当 Ukey 断开时对调用此接口;
-(void)FTDidDeviceDisconnected{
    UKeyIsconnected = NO;
//        ShowAlertView(@"提示", @"音频KEY未连接", nil, @"确认", nil);
    
//    NSInteger ret = [FTKeyInterface FTDisconnectBLEDevice];
//    if(ret != FT_SUCCESS) {
//        ShowAlertView(@"提示", @"断开设备失败", nil, @"确认", nil);
//    }else
//    {
//        BKeyIscnnected = NO;
//    }
}

-(void)FTShowSignView{    //提示用户点击音频KEY的内容
    //    ShowAlertView(nil, @"请核对音频Key中显示的交易信息，并按‘OK’键确认或按‘C’键取消", nil,nil, nil);
    tipsAlert = [[UIAlertView alloc]initWithTitle:nil message:@"请核对音频Key中显示的交易信息，并按‘OK’键确认或按‘C’键取消" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [tipsAlert show];
}

-(void)FTHideSignView{    //隐藏提示内容调用
    
    [self onHideMaskOnMain:nil];
    [tipsAlert dismissWithClickedButtonIndex:[tipsAlert cancelButtonIndex] animated:YES];
    [tipsAlert removeFromSuperview];
}

-(shahaiKeyBoard *)passWordWith:(NSString *)time
{
    _shahaiKeyBoard = nil;
    _shahaiKeyBoard=[[shahaiKeyBoard alloc]init];
    _shahaiKeyBoard.time = time;
    //键盘类型为枚举类型，有全键盘，纯数字键盘，
    _shahaiKeyBoard.keyboardtyp=KeyBoardTypeNumber;
    _shahaiKeyBoard.randomLetter=0;
    _shahaiKeyBoard.randomNumber=1;
    _shahaiKeyBoard.randomSpecial=1;
    _shahaiKeyBoard.maxLen=6;
    _shahaiKeyBoard.minLen=5;
    _shahaiKeyBoard.encrypt=0;
    _shahaiKeyBoard.needHighlighted=1;
    //把当前的textfield传入沙海键盘，当沙海键盘弹出时，系统键盘自动收回
    [_shahaiKeyBoard addTextfield:[NSArray arrayWithObjects:nil]];
    //先设置参数，然后再初始化沙海键盘方法 如果不设置为默认BOOl=0
    [_shahaiKeyBoard initShahaiKeboard];
    //    [self.view addSubview:_shahaiKeyBoard.myKeyboardView];
    UIWindow *ww = [[[UIApplication sharedApplication]windows] objectAtIndex:0];
    [ww addSubview:_shahaiKeyBoard.myKeyboardView];
    
    //输入回调 如果加密传回为* 不加密传回原文
    [_shahaiKeyBoard.myKeyboardView cilck:^(NSInteger length, NSString *value) {
        erWeiMaPassWord.text=_shahaiKeyBoard.myKeyboardView.password;

        //web回调函数
        _string1 = [_string1 stringByAppendingString:value];
        _string2=[NSString stringWithFormat:@"%ld",(long)length];
        
                NSLog(@"密码是=%@\n长度为=%@",_string1,_string2);
        if (VXOrNativePassWord == NO) {
            NSDictionary *dicData = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"0"],@"Flag",_string1,@"passWord",@"false",@"buttonDis", nil];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicData options:0 error:nil];
            NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],newString];
            
            [self stringByEvaluatingJavaScriptFromString:resultString];

        }
        
    }];
    
    //点击删除回调 length=0为长安清空 1为单个删除
    [ _shahaiKeyBoard.myKeyboardView cancle:^(NSInteger length, NSString *value) {
        if (length==0) {
            erWeiMaPassWord.text = @"";
            //            passwordTF.text=@"";
            _string1 = @"";
            if (VXOrNativePassWord == NO) {
                NSDictionary *dicData = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"Flag",@"",@"passWord",@"false",@"buttonDis", nil];
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicData options:0 error:nil];
                NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],newString];
                
                [self stringByEvaluatingJavaScriptFromString:resultString];

            }
            
        }
        else{
            
            //            passwordTF.text=[passwordTF.text substringToIndex:length];
            erWeiMaPassWord.text = [erWeiMaPassWord.text substringToIndex:length];
            _string1 = value;
            if (VXOrNativePassWord ==NO) {
                NSDictionary *dicData = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"Flag",value,@"passWord",@"false",@"buttonDis",nil];
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicData options:0 error:nil];
                NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],newString];
                [self stringByEvaluatingJavaScriptFromString:resultString];
            }
        }
    }];
    
    //点击确定回调 加密传回经过沙海加密库加密后的密文和原文长度，不加密传回原文和原文长度
    [_shahaiKeyBoard.myKeyboardView returnKey:^(NSInteger length, NSString *value) {
        
        _ZZview.hidden = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        //        self.frame = webFrame;
        self.frame = CGRectMake(0, 0, self.superview.bounds.size.width , self.superview.bounds.size.height - 68);
        self.scrollView.contentOffset = CGPointMake(0, 0);
//        self.TransferTabelView.frame = CGRectMake(10, ScreenHeight/2-120,self.frame.size.width-20,240);

        [UIView commitAnimations];
        //
        if ([value isEqualToString:@"-4001"]) {
            
        }else{
            
            _string1=[NSString stringWithString:value];
            passWordSecurity = _string1;

            _string2=[NSString stringWithFormat:@"%ld",(long)length];
            
            //            NSLog(@"密码是=%@\n长度为=%ld",_string1,(long)length);
        if (VXOrNativePassWord==NO) {
                NSDictionary *dicData;
            if ([_string2 intValue]<6) {
                ShowToast(@"卡/折密码为6位数字");
                dicData = [[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"Flag",_string1,@"passWord",@"false",@"buttonDis", nil];
            }
            else{
                dicData = [[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"Flag",_string1,@"passWord",@"true",@"buttonDis", nil];
            }
            
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicData options:0 error:nil];
                NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],newString];
                [self stringByEvaluatingJavaScriptFromString:resultString];

            }else{
                self.TransferTabelView.frame = CGRectMake(10, ScreenHeight/2-(transferName.count*30+15)/2,self.frame.size.width-20,transferName.count*30+15);

            }
            
            _string1 = @"";
            _string2 = @"";
        }
        //        [self.shahaiKeyBoard.myKeyboardView resignFirstResponder];
        //        self.frame = webFrame;
        [erWeiMaPassWord resignFirstResponder];
    }];
    
    return _shahaiKeyBoard;
}

-(void)registerKeyboardNotification
{
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardWillShowNotification:)
    //                                                 name:UIKeyboardWillShowNotification
    //                                               object:nil];
    
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardDidShowNotification:)
    //                                                 name:UIKeyboardDidShowNotification
    //                                               object:nil];
    
    //keyboard iPad键盘浮动解决方案
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardDidChangeFrameNotification:)
    //                                                 name:UIKeyboardDidChangeFrameNotification
    //                                               object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardWillChangeFrameNotification:)
    //                                                 name:UIKeyboardWillChangeFrameNotification
    //                                               object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardWillHideNotification:)
    //                                                 name:UIKeyboardWillHideNotification
    //                                               object:nil];
}

-(void)removeKeyboardNotification
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)selfDisapper
{
    isBackTran = NO;
    isForwordTran = NO;
}
-(NSString *)getStartWebUrl:(NSString *)url{
    if (!url) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查web启动url的值是否为空" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }else if ([url hasPrefix:@"http://"]|| [url hasPrefix:@"https://"]) {
        return url;
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"url格式有误，请检查url格式" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    return nil;
}

- (void)doSetWebViewProperty:(UIWebView*)webViewObj;
{
    webViewObj.dataDetectorTypes=UIDataDetectorTypeNone;
    for (UIView *subview in [webViewObj subviews]) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"_UIWebViewScrollView"]) {
            [((UIScrollView*)subview) setBounces:YES];
            
            for (UIView *shadowView in subview.subviews)
            {
                
                if ([shadowView isKindOfClass:[UIImageView class]])
                {
                    shadowView.hidden = YES;  //隐藏上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
                }
            }
        }
    }
}


#pragma mark - webView截图方法
-(UIImage*)captureView:(UIView *)theView frame:(CGRect)fra{
    
    @autoreleasepool {
        UIGraphicsBeginImageContext(theView.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [theView.layer renderInContext:context];
        theView.layer.contents =nil;
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, fra);
        UIImage *image = [UIImage imageWithCGImage:ref];
        CGImageRelease(ref);
        return image;
    }
    
}

#pragma mark - 前进截图
-(void)onForWardTransition:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onForWardTransitionOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}


-(void)onForWardTransitionOnMain:(NSDictionary*)param{
    
    isForwordTran  = YES;
    isBackTran = NO;
    CGRect sizeOfPage = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIImage*image1= [self captureView:self frame:sizeOfPage];
    imageView1 = [[UIImageView alloc] initWithFrame:self.frame];
    imageView1.image = image1;
    [self.superview addSubview:imageView1];
    self.frame = CGRectMake(rectOriginal.size.width, rectOriginal.origin.y, rectOriginal.size.width, rectOriginal.size.height);
    
    NSString *str =  [NSString stringWithFormat:@"NativeCall.csii__callback[%@]()",[param objectForKey:@"index"]];
//    DebugLog(@"index ======= %@",[param objectForKey:@"index"]);
    [self stringByEvaluatingJavaScriptFromString:str];
    
}

#pragma mark - 后退截图
-(void)onBackTransition:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onBackTransitionOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}
-(void)onBackTransitionOnMain:(NSDictionary*)param{
    isBackTran = YES;
    isForwordTran = NO;
    CGRect sizeOfPage = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIImage*image1= [self captureView:self frame:sizeOfPage];
    imageView1 = [[UIImageView alloc] initWithFrame:rectOriginal];
    imageView1.image = image1;
    [self.superview addSubview:imageView1];
    self.frame = CGRectMake(-rectOriginal.size.width+2*(rectOriginal.origin.x), rectOriginal.origin.y, rectOriginal.size.width, rectOriginal.size.height);
    
    NSString *str =  [NSString stringWithFormat:@"NativeCall.csii__callback[%@]()",[param objectForKey:@"index"]];
    
    [self stringByEvaluatingJavaScriptFromString:str];
    
}
#pragma mark - 开始转场
-(void)onStartTransition:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onStartTransitionOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}
-(void)onStartTransitionOnMain:(NSDictionary*)param{
    
    [self transition];
}

-(void)transition
{
    
    [UIView animateWithDuration:0.4 animations:^{
        if (isBackTran && !isForwordTran)
        {
            self.frame = rectOriginal;
            imageView1.frame =CGRectMake(rectOriginal.size.width , rectOriginal.origin.y, rectOriginal.size.width, rectOriginal.size.height);
        }
        else if(isForwordTran && !isBackTran)
        {
            self.frame = rectOriginal;
            imageView1.frame =CGRectMake(-rectOriginal.size.width+2*(rectOriginal.origin.x), rectOriginal.origin.y, rectOriginal.size.width, rectOriginal.size.height);
        }
    }
                     completion:^(BOOL finished) {
                         NSLog(@"被清除了");
                         [imageView1 removeFromSuperview];
                     }];
}

//转场时添加/移出web的子试图
-(void)changWebSubViews
{
    //    if (!isWebHaveSubViews)
    //    {
    //        for (UIView *subView in self.scrollView.subviews)
    //        {
    //            [subView removeFromSuperview];
    //            [views addObject:subView];
    //        }
    //        [self.layer setNeedsDisplay];
    //    }
    //    else
    //    {
    //        for (UIView *subView in views)
    //        {
    //            [self.scrollView addSubview:subView];
    //        }
    //        [self.layer setNeedsDisplay];
    //        [views removeAllObjects];
    //        isWebHaveSubViews = !isWebHaveSubViews;
    //    }
    
}

#pragma mark -
-(void)onPostToServer:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onPostToServerOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onPostToServerOnMain:(NSDictionary *)parm{
    
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    
    
    NSDictionary* jsDic = [webTools jsonAnalysis:jsonData];
    
    //[MobileBankSession sharedInstance].delegate=self;
    
    if ([[jsDic objectForKey:@"action"] isEqualToString:@"PostBankProductSeq.do"]) {
        
    }
    
    if ([jsDic objectForKey:@"formData"]==nil ) {
        //        [self.WebDelegate WebPostToServer:[jsDic objectForKey:@"action"] Params:nil];
        //[[MobileBankSession sharedInstance] postToServer:[jsDic objectForKey:@"action"] actionParams:nil WithEntry:WEB];
    }else{
//        DebugLog(@"Web PostToServer Params: %@",[jsDic objectForKey:@"formData"]);
        //[[MobileBankSession sharedInstance] postToServer:[jsDic objectForKey:@"action"] actionParams:[jsDic objectForKey:@"formData"]WithEntry:WEB];
        //        [self.WebDelegate WebPostToServer:[jsDic objectForKey:@"action"] Params:[jsDic objectForKey:@"formData"]];
    }
    
    self.parameterDic = parm;
    
}
//表单验证错误信息显示：
-(void)onToast:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onToastOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onToastOnMain:(NSDictionary *)parm{
    
    [self onHideMaskOnMain:nil];
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *jsDataString = [self stringByEvaluatingJavaScriptFromString:string];
    
    //去掉字符串两端的空白符和换行符
    jsDataString = [jsDataString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"%@",jsDataString);
    CustomAlertView*customalert = [[CustomAlertView alloc]initToastWithDelegate:self context:jsDataString];
    customalert.frame = self.frame;
    [customalert show];
    //    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:jsDataString delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    //    alert.tag=ALERT_TOAST_TAG;
    //    [alert show];
//    DebugLog(@"show toast");
}

//设置顶部标题
-(void)onSetTitle:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onSetTitleOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onSetTitleOnMain:(NSDictionary *)parm{
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    UIViewController* viewController = [self getViewController:[self nextResponder]];
    
    UINavigationController *navigationController = nil;
    if(viewController!=nil && viewController.navigationController!=nil)
    {
        navigationController = viewController.navigationController;
    }
    else if(viewController!=nil && viewController.navigationController==nil)
    {
        UINavigationController *rootNavigation = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
        navigationController = rootNavigation;
    }
    
    UILabel *titleLabel = (UILabel*)[[WebViewController sharedInstance].navigationController.navigationBar viewWithTag:99];
    if (titleLabel!=nil) {
        navigationController.title = @"";
        viewController.title = @"";
        titleLabel.text = jsonData;
    }else{
        viewController.title=jsonData;
        //viewController.navigationController.navigationBar.tintColor = [UIColor redColor];
    }
//    NSLog(@"------------%@",viewController);
//    DebugLog(@"set title: %@",jsonData);
}
//Alert弹出框
-(void)onAlert:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onAlertOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onAlertOnMain:(NSDictionary *)parm{
    [self onHideMaskOnMain:nil];
    self.callbackAlert=nil;
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    
    self.callbackAlert = [NSString stringWithFormat:@"NativeCall.csii__callback[%@](%@)",[parm objectForKey:@"index"],@"yes"];
    
    if (self.callbackAlert !=nil) {
        [self stringByEvaluatingJavaScriptFromString:self.callbackAlert];
    }
    //去掉字符串两端的空白符和换行符
    jsonData = [jsonData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([jsonData hasPrefix:@"com.csii"]) {
        jsonData = @"系统繁忙，请稍后再试";
    }
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:jsonData delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    alert.tag=ALERT_TAG;
    [alert show];
//    DebugLog(@"show alert ");
}

//Confirm确认框
-(void)onConfirm:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onConfirmOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onConfirmOnMain:(NSDictionary *)parm{
    
    self.callbackResultYes=nil;
    self.callbackResultNo=nil;
    
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    
    NSDictionary *result=[webTools jsonAnalysis:jsonData];
//    DebugLog(@"confirm result  :%@",result);
    
    /*result
     {
     message = "\U786e\U5b9a\U5220\U9664\U5417?";
     negativeText = "\U53d6\U6d88";
     positiveText = "\U786e\U5b9a";
     title = "\U786e\U8ba4";
     }
     */
    
    self.callbackResultYes = [NSString stringWithFormat:@"NativeCall.csii__callback[%@]('%@')",[parm objectForKey:@"index"],@"Yes"];
    self.callbackResultNo = [NSString stringWithFormat:@"NativeCall.csii__callback[%@]('%@')",[parm objectForKey:@"index"],@"No"];
    
    NSString *message = [result objectForKey:@"message"];
    if (result && message)
    {
        NSString *title = [result objectForKey:@"title"];
        if([title rangeOfString:@"127.0.0.1:9000"].location != NSNotFound)
        {
            title = [title stringByReplacingOccurrencesOfString:@"127.0.0.1:9000" withString:[Context sharedInstance].server_backend_name];
        }
        
        //去掉字符串两端的空白符和换行符
        message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alert.tag=ALERT_CONFIRM_TAG;
        [alert show];
    }
//    DebugLog(@"show confirm");
}

-(void)onGetActionId:(NSNotification *)note
{
    //异步线程
    [self performSelectorOnMainThread:@selector(onGetActionIdOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onGetActionIdOnMain:(NSDictionary *)parm
{
    
    //    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:[MobileBankSession sharedInstance].userInfoDict];
    //
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    //    NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@','%@')",[parm objectForKey:@"index"],[(WebViewController*)self.delegate getActionId],[(WebViewController*)self.delegate getSelfPrdId]];
//    DebugLog(@"%@",resultString);
    
    NSString* str = [self stringByEvaluatingJavaScriptFromString:resultString];
    
    if(str==nil)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"javaScript执行失败" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        alert.tag=ALERT_TAG;
        [alert show];
    }
}
-(void)onGetPrdId:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onGetPrdIdOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onGetPrdIdOnMain:(NSDictionary *)parm
{
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *actionId = [self stringByEvaluatingJavaScriptFromString:string];
//    DebugLog(@"actionId=%@",actionId);
    
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parm objectForKey:@"index"],[(WebViewController*)self.delegate getPrdIdByActionId:actionId]];
//    DebugLog(@"%@",resultString);
    
    [self stringByEvaluatingJavaScriptFromString:resultString];
}

-(void)onGetHints:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onGetHintsOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onGetHintsOnMain:(NSDictionary *)parm
{
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *actionId = [self stringByEvaluatingJavaScriptFromString:string];
//    DebugLog(@"actionId=%@",actionId);
    
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parm objectForKey:@"index"],[(WebViewController*)self.delegate getHintsByActionId:actionId]];
//    DebugLog(@"%@",resultString);
    
    [self stringByEvaluatingJavaScriptFromString:resultString];
}

-(void)onGetBitmapString:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onGetBitmapStringOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onGetBitmapStringOnMain:(NSDictionary *)parm
{
    temp_bitmap_index = [parm objectForKey:@"index"];
    [[MobileBankSession sharedInstance] postToServer:@"GenAcTokenImg.do" actionParams:nil method:@"POST"];
    [MobileBankSession sharedInstance].delegate = self;
}

//关闭webview，返回到本级菜单页面
-(void)onFinishWeb:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onFinishOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onFinishOnMain:(NSDictionary *)parm{
    
    //    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    //    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    
    UIViewController* viewController = [self getViewController:[self nextResponder]];
    
    UINavigationController *navigationController = nil;
    if(viewController!=nil && viewController.navigationController!=nil)
    {
        DebugLog(@"viewController.navigationController!=nil");
        navigationController = viewController.navigationController;
    }
    else if(viewController!=nil && viewController.navigationController==nil)
    {
        DebugLog(@"viewController.navigationController==nil");
        UINavigationController *rootNavigation = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
        navigationController = rootNavigation;
    }
    
    DebugLog(@"onFinishWeb web delloc");
    
    [navigationController popViewControllerAnimated:YES];
}
-(void)onFinishWebMessage:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onFinishOnMainMessage:) withObject:[note userInfo] waitUntilDone:NO];

}
-(void)onFinishOnMainMessage:(NSDictionary *)parm
{
    NSString *resultString= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];

//    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parm objectForKey:@"index"],[parm objectForKey:@"start"]];
    NSString *ss = [self stringByEvaluatingJavaScriptFromString:resultString];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:ss delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = 251;
    [alertView show];
}
//关闭webview，返回到其他级别原生菜单列表页面
-(void)onGotoMenu:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onGotoMenuOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onGotoMenuOnMain:(NSDictionary *)parm{
    
    [self clearWebContent];
    
    UIViewController* viewController = [self getViewController:[self nextResponder]];
    
    UINavigationController *navigationController = nil;
    if(viewController!=nil && viewController.navigationController!=nil)
    {
        navigationController = viewController.navigationController;
    }
    else if(viewController!=nil && viewController.navigationController==nil)
    {
        UINavigationController *rootNavigation = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
        navigationController = rootNavigation;
    }
    
    [navigationController popToRootViewControllerAnimated:NO];
    
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *menuName = [self stringByEvaluatingJavaScriptFromString:string];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FromWebSwitchToOtherMenuBranch" object:nil userInfo:[[NSDictionary alloc]initWithObjectsAndKeys:menuName,@"MenuName", nil]];
//    DebugLog(@"onGotoMenuOnMain web delloc");
}

//关闭遮罩层
-(void)onCloseSplashScreen:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onCloseSplashScreenOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onCloseSplashScreenOnMain:(NSDictionary *)parm{
    //    [webTools hideIndicatorView:PROGESS_WINDOW];
    //    webTools.taskInProgress = NO;
//    DebugLog(@"close screen");
}

//显示遮罩层
-(void)onShowMask:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onShowMaskOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onShowMaskOnMain:(NSDictionary *)parm{
    
    if (!webTools.taskInProgress) {
        //timer=[NSTimer timerWithTimeInterval:10 target:self selector:@selector(onHideMaskAndShowAlert) userInfo:nil repeats:NO];
        //[[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
        [webTools showIndicatorViewWithMessage:@"加载中..." andViews:PROGESS_WINDOW];
        webTools.taskInProgress = YES;
    }
}
//关闭遮罩层
-(void)onHideMaskAndShowAlert
{
    [self onHideMaskOnMain:nil];
    //[timer invalidate];
    UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"请求超时" message:@"加载超时,请检查网络" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
    [alert show];
    
    [self clearWebContent];
}
-(void)onHideMask:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onHideMaskOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onHideMaskOnMain:(NSDictionary *)parm{
    
    //    if (webTools.taskInProgress) {
    //[timer invalidate];
    [webTools hideIndicatorView:PROGESS_WINDOW];
    webTools.taskInProgress = NO;
    //    }
}

//隐藏返回按钮
-(void)onHideBackButton:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onHideBackButtonOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onHideBackButtonOnMain:(NSDictionary *)parm{
    [self.WebDelegate  hideBackButton];
}

//录入页面跳转到确认页面
-(void)onConfirmPage:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onConfirmPageOnMain:) withObject:[note userInfo] waitUntilDone:NO];
}

//js向web模块sendrequest
-(void)onSendRequest:(NSNotification *)note{
    [self performSelectorOnMainThread:@selector(onDealWithRequest:) withObject:[note userInfo] waitUntilDone:NO];
}

-(void)onDealWithRequest:(NSDictionary *)parm{//向VX发送url
//    DebugLog(@"parm = %@",parm);
    
    NSString *string = [NSString stringWithFormat:@"NativeCall.csii__data[%@ + 1]",[parm objectForKey:@"start"]];
    
    NSString *jsonString = [self stringByEvaluatingJavaScriptFromString:string];
    
//    DebugLog(@"jsonstring = %@",jsonString);
    
    NSMutableDictionary *dic = [jsonString objectFromJSONString];
    NSMutableDictionary*Dict = [[NSMutableDictionary alloc]initWithDictionary:[(NSString*)[dic objectForKey:@"Method"]objectFromJSONString]];
    
    NSString *action =[Dict objectForKey:@"Url"];
    NSString *method = [Dict objectForKey:@"Method"];
    NSMutableDictionary *data = [Dict objectForKey:@"Data"];
    //    if(data!=nil && [dic objectForKey:@"Data"]!=[NSNull null])
    //        DebugLog(@"data jsonstring = %@",[data JSONString]);
    if([action hasPrefix:[NSString stringWithFormat:@"/%@/",SERVER_BACKEND_CONTEXT]])
    {
        action = [action stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@/",SERVER_BACKEND_CONTEXT] withString:@""];
    }
    
    self.parameterDic = parm;
    isTransPasswordGetTimestamp = NO;
    [MobileBankSession sharedInstance].delegate = self;
    if ((NSNull*)data == [NSNull null])
    {
        [[MobileBankSession sharedInstance] postToServer:action actionParams:nil method:method IsVx:YES];
    }
    else
    {
        NSMutableDictionary *sendData=[[NSMutableDictionary alloc]initWithDictionary:data];
        [sendData setValue:@"zh_CN" forKey:@"_locale"];
        
        /*
         {
         AcNo = 101150001009092007;
         BeginDate = 20151024;
         CDFlag = "";
         EndDate = 20151103;
         "_locale" = "zh_CN";
         currentIndex = 1;
         }
         */
        
        [[MobileBankSession sharedInstance] postToServer:action actionParams:sendData method:method IsVx:YES];
    }
}

-(void)onConfirmPageOnMain:(NSDictionary *)parm{
    //    NSString *string= [NSString stringWithFormat:@"csii__data[%@]",[parm objectForKey:@"start"]];
    //    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    //    NSDictionary *result=[webTools jsonAnalysis:jsonData];
//    DebugLog(@"confirm Page");
}


#pragma mark - LocalAction_ChangeKeyboard
-(void)onChangeKeyboard:(NSNotification *)note
{
//    DebugLog(@"onChangeKeyboard， showKeyboard:");
    [self performSelectorOnMainThread:@selector(showKeyboard:) withObject:@"changeKeyboard" waitUntilDone:NO];
}

//全数字键盘
-(void)showKeyboard:(NSString *)note
{
    NSString *type = [self stringByEvaluatingJavaScriptFromString:@"document.activeElement.getAttribute('type');"];
//    DebugLog(@"showKeyboard:  Keyboard type : %@",type);
    
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [numberKeyboardView removeFromSuperview];
        
        if ([type isEqualToString:@"numberx"]||[type isEqualToString:@"number"])
        {
//            DebugLog(@"showKeyboard:  show custom number keyboard");
            UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
            if(tempWindow.subviews==nil || tempWindow.subviews.count==0)
                return;
            CGRect tempCGRect = ((UIView*)[tempWindow.subviews objectAtIndex:0]).frame;
            //iOS7适配数字键盘（xuhonglei）
//            if (tempCGRect.size.height >260) {
//                keypad=[[CLKeypad alloc] initWithFrame:CGRectMake(0, tempCGRect.size.height-216, 320, 216)];
//            }else{
//                keypad=[[CLKeypad alloc] initWithFrame:CGRectMake(0, 44, 320, tempCGRect.size.height-44)];
//            }
//            keypad.delegate=self;
//            numberKeyboardView=keypad;
            
            //            if (tempCGRect.size.height == 296)
            //            {
            //                numberKeyboardView.frame = CGRectMake(0, 80, 320, 296);
            //            }
            //            else
            //            {
            //                numberKeyboardView.frame = CGRectMake(0, 44, 320, 296);
            //            }
            
            [[tempWindow.subviews objectAtIndex:0] addSubview:numberKeyboardView];
        }
        
    }
    else
    {
        //iPad type==number
        //iPad 键盘不变,弹出的键盘第1排是数字，后几排是符号
    }
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)note
{
//    DebugLog(@"keyboardWillChangeFrameNotification, keyboardWillChangeFrame:");
    [self performSelectorOnMainThread:@selector(keyboardWillChangeFrame:) withObject:@"keyboardWillChangeFrame" waitUntilDone:NO];
}

-(void)keyboardWillChangeFrame:(NSString*)note
{
    NSString *type = [self stringByEvaluatingJavaScriptFromString:@"document.activeElement.getAttribute('type');"];
//    DebugLog(@"keyboardWillChangeFrame, keyboard type : %@",type);
    
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [numberKeyboardView removeFromSuperview];
        
        if ([type isEqualToString:@"numberx"]||[type isEqualToString:@"number"])
        {
            UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
            [[tempWindow.subviews objectAtIndex:0] addSubview:numberKeyboardView];
        }
    }
}

- (void)keyboardDidChangeFrameNotification:(NSNotification *)note {
    CGRect keyboardEndFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [self convertRect:keyboardEndFrame fromView:nil];
    
    if (CGRectIntersectsRect(keyboardFrame, self.frame)) {
        // Keyboard is visible
//        DebugLog(@"keyboardDidChangeFrameNotification, showKeyboard:");
        [self performSelectorOnMainThread:@selector(showKeyboard:) withObject:@"changeKeyboard" waitUntilDone:NO];
    } else {
        // Keyboard is hidden
//        DebugLog(@"keyboardDidChangeFrameNotification, closeKeyboard");
        [self performSelectorOnMainThread:@selector(closeKeyboard) withObject:@"closeKeyboard" waitUntilDone:NO];
    }
}

- (void)keyboardDidShowNotification:(NSNotification *)note {
//    DebugLog(@"keyboardDidShowNotification， showKeyboard:");
    [self performSelectorOnMainThread:@selector(showKeyboard:) withObject:@"keyboardDidShowNotification" waitUntilDone:NO];
}

- (void)keyboardWillShowNotification:(NSNotification *)note {
//    DebugLog(@"keyboardWillShowNotification， willShowKeyboard:");
    [self performSelectorOnMainThread:@selector(willShowKeyboard:) withObject:@"keyboardWillShowNotification" waitUntilDone:NO];
}

-(void)willShowKeyboard:(NSString*)note
{
    NSString *type = [self stringByEvaluatingJavaScriptFromString:@"document.activeElement.getAttribute('type');"];
//    DebugLog(@"willShowKeyboard, keyboard type : %@",type);
    
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [numberKeyboardView removeFromSuperview];
        
        if ([type isEqualToString:@"numberx"]||[type isEqualToString:@"number"])
        {
            UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
            [[tempWindow.subviews objectAtIndex:0] addSubview:numberKeyboardView];
        }
    }
}
- (void)keyboardWillHideNotification:(NSNotification *)note {
//    DebugLog(@"keyboardWillHideNotification， closeKeyboard");
    [self performSelectorOnMainThread:@selector(closeKeyboard) withObject:@"closeKeyboard" waitUntilDone:NO];
}

-(void)closeKeyboard{
    
}

- (void)changeKeyboardNSNotification:(NSNotification *)note {
    //[self performSelectorOnMainThread:@selector(showKeyboard:) withObject:@"changeKeyboard" waitUntilDone:NO];
}


#pragma mark get navigationcontroller

-(id)getViewController:(UIResponder*)responder{
    
    UIResponder* res = [[UIResponder alloc]init];
    res = [responder nextResponder];
    while (res) {
        if ([res isKindOfClass:[UIViewController class]]) {
            return res;
        }
        else
            [self getViewController:res];
        
    }
    return nil;
    
}

-(void)onCloseConfirm:(NSNotification *)note{
    parameterDic = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parameterDic objectForKey:@"start"]];
    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    
    //    NSDictionary *result=[webTools jsonAnalysis:jsonData];
    //    DebugLog(@"confirm result  :%@",result);
    
    //    NSString *result = [result objectForKey:@"message"];
    
    UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:@"错误信息！" message:jsonData delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    alertView.tag = 123;
    [alertView show];
}

-(void)onShowPassword:(NSNotification *)note{        //弹出密码键盘
    
    parameterDic = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parameterDic objectForKey:@"start"]];
    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    
    [_shahaiKeyBoard show1:_shahaiKeyBoard.myKeyboardView];
    
    _ZZview.hidden = NO;
    int keyHeight = ScreenHeight - _shahaiKeyBoard.myKeyboardView.frame.size.height-64;
    if ([jsonData intValue]>_shahaiKeyBoard.myKeyboardView.frame.origin.y-50) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        webFrame = self.frame;
        self.frame = CGRectMake(0, -[jsonData intValue]+keyHeight-130, self.frame.size.width,ScreenHeight-_shahaiKeyBoard.myKeyboardView.frame.size.height-(-[jsonData intValue]+keyHeight-130));
        _ZZview.frame = CGRectMake(0, 0, self.frame.size.width,ScreenHeight-_shahaiKeyBoard.myKeyboardView.frame.size.height-(-[jsonData intValue]+keyHeight-130));
        [UIView commitAnimations];
    }
//    else{
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.2];
//        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height-ScreenHeight/2-60)];
//        [UIView commitAnimations];
//
//    }
    
    //获取时间戳
    [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
//        DebugLog(@"data ：%@",data);
        NSLog(@"时间戳: %@",[data objectForKey:@"_sysDate"]);
        _shahaiKeyBoard.myKeyboardView.time = [data objectForKey:@"_sysDate"];
    }];
}

-(void)passWordKeyBoardHidden:(UITapGestureRecognizer*)tap{//隐藏密码键盘
    
    [shahaiKeyBoard dissMisskeyboard:self.shahaiKeyBoard.myKeyboardView];
    _string1 = @"";
    _ZZview.hidden = YES;
}

-(void)onGetErWeiMaInfo:(NSNotification *)note{        //二维码转账----用户信息
    
    //note
    //    {name = LocalAction_GetErWeiMaInfo; userInfo = {
    //        index = 3;
    //    }}
    parameterDic = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    
    NSDictionary *dicData = [[NSMutableDictionary alloc]initWithDictionary:[MobileBankSession sharedInstance].userInfoDict];
    //    [MobileBankSession sharedInstance].userInfoDict = {
    //        cardNumber = 6223230011012632866;
    //        userName = "\U538b\U529b\U6d4b\U8bd5";
    //    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicData options:0 error:nil];
    NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],newString];
    
    [self stringByEvaluatingJavaScriptFromString:resultString];
    
}

-(void)onGetBlueToothKeyDic:(NSNotification *)note//蓝牙KEY数据
{
    [FTKeyInterface FTSetTransmitType:1];       // 0 音频KEY       1 蓝牙KEY

    NSInteger ret = [FTKeyInterface FTConnectBLEDevice:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"UkeyId"] timeout:10];
    if(ret != FT_SUCCESS) {
            ShowAlertView(@"提示", @"连接设备失败，请确认蓝牙是否打开，然后重试", nil, @"确认", nil);
        return;
    }else{
        BKeyIscnnected = YES;
    }
}

-(void)onGetAudioKeyDic:(NSNotification *)note{        //音频KEY加密数据

    if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"ukeyType"]isEqualToString:@"2"]) {//蓝牙Key
        if (BKeyIscnnected) {
            parameterDic = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    
            NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parameterDic objectForKey:@"start"]];
            NSString *jsDataString = [self stringByEvaluatingJavaScriptFromString:string];
    
            NSMutableDictionary*dic = [[NSMutableDictionary alloc]initWithDictionary:[jsDataString objectFromJSONString]];
            [dic setObject:@"3333" forKey:@"erWeiMa"];
            [self DoSign:dic];
        }else
        {
            ShowAlertView(@"提示", @"蓝牙Key未连接", nil, @"确认", nil);
        }
    }
    else{
        if (UKeyIsconnected) {
            
            [FTKeyInterface FTSetTransmitType:0];       // 0 音频KEY       1 蓝牙KEY
            
            parameterDic = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
            
            NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parameterDic objectForKey:@"start"]];
            NSString *jsDataString = [self stringByEvaluatingJavaScriptFromString:string];
            
            NSMutableDictionary*dic = [[NSMutableDictionary alloc]initWithDictionary:[jsDataString objectFromJSONString]];
            [dic setObject:@"3333" forKey:@"erWeiMa"];//用于区分二维码转账和其他转账,VX是3333
            [self DoSign:dic];
            
        }else{
            ShowAlertView(@"提示", @"音频KEY未连接", nil, @"确认", nil);
        }
    }
}

-(void)DoSign:(NSMutableDictionary*)dic
{
    unsigned int PinTimes = 0;
    
    NSString *SignRet = nil;
    
    NSString*passWord = [dic objectForKey:@"YPKPassword"];
    
    NSString *msg = [dic objectForKey:@"sinData"];
    
//    (lldb) po msg  二维码
//    <?xml version="1.0" encoding="UTF-8"?><T><D><M><k>收款人账号：</k><v>6223230011012895521</v></M><M><k>收款人户名：</k><v>郭小新</v></M><M><k>转账金额：</k><v>111111</v></M><M><k>付款人账号：</k><v>6223230011012888120</v></M></D><E><M><k>币种：</k><v>01</v></M><M><k>用途：</k><v>转账</v></M></E></T>
    
    
    //    NSString *msg = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><T><D><M><k>收款人:</k><v>王艳双\n</v></M><M><k>收款金额:</k><v>123.23\n</v><k>收款账户:</k> <v>123456789012345600000000\n</v></M></D><E><M><k>流水号：</k><v>12345678</v></M></E><F>hahaha</F></T>";
    
    
    //    NSString *mySN = nil;
    //
    
    
    //    /*读取序列号*/
    //    NSInteger ret1 = [FTKeyInterface FTReadSN:&mySN];
    //    if(ret1 == FT_SUCCESS) {
    //        NSString* strSN = [NSString stringWithFormat:@"序列号为：%@", mySN];
    //        ShowAlertView(@"序列号", strSN, nil, @"确定", nil);
    //    }else {
    //        NSString* strSN = [NSString stringWithFormat:@"获取序列号失败:%ld", (long)ret1];
    //        ShowAlertView(@"序列号", strSN, nil, @"确定", nil);
    //    }
    //
    //    /*读取证书*/
    //    NSString *cert = nil;
    //
    //    NSInteger ret2 = [FTKeyInterface FTReadCertByDN:&cert byDN:@"CN=041@0360428198902050821@1000000015_20150514191515@00000031,OU=Customers,OU=CSRCB,O=CFCA TEST CA,C=cn"];//[FTKeyInterface FTReadCert:&cert];   DN值以后登录的时候会返回
    //
    //    if(ret2 == FT_SUCCESS) {
    //        ShowAlertView(@"证书内容", cert, nil, @"确定", nil);
    //
    //    }else {
    //        NSString* strCert = [NSString stringWithFormat:@"读取证书失败:%ld", (long)ret2];
    //        ShowAlertView(@"读取证书", strCert, nil, @"确定", nil);
    //    }
    //
    
    //    /*单独校验密码，验签校验密码时返回的次数有问题*/已修复
    //    NSInteger ret3;
    //
    //    ret3 = [FTKeyInterface FTVerifyPIN:passWord PinRemaintimes:&PinTimes delegate:self];
    //    if (ret3 == FT_SUCCESS) {
    //
    //    }else if (ret3 == FT_ENERGY_LOW){
    //
    //        ShowAlertView(@"提示", @"音频Key电量不足，不能进行通讯", nil, @"确定", nil);
    //        return;
    //
    //    }else {
    //        NSString *strResult = [NSString stringWithFormat:@"验证密码失败,剩余次数:%d", PinTimes];
    //        ShowAlertView(@"签名结果", strResult, nil, @"确定", nil);
    //        return;
    //    }
    
    
    /*校验密码及验签*/
    NSInteger ret;
    ret = [FTKeyInterface FTSign:msg retData:&SignRet pin:passWord pinRetryTimes:&PinTimes hashAlg:FT_ALG_RSA byDN:nil delegate:self];//@"CN=041@0360428198902050821@1000000015_20150514191515@00000031,OU=Customers,OU=CSRCB,O=CFCA TEST CA,C=cn"
    //返回为十进制  13    14   15   对应的D  E   F
    if (ret == FT_PASSWORD_INVALID_LENGTH) {
        
        NSString *strResult = [NSString stringWithFormat:@"验证密码失败,密码长度错误"];
        ShowAlertView(@"提示", strResult, nil, @"确认", nil);
        
    }
    else if (ret == FT_PASSWORD_INVALID)
    {
        NSString *strResult = [NSString stringWithFormat:@"验证密码失败,剩余次数:%d", PinTimes];
        ShowAlertView(@"提示", strResult, nil, @"确认", nil);
    }
    else if (ret == FT_ENERGY_LOW){
        
        ShowAlertView(@"提示", @"音频Key电量不足，不能进行通讯", nil, @"确认", nil);
    }
    else if (ret == FT_USER_CANCEL){
        
        //        ShowAlertView(@"提示", @"取消操作", nil, @"确定", nil);
    }
    else if (ret == FT_COMM_FAILED){
        
        ShowAlertView(@"提示", @"通讯失败", nil, @"确认", nil);
    }
    else if(ret == FT_PIN_LOCK)
    {
        ShowAlertView(@"提示", @"错误次数达到5次，音频Key已锁定", nil, @"确认", nil);
    }
    else if(ret == FT_SUCCESS)
    {
        NSString *resultString = nil;
        if ([[dic objectForKey:@"erWeiMa"]isEqualToString:@"1111"]) {//扫面二维码支付列表的原生页面
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:SignRet forKey:@"SignData"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
          NSString * jsonStr =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],jsonStr];

        }else{
            resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],SignRet];
        }
        [self stringByEvaluatingJavaScriptFromString:resultString];
    }
    else
    {
        NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('')",[parameterDic objectForKey:@"index"]];
        [self stringByEvaluatingJavaScriptFromString:resultString];
        
//        NSString *strSignResult = [NSString stringWithFormat:@"签名失败:%d", (int)ret];
//        ShowAlertView(@"签名结果", strSignResult, nil, @"确定", nil);
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == ALERT_CONFIRM_TAG) {    //confirm弹框
        if (buttonIndex == 0) {
            [self stringByEvaluatingJavaScriptFromString:self.callbackResultNo];
            
        }else{
            [self stringByEvaluatingJavaScriptFromString:self.callbackResultYes];
        }
    }
    if (alertView.tag ==300) {
        if (buttonIndex==1) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"05" forKey:@"security"];
            [MobileBankSession sharedInstance].delegate = self;
            [[MobileBankSession sharedInstance]postToServer:@"ChannelAuthTypeUpd.do" actionParams:dic method:@"POST"];
        }
    }
    if (alertView.tag==250) {
        if (buttonIndex==0) {
            [[WebViewController sharedInstance] becomeFirstResponder];
            self.isYaoYiYao = YES;
        }
    }
    if (alertView.tag==251) {
        if (buttonIndex==0) {
            [[WebViewController sharedInstance].navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma  mark MobileBankSessionDelegate
//保证模块间的无关联性，同步来解决交易
/*
 -(void)getReturnData:(NSDictionary*)dic withTransaction:(NSString *)transaction;{
 if(dic != nil) {
 NSMutableDictionary* returnDic = [[NSMutableDictionary alloc]init];
 [returnDic setObject:@"Yes" forKey:@"success"];
 [returnDic setObject:dic forKey:@"data"];
 NSString* result = nil;
 
 NSString* newString=[webTools otherTojson:returnDic];
 
 result = [NSString stringWithFormat:@"csii__callback[%@]('%@')",[self.parameterDic objectForKey:@"index"],newString];
 [self stringByEvaluatingJavaScriptFromString:result];
 }else{
 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"返回数据错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 alert.tag=ALERT_TAG;
 [alert show];
 }
 
 }*/

-(void)getReturnData:(id)data WithActionName:(NSString *)action;
{
    DebugLog(@"#####action : %@, \n######server return Data to Web : %@",action,data);
    
    if ([action isEqualToString:@"QueryLYBCustInfo.do"]) {
        NSLog(@"了一包%@",data);
    }
    
    id webdata = nil;
    NSString * status = @"";
    
    if ([action isEqualToString:@"GenTokenNameV1.do"]){
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            SerialNoStr = [data objectForKey:@"SerialNo"];
            
        }else{
            
        }
    }
    
    
  /*  if ([data isKindOfClass:[NSDictionary class]]&&[action hasSuffix:@".do"]&&[MobileBankSession sharedInstance].UserAnalysisActionId.length>0&&![action isEqualToString:@"GenTokenImg.do"]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* plistPath1 = [paths objectAtIndex:0];
        NSString *filename =[plistPath1 stringByAppendingPathComponent:@"UserAnalysis.sqlite"];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:action forKey:@"TransCode"];
        if ([MobileBankSession sharedInstance].UserAnalysisActionId.length==0) {
            [dic setObject:@"" forKey:@"ActionId"];
        }else{
            [dic setObject:[MobileBankSession sharedInstance].UserAnalysisActionId forKey:@"ActionId"];
        }
        //        [dic setValue:[data objectForKey:@"_RejCode"] forKey:@"RejCode"];
        if ([[data allKeys] containsObject:@"_RejCode"]) {
            [dic setObject:[data objectForKey:@"_RejCode"] forKey:@"RejCode"];
        }else{
            [dic setObject:@"000000" forKey:@"RejCode"];
        }
        if ([MobileBankSession sharedInstance].isLogin) {
            [dic setValue:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"] forKey:@"MobileNo"];
        }else
            [dic setObject:@"" forKey:@"MobileNo"];
        NSDate *date = [[NSDate alloc]init];
        NSDateFormatter *daff = [[NSDateFormatter alloc]init];
        [daff setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateSS = [daff stringFromDate:date];
        [dic setValue:dateSS forKey:@"TransTime"];
        NSString *infoString = [Context jsonStrFromDic:dic];
        NSString *infoStringDES = [CommonFunc base64StringFromTextDES:infoString];//将存到数据库里的东西加密了
        
        _dataBase  = [[FMDatabase alloc] initWithPath:filename];
        if([_dataBase open]){
            NSLog(@"数据库创建打开成功");
            [_dataBase open];
            [_dataBase executeUpdate:@"create table User(UserName text)"];
            [_dataBase executeUpdate:@"insert into User(UserName) values(?)",infoStringDES];
            [_dataBase close];
            
        }
        else
            NSLog(@"数据库创建打开失败");
        
        //        self.UserAnalysisActionId = @"";
    }
    
    */
    
    
    
    if([action rangeOfString:@".do"].length != 0)
    {
        webdata = data;
        status = @"200";
    }
    else
    {
        webdata = [data objectForKey:@"WebData"];
        status = [data objectForKey:@"httpStatus"];
    }
//    DebugLog(@"status = %@",status);
    
    if(data != nil && webdata!=nil) {
        
        //        if ([action isEqualToString:@"InlineTransfer.do"]) {
        //
        //            webdata = @"{\"_RejCode\":\"000000\",\"ProcessState\":\"OK\",\"MCSJnlNo\":\"17865\"}";
        //        }
//        DebugLog(@"post给VX***********的数据 = %@",webdata);
        
        
        NSString* dataString;
        if ([webdata isKindOfClass:[NSDictionary class]] || [webdata isKindOfClass:[NSArray class]])
        {
//            dataString = [self stringEscape:[webdata JSONString]];
            dataString = [self stringEscape:[Context jsonStrFromDic:webdata]];
        }
        else
        {
            //dataString = [[[[webdata stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            dataString = [self stringEscape:webdata];
            
        }
        //DebugLog(@"datastring = %@",dataString);
        
        //        NSString *result = [NSString stringWithFormat:@"NativeCall.csii__data[%@].receive('%@','%@')",[self.parameterDic objectForKey:@"start"],status,dataString];
        //
        NSString *result = [NSString stringWithFormat:@"NativeCall.csii__data[%@].receive('%@',unescape('%@'))",[self.parameterDic objectForKey:@"start"],status,dataString];
        
        //DebugLog(@"Web send data to javaScript: %@",result);
        NSString* str = [self stringByEvaluatingJavaScriptFromString:result];
//        DebugLog(@"Web send data to javaScript, return the result of running a script=%@", str);
        if(str==nil)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"javaScript执行失败,httpStatusCode=%@",status] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            alert.tag=ALERT_TAG;
            [alert show];
        }
    }
    else    //没有找到页面   本地或者服务器
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"返回数据错误" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        alert.tag=ALERT_TAG;
        [alert show];
        [self onHideMask:nil];
        return;
    }
}

-(NSString*)stringEscape:(NSString*)string{
    //    NSMutableString *tempString = [[NSMutableString alloc]init];
    //    for (long i = 0; i <[string length]; i++) {
    //
    //    }
    //    return tempString;
    
    
    NSMutableString *tempString = [[NSMutableString alloc]init];
    unsigned int  tempChar;//这里注意
    for (int i = 0; i <[string length]; i++) {
        tempChar = [string characterAtIndex:i];
        if ((tempChar <= 'z' && tempChar >= 'a') ||(tempChar <='Z' && tempChar >= 'A')||(tempChar <= '9' && tempChar >= '0')) {
            [tempString appendFormat:@"%c",tempChar];
        }else if (tempChar < 256){
            [tempString appendString:@"%"];
            if (tempChar < 16) {
                [tempString appendString:@"0"];
            }
            
            [tempString appendFormat:@"%x",tempChar];
            
        }else{
            [tempString appendString:@"%u"];
            
            [tempString appendFormat:@"%x",tempChar];
            
        }
    }
    return tempString;
}
#pragma mark CLKeypadDelegate

- (void)hideCLKeypad {
    [self endEditing:YES];
}

- (void)numberPressed:(NSInteger)number {
    if (number <= 9)
    {    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"NativeCall.csii__InputData(\"%ld\")", (long)number]];
    }
    //decimal point
    else if (number == 10) {
        [self stringByEvaluatingJavaScriptFromString:@"NativeCall.csii__InputData('.');"];
    }
    //0
    else if (number == 11)
        [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"NativeCall.csii__InputData(\"%@\")", @"0"]];
    //backspace
    else if (number == 12) {
        
        [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"NativeCall.csii__InputData(\"%@\")", @"delete"]];
        
    }
}

#pragma mark - 清空web内容
-(void)clearWebContent
{
    //    [_shahaiKeyBoard.myKeyboardView removeFromSuperview];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self loadRequest:request];
    [self selfDisapper];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    
    
//    NSInteger ret = [FTKeyInterface FTDisconnectBLEDevice];//断开蓝牙KEY
//    if(ret == FT_SUCCESS) {
////        [self showMsg:@"提示" Message:[NSString stringWithFormat:@"%@:%d", @"断开设备失败", ret]];
//        BKeyIscnnected = NO;
//    }
    
    //下面这句设置和加载"about:blank"页效果相同。
    //    [self stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
    
    //清空历史网页
    //    id internalWebView=[[myWebView _documentView] webView];
    //    [internalWebView setMaintainsBackForwardList:NO];
    //    [internalWebView setMaintainsBackForwardList:YES];
    
}

#pragma datePicker

- (void) onShowDatePicker:(NSNotification*)note
{
    NSLog(@"123456");
    parameterDic = [note userInfo];
    [self performSelectorOnMainThread:@selector(alterDatePicker) withObject:nil waitUntilDone:NO];
}

- (void) alterDatePicker {
    
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parameterDic objectForKey:@"start"]];
    
    NSMutableString *jsDataString = [[NSMutableString alloc]initWithString:[self stringByEvaluatingJavaScriptFromString:string]];
    NSLog(@"%@",jsDataString);
    self.datePickerTF = [[LWYTextField alloc] initDatePicerViewWithFrame:CGRectMake(0, 0, 0, 0)andString:jsDataString];
    
    self.datePickerTF.text = jsDataString;
    
    [self addSubview:self.datePickerTF];
    [self.datePickerTF becomeFirstResponder];

    
}
-(void)GetDateNum:(NSNotification *)note
{
    NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],[dic objectForKey:@"dateNum"]];
    [self stringByEvaluatingJavaScriptFromString:resultString];
}
-(double )getCurrentTime{
    
    NSTimeInterval firstTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    double a=firstTime;
    
//    [[NSUserDefaults  standardUserDefaults] setObject:[NSNumber numberWithDouble:a] forKey:@"yaoTime"];
    
    return a;
}

-(void)shakeAction
{
//        if (motion != UIEventSubtypeMotionShake) return;
    if (self.isYaoYiYao) {
        double firstAction=[[[NSUserDefaults standardUserDefaults]objectForKey:@"yaoTime"]doubleValue];
        double seconed=[self getCurrentTime];
        double offset=seconed-firstAction;
        
        DebugLog(@"%f %f %f",firstAction,seconed,offset);
        if (offset<3000 && offset!=0) {//解决一次摇动多次调用的bug
            NSLog(@"时间短");
        }else{
            NSLog(@"时间够");
            if (self.isYaoYiYao) {
                
                NSTimeInterval firstTime = [[NSDate date] timeIntervalSince1970] * 1000;
                
                double a=firstTime;
                
                [[NSUserDefaults  standardUserDefaults] setObject:[NSNumber numberWithDouble:a] forKey:@"yaoTime"];

                
                NSString *string= [NSString stringWithFormat:@"NativeCall.csii__callback[%@]('')",[yaoYiYaoDic objectForKey:@"index"]];
                [self stringByEvaluatingJavaScriptFromString:string];
                [[WebViewController sharedInstance] resignFirstResponder];
            }
        }
        self.isYaoYiYao = NO;
    }else{
        
    }

}
-(void)onShakeMobile:(NSNotification *)note
{
    [[WebViewController sharedInstance] becomeFirstResponder];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shakeAction) name:@"shake" object:nil];
    self.isYaoYiYao = YES;
    [[UIApplication sharedApplication]setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
    yaoYiYaoDic = [note userInfo];
}
-(void)onAlertKey:(NSNotification *)note
{
    parameterDic = [note userInfo];
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parameterDic objectForKey:@"start"]];
   NSString *ss = [self stringByEvaluatingJavaScriptFromString:string];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:ss delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = 250;
    [alertView show];
    
}
-(void)GetDiscountInfo:(NSNotification *)note
{
    NSDictionary *parm = [note userInfo];
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSMutableString *jsDataString = [[NSMutableString alloc]initWithString:[self stringByEvaluatingJavaScriptFromString:string]];
    if ([jsDataString rangeOfString:@"PFavorableDetail.html"].length>0) {
        if ([jsDataString rangeOfString:@"Flag=0"].length!=0&&[jsDataString substringFromIndex:[jsDataString rangeOfString:@"&@#$Url="].location+8].length>0) {
            NSString *urlString =[jsDataString substringFromIndex:[jsDataString rangeOfString:@"&@#$Url="].location+8];
            DebugLog(@"%@",[jsDataString substringFromIndex:[jsDataString rangeOfString:@"&@#$Url="].location+8]);
            AdvertisementViewController *ww = [[AdvertisementViewController alloc]init];
            ww.webUrl = urlString;
            ww.webTitleName = @"精彩活动";
            //        ww.adverWeb = NO;
            [[WebViewController sharedInstance].navigationController pushViewController:ww animated:YES];
        }
    }
    else
    {
            NSRange aa = [jsDataString rangeOfString:@"http"];
            NSRange bb = [jsDataString rangeOfString:@"mweb"];
            if (aa.length>0&&bb.length>0) {
                NSString *ti = [jsDataString substringWithRange:NSMakeRange(aa.location, bb.location-aa.location+4)];
                jsDataString = (NSMutableString *)[jsDataString stringByReplacingOccurrencesOfString:ti withString:[NSString stringWithFormat:@"%@/%@",SERVER_BACKEND_URL,SERVER_BACKEND_CONTEXT]];
                NSRange cc = [jsDataString rangeOfString:@"html?"];
                NSMutableString *ss = (NSMutableString *)[jsDataString substringToIndex:cc.location+5];//?参数之前的
                //samples/htmls/PFavorableMessage/PFavorableDetail.html?
                
                NSString *canstring = [jsDataString substringFromIndex:cc.location+5];//?之后的转为base64
                NSData *data = [canstring dataUsingEncoding:NSUTF8StringEncoding];
                NSString *base64String = [CommonFunc base64EncodedStringFrom:data];
                
                NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@%@",SERVER_BACKEND_URL,SERVER_BACKEND_CONTEXT,ss,base64String];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                [self loadRequest:request];
            }
            else{
                AdvertisementViewController *ww = [[AdvertisementViewController alloc]init];
                ww.webUrl = jsDataString;
                
//                NSString *yy =  [self stringByEvaluatingJavaScriptFromString:@"document.title"];//获取当前页面的title

                
//                ww.webTitleName = @"意见反馈";//
                //        ww.adverWeb = NO;
                [[WebViewController sharedInstance].navigationController pushViewController:ww animated:YES];
            }
        }

}

-(void)GetBusinessInfo:(NSNotification *)note
{
    NSDictionary *parm = [note userInfo];
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSMutableString *jsDataString = [[NSMutableString alloc]initWithString:[self stringByEvaluatingJavaScriptFromString:string]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:jsDataString]];
    [self loadRequest:request];
    
}
-(void)GetEwmTransferMessage:(NSNotification *)note
{
    parameterDic = [note userInfo];
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parameterDic objectForKey:@"start"]];
    NSMutableString *jsDataString = [[NSMutableString alloc]initWithString:[self stringByEvaluatingJavaScriptFromString:string]];
   erWeiMadic = [Context jsonDicFromString:jsDataString];
    /*
     (lldb) po erWeiMadic
     {
     Amount = 11;
     Balance = "4971362.02";
     Currency = CNY;
     PayeeAcName = "\U90ed\U5c0f\U65b0";
     PayeeAcNo = 6223230011012895521;
     Remark = "\U8f6c\U8d26";
     flag = 0;
     thenum = 6223230011012895521;
     }
     0 短信
     1 短信+卡密
     2 音频K
     */
    if ([[erWeiMadic objectForKey:@"flag"]intValue] ==0) {
        certifyWays = @"0000";
        transferName = @[@"转账",@"转账金额：",@"转账用途：",@"手机动态码：",@"确认支付"];
    }else if ([[erWeiMadic objectForKey:@"flag"]intValue] == 1)
    {
        certifyWays = @"2222";
        transferName = @[@"转账",@"转账金额：",@"转账用途：",@"卡密码：",@"手机动态码：",@"确认支付"];

    }
    else if ([[erWeiMadic objectForKey:@"flag"]intValue]==2)
    {
        certifyWays = @"1111";
        transferName = @[@"转账",@"转账金额：",@"转账用途：",@"音频K密码：",@"确认支付"];
    }else
    {
    
    }
    
    VXOrNativePassWord = YES;
    SMSField = [[UITextField alloc]initWithFrame:CGRectMake(90, 3, 85, 24)];
    erWeiMaPassWord = [[UITextField alloc]initWithFrame:CGRectMake(90, 3, 85, 24)];
    AutoKeyPassWord = [[UITextField alloc]initWithFrame:CGRectMake(90, 3, 120, 24)];
    
    bgViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    bgBtnview = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    bgBtnview.backgroundColor = [UIColor blackColor];
    bgBtnview.alpha = 0.5f;
    bgBtnview.tag = 208;
    [bgBtnview addTarget:self action:@selector(dissBgView) forControlEvents:UIControlEventTouchUpInside];
    [bgViewController.view addSubview:bgBtnview];
    
    self.TransferTabelView = [[UITableView alloc]init];
    self.TransferTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.TransferTabelView.layer.cornerRadius = 8;
    self.TransferTabelView.layer.masksToBounds = YES;
    self.TransferTabelView.frame = CGRectMake(10, ScreenHeight/2-(transferName.count*30+15)/2,self.frame.size.width-20,transferName.count*30+15);
    self.TransferTabelView.delegate = self;
    self.TransferTabelView.dataSource = self;
    [bgViewController.view addSubview:self.TransferTabelView];
}

-(void)GetImtMessage:(NSNotification *)note
{
    [self performSelectorOnMainThread:@selector(onImtMessage:) withObject:[note userInfo] waitUntilDone:NO];
}
-(void)onImtMessage:(NSMutableDictionary *)parm
{
    NSString *resultString =  [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSMutableString *jsDataString = [[NSMutableString alloc]initWithString:[self stringByEvaluatingJavaScriptFromString:resultString]];
    NSMutableDictionary *imtMessagedic = [[NSMutableDictionary alloc]init];
    imtMessagedic = [Context jsonDicFromString:jsDataString];
    fenQiAlertView = [[CustomAlertView alloc]initWithDic:imtMessagedic delegate:self];
    [fenQiAlertView show];

}
-(void)GetRewardTransName:(NSNotification *)note
{
    NSDictionary *dicc = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[MobileBankSession sharedInstance].rewardString,@"transName", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *dicString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSString *dicString = [Context jsonStrFromDic:dic];
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[dicc objectForKey:@"index"],dicString];
    [self stringByEvaluatingJavaScriptFromString:resultString];
    [MobileBankSession sharedInstance].rewardString = @"";
}
-(void)onAlertAllow:(NSNotification *)note
{
    NSDictionary *parm = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[parm objectForKey:@"start"]];
    NSString *jsonData = [self stringByEvaluatingJavaScriptFromString:string];
    copyCustomAlert = [[CustomAlertView alloc]initProgressAlertViewWithTitle:@"提示" msg:jsonData centerBtnTitle:@"确认" delegate:self];
    [copyCustomAlert show];
}
-(void)GetBranch:(NSNotification *)note
{
    NSDictionary *dicc = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[MobileBankSession sharedInstance].yuYueBranchName forKey:@"branchName"];
    [dic setObject:[MobileBankSession sharedInstance].yuYueBranchId forKey:@"branchId"];
//    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[MobileBankSession sharedInstance].yuYueBranchName,@"branchName",[MobileBankSession sharedInstance].yuYueBranchId,@"branchId", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *dicString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSString *dicString = [Context jsonStrFromDic:dic];
    NSLog(@"预约w%@",dicString);
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[dicc objectForKey:@"index"],dicString];
    [self stringByEvaluatingJavaScriptFromString:resultString];
}
-(void)centerBtnPressedWithinalertView:(CustomAlertView *)alert
{
    if (alert==fenQiAlertView) {
        [fenQiAlertView removeFromSuperview];
    }
    if (alert == copyCustomAlert) {
        [copyCustomAlert removeFromSuperview];
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==transferName.count-1) {
        return 40;
    }
    return 30;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return transferName.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        UILabel *nameLabel = [[UILabel alloc]init];
        if (indexPath.row!=0&&indexPath.row!=transferName.count) {
            nameLabel.frame = CGRectMake(5, 0, 80, 30);
            nameLabel.text = transferName[indexPath.row];
            nameLabel.textAlignment = NSTextAlignmentRight;
        }
//        else{
//            nameLabel.frame = tableView.frame;
//            nameLabel.text = transferName[0];
//            nameLabel.textAlignment = NSTextAlignmentCenter;
//        }
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:12];
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        nameLabel.numberOfLines = 0;
        nameLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:nameLabel];
        
        
    }
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 29, tableView.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    lineView.alpha = 0.3f;
    
    if (indexPath.row ==0) {
        cell.textLabel.text = @"转账";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:lineView];
        UIButton *cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width-50, 0, 30, 30)];
        [cancleBtn setImage:[UIImage imageNamed:@"cancleImage"] forState:UIControlStateNormal];
        [cancleBtn addTarget:self action:@selector(cancleTransfer) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cancleBtn];
    }
     if (indexPath.row==1)
    {//转账金额
        UILabel *transferMoney = [[UILabel alloc]initWithFrame:CGRectMake(90, 3, 200, 24)];
        transferMoney.text = [NSString stringWithFormat:@"%.2f元",[[erWeiMadic objectForKey:@"Amount"]floatValue]];
        transferMoney.textColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.00f alpha:1.00f];
        transferMoney.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:transferMoney];
    }
    if(indexPath.row ==2)
    {//转账用途
        UILabel *usedLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 80, 30)];
        usedLabel.text = [erWeiMadic objectForKey:@"Remark"];
        usedLabel.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:usedLabel];
    }
    if ([certifyWays isEqualToString:@"0000"]) {
        if (indexPath.row==3)
        {
            SMSField.placeholder = @"请输入动态码";
            SMSField.tag = 206;
            SMSField.delegate = self;
            SMSField.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:SMSField];
            SMSCodeButton *button = [[SMSCodeButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width-120, 0, 100, 30)];
            button.phoneNumber = [[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"];
            button.actionName = @"二维码转账";
            [cell.contentView addSubview:button];
        }
    }
    if ([certifyWays isEqualToString:@"1111"]) {
        if (indexPath.row==3)
        {
            AutoKeyPassWord.placeholder = @"请输入音频Key密码";
            AutoKeyPassWord.font = [UIFont systemFontOfSize:10];
            AutoKeyPassWord.delegate = self;
            AutoKeyPassWord.tag = 210;
            AutoKeyPassWord.secureTextEntry = YES;
            AutoKeyPassWord.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:AutoKeyPassWord];
            
        }
    }
    if ([certifyWays isEqualToString:@"2222"]) {
        if (indexPath.row==3)
        {
            erWeiMaPassWord.placeholder = @"请输入卡密码";
            erWeiMaPassWord.delegate = self;
            erWeiMaPassWord.tag = 207;
            erWeiMaPassWord.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:erWeiMaPassWord];
            
        }
        if (indexPath.row==4)
        {
            SMSField.placeholder = @"请输入动态码";
            SMSField.tag = 206;
            SMSField.delegate = self;
            SMSField.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:SMSField];
            SMSCodeButton *button = [[SMSCodeButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width-120, 0, 100, 30)];
            button.phoneNumber = [[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"];
            button.actionName = @"二维码转账";
            [cell.contentView addSubview:button];
        }
    }
    if (indexPath.row==transferName.count-1)
    {//确认支付
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20, 3, tableView.frame.size.width-40, 37)];
        btn.layer.cornerRadius = 3;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(commitTransferResult) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.00f alpha:1.00f];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitle:@"确认转账" forState:UIControlStateNormal];
        [cell.contentView addSubview:btn];
    }
    return cell;
}
-(void)cancleTransfer
{
    VXOrNativePassWord = NO;
//    UIButton *view = (UIButton *)[bgViewController.view viewWithTag:208];
    [bgBtnview removeFromSuperview];
    [self.TransferTabelView removeFromSuperview];
}
-(void)commitTransferResult
{
    if ([certifyWays isEqualToString:@"0000"]) {
        if (SMSField.text.length!=6) {
            ShowAlertView(@"提示", @"手机动态码应为6位数字", nil, @"确认", nil);
            return;
        }
        [erWeiMaConfirmMessage setObject:SMSField.text forKey:@"SmsCode"];//短信验证码
        [erWeiMaConfirmMessage setObject:SerialNoStr forKey:@"SerialNo"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:erWeiMaConfirmMessage options:0 error:nil];
        NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],newString];
        [self stringByEvaluatingJavaScriptFromString:resultString];

    }
    if ([certifyWays isEqualToString:@"2222"]) {
        if (erWeiMaPassWord.text.length!=6) {
            ShowAlertView(@"提示", @"卡/折密码应为6位数字", nil, @"确认", nil);
            return;
        }

        [erWeiMaConfirmMessage setObject:SMSField.text forKey:@"SmsCode"];//短信验证码
        [erWeiMaConfirmMessage setObject:SerialNoStr forKey:@"SerialNo"];
        [erWeiMaConfirmMessage setObject:passWordSecurity forKey:@"CardPassword"];//密文
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:erWeiMaConfirmMessage options:0 error:nil];
        NSString* newString =[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[parameterDic objectForKey:@"index"],newString];
        [self stringByEvaluatingJavaScriptFromString:resultString];

    }
    if ([certifyWays isEqualToString:@"1111"]) {
        
        if (UKeyIsconnected) {
            [FTKeyInterface FTSetTransmitType:0];
//            NSString *ms = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><T><D><M><k>收款人:</k><v>王艳双\n</v></M><M><k>收款金额:</k><v>123.23\n</v><k>收款账户:</k> <v>123456789012345600000000\n</v></M></D><E><M><k>流水号：</k><v>12345678</v></M></E><F>hahaha</F></T>";
            
            NSString *msg = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><T><D><M><k>收款人账号：</k><v>%@</v></M><M><k>收款人户名：</k><v>%@</v></M><M><k>转账金额：</k><v>%@</v></M><M><k>付款人账号：</k><v>%@</v></M></D><E><M><k>币种：</k><v>01</v></M><M><k>用途：</k><v>%@</v></M></E></T>",[erWeiMadic objectForKey:@"PayeeAcNo"],[erWeiMadic objectForKey:@"PayeeAcName"],[erWeiMadic objectForKey:@"Amount"],[erWeiMadic objectForKey:@"thenum"],[erWeiMadic objectForKey:@"Remark"]];
            
            NSMutableDictionary *ddd = [[NSMutableDictionary alloc]init];
            [ddd setObject:msg forKey:@"sinData"];
            [ddd setObject:@"1111" forKey:@"erWeiMa"];
            [ddd setObject:AutoKeyPassWord.text forKey:@"YPKPassword"];
            [self DoSign:ddd];
        }else{
            ShowAlertView(@"提示", @"音频KEY未连接", nil, @"确认", nil);
        }
        
    }
    [self cancleTransfer];
}
-(void)dissBgView
{
    UITextField *smsField = (UITextField *)[self.TransferTabelView viewWithTag:206];
    self.TransferTabelView.frame = CGRectMake(10, ScreenHeight/2-(transferName.count*30+15)/2,self.frame.size.width-20,transferName.count*30+15);
    [smsField resignFirstResponder];
    [AutoKeyPassWord resignFirstResponder];
    [shahaiKeyBoard dissMisskeyboard:_shahaiKeyBoard.myKeyboardView];
}
-(void)ToShowRed:(NSNotification *)note
{
    NSDictionary *dicc = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    NSString *string= [NSString stringWithFormat:@"NativeCall.csii__data[%@]",[dicc objectForKey:@"start"]];
    shareRedPocketString = [self stringByEvaluatingJavaScriptFromString:string];
    //    https://58.210.44.162:454/mobilebank/redPocket.do?flowNo=D33545E9A1662543625E8BB1152755FC4DB104D710AC8513
    NSLog(@"红包%@",shareRedPocketString);
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"logout_weixin",@"img",
                           @"微信好友",@"title",
                           @"1",@"flag",
                           @"weixinFriend",@"subtitle",
                           nil];
    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"logout_pengyouquan",@"img",
                           @"微信朋友圈",@"title",
                           @"2",@"flag",
                           @"weixinCircle",@"subtitle",
                           nil];

   _buttonArray = [NSArray arrayWithObjects:dict2,dict3, nil];
    //初始化分享菜单，指定代理
    CSIIShareView *share = [CSIIShareView shareInstencesWithItems:_buttonArray];
    [CSIIShareView shareViewShow];
    share.delegate = self;

}

-(void)ToGoYinLianInterface:(NSNotification *)note
{
    [MobileBankSession sharedInstance].zijinguijiInfo = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    [[WebViewController sharedInstance]setActionId:@"FundCollectResult" actionName:@"资金归集" prdId:@"FundCollectResult" Id:@"FundCollectResult"];
    
    UIViewController* viewController = [self getViewController:[self nextResponder]];
    
    UINavigationController *navigationController = nil;
    if(viewController!=nil && viewController.navigationController!=nil)
    {
        navigationController = viewController.navigationController;
    }
    else if(viewController!=nil && viewController.navigationController==nil)
    {
        UINavigationController *rootNavigation = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
        navigationController = rootNavigation;
    }
    NSArray* controllers = navigationController.viewControllers;
    
    for (UIViewController* controller in controllers) {
        if (controller.class == WebViewController.class) {
            [controller removeFromParentViewController];
        }
    }
    [navigationController pushViewController:[WebViewController sharedInstance] animated:YES];
    
}
-(void)ToGoBackVXInterface:(NSNotification *)note
{
    NSDictionary *ddic = [[NSDictionary alloc]initWithDictionary:[note userInfo]];
    NSString *newString = [[MobileBankSession sharedInstance].zijinguijiInfo objectForKey:@"index"];
//    NSString *newString = @"orderID=20160422221910671488&merld=999997";
    
    NSString* resultString = [NSString stringWithFormat:@"NativeCall.csii__callback['%@']('%@')",[ddic objectForKey:@"index"],newString];
    [self stringByEvaluatingJavaScriptFromString:resultString];

}
- (void)clickButton:(UIButton *)button withIndex:(NSInteger)index{
    //获取点击按钮的信息
    NSDictionary *dict = [_buttonArray objectAtIndex:index];
    NSLog(@"点击--->>>%@",[dict objectForKey:@"title"]);
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    if ([[dict objectForKey:@"flag"] isEqualToString:@"1"]){
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            handle.WXScene = WXSceneSession;
            [handle messageToWeiXinNews:@"常熟农商银行" Description:@"红包" content:nil Image:[UIImage imageNamed:@"shareimage.png"] URL:shareRedPocketString shareScene:WXSceneSession];
        }else{
            ShowAlertView(@"提示", @"您尚未安装微信客户端", nil, @"确认", nil);
        }
        
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"2"]){
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            handle.WXScene = WXSceneTimeline;
            [handle messageToWeiXinNews:@"常熟农商银行" Description:@"红包" content:nil Image:[UIImage imageNamed:@"shareimage.png"] URL:shareRedPocketString shareScene:WXSceneTimeline];
        }else{
            ShowAlertView(@"提示", @"您尚未安装微信客户端", nil, @"确认", nil);
        }
    }
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.TransferTabelView.frame = CGRectMake(10, ScreenHeight/2-180,self.frame.size.width-20,transferName.count*30+15);

    if (textField.tag==207) {
        erWeiMaPassWord.text = @"";
        [_shahaiKeyBoard show1:_shahaiKeyBoard.myKeyboardView];
        //获取时间戳
        [[MobileBankSession sharedInstance]postToServer:@"GenTimeStamp.do" actionParams:nil method:@"POST" returnBlock:^(NSDictionary *data) {
            //        DebugLog(@"data ：%@",data);
            //        NSLog(@"时间戳: %@",timeStamp);
            _shahaiKeyBoard.myKeyboardView.time = [data objectForKey:@"_sysDate"];
            
        }];
        
        return NO;
    }
  
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    self.TransferTabelView.frame = CGRectMake(10, ScreenHeight/2-200,self.frame.size.width-20,240);

}
@end
