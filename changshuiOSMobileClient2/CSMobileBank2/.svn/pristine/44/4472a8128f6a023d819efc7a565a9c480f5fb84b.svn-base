//
//  CSIIUIToolBar.m
//  iPhoneTZBankClient
//
//  Created by 刘旺 on 11-8-7.
//  Copyright (c) 2011年 科蓝公司. All rights reserved.
//

#import "CSIIUIToolBar.h"
#import "CSIISuperViewController.h" //属性被存放在基类中，取得对象的时候将基类加入避免编译提示错误
#import "LWYTextField.h"
#import "SingleClass.h"
@implementation CSIIUIToolbar
//@synthesize delegate,segmentedControl1s,doneDelegate;

-(id)init{
    
    self = [super initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds] .size.width, 44)];
    if(self!=nil){
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if (IOS7_OR_LATER)
        {
            self.barStyle = UIBarStyleDefault;
            self.translucent = YES;
            //self.alpha = 1;
        }
#else
        self.barStyle = UIBarStyleBlack;
        self.translucent = YES;
        //self.alpha = 1;
#endif
        
        NSMutableArray *buttons = [[NSMutableArray alloc]init];
        
        NSArray *buttonNames = [NSArray arrayWithObjects:@"前一项", @"后一项", nil];
        UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
        segmentedControl.momentary = YES;    //设置在点击后是否恢复原样
        segmentedControl.multipleTouchEnabled=NO;     //可触摸
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [segmentedControl addTarget:self action:@selector(indexControlAction:) forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *myButtonss = [[UIBarButtonItem alloc]initWithCustomView:segmentedControl];
        
        [buttons addObject:myButtonss];
        
        UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [buttons addObject:flexibleSpace1];
        
        NSArray *myButtons = [NSArray arrayWithObjects:@"回到今天", nil];
        self.segmentedControl1s = [[UISegmentedControl alloc] initWithItems:myButtons];
        self.segmentedControl1s.momentary = YES;    //设置在点击后是否恢复原样
        self.segmentedControl1s.multipleTouchEnabled=NO;     //可触摸
        self.segmentedControl1s.segmentedControlStyle = UISegmentedControlStyleBar;
        [self.segmentedControl1s addTarget:self action:@selector(setToday) forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *myttonsss = [[UIBarButtonItem alloc]initWithCustomView:_segmentedControl1s];
        [buttons addObject:myttonsss];
        self.segmentedControl1s.hidden = YES;
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [buttons addObject:flexibleSpace];
        UIButton *doneButton = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-50, 7, 45, 30)];
        [doneButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"done.png" ofType:nil]] forState:UIControlStateNormal];
        [doneButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"done_h.png" ofType:nil]] forState:UIControlStateHighlighted];
        doneButton.tag = 99999;
        [doneButton addTarget:self action:@selector(hiddenKeyboardAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        
        [self setItems:buttons];
    }
    return self;
}

-(void)setToday;
{
    if ([self.delegate respondsToSelector:@selector(setToday)])
        [self.delegate setToday];
}

-(void)hiddenKeyboardAction:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(DoneClick)]) {
        [self.delegate DoneClick];
    }
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        if ([MobileBankSession sharedInstance].isRightViewControllerDone == YES) {
            
            rect = CGRectMake(0.0f, 0.0f, [[[self.delegate delegate] view]frame].size.width, [[[self.delegate delegate] view]frame].size.height);
        }else{
            
            if ([self.delegate class]  == [CustomAlertView class]) {
                rect = CGRectMake(0.0f, 64.0f, [[self.delegate  view]frame].size.width, [[self.delegate  view]frame].size.height);
                
            }else{
                
                rect = CGRectMake(0.0f, 64.0f, [[[self.delegate delegate] view]frame].size.width, [[[self.delegate delegate] view]frame].size.height);
            }
        }
    }
    else
