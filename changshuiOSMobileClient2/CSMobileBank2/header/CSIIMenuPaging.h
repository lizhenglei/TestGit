//
//  CSIIContentPage.h
//  CsiiMobileBank
//
//  Created by 刘旺 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalVariable.h"

@interface CSIIMenuPagingScrollView : UIView <UIScrollViewDelegate> {
	UIScrollView *scrollView;
	UIPageControl *pageControl;
	
	CGRect pageCGRect, pageControlCGRect;
	NSMutableArray *pages;
	id delegate;
    
}
-(void)layoutViews;

@property(nonatomic,assign,getter=getPages)       NSMutableArray * pages;		 /* UIView Subclases */
@property(nonatomic,assign,getter=getCurrentPage) int currentPage;
@property(nonatomic,assign,getter=getDelegate)    id delegate;     /* PageScrollViewDelegate */
@property(nonatomic,strong)UIScrollView*scrollView;
@end

#define IPHONE ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)


@interface CSIIMenuPaging : UIImageView{
    NSMutableArray *pages;
	
    NSTimer *timer;
    id delegate;
    int currentPage;
    int iconNum;//动画标示
    
}

@property(nonatomic,strong) CSIIMenuPagingScrollView *scrollView;
@property(nonatomic,retain) id delegate;
@property(nonatomic,assign,setter = setCurrentPage:,getter = getCurrentPage) int currentPage;
@property(nonatomic,strong)UIButton *delButton;

- (id)initWithFrame:(CGRect)frame WithIconArray:(NSMutableArray*)iconArray pageDelegate:(id)obj iconButtonArray:(NSMutableArray*)iconButtonArray iconLabelArray:(NSMutableArray*)iconLabelArray iconLightArray:(NSMutableArray*) iconLightArray;
@end


