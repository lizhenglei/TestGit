#import "CustomAlertView.h"
#import "ThemeButton.h"
#import "ThemeLabel.h"
#import "LDKGloableVariable.h"
#import "CSIITextField.h"
#import "SingleClass.h"
#import "AllMenuView.h"
#import "CSIIUtility.h"
#import <Foundation/Foundation.h>
#import "LabelButton.h"
#import "CSIILabel.h"
//GesturePass
#import "KeychainItemWrapper.h"
#import "CSIIMenuViewController.h"
#import "XHDrawerController.h"
#import "BindingEquipmentViewController.h"
#import "GetPhoneNumberViewController.h"

#import "CalendarView.h"


#define MAX_CATEGORY_NAME_LENGTH 9
#define kTagViewTextFieldJalBreakPassW (1001)



@interface CustomAlertView ()<MobileSessionDelegate,LWYDoneDelegate,VerificationDelegate,GetPhoneNumberViewControllerDelegate,LWYPickerViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@end

@implementation CustomAlertView {
    
    NSArray *_buttonImages;
    ThemeButton *_msgSend;
    ThemeLabel *_lineLabel;
    ThemeLabel *_titleLabel;
    //NSString* _favouriteKey;
    //NSMutableArray* _favouriteMenu;
    AllMenuView* allMenu;
    BOOL isAnimated;
    
    UITableView*tableView;
    
    NSString * previousString;
    NSString * password;
    UIPickerView *timePickerView;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    NSMutableArray *allArray;
    NSString *hourString;
    NSString *minuteString;
    CalendarView *_customCalendarView;
}

@synthesize customDelegate = _customDelegate;
@synthesize contentLabel;
@synthesize textField;
@synthesize gesturePasswordView;


