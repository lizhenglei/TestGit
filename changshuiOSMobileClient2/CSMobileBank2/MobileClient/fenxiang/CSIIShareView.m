//
//  CSIIShareView.m
//
//  Created by 胡中楷 on 14-11-1.
//  Copyright (c) 2014年 胡中楷. All rights reserved.
//

#import "CSIIShareView.h"
#import "CSIIShareHandle.h"
//#import "CSIIAppDelegate.h"

#define numLine     4      //每行显示多少个图标
#define lineNum     2      //每个视图最多显示多少行
#define btnW        50.0f  //按钮宽度
#define btnH        50.0f  //按钮高度
#define lblHeight   20.0f  //lable高度
#define lblWithBtn  2.0f   //按钮跟lable间隔
#define SXjiange    7.0f   //整体上下间隔

static CSIIShareView *shareView = nil;

@interface CSIIShareView ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,ShareHandleTencentDelegate,CSIISinaAuthorViewControllerDelegate,WBHttpRequestDelegate>{
    
    UIView *viewGround;//黑色背景
    
    UIView *btnView;//分享视图
    
    //UIPageControl *pageControl;//分页控制器
    
    UIButton *btnSet;//设置按钮
    
    UITableView *_authorSetView;//授权设置图
    
    NSMutableArray *_needAuthorArray;//需要授权的分享
    
    UISwitch *_currentSwitch;
    
    CGFloat shareViewHeight;
    
    CGFloat shareScrolHeight;
    
    UILabel *lblTitle;
}

@end

@implementation CSIIShareView
@synthesize buttonArray;
#pragma mark - 初始化方法
+ (id)shareInstencesWithItems:(NSArray *)array{
    if(shareView == nil){
        shareView = [[self alloc] initWithFrame:CGRectMake(320, BOUNDS.size.height-380, 270, 280)];
        shareView.buttonArray = array;
    }
    //[shareView createViewForbuttonArray];
    return shareView;
}

+ (void)shareViewShow{
    [shareView createViewForbuttonArray];
}

+ (void)shareViewHide{
    [shareView handleTapHideShareView];
}

- (void)show{
    [self createViewForbuttonArray];
}

- (void)hide{
    [shareView handleTapHideShareView];
}

////////////////////////////////////////////分享视图/////////////////////////////////////
- (void)createViewForbuttonArray{
    viewGround = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewGround.backgroundColor = [UIColor blackColor];
//    viewGround.alpha = 1;
    [viewGround addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapHideShareView)]];
    UIWindow *windows = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [windows addSubview:viewGround];
    
    self.userInteractionEnabled = YES;
    shareViewHeight = lineNum * 70 + 70;
    shareScrolHeight = lineNum * 80;
    //分享到
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(-60, 0, 55, 25)];
    lblTitle.text = @"分享到";
    lblTitle.font = [UIFont systemFontOfSize:15.0f];
    lblTitle.textColor = [UIColor grayColor];
    lblTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:lblTitle];
    //处理设置界面显示的需要授权的项
    for (int i=0; i<buttonArray.count; i++) {
        if(_needAuthorArray == nil){
            _needAuthorArray = [[NSMutableArray alloc] initWithCapacity:0];
        }
        NSString *subtitle = [[buttonArray objectAtIndex:i] objectForKey:@"subtitle"];
        if([CSIIShareHandle ShareIsNeedAuthor:subtitle]){
            [_needAuthorArray addObject:[buttonArray objectAtIndex:i]];
        }
    }

    for (int i=0; i<buttonArray.count; i++) {
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(0, i*280/4, 270, 280/4);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 12, 76/2, 76/2)];
        imageView.image = [UIImage imageNamed:[[buttonArray objectAtIndex:i]objectForKey:@"img"]];
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(76/2+10, 15, 100, 30)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.text = [[buttonArray objectAtIndex:i] objectForKey:@"title"];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor whiteColor];
        [shareBtn addSubview:nameLabel];
        [shareBtn addSubview:imageView];
        shareBtn.backgroundColor = [UIColor clearColor];
        shareBtn.tag = i;
        [shareBtn addTarget:self action:@selector(clickBtnForContent:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:shareBtn];
    }
    
       self.backgroundColor = [UIColor clearColor];

    
    //弹出分享视图动画
    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2];
    viewGround.alpha = 0.8;
    self.frame = CGRectMake(ScreenWidth-180, BOUNDS.size.height-380, 270, 280);
    [UIView commitAnimations];
    
    [windows addSubview:self];
}

