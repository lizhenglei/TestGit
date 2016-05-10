//
//  myErWeiMaViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/5/8.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "myErWeiMaViewController.h"
#import "CommonFunc.h"

#import "WeiboSDK.h"
#import "CSIIShareHandle.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import "CSIISinaAuthorViewController.h"
#import "CSIISinaContentController.h"

#import "Context.h"

#import "QREncoder.h"
#import "DataMatrix.h"


@class  QREncoder;

@interface myErWeiMaViewController ()<LWYPickerViewDelegate,ShareHandleTencentDelegate,WBHttpRequestDelegate,CSIIShareViewDelegate>
{
    LWYTextField *cardNumber;
    UILabel *userName;
    UIImageView * imageView;
    NSArray *_buttonArray;
    NSMutableArray *numberArray;
    UIImageView *BgBankImageView;
    UIImage *saveViewImage;//保存到相册是整个图片，包含名字什么的

}
@end

@implementation myErWeiMaViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIScrollView *bgView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-64)];
    if (ScreenHeight==480) {
        bgView.contentSize = CGSizeMake(ScreenWidth-20, ScreenHeight);
    }else{
        bgView.contentSize = CGSizeMake(ScreenWidth-20, ScreenHeight-72-64);
    }
    bgView.bounces = NO;
    bgView.showsVerticalScrollIndicator = NO;
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    UIImage *image = [UIImage imageNamed:@"bgBankImage.png"];
    BgBankImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth-20, (ScreenWidth-20)*image.size.height/image.size.width)];
    BgBankImageView.image = image;
    BgBankImageView.userInteractionEnabled = YES;
    [bgView addSubview:BgBankImageView];
 
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30, (int)((ScreenWidth-20)*image.size.height/image.size.width)-60, (int)((ScreenWidth-20)*image.size.height/image.size.width)-60)];
    [BgBankImageView addSubview:imageView];
    
    userName = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.size.width+imageView.frame.origin.x+30, BgBankImageView.frame.size.height/2-15, 100, 30)];
    userName.text = [[MobileBankSession sharedInstance].Userinfo objectForKey:@"UserName"];
    userName.textAlignment = NSTextAlignmentLeft;
    userName.backgroundColor = [UIColor clearColor];
    userName.textColor = [UIColor colorWithRed:0.39f green:0.39f blue:0.39f alpha:1.00f];
    [BgBankImageView addSubview:userName];
    
    NSMutableArray *numberArrayShow = [[NSMutableArray alloc]init];//展示带*的
    numberArray = [[NSMutableArray alloc]init];
    NSArray *cardNuberArray = [[MobileBankSession sharedInstance].Userinfo objectForKey:@"AcList"];
    for (int i=0; i<cardNuberArray.count; i++) {
        if (![[[cardNuberArray objectAtIndex:i] objectForKey:@"AcType"] isEqualToString:@"4"]) {
            [numberArray addObject:[[cardNuberArray objectAtIndex:i] objectForKey:@"AcNo"]];
            NSString *numberCard = [[cardNuberArray objectAtIndex:i] objectForKey:@"AcNo"];
            NSString *ss = [NSString stringWithFormat:@"%@****%@",[numberCard substringWithRange:NSMakeRange(0, 4) ],[numberCard substringWithRange:NSMakeRange(numberCard.length-4, 4)]];
            [numberArrayShow addObject:ss];
        }else{//信用卡之外的可用
            
        }
    }
    cardNumber = [[LWYTextField alloc]initPicerViewWithFrame:CGRectMake(20, BgBankImageView.frame.size.height-35, BgBankImageView.frame.size.width-40, 30) picerDataArray:(NSMutableArray *)numberArrayShow];
