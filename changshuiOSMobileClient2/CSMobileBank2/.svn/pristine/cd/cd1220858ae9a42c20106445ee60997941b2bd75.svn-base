//
//  AllMenuView.m
//  MobileClient
//
//  Created by 杨楠 on 14-8-14.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "AllMenuView.h"
#import "NSString+Substring.h"
#import "MenuButton.h"
#import "CSIILabel.h"
//#import <Foundation/Foundation.h>

@interface AllMenuView ()
{
    NSInteger _columnCount; //每行显示的个数
    float _columnSpace; //二级图标横向间隔
    float _rowSpace; //二级图标纵向间隔
    //NSMutableArray* _favouriteMenu;
    //NSString* _favouriteKey;
    NSArray* _defaultMenu;
    BOOL _useDefault;
    NSMutableArray* _favouriteTitle;
    NSInteger _iconKey;
}
@end

@implementation AllMenuView

- (id)initWithFrame:(CGRect)frame withItems:(NSArray *)items favourites:(NSMutableArray *)favourites defaultMenu:(NSArray *)defaultMenu
{
    self = [super initWithFrame:frame];
    if (self) {
        _columnCount = 4;
        //_rowSpace = self.frame.size.width / 4;// + 5;
        _rowSpace = 61;
        _columnSpace = 80;
        //self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        _favouriteMenu = favourites;
        if (!_favouriteMenu) {
            _favouriteMenu = [[NSMutableArray alloc]init];
            _useDefault = YES;
        } else {
            _useDefault = NO;
            _favouriteTitle = [[NSMutableArray alloc]init];
            for (NSDictionary* dict in _favouriteMenu) {
                [_favouriteTitle addObject:dict[@"ActionImage"]];
            }
        }
        _defaultMenu = defaultMenu;
        _iconKey = [[NSUserDefaults standardUserDefaults] integerForKey:@"SkinSelectKey"];
        _iconKey = _iconKey / 3;
        
        NSMutableArray* singleItems = [[NSMutableArray alloc]init]; //仅有一个菜单，归于其它中
        //跳过第1个“私人定制”菜单
        [self setBackgroundColor:[UIColor clearColor]];
        NSInteger titleCount= 0;
        NSInteger height = 0;
        
        CGRect lastRect = CGRectNull;
        int i = 0;
        for (i = 1; i < items.count; i++) {
            NSArray* oneList = (items[i])[@"MenuList"];
            
            for (int j = 0; j < oneList.count; j++) {
                NSDictionary* oneDict = oneList[j];
                NSArray* twoList = oneDict[@"MenuList"];
                
                NSString*threeStr = @"";       //用来记录三级菜单不为空的actionName
                if (twoList.count > 0) {
                    
                    for (int f = 0; f < twoList.count; f++) {
                        NSDictionary* twoDict = twoList[f];
                        NSArray* threeList = twoDict[@"MenuList"];
                        
                        if (threeList.count>0) {
                            threeStr = oneDict[@"ActionName"];
                            UIView* oneView = [self createOneMenu:titleCount title:twoDict[@"ActionName"] items:threeList];
                            CGRect rect;
                            if (!CGRectIsNull(lastRect)) {
                                rect = CGRectMake(lastRect.origin.x, lastRect.origin.y + lastRect.size.height, oneView.frame.size.width, oneView.frame.size.height);
                            } else {
                                rect = oneView.frame;
                            }
                            UIView* background = [[UIView alloc]initWithFrame:rect];
                            background.backgroundColor = [UIColor clearColor];
                            [background addSubview:oneView];
                            [self addSubview:background];
                            titleCount++;
                            lastRect = background.frame;
                            height += background.frame.size.height;
                        }
                    }
                    if ([oneDict[@"ActionName"] isEqualToString:threeStr]) {
                        
                    }else{
                        UIView* oneView = [self createOneMenu:titleCount title:oneDict[@"ActionName"] items:twoList];
                        CGRect rect;
                        if (!CGRectIsNull(lastRect)) {
                            rect = CGRectMake(lastRect.origin.x, lastRect.origin.y + lastRect.size.height, oneView.frame.size.width, oneView.frame.size.height);
                        } else {
                            rect = oneView.frame;
                        }
                        UIView* background = [[UIView alloc]initWithFrame:rect];
                        background.backgroundColor = [UIColor clearColor];
                        [background addSubview:oneView];
                        [self addSubview:background];
                        titleCount++;
                        lastRect = background.frame;
                        height += background.frame.size.height;
                    }}
                else {
                    [singleItems addObject:oneDict];
                }
            }
        }
        UIView* oneView = [self createOneMenu:titleCount title:@"其它" items:singleItems];
        CGRect rect = CGRectMake(lastRect.origin.x, lastRect.origin.y + lastRect.size.height, oneView.frame.size.width, oneView.frame.size.height);
        UIView* background = [[UIView alloc]initWithFrame:rect];
        background.backgroundColor = [UIColor clearColor];
        [background addSubview:oneView];
        [self addSubview:background];
        titleCount++;
        lastRect = background.frame;
        height += background.frame.size.height;
        self.contentSize = CGSizeMake(frame.size.width, height);
    }
    return self;
}

