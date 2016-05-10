//
//  CSIIMenuViewController.h
//  MobileClient
//
//  Created by wangfaguo on 13-7-17.
//  Copyright (c) 2013年 pro. All rights reserved.
//
#import "CSIISuperViewController.h"
#import "WebViewController.h"
//#import "CSIIWebViewController.h"
#import "Context.h"
#import "CSIIUtility.h"
#import "PublicContentView.h"

typedef enum {
    ESelectNone = 0,
    ESelectTabMenu= 1,
    ESelectMenu = 2
} MenuSelectFlag;

@interface CSIIMenuViewController : CSIISuperViewController<UIAlertViewDelegate,UINavigationControllerDelegate,CustomAlertViewDelegate, UIScrollViewDelegate>
{
}
//-(id)initWithDisplayList:(NSMutableArray*)dicList actionId:(NSString*)actionId;
@property(assign) BOOL isEdit;
@property (strong, nonatomic)NSString *preBottomButtonActionId;//上次的BottomButton actionid
@property (assign, nonatomic)BOOL isloginActionSucceedBack;
@property (assign, nonatomic)BOOL isClickMenuListTabMenuBack;

@property(nonatomic,strong) UIButton * leftBarItem;
@property(nonatomic,strong) UIButton * rightBarItem;//；
@property(nonatomic,strong) UIButton * rightBarItemDone;//；
@property(nonatomic,strong) UIView* headerView;
@property(nonatomic,strong) NSMutableArray* bannerImages;
@property(nonatomic,strong) PublicContentView*pubView;
@property(nonatomic,assign) BOOL       isLoadPubview;//防止公告重叠
@property(nonatomic,strong) NSMutableArray *publicArray;


@property(nonatomic,strong) NSString *currentActionId;//自己的actionid

@property(nonatomic,strong) UIViewController *nativeVC;

@property(nonatomic,assign) BOOL shouldShowTableView;//显示tablview

@property(nonatomic,strong) UIImageView *navilogo;
@property(nonatomic,strong) UILabel *titleLab;

@property(nonatomic,strong)NSString *toActionId;//下级actionid
@property(nonatomic,strong)NSString *toActionName;//下级actionName
@property(nonatomic,strong)NSString *toPrdId;//下级PrdId,同网银菜单中的PrdId一致
@property(nonatomic,strong)NSString *toId;//下级Id,同网银菜单中的Id一致
@property(nonatomic,strong)NSString *toClickable;//下级Clickable    判断是否可点击
@property(nonatomic,strong)NSString *toIslogin;//下级Islogin        是否需要登录权限
@property(nonatomic,strong)NSString *toRoleCtr;//下级RoleCtr        大众版或专业版

@property(nonatomic,strong)NSMutableArray *toMenuArray;
@property(nonatomic,assign)NSInteger menuArrayIndex;
@property(nonatomic,assign)MenuSelectFlag menuSelectFlag;

+(CSIIMenuViewController*)sharedInstance;

-(void)setMenuArray:(NSArray*)array;
-(NSArray*)getMenuArray;
-(void)setcurrentActionId:(NSString*)actionId;
-(NSString*)getcurrentActionId;
-(BOOL)isMyFavoriteFixedMenu:(NSDictionary *)menuDic;
-(UIViewController*)getNativeViewControllerWithActionId:(NSString*)actionId prdId:(NSString*)prdId Id:(NSString*)Id;
-(void)reLayoutView;
@end
