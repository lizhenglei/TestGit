//
//  myCommentViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15/5/13.
//  Copyright (c) 2015年 pro. All rights reserved.

#import "myCommentViewController.h"
#import "CWStarRateView.h"
#import "CustomAlertView.h"

#define kMaxLength 100//评论内容,限制100字
@interface myCommentViewController ()<CWStarRateViewDelegate,UITextViewDelegate,UIAlertViewDelegate,CustomAlertViewDelegate>
{
    UITextView *commentTextView;//评论内容,限制100字
    int AspectScore,SmoothScore,ComplitionScore;//三个评价的分数
    BOOL isComment;
    UILabel *hintsLabel;
    UIScrollView *bgView;
    UIButton *bgBtn;//加这个背景按钮是因为在5s的一天手机上返回到主页会弹一下键盘
}
@end

@implementation myCommentViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)name:@"UITextViewTextDidChangeNotification" object:commentTextView];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isComment = NO;
    [self initSubViews];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"CifValucateQry.do" actionParams:nil method:@"POST"]; //查询是否已经评价
    
}

-(void)initSubViews{
    //    bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-78-64)];
    bgView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-78-64)];
    bgView.contentSize = CGSizeMake(ScreenWidth-20, ScreenHeight-50);
    bgView.bounces = NO;
    bgView.showsVerticalScrollIndicator = NO;
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    UILabel *commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 100, 20)];
    commentLabel.font = [UIFont systemFontOfSize:14];
    commentLabel.text = @"认真评个分";
    commentLabel.textColor = [UIColor colorWithRed:0.95f green:0.53f blue:0.00f alpha:1.00f];;
    [bgView addSubview:commentLabel];
    NSArray *startTextArray = @[@"页面美观",@"交易流畅",@"功能齐全"];
    for (int i=0; i<startTextArray.count; i++) {
        UILabel *startLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,40+i%3*30, 80, 25)];
        startLabel.text = [startTextArray objectAtIndex:i];
        [bgView addSubview:startLabel];
        CWStarRateView *startView = [[CWStarRateView alloc]initWithFrame:CGRectMake(startLabel.frame.size.width+startLabel.frame.origin.x+10, 40+i%3*30, 150, 20) numberOfStars:5];
        startView.scorePercent = 0;
        startView.delegate =self;
        startView.tag = i+100;
        startView.allowIncompleteStar = NO;
        startView.hasAnimation = YES;
        [bgView addSubview:startView];
    }
    
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(20, 40+startTextArray.count*30, 200, 50)];
    label.numberOfLines = 0;
    label.text = @"随便吐个槽";
    label.textColor = [UIColor colorWithRed:0.95f green:0.53f blue:0.00f alpha:1.00f];
    label.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:label];
    commentTextView = [[UITextView alloc]initWithFrame:CGRectMake(20, label.frame.size.height+label.frame.origin.y-10, bgView.frame.size.width-40, 130)];
    commentTextView.layer.cornerRadius = 8;
    commentTextView.layer.masksToBounds = YES;
    commentTextView.layer.borderWidth = 1.0f;
    commentTextView.delegate = self;
    commentTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    commentTextView.font = [UIFont systemFontOfSize:13];
    //    commentTextField.borderStyle = UITextBorderStyleRoundedRect;
    [bgView addSubview:commentTextView];
    
    hintsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 160, 20)];
    hintsLabel.text = @"输入内容不超过100字";
    hintsLabel.font = [UIFont systemFontOfSize:13];
    hintsLabel.backgroundColor = [UIColor clearColor];
    hintsLabel.enabled = NO;
    [commentTextView addSubview:hintsLabel];
    
    
    
    UIButton *finishCommentBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    finishCommentBtn.frame = CGRectMake(20, commentTextView.frame.size.height+commentTextView.frame.origin.y+10, bgView.frame.size.width-40, 30);
    finishCommentBtn.backgroundColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.00f alpha:1.00f];
    [finishCommentBtn setTitle:@"提交" forState:UIControlStateNormal];
    finishCommentBtn.layer.cornerRadius = 3;
    finishCommentBtn.layer.masksToBounds = YES;
    [finishCommentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishCommentBtn addTarget:self action:@selector(finishComment) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:finishCommentBtn];
    
    UIImageView *hintsImageView = [self addDefaultHints:@" 您可以通过多方面对我行手机银行进行评价和吐槽。" FromY:finishCommentBtn.frame.origin.y+40  FromX:10];
    hintsImageView.backgroundColor = [UIColor clearColor];
    [bgView addSubview:hintsImageView];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [self.view endEditing:YES];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    bgView.frame = CGRectMake(10, 10,ScreenWidth-20, ScreenHeight-72-64);
    [UIView commitAnimations];
}
-(void)finishComment
{
    //    [self.view endEditing:YES];
    //        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:commentTextView.text,@"Content", nil];
    //   [dic setObject:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"CifNo"] forKey:@"CifNo"];
    
    //    if (!isComment) {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSString stringWithFormat:@"%d",ComplitionScore] forKey:@"Complition"];
    [dic setObject:commentTextView.text forKey:@"Content"];
    [dic setObject:[NSString stringWithFormat:@"%d",AspectScore] forKey:@"Aspect"];
    [dic setObject:[NSString stringWithFormat:@"%d",SmoothScore] forKey:@"Smooth"];
    
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"CifValucateSet.do" actionParams:dic method:@"POST"];
    //    }else{
    //        [[MobileBankSession sharedInstance]postToServer:@"CifCommentSet.do" actionParams:dic method:@"POST"];
    //    }
}
#pragma CWStarRateViewDelegate
- (void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent
{//每颗星0.2分
    NSLog(@"%f",newScorePercent);
    if (starRateView.tag == 100){
        AspectScore = newScorePercent*10/2;
    }
    if (starRateView.tag == 101) {
        SmoothScore = newScorePercent*10/2;
    }
    if (starRateView.tag == 102) {
        ComplitionScore = newScorePercent*10/2;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideKeyboard];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"我要吐槽";
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [commentTextView resignFirstResponder];
    bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgBtn.frame = self.view.bounds;
    bgBtn.backgroundColor = [UIColor clearColor];
    [bgBtn addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bgBtn];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    bgView.frame = CGRectMake(10, -90,ScreenWidth-20, ScreenHeight-72-64);
    [UIView commitAnimations];
    return YES;
}
-(void)hideKeyboard
{
    [commentTextView resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    bgView.frame = CGRectMake(10, 10,ScreenWidth-20, ScreenHeight-72-64);
    [UIView commitAnimations];
    [bgBtn removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    NSString*message;
    if ( [action isEqualToString:@"CifValucateQry.do"]) {
        if ([[data objectForKey:@"_RejCode"] isEqualToString:@"000000"]){
            
            if ([[data objectForKey:@"CifPInfo"] isKindOfClass:[NSString class]]){     //isEqualToString:@""]) {
                return;
            }
            //            isComment = YES;
            AspectScore = [[[data objectForKey:@"CifPInfo"]objectForKey:@"Aspect" ] intValue];
            SmoothScore = [[[data objectForKey:@"CifPInfo"]objectForKey:@"Smooth" ] intValue];
            ComplitionScore = [[[data objectForKey:@"CifPInfo"]objectForKey:@"Complition" ] intValue];
            
            CWStarRateView *asp = (CWStarRateView *)[self.view viewWithTag:100];
            asp.scorePercent = (CGFloat)AspectScore/5;
            //            [asp removeGestureRecognizer:asp.gestureTap];
            CWStarRateView *smo = (CWStarRateView *)[self.view viewWithTag:101];
            smo.scorePercent = (CGFloat)SmoothScore/5;
            //            [smo removeGestureRecognizer:smo.gestureTap];
            CWStarRateView *com = (CWStarRateView *)[self.view viewWithTag:102];
            com.scorePercent = (CGFloat)ComplitionScore/5;
            //            [com removeGestureRecognizer:com.gestureTap];
            
        }else{
            
        }
    }
    
    if ([action isEqualToString:@"CifValucateSet.do"]){//评论
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            message =@"评价成功";
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
            [commentTextView resignFirstResponder];
            //            isComment = YES;
        }else{
            message = @"评价失败";
            ShowAlertView(@"提示", message, nil, @"确认", nil);
            return;
        }
    }
    //    if ([action isEqualToString:@"CifCommentSet.do"]) {//吐槽
    //        if ([[data objectForKey:@"_RejCode"] isEqualToString:@"000000"]) {
    //            ShowAlertView(@"提示", @"吐槽成功", nil, @"确定", nil);
    //        }else{
    //            ShowAlertView(@"提示", @"吐槽失败", nil, @"确定", nil);
    //        }
    //    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
//    hintsLabel.text =  textView.text;
    if (textView.text.length == 0) {
        hintsLabel.text = @"输入内容不超过100字";
    }else{
        hintsLabel.text = @"";
    }
}
-(void)textFiledEditChanged:(NSNotification *)obj{//限制搜索关键字个数100个
    
    
    UITextView *textField = (UITextView *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