- (UIView *)createOneMenu:(NSInteger)index title:(NSString *)title items:(NSArray *)items {
    UILabel* oneTitle = [[CSIILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    //    oneTitle.font = [UIFont systemFontOfSize:14];
    oneTitle.textColor = [UIColor colorWithHue:1.0 saturation:0.63 brightness:0.85 alpha:1.0];
    oneTitle.text = title;
    NSInteger count = items.count;
    NSInteger rowCount = [self getRowCount:count];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, oneTitle.frame.size.height + 2, self.frame.size.width, 1)];
    line.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.87 alpha:1.0];
    
    UIView* icons = [[UIView alloc]initWithFrame:CGRectMake(0, line.frame.origin.y + line.frame.size.height + 4, self.frame.size.width, 81 * rowCount)];
    UIView* background = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, icons.frame.origin.y + icons.frame.size.height)];
    
    [background addSubview:oneTitle];
    [background addSubview:line];
    
    for (int i = 0; i < count; i++) {
        NSInteger row = i % 4;
        NSInteger column = i / 4;
        NSDictionary* dict = items[i];
        NSString* buttonTitle = dict[@"ActionName"];
        NSString* buttonImage = dict[@"ActionImage"];
        MenuButton* button = [[MenuButton alloc]initWithFrame:CGRectMake(62 * row, 81 * column, 62, 81) title:buttonTitle imageName:buttonImage iconKey:_iconKey];
        //        button.backgroundColor = [UIColor blueColor];
        button.info = dict;
        if (_useDefault && [buttonImage isEqualToItem:_defaultMenu]) {
            [_favouriteMenu addObject:dict];
            button.selected = YES;
        } else if ([buttonImage isEqualToItem:_favouriteTitle]) {
            button.selected = YES;
        }
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [icons addSubview:button];
    }
    [background addSubview:icons];
    
    //    background.backgroundColor = [UIColor greenColor];
    //    oneTitle.backgroundColor = [UIColor redColor];
    //    line.backgroundColor = [UIColor yellowColor];
    //    icons.backgroundColor = [UIColor brownColor];
    
    return background;
}

- (NSInteger)getRowCount:(NSInteger)count {
    NSInteger row = count % _columnCount;
    if (row == 0) {
        return count / _columnCount;
    } else {
        row = (_columnCount - row + count) / _columnCount;
        return row;
    }
}

- (void)buttonAction:(MenuButton *)sender {
    BOOL selected = sender.selected;
    if (selected) {
        [_favouriteMenu removeObject:sender.info];
    } else {
        [_favouriteMenu addObject:sender.info];
    }
    sender.selected = !selected;
}

@end