- (id)initRemindAlert{
    return nil;
}
//含有title，提示内容以及两个button.
- (id)initWithTitle:(NSString*)title  msg:(NSString*)msg rightBtnTitle:(NSString*)rightTitle leftBtnTitle:(NSString*)leftTitle  delegate:(id<CustomAlertViewDelegate>) _delegate
{
    if ((self = [super initWithFrame:[[UIScreen mainScreen]bounds]]))
    {
        // Initialization code
        _alertViewType=CustomAlertViewType_Msg_TwoBtn;
        self.customDelegate=_delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        
        
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //[_bgView release];
        
        CGRect alertRect = [self getAlertBounds];
        //        原来
        //        _alertView = [[UIView alloc] initWithFrame:alertRect];
        // hc 修改
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(alertRect.origin.x, alertRect.origin.y, alertRect.size.width, alertRect.size.height-50)];
        
        _alertView.layer.cornerRadius = 10;
        _alertView.layer.masksToBounds = YES;
        
        UIImageView *alertBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, alertRect.size.width, alertRect.size.height)];
        alertBg.backgroundColor = [UIColor whiteColor];
        alertBg.image = [UIImage imageNamed:@"AlertView_background.png"];
        [_alertView addSubview:alertBg];
        //[alertBg release];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        titleLabel.text =title;
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [_alertView addSubview:titleLabel];
        //[titleLabel release];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 200, 40)];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:15.0];
        contentLabel.text =msg;
        contentLabel.textAlignment=NSTextAlignmentCenter;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.numberOfLines = 0;
        [_alertView addSubview:contentLabel];
        //[contentLabel release];
        
        //UIImage* unselectedImg=[UIImage imageNamed:@"button_unselected.png"];
        UIImage* selectedImg=[UIImage imageNamed:@"button_selected.png"];
        
        rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            rightBtn.layer.borderWidth = 1.0f;
        else
            rightBtn.layer.borderWidth = 0.5f;
        rightBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [rightBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [rightBtn setTitle:rightTitle forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        rightBtn.frame=CGRectMake(_alertView.frame.size.width/2, _alertView.frame.size.height-40, _alertView.frame.size.width/2, 40);
        [rightBtn addTarget:self action:@selector(rightBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:rightBtn];
        
        leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            leftBtn.layer.borderWidth = 1.0f;
        else
            leftBtn.layer.borderWidth = 0.5f;
        leftBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [leftBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        leftBtn.frame=CGRectMake(0, _alertView.frame.size.height-40, _alertView.frame.size.width/2, 40);
        [leftBtn addTarget:self action:@selector(leftBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:leftBtn];
        
        [self addSubview:_alertView];
        //[_alertView release];
        [self showBackground];
        [self showAlertAnmation];
        
    }
    return self;
}


//可修改字体
- (id)initWithTitle:(NSString*)title
                msg:(NSString*)msg
      rightBtnTitle:(NSString*)rightTitle
       leftBtnTitle:(NSString*)leftTitle
           delegate:(id<CustomAlertViewDelegate>) _delegate
        msgFontSize:(CGFloat)fontSize
{
    if ((self = [super initWithFrame:[[UIScreen mainScreen] bounds]]))
    {
        // Initialization code
        _alertViewType=CustomAlertViewType_Msg_TwoBtn;
        self.customDelegate=_delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //[_bgView release];
        
        CGRect alertRect = [self getAlertBounds];
        _alertView = [[UIView alloc] initWithFrame:alertRect];
        _alertView.layer.cornerRadius = 10;
        _alertView.layer.masksToBounds = YES;
        
        UIImageView *alertBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, alertRect.size.width, alertRect.size.height)];
        alertBg.backgroundColor = [UIColor whiteColor];
        alertBg.image = [UIImage imageNamed:@"AlertView_background.png"];
        [_alertView addSubview:alertBg];
        //[alertBg release];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        titleLabel.text =title;
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [_alertView addSubview:titleLabel];
        //[titleLabel release];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 260, 40)];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:fontSize];
        contentLabel.text =msg;
        contentLabel.textAlignment=NSTextAlignmentCenter;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.numberOfLines = 0;
        [_alertView addSubview:contentLabel];
        //[contentLabel release];
        
        //UIImage* unselectedImg=[UIImage imageNamed:@"button_unselected.png"];
        UIImage* selectedImg=[UIImage imageNamed:@"button_selected.png"];
        
        rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            rightBtn.layer.borderWidth = 1.0f;
        else
            rightBtn.layer.borderWidth = 0.5f;
        rightBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [rightBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [rightBtn setTitle:rightTitle forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        rightBtn.frame=CGRectMake(_alertView.frame.size.width/2, _alertView.frame.size.height-40, _alertView.frame.size.width/2, 40);
        [rightBtn addTarget:self action:@selector(rightBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:rightBtn];
        
        leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            leftBtn.layer.borderWidth = 1.0f;
        else
            leftBtn.layer.borderWidth = 0.5f;
        leftBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [leftBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        leftBtn.frame=CGRectMake(0, _alertView.frame.size.height-40, _alertView.frame.size.width/2, 40);
        [leftBtn addTarget:self action:@selector(leftBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:leftBtn];
        
        [self addSubview:_alertView];
        //[_alertView release];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}


- (id)initWithDic:(NSMutableDictionary *)dic delegate:(id<CustomAlertViewDelegate>)_delegate
{
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if(self)
    {
        _alertViewType=CustomAlertViewType_Msg_OneBtn;
        self.customDelegate=_delegate;
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //[_bgView release];
        CGRect alertRect = CGRectMake((self.frame.size.width-300)/2, (self.frame.size.height-200)/2, 300, 250);

        _alertView = [[UIView alloc] initWithFrame:alertRect];
        _alertView.layer.cornerRadius = 10;
        _alertView.layer.masksToBounds = YES;
        
        UIImageView *alertBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, alertRect.size.width, alertRect.size.height)];
        alertBg.backgroundColor = [UIColor whiteColor];
        alertBg.image = [UIImage imageNamed:@"AlertView_background.png"];
        [_alertView addSubview:alertBg];
        NSMutableArray *showArray =[[NSMutableArray alloc]init];
        [showArray addObject:@""];
        [showArray addObject:[dic objectForKey:@"desc"]];//交易描述
        [showArray addObject:[dic objectForKey:@"tranDate"]];//交易日期
        [showArray addObject:[NSString stringWithFormat:@"¥%@",[dic objectForKey:@"flexAmt"]]];//分期金额
        [showArray addObject:[NSString stringWithFormat:@"%@期",[dic objectForKey:@"flexDate"]]];//分期期数
        [showArray addObject:[NSString stringWithFormat:@"¥%@",[dic objectForKey:@"feeAmount"]]];//手续费
        [showArray addObject:[NSString stringWithFormat:@"¥%@",[dic objectForKey:@"monPayBack"]]];//每期还款额
        [showArray addObject:[NSString stringWithFormat:@"%d期",[[dic objectForKey:@"repayterm"] intValue]]];//剩余期数
        NSArray *titleArray = [NSArray arrayWithObjects:@"分期交易明细",@"交易描述",@"交易日期",@"分期金额",@"分期期数",@"手续费",@"每期还款额",@"剩余期数", nil];
        for (int i=0; i<8; i++) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 10+i*30, 120, 25)];
            label.text = titleArray[i];
            if (i==0) {
                label.textColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.00f alpha:1.00f];
            }
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:15];
            [_alertView addSubview:label];
            
            UILabel *labelShow = [[UILabel alloc]initWithFrame:CGRectMake(100, 10+i*30, _alertView.frame.size.width-110, 25)];
            labelShow.text = showArray[i];
            labelShow.font = [UIFont systemFontOfSize:15];
            labelShow.textColor = [UIColor grayColor];
            labelShow.textAlignment = NSTextAlignmentLeft;
            [_alertView addSubview:labelShow];
        }
        
        UIImage* selectedImg=[UIImage imageNamed:@"cancleImage"];
        centerBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [centerBtn setImage:selectedImg forState:UIControlStateNormal];
        centerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        centerBtn.frame=CGRectMake(_alertView.frame.size.width-58,0, 48, 48);
        [_alertView addSubview:centerBtn];
        [centerBtn addTarget:self action:@selector(centerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_alertView];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}


//含有title，UIActivityIndicatorView控件,提示内容以及一个button.
- (id)initProgressAlertViewWithTitle:(NSString*)title  msg:(NSString*)msg centerBtnTitle:(NSString*)centerTitle  delegate:(id<CustomAlertViewDelegate>) _delegate
{
    if ((self = [super initWithFrame:[[UIScreen mainScreen] bounds]]))
    {
        // Initialization code
        _alertViewType=CustomAlertViewType_ActivityIndiAndMsg_OneBtn;
        self.customDelegate=_delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //[_bgView release];
        
        CGRect alertRect = CGRectMake((self.frame.size.width-300)/2, self.frame.size.height/2-60, 300, 120);
        _alertView = [[UIView alloc] initWithFrame:alertRect];
        _alertView.layer.cornerRadius = 10;
        _alertView.layer.masksToBounds = YES;
        _alertView.backgroundColor = [UIColor colorWithRed:0.98f green:0.98f blue:0.98f alpha:1.00f];;
        UIImageView *alertBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, alertRect.size.width, alertRect.size.height)];
        alertBg.backgroundColor = [UIColor whiteColor];
        alertBg.image = [UIImage imageNamed:@"AlertView_background.png"];
        [_alertView addSubview:alertBg];
        //[alertBg release];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 20)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        titleLabel.text =title;
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [_alertView addSubview:titleLabel];
        //[titleLabel release];
        
//        indicatorView= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(80.0, 45.0, 30.0, 30.0)];
//        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//        indicatorView.hidesWhenStopped=NO;
//        [_alertView addSubview:indicatorView];
//        //[indicatorView release];
//        [indicatorView startAnimating];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 50.0, 100.0, 20.0)];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont boldSystemFontOfSize:15.0];
        contentLabel.text =msg;
        contentLabel.textAlignment=NSTextAlignmentCenter;
        [_alertView addSubview:contentLabel];
        //[contentLabel release];
        UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        copyBtn.frame = CGRectMake(230, 50, 50, 20);
        [copyBtn setTitle:@"复制" forState:UIControlStateNormal];
        [copyBtn setTitleColor:[UIColor colorWithRed:0.00f green:0.48f blue:1.00f alpha:1.00f] forState:UIControlStateNormal];
        [copyBtn addTarget:self action:@selector(copyText) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:copyBtn];
        
        
        centerBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        //[centerBtn setBackgroundImage:selectedImg forState:UIControlStateNormal];
        centerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [centerBtn setTitle:centerTitle forState:UIControlStateNormal];
        [centerBtn setTitleColor:[UIColor colorWithRed:0.00f green:0.48f blue:1.00f alpha:1.00f] forState:UIControlStateNormal];
        centerBtn.frame=CGRectMake(27, 80, 249, 40);
        [_alertView addSubview:centerBtn];
        [centerBtn addTarget:self action:@selector(centerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_alertView];
        //[_alertView release];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}
-(void)copyText
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = contentLabel.text;
    [self initToastWithDelegate:nil context:@"复制成功"];
    [self sendSubviewToBack:_alertView];

}
//含有title，一个定制的UIView控件以及一个button.
- (id)initWithCustomView:(UIView*)customView title:(NSString*)title centerBtnTitle:(NSString*)centerTitle  delegate:(id<CustomAlertViewDelegate>) _delegate
{
    if ((self = [super initWithFrame:[[UIScreen mainScreen] bounds]]))
    {
        // Initialization code
        _alertViewType=CustomAlertViewType_View_OneBtn;
        self.customDelegate=_delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //[_bgView release];
        
        CGRect alertRect = [self getAlertBounds];
        alertRect.size.height = 30 + customView.frame.size.height + 45;
        alertRect.origin.y = (self.frame.size.height-alertRect.size.height)/2;
        _alertView = [[UIView alloc] initWithFrame:alertRect];
        _alertView.layer.cornerRadius = 10;
        _alertView.layer.masksToBounds = YES;
        
        UIImageView *alertBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, alertRect.size.width, alertRect.size.height)];
        alertBg.backgroundColor = [UIColor whiteColor];
        alertBg.image = [UIImage imageNamed:@"AlertView_background.png"];
        [_alertView addSubview:alertBg];
        //[alertBg release];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 20)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        titleLabel.text =title;
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [_alertView addSubview:titleLabel];
        //[titleLabel release];
        
        [_alertView addSubview:customView];
        
        UIImage* selectedImg=[UIImage imageNamed:@"button_selected.png"];
        centerBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            centerBtn.layer.borderWidth = 1.0f;
        else
            centerBtn.layer.borderWidth = 0.5f;
        centerBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        //[centerBtn setBackgroundImage:selectedImg forState:UIControlStateNormal];
        [centerBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        centerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [centerBtn setTitle:centerTitle forState:UIControlStateNormal];
        [centerBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        centerBtn.frame=CGRectMake(0, _alertView.frame.size.height-40, 300, 40);
        [_alertView addSubview:centerBtn];
        [centerBtn addTarget:self action:@selector(centerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_alertView];
        //[_alertView release];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}

//含有title，定制的textfield，提示内容以及两个button.
- (id)initWithCustomTextField:(UITextField*)customTextField title:(NSString*)title  msg:(NSString*)msg rightBtnTitle:(NSString*)rightTitle leftBtnTitle:(NSString*)leftTitle delegate:(id<CustomAlertViewDelegate>) _delegate
{
    if ((self = [super initWithFrame:[[UIScreen mainScreen] bounds]]))
    {
        // Initialization code
        _alertViewType=CustomAlertViewType_Msg_CustomTextField_TwoBtn;
        self.customDelegate=_delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //[_bgView release];
        
        CGRect alertRect = [self getAlertBounds];
        alertRect.size.height = customTextField.frame.origin.y + customTextField.frame.size.height + 15 + 45;
        alertRect.origin.y = (self.frame.size.height-alertRect.size.height)/2 - 20 - 20;
        _alertView = [[UIView alloc] initWithFrame:alertRect];
        _alertView.layer.cornerRadius = 10;
        _alertView.layer.masksToBounds = YES;
        
        UIImageView *alertBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, alertRect.size.width, alertRect.size.height)];
        alertBg.backgroundColor = [UIColor whiteColor];
        alertBg.image = [UIImage imageNamed:@"AlertView_background.png"];
        [_alertView addSubview:alertBg];
        //[alertBg release];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 15, 300, 20)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        titleLabel.text =title;
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [_alertView addSubview:titleLabel];
        //[titleLabel release];
        
        if(msg != nil && msg.length != 0)
        {
            contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 33.0, 300.0, 12.0)];
            contentLabel.textColor = [UIColor blackColor];
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = [UIFont boldSystemFontOfSize:8.0];
            contentLabel.textAlignment=NSTextAlignmentCenter;
            contentLabel.text = msg;
            [_alertView addSubview:contentLabel];
            //[contentLabel release];
        }
        
        [_alertView addSubview:customTextField];
        self.textField = customTextField;
        
        //UIImage* unselectedImg=[UIImage imageNamed:@"button_unselected.png"];
        UIImage* selectedImg=[UIImage imageNamed:@"button_selected.png"];
        
        rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            rightBtn.layer.borderWidth = 1.0f;
        else
            rightBtn.layer.borderWidth = 0.5f;
        rightBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [rightBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [rightBtn setTitle:rightTitle forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        rightBtn.frame=CGRectMake(_alertView.frame.size.width/2, _alertView.frame.size.height-40, _alertView.frame.size.width/2, 40);
        [rightBtn addTarget:self action:@selector(rightBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:rightBtn];
        
        leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            leftBtn.layer.borderWidth = 1.0f;
        else
            leftBtn.layer.borderWidth = 0.5f;
        leftBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [leftBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        leftBtn.frame=CGRectMake(0, _alertView.frame.size.height-40, _alertView.frame.size.width/2, 40);
        [leftBtn addTarget:self action:@selector(leftBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:leftBtn];
        
        [self addSubview:_alertView];
        //[_alertView release];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}

//含有title，textfield，提示内容以及两个button.
- (id)initTextFieldWithTitle:(NSString*)title  msg:(NSString*)msg rightBtnTitle:(NSString*)rightTitle leftBtnTitle:(NSString*)leftTitle delegate:(id<CustomAlertViewDelegate>) _delegate
{
    if ((self = [super initWithFrame:[[UIScreen mainScreen] bounds]]))
    {
        // Initialization code
        _alertViewType=CustomAlertViewType_Msg_TextField_TwoBtn;
        self.customDelegate=_delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //[_bgView release];
        
        CGRect alertRect = [self getAlertBounds];
        _alertView = [[UIView alloc] initWithFrame:alertRect];
        _alertView.layer.cornerRadius = 10;
        _alertView.layer.masksToBounds = YES;
        
        UIImageView *alertBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, alertRect.size.width, alertRect.size.height)];
        alertBg.backgroundColor = [UIColor whiteColor];
        alertBg.image = [UIImage imageNamed:@"AlertView_background.png"];
        [_alertView addSubview:alertBg];
        //[alertBg release];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 15, 300, 20)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        titleLabel.text =title;
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [_alertView addSubview:titleLabel];
        //[titleLabel release];
        
        if(msg != nil && msg.length != 0)
        {
            contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 33.0, 300.0, 12.0)];
            contentLabel.textColor = [UIColor blackColor];
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = [UIFont boldSystemFontOfSize:8.0];
            contentLabel.textAlignment=NSTextAlignmentCenter;
            [_alertView addSubview:contentLabel];
            //[contentLabel release];
        }
        
        CtextField = [[UITextField alloc] initWithFrame:CGRectMake(21, 45, 260, 30)];
        CtextField.borderStyle = UITextBorderStyleRoundedRect;
        CtextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        CtextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        CtextField.placeholder = msg;
        [CtextField addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
        [_alertView addSubview:CtextField];
        //        [textField release];
        
        //UIImage* unselectedImg=[UIImage imageNamed:@"button_unselected.png"];
        UIImage* selectedImg=[UIImage imageNamed:@"button_selected.png"];
        
        rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            rightBtn.layer.borderWidth = 1.0f;
        else
            rightBtn.layer.borderWidth = 0.5f;
        rightBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [rightBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [rightBtn setTitle:rightTitle forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        rightBtn.frame=CGRectMake(_alertView.frame.size.width/2, _alertView.frame.size.height-40, _alertView.frame.size.width/2, 40);
        [rightBtn addTarget:self action:@selector(rightBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:rightBtn];
        
        leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(IPAD)
            leftBtn.layer.borderWidth = 1.0f;
        else
            leftBtn.layer.borderWidth = 0.5f;
        leftBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [leftBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
        leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorWithRed:23.0/255 green:92.0/255 blue:212.0/255 alpha:1.0] forState:UIControlStateNormal];
        leftBtn.frame=CGRectMake(0, _alertView.frame.size.height-40, _alertView.frame.size.width/2, 40);
        [leftBtn addTarget:self action:@selector(leftBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:leftBtn];
        
        [self addSubview:_alertView];
        //[_alertView release];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}

-(id)initGesturePass:(id<CustomAlertViewDelegate>)delegate{
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [SingleClass shareClass].inputControls = [[NSMutableArray alloc] init];
        _alertViewType = CustomAlertViewTypeGesturePass;
        self.customDelegate = delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //        UIImageView* alertBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"弹出框"]];
        
        _alertView = [[UIView alloc] initWithFrame:self.bounds];
        _alertView.tag = 333;
        _alertView.layer.cornerRadius = 0;
        _alertView.layer.masksToBounds = YES;
        _alertView.backgroundColor = [UIColor redColor];
        //        [_alertView addSubview:alertBg];
        
        
        previousString = [NSString string];
        KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
        password = [keychin objectForKey:(__bridge id)kSecValueData];
        
        
        gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [gesturePasswordView.tentacleView setRerificationDelegate:(id)delegate];
        [gesturePasswordView.tentacleView setStyle:1];
        gesturePasswordView.imgView.hidden = YES;
        [gesturePasswordView.imgViewLogo setHidden:NO];
        [gesturePasswordView setGesturePasswordDelegate:self];
        [_alertView addSubview:gesturePasswordView];
        
        [self addSubview:_alertView];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}

-(id)initReSetGesturePass:(id<CustomAlertViewDelegate>)delegate{
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [SingleClass shareClass].inputControls = [[NSMutableArray alloc] init];
        _alertViewType = CustomAlertViewTypeReSetGesturepass;
        self.customDelegate = delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //        UIImageView* alertBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"弹出框"]];
        
        _alertView = [[UIView alloc] initWithFrame:self.bounds];
        _alertView.tag = 333;
        _alertView.layer.cornerRadius = 0;
        _alertView.layer.masksToBounds = YES;
        _alertView.backgroundColor = [UIColor redColor];
        //        [_alertView addSubview:alertBg];
        
        
        previousString = [NSString string];
        KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
        password = [keychin objectForKey:(__bridge id)kSecValueData];
        
        gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [gesturePasswordView.tentacleView setResetDelegate:self];
        [gesturePasswordView setGesturePasswordDelegate:self];
        [gesturePasswordView.tentacleView setStyle:2];
        [gesturePasswordView.imgView setHidden:NO];
        [gesturePasswordView.imgViewLogo setHidden:YES];
        [gesturePasswordView.forgetButton setHidden:NO];
        [gesturePasswordView.changeButton setHidden:YES];
        [_alertView addSubview:gesturePasswordView];
        
        [self addSubview:_alertView];
        // [_alertView release];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}

-(id)initCalendarWithDelegate:(id<CustomAlertViewDelegate>)delegate context:(NSString *)contextStr title:(NSString *)strTitle{
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        _alertViewType = CustomAlertViewTypeCalendar;
        self.customDelegate = delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        //                UIImageView* alertBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"弹出框"]];
        
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(10, ScreenHeight/2-100/2-60, ScreenWidth-20, 260)];
        _alertView.tag = 10001;
        _alertView.layer.cornerRadius = 0;
        _alertView.layer.masksToBounds = YES;
        _alertView.layer.borderWidth = 1;
        _alertView.layer.borderColor = [UIColor grayColor].CGColor;
        _alertView.backgroundColor = [UIColor whiteColor];
        
        UILabel*titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _alertView.frame.size.width, 40)];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.text = strTitle;
        titleLab.textAlignment = NSTextAlignmentCenter;
        [_alertView addSubview:titleLab];
        
        _contextTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 35, _alertView.frame.size.width-20, 40)];
        _contextTF.placeholder = @"输入内容不超过15个字";
        _contextTF.borderStyle = UITextBorderStyleRoundedRect;
        if (![contextStr isEqualToString:@""]) {
            _contextTF.text = contextStr;
        }
        _contextTF.font = [UIFont systemFontOfSize:14.0];
        _contextTF.backgroundColor = [UIColor whiteColor];
        [_alertView addSubview:_contextTF];
        hourArray = [[NSMutableArray alloc]init];
        for (int i=0; i<24; i++) {
            [hourArray addObject:[NSString stringWithFormat:@"%.2d",i]];
        }
        minuteArray = [[NSMutableArray alloc]init];
        for (int i=0; i<60; i++) {
            [minuteArray addObject:[NSString stringWithFormat:@"%.2d",i]];
        }
        allArray = [NSMutableArray arrayWithObjects:hourArray,minuteArray, nil];
        //        LWYTextField *timePickerView = [[LWYTextField alloc]initPicerViewWithFrame:CGRectMake(10, 80, _alertView.frame.size.width, 80) picerDataArray:allArray];
        //        timePickerView.pickerViewDelegate = self;
        UILabel *remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 200, 10)];
        remindLabel.text = @"请选择提醒时间：";
        remindLabel.backgroundColor = [UIColor clearColor];
        [_alertView addSubview:remindLabel];
        timePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(10, 90, _alertView.frame.size.width-20, 140)];
        timePickerView.delegate = self;
        timePickerView.dataSource = self;
        NSDate *date = [[NSDate alloc]init];
        NSDateFormatter *ff = [[NSDateFormatter alloc]init];
        [ff setDateFormat:@"HH:mm:ss"];
        NSString  *dateString = [ff stringFromDate:date];
        NSString *hour = [dateString substringToIndex:2];
        NSString *minute = [dateString substringWithRange:NSMakeRange(3, 2)];
        [timePickerView selectRow:[hour intValue] inComponent:0 animated:NO];
        [timePickerView selectRow:[minute intValue] inComponent:2 animated:NO];
        [_alertView addSubview:timePickerView];
        
        hourString = [NSString stringWithString:hour];
        minuteString = [NSString stringWithString:minute];
        
        leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 220, _alertView.frame.size.width/2, 40);
        leftBtn.backgroundColor = [UIColor colorWithRed:0.91f green:0.53f blue:0.09f alpha:1.00f];
        [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [leftBtn addTarget:self action:@selector(leftBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:leftBtn];
        
        
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(_alertView.frame.size.width/2, 220, _alertView.frame.size.width/2, 40);
        rightBtn.backgroundColor = [UIColor colorWithRed:0.91f green:0.53f blue:0.09f alpha:1.00f];
        [rightBtn setTitle:@"确认" forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [rightBtn addTarget:self action:@selector(rightBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:rightBtn];
        
        self.inputControls = [SingleClass shareClass].inputControls;
        
        [self addSubview:_alertView];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}
-(id)initSignCalendarWithDelegate:(id<CustomAlertViewDelegate>)delegate andSignData:(NSDictionary *)signData isSign:(BOOL)isSign
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
    self.customDelegate=delegate;
    [self setBackgroundColor:[UIColor clearColor]];
    _bgView = [[UIView alloc] initWithFrame:self.frame];
    [_bgView setBackgroundColor:[UIColor blackColor]];
    [self addSubview:_bgView];
    _alertView = [[UIView alloc] initWithFrame:CGRectMake(20, 120, ScreenWidth-40, 310)];
        _alertView.backgroundColor = [UIColor whiteColor];
        _alertView.layer.cornerRadius = 5;
        _alertView.layer.masksToBounds = YES;
        UILabel *titleSignLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, _alertView.frame.size.width, 20)];
        if (isSign) {
            titleSignLabel.text = [NSString stringWithFormat:@"今天已签过啦"];
        }else
            titleSignLabel.text = [NSString stringWithFormat:@"签到成功，已连续签到%@天",[signData objectForKey:@"SeriesSignDay"]];
        titleSignLabel.textAlignment = NSTextAlignmentCenter;
        [_alertView addSubview:titleSignLabel];
        UIButton *cacleSignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cacleSignBtn.frame = CGRectMake(_alertView.frame.size.width-45, 5, 30, 30);
        [cacleSignBtn setImage:[UIImage imageNamed:@"cancleImage.png"] forState:UIControlStateNormal];;
        [cacleSignBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:cacleSignBtn];
        
        NSArray *signCalendarData2 = [signData objectForKey:@"MonthSignDayList"];
        
        
     _customCalendarView = [[CalendarView alloc]initWithFrame:CGRectMake(0, 40,_alertView.frame.size.width, 270)];
        _customCalendarView.signCalendarData = signCalendarData2;
        _customCalendarView.isSignCalen = YES;
        _customCalendarView.allowsChangeMonthBySwipe = NO;
        _customCalendarView.monthAndDayTextColor        = [UIColor colorWithRed:0.43f green:0.42f blue:0.41f alpha:1.00f];
        _customCalendarView.dayBgColorWithData          = [UIColor colorWithRed:0.83f green:0.94f blue:1.00f alpha:1.00f];
        _customCalendarView.dayBgColorWithoutData       = [UIColor colorWithRed:0.83f green:0.94f blue:1.00f alpha:1.00f];
        _customCalendarView.dayBgColorSelected          = [UIColor colorWithRed:0.60f green:0.82f blue:0.93f alpha:1.00f];
        _customCalendarView.dayTxtColorWithoutData      = [UIColor colorWithRed:0.46f green:0.45f blue:0.45f alpha:1.00f];
        _customCalendarView.dayTxtColorWithData         = [UIColor colorWithRed:0.43f green:0.42f blue:0.41f alpha:1.00f];
        _customCalendarView.dayTxtColorSelected         = [UIColor colorWithRed:0.46f green:0.45f blue:0.45f alpha:1.00f];
        _customCalendarView.borderColor                 = [UIColor colorWithRed:0.98f green:0.98f blue:0.98f alpha:1.00f];
        _customCalendarView.borderWidth                 = 3;
        _customCalendarView.allowsChangeMonthByDayTap   = NO;
        _customCalendarView.allowsChangeMonthByButtons  = NO;
        _customCalendarView.keepSelDayWhenMonthChange   = YES;
        _customCalendarView.nextMonthAnimation          = UIViewAnimationOptionTransitionFlipFromRight;
        _customCalendarView.prevMonthAnimation          = UIViewAnimationOptionTransitionFlipFromLeft;

    [_alertView addSubview:_customCalendarView];
    [self addSubview:_alertView];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeAlertViewFrame:) name:@"changeFooterViewFrame" object:nil];
    [self showBackground];
    [self showAlertAnmation];
    }
    return self;
}
-(void)changeAlertViewFrame:(NSNotification *)note
{
    _alertView.frame =CGRectMake(20,120, ScreenWidth-40, _customCalendarView.frame.size.height+80) ;
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component==0) {
        return hourArray.count;
    }else if(component==2)
        return minuteArray.count;
    else
        return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (component==0)
        return hourArray[row];
    else if(component==1)
        return @"时";
    else if(component==2)
        return minuteArray[row];
    else
        return @"分";
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component==0) {
        NSLog(@"----%@",hourArray[row]);
        hourString = [NSString stringWithFormat:@"%@",hourArray[row]];
    }else if(component==2)
    {
        NSLog(@"-----%@",minuteArray[row]);
        minuteString = [NSString stringWithFormat:@"%@",minuteArray[row]];
    }
}

