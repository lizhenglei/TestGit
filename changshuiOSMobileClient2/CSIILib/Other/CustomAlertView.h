//
//  CustomAlertView.h
//  IOS7CustomAlertView
//
//  Created by hanruimin on 13-10-11.
//  Copyright (c) 2013年 hanruimin. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PowerEnterUITextField.h"
#import "LWYTextField.h"
#import "LabelButton.h"
#import "CSIITextField.h"
#pragma mark -- GesturePass
#import "TentacleView.h"
#import "GesturePasswordView.h"

typedef enum
{
    CustomAlertViewType_Msg_TwoBtn=1,//含有title，提示内容以及两个button.
    CustomAlertViewType_Msg_OneBtn,//含有title，提示内容以及一个button.
    CustomAlertViewType_ActivityIndiAndMsg_OneBtn, //含有title，UIActivityIndicatorView控件,提示内容以及一个button.
    CustomAlertViewType_View_OneBtn, //含有title，一个UIView控件以及一个button.
    CustomAlertViewType_Msg_CustomTextField_TwoBtn,//含有title，定制的textfield，提示内容以及两个button.
    CustomAlertViewType_Msg_TextField_TwoBtn,//含有title，textfield，提示内容以及两个button.
    CustomAlertViewType_JalBreakBuy_Login,//含title,两个button，密码输入textfield，用户名等提示信息
    CustomAlertViewType_RemindTime,
    CustomAlertViewType_msgVerify,//两个textfield，两个label，两个button
    CustomAlertViewTypeBottomButtom,  //关联交易
    CustomAlertViewTypeGongGao,       //公告
    CustomAlertViewTypeGesturePass,     //手势密码
    CustomAlertViewTypeReSetGesturepass,  //重置手势密码
    CustomAlertViewTypeCalendar,         //金融日历
    CustomAlertViewTypePhoneNumber,       //本地通讯录
    CustomAlertViewTypeToast       //toast指令
}CustomAlertViewType;

@protocol CustomAlertViewDelegate;

@interface CustomAlertView : UIView<UITextFieldDelegate,VerificationDelegate,ResetDelegate,GesturePasswordDelegate>{
    //CustomAlertViewType _alertViewType;
    id <CustomAlertViewDelegate> __unsafe_unretained  _customDelegate;
    
    UILabel* titleLabel;
    UILabel* contentLabel;
    
    UIButton* leftBtn;
    UIButton* rightBtn;
    UIButton* centerBtn;
    
    UIActivityIndicatorView *indicatorView;
    
    UITextField*CtextField;
    
    UIView* _alertView;
    UIView* _bgView;
}

@property (unsafe_unretained) id<CustomAlertViewDelegate> customDelegate;
@property (nonatomic,retain) UILabel* contentLabel;
@property (nonatomic,assign) UITextField*textField;
@property(nonatomic, strong) UILabel *titleLB;
@property (nonatomic) CustomAlertViewType alertViewType;
@property(nonatomic,assign) UITextField *trsPasswordTF;
@property(nonatomic,assign) LWYTextField *msgVerifyCodeTF;

@property(nonatomic ,strong) UITextField*contextTF;
@property(nonatomic,strong)  UITextView *gonggaoTV;
@property(nonatomic ,strong) LWYTextField *userNameTF;
@property(nonatomic ,strong) UITextField *passwordTF;
@property(nonatomic ,strong) LWYTextField *validateCodeTF;
@property(nonatomic ,strong) UIButton *validateCodeBTN;
@property(nonatomic ,strong) UIButton *isRememberMarkBTB;
@property(nonatomic ,strong) UILabel *rememberHintLB;
@property(nonatomic ,strong) UIButton *selfAssisstantLinkBTN;
@property(nonatomic ,strong) UIButton *resetPasswordLinkBTN;
@property(nonatomic ,strong) UIButton *loginBTN;
@property(nonatomic ,strong) NSString*AuthenticateTypeStr;
@property(nonatomic, copy) NSMutableArray* inputControls;
@property(nonatomic,retain)LabelButton*rememberButton;
@property (nonatomic,strong) GesturePasswordView * gesturePasswordView;

@property(nonatomic,strong)NSString *titleString;
@property(nonatomic,strong)NSString *contentString;

