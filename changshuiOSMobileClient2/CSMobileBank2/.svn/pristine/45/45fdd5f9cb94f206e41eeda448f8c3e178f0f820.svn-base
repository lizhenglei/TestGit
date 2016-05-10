//
//  CSIIShareHandle.h
//
//
//  Created by 胡中楷 on 14-11-1.
//  Copyright (c) 2014年 胡中楷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <MessageUI/MessageUI.h>
#import "CSIIShareView.h"
#import "CSIISinaAuthorViewController.h"


////////////////////////////////////////***新浪微博***////////////////////////////////////////

#define kSinaWeiboSDKOAuth2APIDomain       @"https://api.weibo.com/oauth2/"
#define kSinaWeiboWebAuthURL               @"https://api.weibo.com/oauth2/authorize"    //授权接口
#define kSinaWeiboWebAccessTokenURL        @"https://api.weibo.com/oauth2/access_token" //授权查询接口

#define kSinaAppKey         @"2812335374"//@"1790776830"
#define kSinaAppSecret      @"8111f6aabde9f87cc7e439be28a7f29f"
#define kSinaRedirectURI    @"https://api.weibo.com/oauth2/default.html"                //回调地址
#define kSinaUploadURL      @"https://upload.api.weibo.com/2/statuses/upload.json"      //上传图片并发布
#define kSinaUpdateURL      @"https://api.weibo.com/2/statuses/update.json"             //发布


////////////////////////////////////////***微信/QQ***///////////////////////////////////
#import "WXApi.h"
#define TencentAppKey    @"1104903627"   //222222
#define kWeiXinAppKey    @"wxd7c92ad28e81c14d"//@"wxd930ea5d5a258f4f"
#define kWeiXinAppdesc   @"demo 2.0"


@protocol ShareHandleTencentDelegate <NSObject>

- (void)TencentLoginSuccess;//登录成功
- (void)TencentLoginFaield:(NSString *) errInfo;//错误信息
- (void)TencentNotNetWork;//无网络
- (void)TencentDidLogout;//登出

@end

@interface CSIIShareHandle : NSObject<WeiboSDKDelegate,TencentSessionDelegate,WXApiDelegate,MFMessageComposeViewControllerDelegate,WBHttpRequestDelegate>

@property (nonatomic ,strong) NSString *itemFlag;//分享平台标识

////////////////////////////////////***新浪***/////////////////////////////////////
@property (nonatomic ,strong) NSString *SinaWBToken;//新浪微博token
@property (nonatomic ,strong) NSString *SinaWBUserID;//用户名
@property (nonatomic ,strong) NSDate   *SinaWBTokenDate;//有效时间
@property (nonatomic ,assign) NSTimeInterval SinaWBExpires_in;//生命周期

///////////////////////////////////////***腾讯QQ***////////////////////////////////
@property (nonatomic ,assign) id<ShareHandleTencentDelegate> tencentDelegate;
@property (nonatomic ,strong) TencentOAuth *TCAuthor;//
@property (nonatomic ,strong) NSString *TCaccessToken;//token
@property (nonatomic ,strong) NSDate *TCexpirationDate;//失效日期
@property (nonatomic ,strong) NSString *TCopenID;//openID

///////////////////////////////////////***微信***//////////////////////////////////
@property (nonatomic ,assign) int WXScene; //微信分享场景

+ (id)ShareHandleInstance;
+ (BOOL)ShareIsNeedAuthor:(NSString *) shareSubtitle;
+ (BOOL)ShareSearchIsFinishAuthor:(NSString *) shareSubtitle;
- (void)showSMSPicker:(UIViewController *) ViewController;   //发送短信

#pragma mark - Tencent
+ (BOOL)TencentTokenIsInvalid;
- (void)TencentLogin;
- (void)messageToTencentNews:(NSString *) title                            //网页内容标题
                 Description:(NSString *) description                      //内容描述
                         URL:(NSString *) url                              //访问地址
               PreviewImgData:(NSData *) imgData;                          //缩略图地址

#pragma mark - 分享到微信
- (void)messageToWeiXinNews:(NSString *) title
                Description:(NSString *) description
                    content:(NSString *) content
                      Image:(UIImage *)  img
                        URL:(NSString *) url
                 shareScene:(int)        Scene;                            //分享场景(朋友圈还是好友)

#pragma mark - SINA
+ (BOOL)SinaWeiBoTokenIsInvalid;
- (void)SinaWeiBoLogin:(id<CSIISinaAuthorViewControllerDelegate>) sinaLoginDelegate;
- (WBMessageObject *)messageToSinaShareOnlyWords:(NSString *) content;       //内容
- (WBMessageObject *)messageToSinaShareOnlyWords:(NSString *)content        //内容
                                          andUrl:(NSString *)url;           //链接

- (WBMessageObject *)messageToSinaShareWords:(NSString *) content           //内容
                                      andImg:(UIImage *) image;             //图片

- (WBMessageObject *)messageToSinaShareNews:(NSString *)ID                  //唯一标识
                                   andTitle:(NSString *)title               //标题
                                Description:(NSString *)description         //简介
                                   ImgSmall:(UIImage *)img                  //图片
                                        Url:(NSString *)url;                //url

- (NSDictionary *)SinaParamsWithKey:(NSString *)Appkey
                        redirectUrl:(NSString *)url
                           andScope:(NSString *)scope
                              State:(NSString *)state
                        DisplayType:(NSString *)type
                         forceLogin:(BOOL)value
                           Language:(NSString *)language;//封装授权参数
- (void)messageToTencentNews:(NSString *)title Description:(NSString *)description PreviewImgData:(NSData *) imgData;
- (void)messageToWeiXinNews:(NSString *)title Description:(NSString *)description content:(NSString *)content Image:(UIImage *)img shareScene:(int)Scene;

@end
