//
//  GesturePasswordView.m
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

#import "GesturePasswordView.h"
#import "GesturePasswordButton.h"
#import "TentacleView.h"
@implementation GesturePasswordView {
    NSMutableArray * buttonArray;
    
    CGPoint lineStartPoint;
    CGPoint lineEndPoint;
    
    NSMutableArray*buttonTag;
}
@synthesize imgView;
@synthesize forgetButton;
@synthesize changeButton;

@synthesize tentacleView;
@synthesize state;
@synthesize gesturePasswordDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage*img = [UIImage imageNamed:@"login_bg"];
        UIImageView*bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bg.image = img;
        bg.backgroundColor = [UIColor clearColor];
        [self addSubview:bg];
        
        bg.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        
        buttonArray = [[NSMutableArray alloc]initWithCapacity:0];
        
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/2-160, frame.size.height/2-80, 320, 320)];
        for (int i=0; i<9; i++) {
            NSInteger row = i/3;
            NSInteger col = i%3;
            // Button Frame
            
            NSInteger distance = 320/3-10;
            NSInteger size = distance/1.5;
            NSInteger margin = size/4;
            GesturePasswordButton * gesturePasswordButton = [[GesturePasswordButton alloc]initWithFrame:CGRectMake(col*distance+margin+16, row*distance-10, size, size)];
            [gesturePasswordButton setTag:i];
            [view addSubview:gesturePasswordButton];
            [buttonArray addObject:gesturePasswordButton];
        }
        frame.origin.y=0;
        [self addSubview:view];
        tentacleView = [[TentacleView alloc]initWithFrame:CGRectMake(frame.size.width/2-159, frame.size.height/2-88, 320, 320)];
        [tentacleView setButtonArray:buttonArray];
        tentacleView.backgroundColor = [UIColor clearColor];
        [tentacleView setTouchBeginDelegate:self];
        [self addSubview:tentacleView];
        
        state = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2-140, frame.size.height/2-140, 280, 30)];
        [state setTextAlignment:NSTextAlignmentCenter];
        [state setFont:[UIFont systemFontOfSize:14.f]];
        state.text = @"请输入手势密码";
        [state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];

        [self addSubview:state];
        
        
        _imgViewLogo = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2-35, frame.size.width/2-([Context iPhone4]?130
                                                                                                               :100), 70, 70)];
        _imgViewLogo.image = [UIImage imageNamed:@"login_logo"];
        _imgViewLogo.backgroundColor = [UIColor clearColor];
        [self addSubview:_imgViewLogo];
        
        
        imgView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2-30, frame.size.width/2-([Context iPhone4]?130
                                                               :100), 50, 50)];
        [imgView setBackgroundColor:[UIColor colorWithRed:0.11f green:0.37f blue:0.63f alpha:1.00f]];
        [imgView.layer setBorderColor:[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:0.50f].CGColor];
        [imgView.layer setCornerRadius:4];
        [imgView.layer setBorderWidth:0.2];
        [self addSubview:imgView];
        
        buttonTag = [[NSMutableArray alloc]init];
        
        for (int x=0; x<9; x++) {
            UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(6.5+x%3*14.5, 6.5+x/3*14.5, 8, 8);
            btn.backgroundColor = [UIColor colorWithRed:0.67f green:0.67f blue:0.67f alpha:1.00f];
            btn.tag = x;
            [buttonTag addObject:btn];
            [imgView addSubview:btn];
        }
        
        forgetButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2-150,ScreenHeight-40, 120, 30)];
        [forgetButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [forgetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [forgetButton setTitle:@"取消       " forState:UIControlStateNormal];
        [forgetButton addTarget:self action:@selector(hidden) forControlEvents:UIControlEventTouchDown];
        [self addSubview:forgetButton];
        
        changeButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2+30, ScreenHeight-40, 120, 30)];
        [changeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [changeButton setTitle:@"其他方式登录" forState:UIControlStateNormal];
        [changeButton addTarget:self action:@selector(changeLoginFlag) forControlEvents:UIControlEventTouchDown];
        [self addSubview:changeButton];
    }
    
    return self;
}


-(void)initHeaderView:(NSString*)passResult{
    
    for (int x=0; x<passResult.length; x++) {
        NSRange range = NSMakeRange(x,1);
        UIButton*btn = [buttonTag objectAtIndex:[[passResult substringWithRange:range]intValue]];
        btn.backgroundColor = [UIColor colorWithRed:0.89f green:0.87f blue:0.16f alpha:1.00f];
    }
}

-(void)resetHeaderView{

    for (int x = 0; x<buttonTag.count; x++) {
        UIButton*btn = [buttonTag objectAtIndex:x];
        btn.backgroundColor = [UIColor colorWithRed:0.67f green:0.67f blue:0.67f alpha:1.00f];
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] =
    {
        134 / 255.0, 157 / 255.0, 147 / 255.0, 1.00,
        3 / 255.0,  3 / 255.0, 37 / 255.0, 1.00,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents
    (rgb, colors, NULL, sizeof(colors)/(sizeof(colors[1])*4));
    CGColorSpaceRelease(rgb);
    CGContextDrawLinearGradient(context, gradient,CGPointMake
                                (0.0,0.0) ,CGPointMake(0.0,self.frame.size.height),
                                kCGGradientDrawsBeforeStartLocation);
}

- (void)gestureTouchBegin {
    state.text = @"请输入手势密码";
    [state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
}

-(void)hidden{
    [gesturePasswordDelegate hiddenLoginAlert];
}

-(void)changeLoginFlag{
    [gesturePasswordDelegate changeLoginFlag];
}


@end
