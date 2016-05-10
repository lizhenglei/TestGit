//
//  ReSetPasswordViewController.h
//  MobileClient
//
//  Created by 李正雷 on 15/5/11.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "CSIISuperViewController.h"

#define ShowAlertView(T,M,D,BT,OBT) UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:T message:M delegate:D cancelButtonTitle:BT otherButtonTitles:OBT, nil];[alertView show];
#define ISPRINTLOG YES

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
@interface ReSetPasswordViewController : CSIISuperViewController
@property(nonatomic,strong)NSMutableDictionary*postDic;
@end
