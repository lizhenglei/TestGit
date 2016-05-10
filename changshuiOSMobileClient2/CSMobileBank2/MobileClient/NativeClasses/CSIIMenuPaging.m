//
//  CSIIContentPage.m
//  CsiiMobileBank
//
//  Created by 刘旺 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "CSIIMenuPaging.h"
#import "CSIIMenuViewController.h"
//icon宽
#define ICONIMG_WIDTH 95/2
//icon高
#define ICONIMG_HEIGHT 95/2
//icon与屏幕左边的间距
#define ICONIMG_LEVEL 26
//icon横向左右间隔
#define ICONIMG_LEVEL_SPACE 26
//icon之间上下间隔
#define ICONIMG_VERTICAL_SPACE 40//30//20
//icon与上方间距
#define ICONIMG_VERTICAL 20
//label宽
#define ICONTXT_WIDTH 95/2+25
//label高
#define ICONTXT_HEIGHT 35
//label与屏幕左边的间距
#define ICONTXT_LEVEL 10
//label横向左右间隔
#define ICONTXT_LEVEL_SPACE 3
//label与上方间距
#define ICONTXT_VERTICAL (ICONIMG_VERTICAL+ICONIMG_HEIGHT-2)
//灯 宽
#define ICONLIGHT_WIDTH 76
//灯 高
#define ICONLIGHT_HEIGHT 60
//灯横向间隔
#define ICONLIGHT_LEVEL_SPACE 0
//灯与左边的间距
#define ICONLIGHT_LEVEL 8
//灯之间上下间隔
#define ICONLIGHT_VERTICAL 18
//灯与上方间隔
//#define ICONLIGHT_VERTICAL_SPACE 29
#define ICONLIGHT_VERTICAL_SPACE 34

//#define PAGEICONNUM ((iPhone5)?16:12)

#define POINT_IMG_SELECT @"pagePoint1.png"
#define POINT_IMG_NORMAL @"pagePoint2.png"

#define IPad_Menu_Button_Width 112 //按钮宽
#define IPad_Menu_Button_Height 129 //按钮高
#define IPad_Menu_Left_Space 112 //左边按钮距离左边框长度
#define IPad_Menu_Top_Space 32 //顶部按钮距离顶部长度
#define IPad_Menu_GapV_Space 48 //按钮上下间隔
#define IPad_Menu_GapH_Space 32 //按钮左右间隔

#define IPad_Menu_ButtonLabel_Width 112 //按钮文字宽
#define IPad_Menu_ButtonLabel_Height 35 //按钮文字高

#import "Context.h"

@implementation CSIIMenuPagingScrollView
@synthesize scrollView = scrollView;

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame: frame];
	if (self != nil) {
		pageCGRect = frame;
		pageControlCGRect = CGRectMake(0, frame.size.height-8, frame.size.width,0);
		scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.bounces = NO;
		scrollView.pagingEnabled = YES;
		scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
		[self addSubview:scrollView];
		pageControl = [[UIPageControl alloc] initWithFrame: pageControlCGRect];
		[pageControl addTarget: self action: @selector(pageControlDidChange:) forControlEvents: UIControlEventValueChanged];
		[self addSubview: pageControl];
	}
	return self;
}

-(void)setPages:(NSMutableArray *)pagesObj {
	for(int i=0;i<[pages count];i++) {
		[[pages objectAtIndex: i] removeFromSuperview];
	}
	pages = pagesObj;
	scrollView.contentOffset = CGPointMake(0.0, 0.0);
    
        
    scrollView.contentSize = CGSizeMake(pageCGRect.size.width, ScreenHeight-20-44-51-271/2);
    
    scrollView.showsVerticalScrollIndicator = NO;

	pageControl.numberOfPages = [pages count];
	pageControl.currentPage = 0;
    
    for(int i=0;i<[pages count];i++) {
        UIImageView *pageIcon = [pageControl.subviews objectAtIndex:i];
        /* check for class type, in case of upcomming OS changes */
        if([pageIcon isKindOfClass:[UIImageView class]]) {
            if([pages count]>=2)
            {
                if(i==pageControl.currentPage) {
                    /* use the active image */
                    [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_SELECT ofType:nil]]];
                }
                else {
                    /* use the inactive image */
                    [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_NORMAL ofType:nil]]];
                }
            }
            else
            {
                [pageIcon setImage:nil];
            }
        }
    }
    if ([pages count] == 1) {
        pageControl.hidden = YES;
    }
	[self layoutViews];
}

