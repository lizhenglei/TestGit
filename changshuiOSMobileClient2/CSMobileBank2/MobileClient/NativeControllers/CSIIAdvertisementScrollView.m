//
//  CSIIAdvertisementScrollView.m
//  MobileClient
//
//  Created by 李正雷 on 15/9/15.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "CSIIAdvertisementScrollView.h"

@implementation CSIIAdvertisementScrollView


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _AdscrollView = [[UIScrollView alloc]initWithFrame:self.frame];
        [self addSubview:_AdscrollView];
        pageCGRect = self.frame;
        _AdscrollView.showsHorizontalScrollIndicator = NO;
        _AdscrollView.showsVerticalScrollIndicator = NO;
        _AdscrollView.delegate = self;
        _AdscrollView.pagingEnabled = YES;
        _AdscrollView.bounces = NO;
        pageControlCGRect = CGRectMake(0, self.frame.size.height-20, self.frame.size.width,20);

        pageControl = [ [ UIPageControl alloc ] initWithFrame: pageControlCGRect ];
//        [ pageControl addTarget: self action: @selector(pageControlDidChange:) forControlEvents: UIControlEventValueChanged ];
        if(IOS7_OR_LATER){
            [pageControl setPageIndicatorTintColor:[UIColor grayColor]];
            [pageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
        }
        [ self addSubview: pageControl ];
    }
    return self;
}
-(void)setPages:(NSMutableArray *)pages
{
    for(int i=0;i<[_pages count];i++) {
        [ [ pages objectAtIndex: i ] removeFromSuperview ];
    }
    _pages = pages;
    _AdscrollView.contentOffset = CGPointMake(0.0, 0.0);
    _AdscrollView.contentSize = CGSizeMake(pageCGRect.size.width * [ _pages count ], pageCGRect.size.height);
    pageControl.numberOfPages = [ _pages count ];
    pageControl.tag = 100;
    pageControl.currentPage = 0;
    
    for(int i=0;i<[_pages count];i++) {
        UIImageView *pageIcon = [pageControl.subviews objectAtIndex:i];
        /* check for class type, in case of upcomming OS changes */
        if([pageIcon isKindOfClass:[UIImageView class]]) {
//            if(i==pageControl.currentPage) {
//                /* use the active image */
//                [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_SELECTHD ofType:nil]]];
//            }
//            else {
//                /* use the inactive image */
//                [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_NORMALHD ofType:nil]]];
//            }
        }
    }
    
    [ self layoutViews ];
}
- (void)layoutViews {
    for(int i=0;i<[ _pages count];i++) {
        UIView *page = [ _pages objectAtIndex: i ];
        CGRect bounds = page.bounds;
        CGRect frame = CGRectMake(pageCGRect.size.width * i, 0.0, pageCGRect.size.width, pageCGRect.size.height);
        page.frame = frame;
        page.bounds = bounds;
        [ _AdscrollView addSubview: page ];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(changePage) userInfo:nil repeats:YES];
}
-(int)getCurrentPage {
    return (int) (_AdscrollView.contentOffset.x / pageCGRect.size.width);
}

-(void)changePage;
{
    if ((_AdscrollView.contentOffset.x/self.frame.size.width+1)<=[_pages count]-1) {
        [self setCurrentPage:(_AdscrollView.contentOffset.x/self.frame.size.width+1)];
    }else {
        [self setCurrentPage:0];
    }
}
-(void)setCurrentPage:(int)page {
    [ _AdscrollView setContentOffset: CGPointMake(pageCGRect.size.width * page, _AdscrollView.contentOffset.y) animated: YES ];
    pageControl.currentPage = page;
//    for(int i=0;i<[_pages count];i++) {
//        UIImageView *pageIcon = [pageControl.subviews objectAtIndex:i];
        /* check for class type, in case of upcomming OS changes */
//        if([pageIcon isKindOfClass:[UIImageView class]]) {
//            if(i==pageControl.currentPage) {
//                /* use the active image */
//                [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_SELECTHD ofType:nil]]];
//            }
//            else {
//                /* use the inactive image */
//                [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_NORMALHD ofType:nil]]];
//            }
//        }
//    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int a = scrollView.contentOffset.x/self.frame.size.width;
    UIPageControl *cccc = (UIPageControl *)[self viewWithTag:100];
    cccc.currentPage = a;
//    if (a==_pages.count-1) {
//        [_AdscrollView setContentOffset:CGPointMake(0, _AdscrollView.contentOffset.y)];
//        pageControl.currentPage = 0;
//    }
//    if (a==0) {
//        [_AdscrollView setContentOffset:CGPointMake(_pages.count*pageCGRect.size.width, _AdscrollView.contentOffset.y)];
//        pageControl.currentPage = _pages.count-1;
//    }
}
@end