-(id)initPhoneNumberWithDelegate:(id<CustomAlertViewDelegate>)delegate{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.alertViewType = CustomAlertViewTypePhoneNumber;
        [SingleClass shareClass].inputControls = [[NSMutableArray alloc] init];
        self.customDelegate = delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_bgView];
        
        GetPhoneNumberViewController*vc = [[GetPhoneNumberViewController alloc] init];
        vc.delegate = self;
        [self addSubview:vc.view];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
    
}

//toast提示框
-(id)initToastWithDelegate:(id<CustomAlertViewDelegate>)delegate context:(NSString *)contextStr{
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        _alertViewType = CustomAlertViewTypeToast;
        self.customDelegate = delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        [_bgView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_bgView];
        
        UILabel*lab = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2-contextStr.length*15/2, self.frame.size.height/2-25/2, contextStr.length*15, 25)];
        lab.text = contextStr;
        lab.layer.cornerRadius = 3;
        lab.font = [UIFont systemFontOfSize:12];
        lab.layer.masksToBounds = YES;
        lab.alpha = 0.7;
        lab.backgroundColor = [UIColor blackColor];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor whiteColor];
        [self addSubview:lab];
        
        [self performSelector:@selector(hideAlertView) withObject:self afterDelay:3];
        
        [self addSubview:_alertView];
        [self showBackground];
        [self showAlertAnmation];
    }
    return self;
}

