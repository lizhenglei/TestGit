//
//  CSIIUIToolBar.h
//  iPhoneTZBankClient
//
//  Created by 刘旺 on 11-8-7.
//  Copyright (c) 2011年 科蓝公司. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CSIISuperViewController.h" //属性被存放在基类中，取得对象的时候将基类加入避免编译提示错误
//#import "CSIIUIToolbarDelegate.h"

@protocol CSIIUIToolbarViewDelegate <NSObject>

- (UIView *)view;
@property (strong,nonatomic) NSMutableArray *inputControls;

@end

@protocol CSIIUIToolbarDelegate <UIToolbarDelegate>

@optional

@property (nonatomic, assign) id<CSIIUIToolbarViewDelegate> delegate;
@property(nonatomic,readonly) UIView       *superview;

-(void)DoneClick;
-(void)setToday;
- (UIView *)view;
- (BOOL)resignFirstResponder;

@end

@interface CSIIUIToolbar : UIToolbar
//{
//    @private
//    id <CSIIUIToolbarDelegate>delegate;
//    UISegmentedControl* segmentedControl1s;
//    id<UIToolbarDoneDelegate>doneDelegate;
//}
@property (nonatomic, assign) id<CSIIUIToolbarDelegate> delegate;
//@property (nonatomic, retain) id doneDelegate;
@property (nonatomic, strong) UISegmentedControl* segmentedControl1s;
-(void)hiddenKeyboardAction:(id)sender;
-(void)indexControlAction:(id) sender;

@end