//    cardNumber.tintColor = [UIColor clearColor];
    cardNumber.textAlignment = NSTextAlignmentCenter;
    cardNumber.font = [UIFont systemFontOfSize:17];
    cardNumber.textColor = [UIColor colorWithRed:0.39f green:0.39f blue:0.39f alpha:1.00f];
    NSString *mainNum = [[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"];
    cardNumber.text = [NSString stringWithFormat:@"%@****%@",[mainNum substringWithRange:NSMakeRange(0, 4) ],[mainNum substringWithRange:NSMakeRange(mainNum.length-4, 4)]];
    cardNumber.delegate =self;
    cardNumber.pickerViewDelegate =self;
    [self.inputControls addObject:cardNumber];
    [BgBankImageView addSubview:cardNumber];
    
    for (int i=0; i<numberArrayShow.count; i++) {
        if ([[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"]isEqualToString:[numberArray objectAtIndex:i]]) {
            [cardNumber.pickerView selectRow:i inComponent:0 animated:YES];
        }
    }
    
    UIButton *xiangCe = [UIButton buttonWithType:UIButtonTypeCustom];
    xiangCe.layer.cornerRadius = 3;
    xiangCe.layer.masksToBounds = YES;
    xiangCe.backgroundColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.00f alpha:1.00f];
    xiangCe.frame = CGRectMake(bgView.frame.size.width/2-120, BgBankImageView.frame.origin.y+BgBankImageView.frame.size.height+20, 100, 35);
    [xiangCe setTitle:@"保存到相册" forState:UIControlStateNormal];
    xiangCe.titleLabel.font = [UIFont systemFontOfSize:16];
    [xiangCe setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [xiangCe addTarget:self action:@selector(saveToPhotos) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:xiangCe];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.backgroundColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.00f alpha:1.00f];
    shareBtn.frame = CGRectMake(bgView.frame.size.width/2+20, BgBankImageView.frame.origin.y+BgBankImageView.frame.size.height+20, 90, 35);
    shareBtn.layer.cornerRadius = 3;
    shareBtn.layer.masksToBounds = YES;
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(sharedMessage) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:shareBtn];
    
}
#pragma 保存到相册
-(void)saveToPhotos
{
    UIImageWriteToSavedPhotosAlbum(saveViewImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = nil;
    if (error!=NULL)
        message = @"图片保存失败";
    else
        message = @"图片保存成功";
    UIAlertView *saveAlert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [saveAlert show];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"收款二维码";
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:userName.text,@"userName",[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MainAcNo"],@"cardNumber", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dicString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *dicStringDES = [CommonFunc base64StringFromTextDES:dicString];
    
    [Context setNSUserDefaults:dicStringDES keyStr:@"erWeiMa"];
    
    
    int qrcodeImageDimension = 250;//生成二维码
    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:dicStringDES];
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    imageView.image = qrcodeImage;
    
    UIGraphicsBeginImageContextWithOptions(BgBankImageView.bounds.size, BgBankImageView.opaque, [[UIScreen mainScreen] scale]);
    //截取需要保存的图片
    UIGraphicsBeginImageContext(BgBankImageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [BgBankImageView.layer renderInContext:context];
    saveViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}
-(void) myPickerView:(LWYTextField *)pickerView DidSlecetedAtRow:(int) row
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:userName.text,@"userName",numberArray[row],@"cardNumber", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dicString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *dicStringDES = [CommonFunc base64StringFromTextDES:dicString];
    [Context setNSUserDefaults:dicStringDES keyStr:@"erWeiMa"];
    
    int qrcodeImageDimension = 250;
    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:dicStringDES];
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    imageView.image = qrcodeImage;
}

-(void)sharedMessage
{
    NSData *imageData = UIImagePNGRepresentation(saveViewImage);
    NSString *string = [CommonFunc base64EncodedStringFrom:imageData];
    [Context setNSUserDefaults:string keyStr:@"saveViewImage"];

    NSLog(@"分享");
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"logout_weibo",@"img",
                           @"新浪微博",@"title",
                           @"0",@"flag",
                           @"sina",@"subtitle",
                           nil];
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
    NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"logout_qq",@"img",
                           @"腾讯QQ",@"title",
                           @"3",@"flag",
                           @"qq",@"subtitle",
                           nil];
    _buttonArray = [NSArray arrayWithObjects:dict1,dict2,dict3,dict4, nil];
    //初始化分享菜单，指定代理
    CSIIShareView *share = [CSIIShareView shareInstencesWithItems:_buttonArray];
    [CSIIShareView shareViewShow];
    share.delegate = self;
    
}