#pragma mark -- GetPhoneNumberDelegate--
-(void)gobackPhone:(NSString *)phone Name:(NSString *)name{
    
    NSMutableDictionary*dic = [[NSMutableDictionary alloc]init];
    [dic setObject:name forKey:@"name"];
    [dic setObject:phone forKey:@"phone"];
    NSLog(@"电话%@",dic);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocalAction_GetPhoneNumberAndName" object:nil userInfo:dic];
    [self hideAlertView];
}

#pragma mark --- GesturePass  -----
#pragma -mark 验证手势密码
- (void)verify{
    gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [gesturePasswordView.tentacleView setRerificationDelegate:self];
    [gesturePasswordView.tentacleView setStyle:1];
    [gesturePasswordView setGesturePasswordDelegate:self];
    [self addSubview:gesturePasswordView];
}

#pragma -mark 重置手势密码
- (void)reset{
    gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [gesturePasswordView.tentacleView setResetDelegate:self];
    [gesturePasswordView.tentacleView setStyle:2];
    [gesturePasswordView.imgView setHidden:YES];
    [gesturePasswordView.forgetButton setHidden:YES];
    [gesturePasswordView.changeButton setHidden:YES];
    [self addSubview:gesturePasswordView];
}

#pragma -mark 清空记录
- (void)clear{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    [keychin resetKeychainItem];
}

