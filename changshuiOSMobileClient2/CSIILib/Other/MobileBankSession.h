//
//  MobileBankSession.h
//  MobileBankSession
//
//  Created by Yuxiang on 13-6-20.
//  Copyright (c) 2013年 北京科蓝软件系统有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^RetrunData)(NSDictionary *data);

typedef enum{
    Alert=101,
    Confirm,
}alertType;

typedef enum{
    Common=0
}maskType;
typedef enum
{
    ENoAuthority=0, //没权限,需登录
    ENativeList=1,//打开菜单native list页面
    ENative=2, //打开native页面
    EWeburl=3, //打开weburl页面
    EDisabled=4 //不可用,无响应
}OpenMode;

@protocol MobileSessionDelegate <NSObject>

@optional
-(void)getReturnData:(id)data WithActionName:(NSString *)action;//返回数据
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;//alert 回调方法自己实现
-(void)OpenNextView:(OpenMode)mode;
@end


@interface MobileBankSession : NSObject{
    
}
@property(nonatomic,retain)id <MobileSessionDelegate>delegate;
@property(nonatomic,retain)NSMutableArray *MenuArray;//菜单数据
@property(nonatomic,assign)BOOL isLogin;//登录状态
@property(nonatomic,retain)NSDictionary *unloginMenuData;//未登录时的菜单数据

@property(nonatomic,assign) int recentlyMenuGrade;//跟踪上级菜单
@property(nonatomic,strong)NSString *actionID;

@property(nonatomic,assign)int menuViewSlectedTag;              //记录menuView底部按钮的tag
@property(nonatomic,assign)int menuListSlectedTag;              //记录menulist底部按钮的tag
@property(nonatomic,strong)NSString*RandomNumberStr;     //存储加密用得随机数
@property(nonatomic,assign)BOOL isPassiveLogin;     //判断用户是否为被动登录
@property(nonatomic,strong)UIViewController*isPassiveLoginDelegate;   //存储menuview或者menulistview   用来作为被动登陆之后继续进行交易的代理类
@property(nonatomic,strong)NSString*tokenNameStr;
@property(nonatomic,assign)BOOL isMapPosition;

//下面这些是????的东西

@property(nonatomic,assign)BOOL IsVxData; //判断是否的vx发出的请求
@property(nonatomic,retain) NSDictionary*userInfoDict;  //vx需要的用户信息
@property(nonatomic,strong) NSData *ImgData;
@property(nonatomic,assign) BOOL shouldPushToBinding;
@property(nonatomic,assign) BOOL isMenuListViewController;//是否是menulist类进行跳转
@property(nonatomic,assign) BOOL isRightViewControllerDone;//rightViewController点击完成
@property(nonatomic,retain) NSMutableDictionary *Userinfo;  //存储登录返回的用户信息
@property(nonatomic,strong)NSMutableArray*setMenuArray;    //存储设置菜单
@property(nonatomic,strong)NSString *changeSkinType;
////////到这里


+ (MobileBankSession *)sharedInstance;
-(void)sessionInit;//初始化
-(int)deviceNetWorkState;//网络状态
-(void)showAlert:(NSString *)alertTitle alertMessages:(NSString *)alertMessages alertType:(alertType)alertType;//显示提示对话窗口
-(void)showMask:(NSString *)maskTitle maskMessage:(NSString *)messages maskType:(maskType)type;//显示等待遮罩层
-(void)hideMask;//隐藏等待遮罩层
-(void)menuStartAction:(NSDictionary*)menuDictionary;//菜单启动接口
-(void)postToServerStream:(NSString *)action actionParams:(NSMutableDictionary *)params;//数据接口 返回stream
-(void)postToServer:(NSString *)action actionParams:(NSMutableDictionary *)params;//数据接口返回string
-(void)postToServer:(NSString *)action actionParams:(NSMutableDictionary *)params method:(NSString*)method;
//vx调用这个方法
-(void)postToServer:(NSString *)action actionParams:(NSMutableDictionary *)params method:(NSString*)method IsVx:(BOOL)isVx;
-(BOOL)loginState;//登录状态
-(NSString *)getLastErrorMessage;//错误信息
-(BOOL)authenticationCheck:(NSString *)actionId;//隐式鉴权
-(BOOL)authentication:(NSString *)actionId;//显式鉴权
-(void)getLoginPage:(NSString*)name Password:(NSString*)password;//申请登录
-(int )last:(NSString*)lastTimer now:(NSString*)nowTime;//返回时间间隔

//
-(NSString*)newSHA1String:(const char*)bytes Datalength:(size_t)length;   //获取https证书指纹
//- (id)initWithTrans:(NSString*)trans args:(NSMutableDictionary*)args;
//- (id)initWithTrans:(NSString *)trans;

//-(NSString *)getCurrentTimeStamp;
-(void)setMaskShowTimeOut:(NSTimeInterval)interval;

-(void)postToServer:(NSString *)action actionParams:(NSMutableDictionary *)params method:(NSString*)method returnBlock:(RetrunData)_returnData111;

@end