#endif
    {
        if ([self.delegate class]  == [CustomAlertView class]) {
            rect = CGRectMake(0.0f, 0.0f, [[self.delegate  view]frame].size.width, [[self.delegate  view]frame].size.height);
            
        }else{
            rect = CGRectMake(0.0f, 0.0f, [[[self.delegate delegate] view]frame].size.width, [[[self.delegate delegate] view]frame].size.height);
        }
    }
    if ([self.delegate class]  == [CustomAlertView class]) {
        [[self.delegate  view]setFrame:rect];
        
    }else{
        [[[self.delegate delegate] view]setFrame:rect];
    }
    
    [UIView commitAnimations];
    [self.delegate resignFirstResponder];
    //    if ([[self.delegate class] isSubclassOfClass:[UITextField class]]) {
    //        UITextField* textField = (UITextField *)self.delegate;
    //        [textField resignFirstResponder];
    //    }
}

-(void)indexControlAction:(id) sender
{
    
    SingleClass *single = [SingleClass shareClass];
    
    
    
    //    if ([[self.delegate delegate] isKindOfClass:[RightViewController class]]) {
    //
    //        [[self.delegate delegate] setInputControls:single.inputControls];
    //    }
    
    //    if ([[self.delegate delegate] isKindOfClass:[RegistTableViewController class]]) {
    //
    //        [[self.delegate delegate] setInputControls:single.inputControls];
    //    }
    
    if ([[[self.delegate delegate] inputControls] count]==1) {
        return;
    }
    
    
    
    int preIndex=0;
    int nexIndex=0; //为什么不用取余？
    
    //如果是被动登录框
    if ([[self.delegate superview] tag] == 333) {
        //        [self.delegate setInputControls:single.inputControls];
        
        for (int i = 0; i<[single.inputControls count]; i++) {
            
            if (i==0) {
                
                preIndex = 1;
                nexIndex = 0;
                
            }else {
                preIndex = 0;
                nexIndex = 1;
                
            }
        }
    }
    
    //非被动登录框
    for (int i = 0; i<[[[self.delegate delegate] inputControls] count]; i++) {
        
        if ([[[self.delegate delegate] inputControls] objectAtIndex:i] == self.delegate) {
            
            if (i==0) {
                
                preIndex = (int)[[[self.delegate delegate] inputControls] count]-1;
                nexIndex = i+1;
                
            }else if(i == [[[self.delegate delegate] inputControls] count]-1){
                
                preIndex = i-1;
                nexIndex = 0;
                
            }else{
                
                preIndex = i-1;
                nexIndex = i+1;
                
            }
        }
    }
    
    switch([sender selectedSegmentIndex]){
            
        case 0:
            
            [self.delegate resignFirstResponder];
            if ([[self.delegate superview] tag] == 333) {
                static int l = 0;
                l++;
                if (l != 1) {
                    preIndex = l%2;
                }
                if ([[[single inputControls] objectAtIndex:preIndex] isFirstResponder] && preIndex == 1) {
                    preIndex = 1;
                }
                if ([[[single inputControls] objectAtIndex:preIndex] isFirstResponder] && preIndex == 0) {
                    preIndex = 0;
                }
                [[[single inputControls] objectAtIndex:preIndex] becomeFirstResponder];
            }else{
                [[[[self.delegate delegate] inputControls]objectAtIndex:preIndex] becomeFirstResponder];
            }
            break;
            
        case 1:
            
            [self.delegate resignFirstResponder];
            if ([[self.delegate superview] tag] == 333) {
                static int m = 0;
                m++;
                if (m != 1) {
                    nexIndex = m%2;
                }
                
                if ([[[single inputControls] objectAtIndex:nexIndex] isFirstResponder] && nexIndex == 1) {
                    nexIndex = 0;
                }
                if ([[[single inputControls] objectAtIndex:nexIndex] isFirstResponder] && nexIndex == 0) {
                    nexIndex = 1;
                }
                
                [[[single inputControls] objectAtIndex:nexIndex] becomeFirstResponder];
            }else{
                [[[[self.delegate delegate] inputControls]objectAtIndex:nexIndex] becomeFirstResponder];
                
            }
            break;
            
        default:
            break;
    }
    
}


@end