#pragma -mark 使用其他方式登录
-(void)changeLoginFlag{
    [self hideAlertView];
    [MobileBankSession sharedInstance].isPassiveLogin = YES;
    if ([self.customDelegate respondsToSelector:@selector(gestureOtherWay:)]) {
        [self.customDelegate gestureOtherWay:self];
    }
    [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];


}

#pragma -mark 取消登录
-(void)hiddenLoginAlert{
    if ([self.customDelegate respondsToSelector:@selector(gestureExit:)]) {
        [self.customDelegate gestureExit:self];
    }
    [self hideAlertView];
}

- (BOOL)verification:(NSString *)result{
    if ([result isEqualToString:password]) {
        [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [gesturePasswordView.state setText:@"输入正确"];
        
        [self hideAlertView];
        
        return YES;
    }
    [gesturePasswordView.tentacleView enterArgin];
    [gesturePasswordView.state setTextColor:[UIColor redColor]];
    [gesturePasswordView.state setText:@"手势密码错误"];
    return NO;
}

- (BOOL)resetPassword:(NSString *)result{
    if ([previousString isEqualToString:@""]) {
        previousString=result;
        if (result.length<4) {
            previousString = @"";
            [gesturePasswordView.tentacleView enterArgin];
            [gesturePasswordView resetHeaderView];
            [gesturePasswordView.state setTextColor:[UIColor redColor]];
            [gesturePasswordView.state setText:@"最小长度为4，请重新输入"];
            return NO;
        }
        [gesturePasswordView initHeaderView:result];
        [gesturePasswordView.tentacleView enterArgin];
        [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [gesturePasswordView.state setText:@"请确认手势密码"];
        return YES;
    }
    else {
        if ([result isEqualToString:previousString]) {
            KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
            [keychin setObject:[Context getNSUserDefaultskeyStr:@"userID"] forKey:(__bridge id)kSecAttrAccount];
            [keychin setObject:result forKey:(__bridge id)kSecValueData];
            //[self presentViewController:(UIViewController) animated:YES completion:nil];
            [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
            [gesturePasswordView.state setText:@"已保存手势密码"];
            
            if ([self.customDelegate respondsToSelector:@selector(verGestureSucess:)]) {
                [self.customDelegate verGestureSucess:self];
            }
            
            [self performSelector:@selector(hideAlertView) withObject:self afterDelay:0.5];
            
            return YES;
        }
        else{
            previousString = @"";
            [gesturePasswordView.tentacleView enterArgin];
            [gesturePasswordView resetHeaderView];
            [gesturePasswordView.state setTextColor:[UIColor redColor]];
            [gesturePasswordView.state setText:@"两次密码不一致，请重新输入"];
            return NO;
        }
    }
    
}
#pragma mark  --- GesturePass --End

-(void)textFieldDidBeginEditing:(UITextField *)_textField
{
    if (self.alertViewType == CustomAlertViewType_JalBreakBuy_Login) {
        if (IOS8_OR_LATER) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            _alertView.frame = CGRectMake(_alertView.frame.origin.x,[Context iPhone4]?_alertView.frame.origin.y-155:_alertView.frame.origin.y-120,_alertView.frame.size.width,_alertView.frame.size.height);
            [UIView commitAnimations];
        }else{
            
            _alertView.frame = CGRectMake(_alertView.frame.origin.x,[Context iPhone4]?_alertView.frame.origin.y-155:_alertView.frame.origin.y-120,_alertView.frame.size.width,_alertView.frame.size.height);
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)_textField
{
    if (self.alertViewType == CustomAlertViewType_JalBreakBuy_Login ) {
        
        //        if (_textField == _passwordTF) {
        //            [UIView beginAnimations:nil context:NULL];
        //            [UIView setAnimationDuration:0.3];
        //
        //            _alertView.frame = CGRectMake(6.5 ,130.5,_alertView.frame.size.width,_alertView.frame.size.height);
        //
        //            [UIView commitAnimations];
        //
        //        }else
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        _alertView.frame = CGRectMake(18.75 ,ScreenHeight/2-_alertView.frame.size.height/2,_alertView.frame.size.width,_alertView.frame.size.height);
        [UIView commitAnimations];
        
    }
}

- (UIView *)view {
    return _alertView;
}

-(void)DoneClick{
    
    if(_alertView != nil){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        _alertView.frame = CGRectMake(18.75 ,ScreenHeight/2-_alertView.frame.size.height/2,_alertView.frame.size.width,_alertView.frame.size.height);
        [_userNameTF resignFirstResponder];
        [UIView commitAnimations];
    }
}


-(void)showAfterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(show) withObject:nil afterDelay:delay];
}


-(void)show
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    NSArray* windowSubviews = [window subviews];
    if(windowSubviews && [windowSubviews count]>0){
        UIView* topSubView = [windowSubviews objectAtIndex:windowSubviews.count-1];
        for(UIView* aView in topSubView.subviews)
        {
            [aView.layer removeAllAnimations];
        }
        [topSubView addSubview:self];
    }
    
    //-----------------------------------------//
    
    for(UIView* aView in window.subviews)
    {
        [aView.layer removeAllAnimations]; //清除动画，会清除提示等待的菊花遮罩
    }
    [window addSubview:self];
}

- (void) showBackground
{
    _bgView.alpha = 0;
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _bgView.alpha = 0.6;
    [UIView commitAnimations];
}

-(void) showAlertAnmation
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.30;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [_alertView.layer addAnimation:animation forKey:nil];
    
}

