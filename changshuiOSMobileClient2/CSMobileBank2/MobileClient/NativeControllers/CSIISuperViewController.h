//
//  CSIISuperViewController.h
//  MobileClient
//
//  Created by wangfaguo on 13-7-17.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDKGloableVariable.h"
#import "CustomAlertView.h"

#import "MobileBankSession.h"

@class CustomAlertView;

@interface CSIISuperViewController : UIViewController<UITextFieldDelegate,MobileSessionDelegate>
{
    NSMutableArray *inputControls;
    UIImageView *hintsBackgroundView;
}

//@property (strong, nonatomic) CustomAlertView* loginAlertView;



@property (nonatomic) BOOL changBackGround;
@property (strong,nonatomic) UIButton *leftButton;
@property (strong,nonatomic) UIButton *rightButton;
@property (strong,nonatomic)UISwipeGestureRecognizer*Swipe;
@property (strong,nonatomic) NSMutableArray *inputControls;
//@property (strong,nonatomic) NSArray *relatedPageServerHints;
@property (strong,nonatomic) UIImageView *hintsBackgroundView;
@property (strong, nonatomic) UIImageView* backgroundView;
@property (retain,nonatomic) MobileBankSession *mobileBankSession;// 内置对象
@property (nonatomic,assign) BOOL isShowbottomMenus;// 内置对象
@property(nonatomic,strong)NSMutableArray *barButtonItemArray;

@property(nonatomic,strong)CustomAlertView *loginAlertView;//手势密码

@property(nonatomic,strong)UIButton *saoYisaoBtn;

-(void)leftButtonAction:(id)sender;
-(void)rightButtonAction:(id)sender;

-(BOOL)validateTextFormat;//验证textfield数据格式
+(CSIISuperViewController *)defaultController;

//设置菜单关联页面的温馨提示，包括录入页面，确认页，结果页的温馨提示
//-(void)setMenuRelatedPageServerHints:(NSArray*)hints;
//单个页面获取温馨提示
-(NSString*)getSinglePageServerHintsWithPageNo:(NSInteger)pageNo;
//添加服务器下发的温馨提示
-(UIImageView*)addServerHintsByPageNo:(NSUInteger)pageNo FromY:(CGFloat)y;
//添加默认的温馨提示
-(UIImageView*)addDefaultHints:(NSString*)defaultHints FromY:(CGFloat)y FromX:(CGFloat)x;

- (NSString *)showStrInName:(NSString *)nameStr;
//-(void)alertPassword;
-(NSString *) formateDate:(NSDate *) date;
-(void)addBottomMenus;
-(NSString *)showHorizontal:(NSString *)str;
-(NSString *)splitByRmb:(NSString *)moneyStr;
-(NSString *)splitMoneyStr:(NSString *)moneyStr;
- (NSDate *)formateStrToDate:(NSString *)str;
-(void)gestureExit:(CustomAlertView *)alert;

-(void)bottomButtonAction:(UIButton *)sender;
-(void)viewDidLoad;

@end
