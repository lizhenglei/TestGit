//
//  LWYGlobalVariable.h
//  MobileClient
//
//  Created by 李文友 on 14-3-26.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#ifndef MobileClient_LWYGlobalVariable_h
#define MobileClient_LWYGlobalVariable_h


#import "Config.h"
#import "Context.h"

#import "GlobalVariable.h"
#import "LWYTextField.h"
#import "MobileBankSession.h"

#define SCREEN_SIZE self.view.bounds.size //屏幕大小

//#define LBRect CGRectMake( 15, 2.5, 135, 40)//左边文本标签（加在背景imgV里）
#define rightLabelRect CGRectMake(120, 2.5, 175, 40)
#define rightLabelRect1 CGRectMake(95, 2.5, 190, 40)

#define mRTFRect CGRectMake(IMGV_X + 120,IMGV_Y - IMGV_H + 5,100,35)

#define rightTextfield CGRectMake(120, 2.5+5, 170, 35)

#define extentBottomLBRect CGRectMake( 20, 60, 80, 20)//左边文本标签（相对一般底部拓展背景）

#define SCRVL_OFFSET 8//于navigationBar底下的距离  当时设计有误，如果可以把导航栏的阴影在最后添加就没有那么多事了
#define SCRVL_SIZE CGSizeMake(320, 568*1.2) //这个貌似可以去掉没多大用


#define cellHight 55 //每一个条目背景图片的高度，于tableviewCell的高度类似

#define IMGV_ORIGIN_X 0 //x轴的偏移量
#define IMGV_ORIGIN_WIDTH 300 //宽度，若想动态居中，可以用：320 - IMGV_ORIGIN_X * 2
#define IMGV_ORIGIN_HEIGHT cellHight

//下一图片个背景
#define IMGV_W imageView.frame.size.width
#define IMGV_H imageView.frame.size.height
#define IMGV_X imageView.frame.origin.x
#define IMGV_Y imageView.frame.origin.y + IMGV_H
//下一图片个背景Rect
#define IMGVRect CGRectMake(IMGV_X, IMGV_Y, IMGV_W, IMGV_H)
//带紫色拓展的背景
#define EXTIMGVRect CGRectMake(IMGV_X, IMGV_Y, IMGV_W, 100)

//文本框右边
//#define TFRect CGRectMake(IMGV_X + 95,IMGV_Y - IMGV_H + 5,180,30)//长

//当时其实设了imgV的userInteraction就可以直接添加在imgV上了，这里添加在view或scrollView里了
//对应左边label的长度设置textfield不同的长度
#define rTFRect CGRectMake(IMGV_X + 120,IMGV_Y - IMGV_H + 5,170,35)//中
//#define TFRect rTFRect

#define TFRect1 CGRectMake(IMGV_X + 100,IMGV_Y - IMGV_H + 5,180,35)
#define TFRect2 CGRectMake(IMGV_X + 100,IMGV_Y - IMGV_H + 5,190,35)

#define mTFRect CGRectMake(IMGV_X + 125,IMGV_Y - IMGV_H + 5,100,35)
#define lTFRect CGRectMake(220,IMGV_Y - IMGV_H + 5,75,35)//每行最后一个

#define ShortTFRect CGRectMake(IMGV_X + 150,IMGV_Y - IMGV_H + 5,145,35)//短

//按钮对y轴的偏移量
#define BTN_Y IMGV_Y + 20
#define BTNRect CGRectMake(50,BTN_Y,220,40)

#define TWO_BTN1_Rect CGRectMake(25,BTN_Y-70 ,120,35)
#define TWO_BTN2_Rect CGRectMake(170,BTN_Y-70 ,120,35)

#define THREE_BTNS_Y BTN_Y + 30 + 25
#define THREE_BTN1_BELOW_BTN_Rect CGRectMake(15,THREE_BTNS_Y,80,30)
#define THREE_BTN2_BELOW_BTN_Rect CGRectMake(120,THREE_BTNS_Y,80,30)
#define THREE_BTN3_BELOW_BTN_Rect CGRectMake(225,THREE_BTNS_Y,80,30)


#define THREE_BTN1_Rect CGRectMake(35,IMGV_Y - 45,70,30)
#define THREE_BTN2_Rect CGRectMake(125,IMGV_Y - 45,70,30)
#define THREE_BTN3_Rect CGRectMake(215,IMGV_Y - 45,70,30)


#define BRIEF_LEFT_LBRect1 CGRectMake(15,5,80,20)
#define BRIEF_LEFT_LBRect2 CGRectMake(15,35,80,20)
#define BRIEF_LEFT_LBRect3 CGRectMake(15,65,80,20)
#define BRIEF_LEFT_LBRect4 CGRectMake(15,95,80,20)
#define BRIEF_LEFT_LBRect5 CGRectMake(15,125,80,20)


#define BRIEF_LEFT_LBRect11 CGRectMake(15,5+75/4,80,20)
#define BRIEF_LEFT_LBRect21 CGRectMake(15,35+75/4,80,20)
#define BRIEF_LEFT_LBRect31 CGRectMake(15,65+75/4,80,20)
#define BRIEF_LEFT_LBRect41 CGRectMake(15,95+75/4,80,20)
#define BRIEF_LEFT_LBRect51 CGRectMake(15,125+75/4,40+80,20)
#define BRIEF_LEFT_LBRect61 CGRectMake(15,155+75/4,80,20)



#define BRIEF_RIGHT_LBRect1 CGRectMake(80,5,170,20)
#define BRIEF_RIGHT_LBRect2 CGRectMake(100,35,150,20)
#define BRIEF_RIGHT_LBRect3 CGRectMake(100,65,150,20)
#define BRIEF_RIGHT_LBRect4 CGRectMake(100,95,150,20)
#define BRIEF_RIGHT_LBRect5 CGRectMake(100,125,150,20)


#define BRIEF_RIGHT_LBRect11 CGRectMake(100,5+75/4,150,20)
#define BRIEF_RIGHT_LBRect21 CGRectMake(100,35+75/4,150,20)
#define BRIEF_RIGHT_LBRect31 CGRectMake(100,65+75/4,150,20)
#define BRIEF_RIGHT_LBRect41 CGRectMake(100,95+75/4,150,20)
#define BRIEF_RIGHT_LBRect51 CGRectMake(100,125+75/4,150,20)
#define BRIEF_RIGHT_LBRect61 CGRectMake(100,155+75/4,150,20)

//tableViewCell DISCLOSURE_RIGHT 账户查询

#define BRIEF_DISCLOSURE_RIGHT CGRectMake(270, imageView.frame.size.height/2 - 10, 15, 20)
#define BRIEF_DISCLOSURE_RIGHTNEW CGRectMake(270, imageView.frame.size.height/2 - 10, 9, 13)

#define ICCARD_DISCLOSURE_RIGHT BRIEF_DISCLOSURE_RIGHT
#define ICCARD_DISCLOSURE_RIGHTNEW BRIEF_DISCLOSURE_RIGHTNEW


//#define setContentSCRV \
//self.contentSCRV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width, SCREEN_SIZE.height*1.5)];\
//self.contentSCRV.contentInset = UIEdgeInsetsMake(0, 0, 450, 0);\
//self.contentSCRV.scrollEnabled = YES;\
//self.contentSCRV.showsHorizontalScrollIndicator = NO;\
//self.contentSCRV.scrollEnabled = YES;\
//self.contentSCRV.contentSize = CGSizeMake(320, 480);


#endif