- (void)layoutViews {
	for(int i=0;i<[pages count];i++) {
		UIView *page = [pages objectAtIndex: i];
		CGRect frame = CGRectMake(pageCGRect.size.width * i, 1.0, pageCGRect.size.width, pageCGRect.size.height+2000);  //+2000解决超过五行不能点击的问题
		page.frame = frame;
		[scrollView addSubview: page];
	}
}

-(id)getDelegate {
	return delegate;
}

- (void)setDelegate:(id)delegateObj {
	delegate = delegateObj;
}

-(NSMutableArray *)getPages {
	return pages;
}

-(void)setCurrentPage:(int)page {
	[scrollView setContentOffset: CGPointMake(pageCGRect.size.width * page, scrollView.contentOffset.y) animated: NO];
    pageControl.currentPage = page;
    
    for(int i=0;i<[pages count];i++) {
        UIImageView *pageIcon = [pageControl.subviews objectAtIndex:i];
        /* check for class type, in case of upcomming OS changes */
        if([pageIcon isKindOfClass:[UIImageView class]]) {
            if([pages count]>=2)
            {
                if(i==pageControl.currentPage) {
                    /* use the active image */
                    [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_SELECT ofType:nil]]];
                }
                else {
                    /* use the inactive image */
                    [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_NORMAL ofType:nil]]];
                }
            }
            else
            {
                [pageIcon setImage:nil];
            }
        }
    }
}

//-(int)getCurrentPage {
////	return (int) (scrollView.contentOffset.x / pageCGRect.size.width);
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControl.currentPage = self.currentPage;
    NSString *currentPage = [NSString stringWithFormat:@"%d",self.currentPage];
    [[NSUserDefaults standardUserDefaults] setObject:currentPage forKey:@"currentPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    for(int i=0;i<[pages count];i++) {
        UIImageView *pageIcon = [pageControl.subviews objectAtIndex:i];
        /* check for class type, in case of upcomming OS changes */
        if([pageIcon isKindOfClass:[UIImageView class]]) {
            if([pages count]>=2)
            {
                if(i==pageControl.currentPage) {
                    /* use the active image */
                    [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_SELECT ofType:nil]]];
                }
                else {
                    /* use the inactive image */
                    [pageIcon setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:POINT_IMG_NORMAL ofType:nil]]];
                }
            }
            else
            {
                [pageIcon setImage:nil];
            }
        }
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
}

-(void) pageControlDidChange: (id)sender
{
    UIPageControl *control = (UIPageControl *) sender;
    if (control == pageControl) {
		self.currentPage = (int)control.currentPage;
	}
}
@end



