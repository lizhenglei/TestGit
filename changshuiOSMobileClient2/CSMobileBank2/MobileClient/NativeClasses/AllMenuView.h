//
//  AllMenuView.h
//  MobileClient
//
//  Created by 杨楠 on 14-8-14.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>

//用于显示私人定制的添加菜单
@interface AllMenuView : UIScrollView

@property (nonatomic, strong)NSMutableArray* favouriteMenu;

- (id)initWithFrame:(CGRect)frame withItems:(NSArray *)items favourites:(NSMutableArray *)favourites defaultMenu:(NSArray *)defaultMenu;

@end