- (void)clickButton:(UIButton *)button withIndex:(NSInteger)index{
    //获取点击按钮的信息
    NSDictionary *dict = [_buttonArray objectAtIndex:index];
    NSLog(@"点击--->>>%@",[dict objectForKey:@"title"]);
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    if([[dict objectForKey:@"flag"] isEqualToString:@"0"]){
        //判断是否能用新浪客户端进行授权登录
        
        if([WeiboSDK isCanSSOInWeiboApp]){
            if(![CSIIShareHandle SinaWeiBoTokenIsInvalid]){
                CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
                //新闻信息
                WBMessageObject *messageObj = [handle messageToSinaShareWords:@"我的二维码" andImg:saveViewImage];
                //图文片信息
                //                WBMessageObject *messageObj = [handle messageToSinaShareWords:@"哈哈哈哈——————测试用得åå" andImg:[UIImage imageNamed:@"icon7"]];
                //文字信息
                //WBMessageObject *messageObj = [handle messageToSinaShareOnlyWords:@"仅仅是文字信息的发布。____测试。"];
                
                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObj authInfo:nil access_token:handle.SinaWBToken];
                [WeiboSDK sendRequest:request];
                
            }else{
                //通过新浪客户端做授权操作
                [handle SinaWeiBoLogin:nil];
                //[self sinaFinishLogin];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sinaFinishLogin) name:@"sinaClietFinishLogin" object:nil];
            }
        }
        else{
            //如不支持客户端分享，将使用自定义分享
            CSIISinaContentController *content = [[CSIISinaContentController alloc] init];
            content.erWeiMaImage = saveViewImage;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:content];
            [self presentViewController:nav animated:YES completion:nil];
            [CSIIShareView shareViewHide];
        }
        
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"1"]){
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            handle.WXScene = WXSceneSession;
            [handle messageToWeiXinNews:@"常乐生活" Description:@"常熟农商银行" content:nil Image:saveViewImage shareScene:WXSceneSession];
        }else{
            ShowAlertView(@"提示", @"您尚未安装微信客户端", nil, @"确认", nil);
        }
        
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"2"]){
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            handle.WXScene = WXSceneTimeline;
            [handle messageToWeiXinNews:@"常乐生活" Description:@"常熟农商银行" content:nil Image:saveViewImage  shareScene:WXSceneTimeline];
        }else{
            ShowAlertView(@"提示", @"您尚未安装微信客户端", nil, @"确认", nil);
        }
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"3"]){
        if ([QQApi isQQInstalled]) {
            if(![CSIIShareHandle TencentTokenIsInvalid]){
                [self TencentLoginSuccess];
            }else{
                [self TencentLoginSuccess];
                //授权
                //handle.tencentDelegate = self;
                //[handle TencentLogin];//腾讯登陆
            }
            
        }else{
            ShowAlertView(@"提示", @"您尚未安装腾讯QQ客户端", nil, @"确认", nil);
        }
    }else if ([[dict objectForKey:@"flag"] isEqualToString:@"4"]){
        handle.WXScene = WXSceneTimeline;
        [handle showSMSPicker:self];
    }
}

#pragma mark - 使用新浪客户端登录授权的通知
- (void)sinaFinishLogin{
    [self performSelector:@selector(sendSinaMessage) withObject:nil afterDelay:1.5];
}

- (void)sendSinaMessage{
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    WBMessageObject *messageObj = [handle messageToSinaShareWords:@"常熟农商银行-" andImg:[UIImage imageNamed:@"sns_icon_1.png"]];
    //文字信息
    //WBMessageObject *messageObj = [handle messageToSinaShareOnlyWords:@"仅仅是文字信息的发布。____测试。"];
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObj authInfo:nil access_token:handle.SinaWBToken];
    [WeiboSDK sendRequest:request];
}

#pragma mark - QQ好友分享，实现回调方便在第一次授权之后自动跳转到分享界面
- (void)TencentLoginSuccess{
    //    UIImage *image = [UIImage imageNamed:@"icon7"];
    NSData *imageData = UIImagePNGRepresentation(saveViewImage);
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    [handle messageToTencentNews:@"常乐生活" Description:@"常熟农商银行" PreviewImgData:imageData];
    
}

- (void)TencentNotNetWork{
    
}

- (void)TencentLoginFaield:(NSString *)errInfo{
    
}

- (void)TencentDidLogout{
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"erWeiMa"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