@implementation CSIIMenuPaging
@synthesize delegate,currentPage,delButton;
- (id)initWithFrame:(CGRect)frame WithIconArray:(NSMutableArray*)iconArray pageDelegate:(id)obj iconButtonArray:(NSMutableArray*)iconButtonArray iconLabelArray:(NSMutableArray*)iconLabelArray iconLightArray:(NSMutableArray *)iconLightArray
{
    
    if (iconArray.count == 0 || iconArray==nil) {
        return nil;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        NSMutableArray *iconImgCGRectArray = [[NSMutableArray alloc]init];
        
        NSInteger rowCount  =  (iconArray.count-1)/4+1;         //四个一排  计算行数
        
//        NSInteger rowCount  = 4; //现在最多有11个功能，暂时设置成4行,暂时没有解决方案
//        if (IPHONE) {
//            rowCount = ((NSInteger)(frame.size.height-ICONIMG_VERTICAL))/((NSInteger)(ICONIMG_HEIGHT+ICONIMG_VERTICAL_SPACE));
//        } else {
//            rowCount = ((NSInteger)(frame.size.height-IPad_Menu_Top_Space))/((NSInteger)(IPad_Menu_Button_Height+IPad_Menu_GapV_Space));
//        }
        
        
        if (IPHONE) {
            //手机
            if([Context iPhone5]){
                for (int i=0; i<rowCount; i++) {
                    for (int j=0;j<4; j++) {//更改每页有多少行、列图标。
                        [iconImgCGRectArray addObject:NSStringFromCGRect(CGRectMake(j*(ICONIMG_WIDTH+ICONIMG_LEVEL_SPACE)+ICONIMG_LEVEL, i*(ICONIMG_HEIGHT+ICONIMG_VERTICAL_SPACE)+ICONIMG_VERTICAL, ICONIMG_WIDTH, ICONIMG_HEIGHT))];
                    }
                }
                
            }else{
                for (int i=0; i<rowCount; i++) {
                    for (int j=0;j<4; j++) {//更改每页有多少行、列图标。
                        [iconImgCGRectArray addObject:NSStringFromCGRect(CGRectMake(j*(ICONIMG_WIDTH+ICONIMG_LEVEL_SPACE)+ICONIMG_LEVEL, i*(ICONIMG_HEIGHT+ICONIMG_VERTICAL_SPACE)+ICONIMG_VERTICAL, ICONIMG_WIDTH, ICONIMG_HEIGHT))];
                    }
                }
                
            }
        } else {
            //pad
            for (int i=0; i<rowCount; i++) {
                for (int j=0;j<4; j++) {//更改每页有多少行、列图标。
                    [iconImgCGRectArray addObject:NSStringFromCGRect(CGRectMake(j*(IPad_Menu_Button_Width+IPad_Menu_GapH_Space)+IPad_Menu_Left_Space, i*(IPad_Menu_Button_Height+IPad_Menu_GapV_Space)+IPad_Menu_Top_Space, IPad_Menu_Button_Width, IPad_Menu_Button_Height))];
                }
            }
            
        }
        
        
        NSMutableArray *iconLableCGRectArray = [[NSMutableArray alloc]init];
        if (IPHONE) {
            //手机
            if([Context iPhone5]){
                for (int i=0; i<rowCount; i++) {
                    for (int j=0;j<4; j++) {
                        [iconLableCGRectArray addObject:NSStringFromCGRect(CGRectMake(j*(ICONTXT_WIDTH+ICONTXT_LEVEL_SPACE)+ICONTXT_LEVEL, i*(ICONIMG_HEIGHT+ICONIMG_VERTICAL_SPACE)+ICONTXT_VERTICAL, ICONTXT_WIDTH, ICONTXT_HEIGHT))];
                    }
                }
            }else{
                for (int i=0; i<rowCount; i++) {
                    for (int j=0;j<4; j++) {
                        [iconLableCGRectArray addObject:NSStringFromCGRect(CGRectMake(j*(ICONTXT_WIDTH+ICONTXT_LEVEL_SPACE)+ICONTXT_LEVEL, i*(ICONIMG_HEIGHT+ICONIMG_VERTICAL_SPACE)+ICONTXT_VERTICAL, ICONTXT_WIDTH, ICONTXT_HEIGHT))];
                    }
                }
            }
        } else {
            //pad
            for (int i=0; i<rowCount; i++) {
                for (int j=0;j<4; j++) {
                    [iconLableCGRectArray addObject:NSStringFromCGRect(CGRectMake(j*(IPad_Menu_ButtonLabel_Width+IPad_Menu_GapH_Space)+IPad_Menu_Left_Space, i*(IPad_Menu_Button_Height+IPad_Menu_GapV_Space)+IPad_Menu_Top_Space+IPad_Menu_Button_Height, IPad_Menu_ButtonLabel_Width, IPad_Menu_ButtonLabel_Height))];
                }
            }
        }
        
        
        NSMutableArray *iconLightCGRectArray = [[NSMutableArray alloc]init];
        if([Context iPhone5]){
            for (int i=0; i<rowCount; i++) {
                for (int j=0;j<4; j++) {
                    [iconLightCGRectArray addObject:NSStringFromCGRect(CGRectMake(j*(ICONLIGHT_WIDTH+ICONLIGHT_LEVEL_SPACE)+ICONLIGHT_LEVEL_SPACE + ICONLIGHT_LEVEL, i*(ICONIMG_HEIGHT+ICONLIGHT_VERTICAL)+ICONLIGHT_VERTICAL_SPACE, ICONLIGHT_WIDTH, ICONLIGHT_HEIGHT))];
                }
            }
        }else{
            for (int i=0; i<rowCount; i++) {
                for (int j=0;j<4; j++) {
                    [iconLightCGRectArray addObject:NSStringFromCGRect(CGRectMake(j*(ICONLIGHT_WIDTH+ICONLIGHT_LEVEL_SPACE)+ICONLIGHT_LEVEL_SPACE + ICONLIGHT_LEVEL, i*(ICONIMG_HEIGHT+ICONLIGHT_VERTICAL)+ICONLIGHT_VERTICAL_SPACE, ICONLIGHT_WIDTH, ICONLIGHT_HEIGHT))];
                }
            }
        }
        
        int iconArrayCount = (int)[iconArray count];
        int pageIconNum = (int)rowCount*4; //= PAGEICONNUM
        int pageCount = 0;
        if(pageIconNum>0)
        {
            pageCount = iconArrayCount/pageIconNum;
            if (iconArrayCount%pageIconNum!=0) {
                pageCount+=1;
            }
        }
        int iconArrayIndex = 0;
        pages = [[NSMutableArray alloc]init];
        for (int i=0; i<pageCount; i++) {
            UIView *page = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
            page.userInteractionEnabled = YES;
            //page.bounds = [[UIScreen mainScreen]bounds];
            int pageIconCount=0;
            if (i==pageCount-1) {
                if (iconArrayCount!=pageIconNum) {
                    pageIconCount=iconArrayCount%pageIconNum;
                    if(pageIconCount==0){
                        pageIconCount=pageIconNum;
                    }
                }else{
                    pageIconCount=pageIconNum;
                }
            }else{
                pageIconCount=pageIconNum;
            }
            
            NSString *unZipPath = [Context unZipPath];//获取沙河路径
            
            for (int j=0; j<pageIconCount; j++) {
                UIImageView *light = [[UIImageView alloc]initWithFrame:CGRectFromString([iconLightCGRectArray objectAtIndex:j])];
                light.image = IMAGE(@"灯");
                
                UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectFromString([iconImgCGRectArray objectAtIndex:j])];
                menuButton.tag = iconArrayIndex;
                
                NSString* imageName = [[iconArray objectAtIndex:iconArrayIndex] objectForKey:@"ActionImage"];//换肤图片名字修改
//                if ([imageName isEqualToString:@"addiconsimg"]) {
////                    imageName = imageName;
//                }
//                else {     //第二套图标
//                }
                if ([UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.png",unZipPath,[MobileBankSession sharedInstance].changeSkinColor,imageName]]==nil) {
                            imageName = @"tsfwimg";
                }
                [menuButton setImage:[Context ImageName:imageName] forState:UIControlStateNormal];//换肤
                
                //加lable
                UIImageView *menuLabel = [[UIImageView alloc]initWithFrame:CGRectFromString([iconLableCGRectArray objectAtIndex:j])];
                //menuLabel.image = IMAGE(@"图标文字板");
                
                //                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ICONTXT_WIDTH, ICONTXT_HEIGHT)];
                UILabel *label = [[UILabel alloc]init];
                
                if (IPHONE) {
                    label.frame = CGRectMake(0, 0, ICONTXT_WIDTH, ICONTXT_HEIGHT);
                    [label setFont:[UIFont systemFontOfSize:14]];//fontWithName:@"Helvetica" size:12]];
                    
                } else {
                    label.frame = CGRectMake(0, 0, IPad_Menu_ButtonLabel_Width, IPad_Menu_ButtonLabel_Height);
                    [label setFont:[UIFont boldSystemFontOfSize:16]];//fontWithName:@"Helvetica" size:12]];
                    
                }
                label.text = [[iconArray objectAtIndex:iconArrayIndex] objectForKey:@"ActionName"];
                
                if(label.text!=nil && [[iconArray objectAtIndex:iconArrayIndex] objectForKey:@"ActionName"]!=[NSNull null] && label.text.length>6)
                {
                    if(IPHONE){
                        label.text = [label.text substringToIndex:6];
//                    label.text = [NSString stringWithFormat:@"%@...",label.text];
                    }
                    else
                        label.text = [label.text substringToIndex:7];
                }
                label.textAlignment = NSTextAlignmentCenter;
                label.lineBreakMode = NSLineBreakByTruncatingTail;
                label.backgroundColor = [UIColor clearColor];
                label.textColor=[UIColor blackColor];
                [menuLabel addSubview:label];
                
                //                if ((menuButton.tag == [iconArray count]-1)&&[[[iconArray objectAtIndex:0] objectForKey:@"ActionId"] isEqualToString:@"Calculator" ]) {
                if ([[[CSIIMenuViewController sharedInstance]getcurrentActionId] isEqualToString:ACTIONID_FOR_MYFAVOURITE] && menuButton.tag == ([iconArray count]-1) && [[[iconArray objectAtIndex:iconArrayIndex] objectForKey:@"ActionId"] isEqualToString:@"000000"]) {
                    [menuButton addTarget:obj action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                }else{
#pragma 菜单的点击事件
                    [menuButton addTarget:obj action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    
                if([[[CSIIMenuViewController sharedInstance]getcurrentActionId] isEqualToString:ACTIONID_FOR_MYFAVOURITE] && [[CSIIMenuViewController sharedInstance]isMyFavoriteFixedMenu:[iconArray objectAtIndex:iconArrayIndex]] == YES)
                    {//添加删除小图片
                        CGRect iconFrame = menuButton.frame;
                        delButton = [[UIButton alloc]initWithFrame:CGRectMake(iconFrame.size.width-20, 0, 20, 20)];
                        delButton.backgroundColor = [UIColor blackColor];
                        [delButton setImage:[UIImage imageNamed:@"menu_delete"] forState:UIControlStateNormal];
                        delButton.alpha = 0.5;
                        delButton.tag = menuButton.tag;
                        delButton.layer.cornerRadius = 10.0;
                        delButton.hidden = ![CSIIMenuViewController sharedInstance].isEdit;
                        delButton.layer.masksToBounds = YES;
                        [delButton addTarget:[CSIIMenuViewController sharedInstance] action:@selector(delButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                        [menuButton addSubview:delButton];
                    }
                    
                    
                    if([[[CSIIMenuViewController sharedInstance]getcurrentActionId] isEqualToString:ACTIONID_FOR_MYFAVOURITE])
                    {
                        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:obj action:@selector(longPressDelete:)];
                        [longPress setMinimumPressDuration:(CFTimeInterval)0.5];
                        longPress.delegate = obj;
                        [menuButton addGestureRecognizer:longPress];
                    }
                    
                }
                [iconLabelArray addObject:menuLabel];
                [iconButtonArray addObject:menuButton];
                [iconLightArray addObject:light];
//                
//                [page addSubview:[iconButtonArray objectAtIndex:iconArrayIndex]];
//                [page addSubview:[iconLabelArray objectAtIndex:iconArrayIndex]];
                [page addSubview:menuButton];
                [page addSubview:menuLabel];
                iconArrayIndex++;
            }
            [pages addObject:page];
        }
        _scrollView = [[CSIIMenuPagingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.userInteractionEnabled = YES;
        [self addSubview:_scrollView];
        _scrollView.pages = pages;
        _scrollView.delegate = self;
        //动画效果
//                if (![obj isEdit]) {
//                     [self animationMenuIcon];
//                }
    }
    return self;
}
-(void)animationMenuIcon
{
    CATransition *animation=[CATransition animation];
    animation.duration=0.5f;
    animation.timingFunction=UIViewAnimationCurveEaseInOut;
    
    animation.type=kCATransitionMoveIn;
    
    if([Context sharedInstance].cunAnimationID < [Context sharedInstance].preAnimationID)
    {
        animation.subtype=kCATransitionFromLeft;
    }else{
        animation.subtype=kCATransitionFromRight;
    }
    [Context sharedInstance].preAnimationID=[Context sharedInstance].cunAnimationID;
    
    [Context sharedInstance].firstFlage=NO;
    [self.layer addAnimation:animation forKey:@"ani"];
}
-(void)setCurrentPage:(int)pageIndex;
{
    if (pageIndex>=[pages count]) {
        [_scrollView setCurrentPage:(int)[pages count]-1];
    }else{
        [_scrollView setCurrentPage:pageIndex];
    }
    
    //    scrollView setCurrentPage:(int)
}
-(int)getCurrentPage;
{
    return _scrollView.currentPage;
}
@end