#pragma mark - 隐藏
- (void)handleTapHideShareView{
    [UIView beginAnimations:@"hideShare" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    viewGround.alpha = 0.0;
    self.frame = CGRectMake(320, BOUNDS.size.height-380, 270, 280);
    [UIView commitAnimations];
    [_needAuthorArray removeAllObjects];
    NSLog(@"___取消。");
}

#pragma mark - 点击不同分享按钮
- (void)clickBtnForContent:(UIButton *) btn{
    NSDictionary *dict = [buttonArray objectAtIndex:btn.tag];
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    handle.itemFlag = [dict objectForKey:@"flag"];
    [self.delegate clickButton:btn withIndex:btn.tag];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"___分享视图移除。");
    [viewGround removeFromSuperview];
    [_authorSetView removeFromSuperview];
    [btnView removeFromSuperview];
    [shareView removeFromSuperview];
    [lblTitle removeFromSuperview];
    [btnSet removeFromSuperview];
    
    viewGround = nil;
    _authorSetView = nil;
    btnView = nil;
    lblTitle = nil;
    btnSet = nil;
    _needAuthorArray = nil;
}



////////////////////////////////////////设置视图////////////////////////////////////////
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _needAuthorArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [NSString stringWithFormat:@"%ld %ld",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[[_needAuthorArray objectAtIndex:indexPath.row] objectForKey:@"img"]]];
        imgV.frame = CGRectMake(5, 7, 30, 30);
        cell.imageView.image = [UIImage imageNamed:@"cellBkImg.png"];
        [cell.imageView addSubview:imgV];
        cell.textLabel.text = [[_needAuthorArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *authorSwitch = [[UISwitch alloc] init];
        //TODO:7
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
            authorSwitch.frame = CGRectMake(250, 7, 40, 20);
        }else{
            authorSwitch.frame = CGRectMake(220, 7, 40, 20);
        }
        [authorSwitch addTarget:self action:@selector(openAuthor:) forControlEvents:UIControlEventValueChanged];
        if([CSIIShareHandle ShareSearchIsFinishAuthor:[[_needAuthorArray objectAtIndex:indexPath.row] objectForKey:@"subtitle"]]){
            authorSwitch.on = YES;
        }else{
            authorSwitch.on = NO;
        }
        [cell.contentView addSubview:authorSwitch];
        authorSwitch.tag = indexPath.row;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)openAuthor:(UISwitch *) open{
    NSDictionary *dict = [_needAuthorArray objectAtIndex:open.tag];
    _currentSwitch = open;
    if(!open.on){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:[NSString stringWithFormat:@"确认要关闭对【%@】的授权吗？",[dict objectForKey:@"title"]] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        [alert show];
    }else{
        CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
        //做授权操作
        if([[dict objectForKey:@"subtitle"] isEqualToString:@"qq"]){
            handle.tencentDelegate = self;
            handle.itemFlag = @"3";
            [handle TencentLogin];
        }else if ([[dict objectForKey:@"subtitle"] isEqualToString:@"sina"]){
            [CSIIShareView shareViewHide];
            handle.itemFlag = @"0";
            [handle SinaWeiBoLogin:self];
        }
    }
}

#pragma mark - UIAlertViewDelegate 授权取消操作
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        NSDictionary *dict = [_needAuthorArray objectAtIndex:_currentSwitch.tag];
        //做取消授权操作
        CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
        if([[dict objectForKey:@"subtitle"] isEqualToString:@"qq"]){
            handle.tencentDelegate = self;
            [handle.TCAuthor logout:handle];
        }else if ([[dict objectForKey:@"subtitle"] isEqualToString:@"sina"]){
            [WeiboSDK logOutWithToken:handle.SinaWBToken delegate:self withTag:@"Sinalogout"];
        }
    }else{
        _currentSwitch.on = YES;
    }
}

////////////////////////////////////////各个分享平台手动授权回调///////////////////////////////
#pragma mark - 腾讯手动授权 回调方法
- (void)TencentLoginFaield:(NSString *)errInfo{
    _currentSwitch.on = NO;
}

- (void)TencentLoginSuccess{
    _currentSwitch.on = YES;
}

- (void)TencentNotNetWork{
    _currentSwitch.on = NO;
}

#pragma mark - 腾讯QQ授权回收
- (void)TencentDidLogout{
    _currentSwitch.on = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"操作成功" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TCtoken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TCdate"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TCopenID"];
}
#if 0
#pragma mark - 新浪微博手动授权 回调方法
- (void)SinaAuthorViewDidFailAndErrorInfo:(NSDictionary *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:[error objectForKey:@"error"] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)SinaAuthorViewDidFinishAndAuthorInfo:(NSDictionary *)authorInfo{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"授权成功" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)SinaAuthorViewUserCancel{
    NSLog(@"___用户手动授权时取消。");
}

#pragma mark - 新浪微博授权回收 回调
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result{
    if([request.tag isEqualToString:@"Sinalogout"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"操作成功" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        _currentSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sinaToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sinaUserID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sinaTokenDate"];
    }
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error{
    if([request.tag isEqualToString:@"Sinalogout"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"请求失败" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        _currentSwitch.on = YES;
    }
}
#endif
@end
