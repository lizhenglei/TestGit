//
//  SearchViewController.h
//  MobileClient
//
//  Created by xiaoxin on 15/4/23.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "CSIISuperViewController.h"

@interface SearchViewController : CSIISuperViewController
@property(nonatomic,retain)UITextField*searchTextfield;
@property(nonatomic,retain)UIButton*searchBtn;
@property(nonatomic,retain)NSMutableArray*displayMenuArray;
@end
