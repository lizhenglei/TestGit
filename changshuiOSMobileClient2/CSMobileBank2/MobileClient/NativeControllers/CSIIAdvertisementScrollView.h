//
//  CSIIAdvertisementScrollView.h
//  MobileClient
//
//  Created by 李正雷 on 15/9/15.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CSIIAdvertisementScrollView : UIView <UIScrollViewDelegate>
{
    UIPageControl *pageControl;
    CGRect pageCGRect, pageControlCGRect;
    NSTimer *_timer;
}
@property(nonatomic,strong)NSMutableArray *pages;
@property(nonatomic,assign,getter=getCurrentPage) int currentPage;

@property(nonatomic,strong)UIScrollView *AdscrollView;
@end
