//
//  GesturePasswordButton.m
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

#import "GesturePasswordButton.h"

#define bounds self.bounds

@implementation GesturePasswordButton
@synthesize selected;
@synthesize success;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        success=YES;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage*img = [UIImage imageNamed:@"GestureSec"];//小黄圆点
    _SecimgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, img.size.width*0.85, img.size.height*0.85)];
    _SecimgView.image = img;
    _SecimgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_SecimgView];
    
    if (selected) {
        _SecimgView.hidden = NO;

        
        if (success) {
            CGContextSetRGBStrokeColor(context, 2/255.f, 174/255.f, 240/255.f,1);//线条颜色
            CGContextSetRGBFillColor(context,2/255.f, 174/255.f, 240/255.f,1);
        }
//        else {
//            CGContextSetRGBStrokeColor(context, 208/255.f, 36/255.f, 36/255.f,1);//线条颜色
//            CGContextSetRGBFillColor(context,208/255.f, 36/255.f, 36/255.f,1);
//        }
//        CGRect frame = CGRectMake(bounds.size.width/2-bounds.size.width/8+3.5, bounds.size.height/2-bounds.size.height/8+2, bounds.size.width/4, bounds.size.height/4);
//        
//        CGContextAddEllipseInRect(context,frame);
//        CGContextFillPath(context);
    }
    else{
        _SecimgView.hidden = YES;
        CGContextSetRGBStrokeColor(context, 0.09,0.54,0.96,1.00);//线条颜色         //边框颜色
    }
    
    CGContextSetLineWidth(context,1);                            //边框宽度
    CGRect frame = CGRectMake(5, 5, bounds.size.width-10, bounds.size.height-10);   //大按钮的坐标和大小
    CGContextAddEllipseInRect(context,frame);
    CGContextStrokePath(context);
    
    if (success) {
        CGContextSetRGBFillColor(context,30/255.f, 175/255.f, 235/255.f,0.3);
    }
    else {
        CGContextSetRGBFillColor(context,0.01f, 0.28f, 0.55f,1.00f);
    }
    CGContextAddEllipseInRect(context,frame);
    if (selected) {
        CGContextFillPath(context);
    }else{
        CGContextSetRGBFillColor(context,0.01f, 0.28f, 0.55f,1.00f);
        CGContextFillPath(context);
    }
    
}


@end