-(void) hideAlertAnmation
{
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.3];
    _bgView.alpha = 0.0;
    [UIView commitAnimations];
}



-(CGRect)getAlertBounds
{
    CGRect retRect;
    
    if (_alertViewType == CustomAlertViewType_JalBreakBuy_Login)
    {
        
        retRect= CGRectMake((self.frame.size.width-300)/2, (self.frame.size.height-320)/2, 300, 320);
        
    }
    else
    {
        //        UIImage* image=[UIImage imageNamed:@"AlertView_background.png"];
        //        CGSize imageSize = image.size;
        //        retRect= CGRectMake((self.frame.size.width-imageSize.width)/2, (self.frame.size.height-imageSize.height)/2, imageSize.width, imageSize.height);
        
        retRect= CGRectMake((self.frame.size.width-300)/2, (self.frame.size.height-200)/2, 300, 220);
    }
    
    return retRect;
}

- (void) hideAlertView
{
    if ([self.customDelegate isKindOfClass:[BindingEquipmentViewController class]]) {
        [MobileBankSession sharedInstance].isLogin = YES;
        [[CSIIMenuViewController sharedInstance].navigationController popViewControllerAnimated:NO];
        [[CSIIMenuViewController sharedInstance].drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:nil];
    }
    
    _alertView.hidden = YES;
    [self hideAlertAnmation];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
}

