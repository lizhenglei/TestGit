//
//  PiontStoreViewController.h
//  MobileClient
//
//  Created by 李正雷 on 15/7/20.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "CSIISuperViewController.h"

@interface PiontStoreViewController : CSIISuperViewController
@property(nonatomic,strong)NSString *webViewName;
@property(nonatomic,strong)NSString *webViewUrl;

@property(nonatomic,strong)NSString *webShareText;
@property(nonatomic,strong)NSString *webShareUrl;
@property(nonatomic,strong)NSString *webShareTitle;

@property(nonatomic,assign)BOOL adverWeb;//将广告的和菜单的分开了

+(PiontStoreViewController*)sharedInstance;

@end