@property(nonatomic,strong)UIButton *bottomButtom;//公告下一页按钮
//含有title，提示内容以及两个button.
- (id)initWithTitle:(NSString*)title  msg:(NSString*)msg rightBtnTitle:(NSString*)rightTitle leftBtnTitle:(NSString*)leftTitle delegate:(id<CustomAlertViewDelegate>) _delegate;

- (id)initWithTitle:(NSString*)title  msg:(NSString*)msg rightBtnTitle:(NSString*)rightTitle leftBtnTitle:(NSString*)leftTitle delegate:(id<CustomAlertViewDelegate>) _delegate msgFontSize:(CGFloat)fontSize;
//含有title，提示内容以及一个button.
- (id)initWithTitle:(NSString*)title  msg:(NSString*)msg centerBtnTitle:(NSString*)centerTitle;

//含有title，UIActivityIndicatorView控件,提示内容以及一个button.
- (id)initProgressAlertViewWithTitle:(NSString*)title  msg:(NSString*)msg centerBtnTitle:(NSString*)centerTitle delegate:(id<CustomAlertViewDelegate>) _delegate;

//含有title，一个定制的UIView控件以及一个button.
- (id)initWithCustomView:(UIView*)customView title:(NSString*)title centerBtnTitle:(NSString*)centerTitle  delegate:(id<CustomAlertViewDelegate>) _delegate;

//含有title，定制的textfield，提示内容以及两个button.
- (id)initWithCustomTextField:(UITextField*)customTextField title:(NSString*)title  msg:(NSString*)msg rightBtnTitle:(NSString*)rightTitle leftBtnTitle:(NSString*)leftTitle delegate:(id<CustomAlertViewDelegate>) _delegate;

//含有title，textfield，提示内容以及两个button.
- (id)initTextFieldWithTitle:(NSString*)title  msg:(NSString*)msg rightBtnTitle:(NSString*)rightTitle leftBtnTitle:(NSString*)leftTitle delegate:(id<CustomAlertViewDelegate>) _delegate;

//含title,两个button，密码输入textfield，用户名等提示信息
-(id)initLoginWithDelegate:(id<CustomAlertViewDelegate>)delegate userId:(NSString*)userid title:(NSString*)strTitle rightBtnTitle:(NSString*)strRbt;
//含两个label,两个textField,两个button和一个短信button

//手势密码
-(id)initGesturePass:(id<CustomAlertViewDelegate>)delegate;
//重置手势密码
-(id)initReSetGesturePass:(id<CustomAlertViewDelegate>)delegate;
//金融日历弹出框   添加和修改
-(id)initCalendarWithDelegate:(id<CustomAlertViewDelegate>)delegate context:(NSString*)contextStr title:(NSString*)strTitle;
/** */
- (id)initRemindAlert;

//单例方法
+(CustomAlertView *)defaultAlertView;

-(void)showAfterDelay:(NSTimeInterval)delay;
-(void) show;

- (void) hideAlertView;

-(void) setTitle:(NSString*) title;

- (UIView *)view;

/*vx交互添加自定义弹框*/
//本地通讯录
-(id)initPhoneNumberWithDelegate:(id<CustomAlertViewDelegate>)delegate;

//首页公告
-(id)initToastWithDelegate:(id<CustomAlertViewDelegate>)delegate context:(NSString *)contextStr;

@end

@protocol CustomAlertViewDelegate <NSObject>

@optional

- (void) leftBtnPressedWithinalertView:(CustomAlertView *)alert;
- (void) rightBtnPressedWithinalertView:(CustomAlertView *)alert;
- (void) cancelBtnPressedWithinalertView:(CustomAlertView *)alert;
- (void) centerBtnPressedWithinalertView:(CustomAlertView *)alert;
-(void)rightBtnPressedWithinalertView:(CustomAlertView *)alert andHourString:(NSString *)hour andMinuteString:(NSString *)minute;

- (void)gestureExit:(CustomAlertView *)alert;
- (void)verGestureSucess:(CustomAlertView *)alert;


//登陆
- (void) validCodeBtnPressedWithinAlertView:(CustomAlertView *)alert;
- (void) selfAssisstantLinkBtnPressedWithinAlertView:(CustomAlertView *)alert;
- (void) resetPasswordBtnPressedWithinAlertView:(CustomAlertView *)alert;
- (void) loginBtnPressedWithinAlertView:(CustomAlertView *)alert;

//添加发送短信的方法
- (void) sendMessage:(CustomAlertView *) alert;


@end