-(void) removeFromSuperview
{
    
    [super removeFromSuperview];
    
}

- (void) leftBtnPressed:(id)sender
{
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(leftBtnPressedWithinalertView:)])
    {
        [_customDelegate leftBtnPressedWithinalertView:self];
        if (_alertViewType != CustomAlertViewTypeGongGao) {
            [self hideAlertView];
        }
    }
    else
    {
        [self hideAlertView];
    }
}

- (void) rightBtnPressed:(id)sender
{
    if (_alertViewType ==CustomAlertViewTypeCalendar) {
        if (_customDelegate && [_customDelegate respondsToSelector:@selector(rightBtnPressedWithinalertView:andHourString:andMinuteString:)])
        {
            [_customDelegate rightBtnPressedWithinalertView:self andHourString:hourString andMinuteString:minuteString];
        }
        return;
    }
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(rightBtnPressedWithinalertView:)])
    {
        [_customDelegate rightBtnPressedWithinalertView:self];
    }
    else
    {
        [self hideAlertView];
    }
}
-(void)cancelBtnPressed:(id)sender
{
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(cancelBtnPressedWithinalertView:)])
    {
        [_customDelegate cancelBtnPressedWithinalertView:self];
    }
    else
    {
        [self hideAlertView];
    }
}
- (void) centerBtnPressed:(id)sender
{
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(centerBtnPressedWithinalertView:)])
    {
        [_customDelegate centerBtnPressedWithinalertView:self];
    }
    else
    {
        [self hideAlertView];
    }
}

-(void) setTitle:(NSString*) title
{
    titleLabel.text = title;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}


-(void) textFieldChanged
{
    if ([textField.text length] > MAX_CATEGORY_NAME_LENGTH)
    {
        textField.text = [textField.text substringToIndex:MAX_CATEGORY_NAME_LENGTH];
    }
}

#pragma mark - DelegateTextField


- (BOOL)textFieldShouldReturn:(UITextField *)_textField
{
    if (_textField.tag == kTagViewTextFieldJalBreakPassW)
    {
        [self rightBtnPressed:nil];
        return NO;
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField_ shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField_.tag == kTagViewTextFieldJalBreakPassW)
    {
        
        if (string && [string length] && [textField_.text length]>15)
        {
            return NO;
        }
        
    }
    
    if (textField_ == self.userNameTF) {
        if (string && [string length] && [textField_.text length]>10)
        {
            return NO;
        }
    }
    
    return YES;
    
}

#pragma mark - sendMessage

- (void) sendClick:(UIButton *) btn {
    static int num = 60;
    [_msgSend setUserInteractionEnabled:NO];
    dispatch_queue_t queue = dispatch_queue_create("sendMessage", NULL);
    //创建一个子线程
    dispatch_async(queue, ^{
        // 子线程
        NSLog(@"发送短信");
        
        //主线程
        int i;
        for (i = num;i >= 0;i--) {
            if (i < num) {
                sleep(1);
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                Boolean isMain = [NSThread isMainThread];
                if (isMain) {
                    if (i == 0) {
                        _lineLabel.hidden = NO;
                        _msgSend.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                        [_msgSend setTitle:@"重新获取" forState:UIControlStateNormal];
                        [_msgSend setUserInteractionEnabled:YES];
                    } else {
                        _lineLabel.hidden = YES;
                        _msgSend.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]+5];
                        [_msgSend setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
                    }
                }
            });
        }
    });
    if (_AuthenticateTypeStr==Nil) {
        _AuthenticateTypeStr = @"";
    }
    NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"ST" forKey:@"_TokenType"];
    [dict setObject:_AuthenticateTypeStr forKey:@"_AuthenticateType"];
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance] postToServer:@"OTPPreAuthenticate.do" actionParams:dict method:@"POST"];
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
        if ([action isEqualToString:@"OTPPreAuthenticate.do"]) {
            if ([SERVER_BACKEND_URL isEqualToString:@"https://59.45.207.102"]) {
                
            }else{
                //                _msgVerifyCodeTF.text = [data objectForKey:@"OTPPassword"];
            }
        }
    }
    else
    {
        //        NSString*msg = [data objectForKey:@"jsonError"];
        //        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"错误提示" message:msg delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
        //        [alert show];
    }
}

- (void) validCodeBtnPressedWithinAlertView:(CustomAlertView *)alert{
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(validCodeBtnPressedWithinAlertView:)])
    {
        [_customDelegate validCodeBtnPressedWithinAlertView:self];
    }
    else
    {
        [self hideAlertView];
    }
    
}
- (void) selfAssisstantLinkBtnPressedWithinAlertView:(CustomAlertView *)alert{
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(selfAssisstantLinkBtnPressedWithinAlertView:)])
    {
        [_customDelegate selfAssisstantLinkBtnPressedWithinAlertView:self];
    }
    else
    {
        [self hideAlertView];
    }
    
    
}
- (void) resetPasswordBtnPressedWithinAlertView:(CustomAlertView *)alert{
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(resetPasswordBtnPressedWithinAlertView:)])
    {
        [_customDelegate resetPasswordBtnPressedWithinAlertView:self];
    }
    else
    {
        [self hideAlertView];
    }
    
    
}
- (void) loginBtnPressedWithinAlertView:(CustomAlertView *)alert{
    
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(loginBtnPressedWithinAlertView:)])
    {
        [_customDelegate loginBtnPressedWithinAlertView:self];
    }
    else
    {
        [self hideAlertView];
    }
}

+(CustomAlertView *)defaultAlertView {
    static CustomAlertView *alertView = nil;
    if (alertView == nil) {
        alertView = [[CustomAlertView alloc] init];
    }
    return alertView;
}

@end