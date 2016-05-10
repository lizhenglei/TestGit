//
//  TYMActivityIndicatorView.m
//  TYMActivityIndicatorView
//
//  Created by Yiming Tang on 14-2-9.
//  Copyright (c) 2014 Yiming Tang. All rights reserved.
//

#import "TYMActivityIndicatorView.h"

@interface TYMActivityIndicatorView ()
{
    NSTimer *timer;
    int count;
}
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation TYMActivityIndicatorView

#pragma mark - Accessors

@synthesize animating = _animating;
@synthesize indicatorImage = _indicatorImage;
@synthesize backgroundImage = _backgroundImage;
@synthesize indicatorImageView = _indicatorImageView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize hidesWhenStopped = _hidesWhenStopped;
@synthesize fullRotationDuration = _fullRotationDuration;
@synthesize progress = _progress;
@synthesize minProgressUnit = _minProgressUnit;
@synthesize activityIndicatorViewStyle = _activityIndicatorViewStyle;

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _backgroundImageView;
}


- (UIImageView *)indicatorImageView
{
    if (!_indicatorImageView) {
        _indicatorImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _indicatorImageView;
}


- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = _backgroundImage;
    [self setNeedsLayout];
}


- (void)setIndicatorImage:(UIImage *)indicatorImage
{
    _indicatorImage = indicatorImage;
    self.indicatorImageView.image = _indicatorImage;
    [self setNeedsLayout];
}


- (void)setActivityIndicatorViewStyle:(TYMActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    NSString *backgroundImageName;
    NSString *indicatorImageName;
    switch (_activityIndicatorViewStyle) {
        case TYMActivityIndicatorViewStyleNormal:
            backgroundImageName = @"loading1";
            indicatorImageName = @"";
            break;
        case TYMActivityIndicatorViewStyleLarge:
            backgroundImageName = @"Loadbackground-large";
            indicatorImageName = @"Loadspinner-large";
            break;
    }
    
    _backgroundImage = [UIImage imageNamed:backgroundImageName];
    _indicatorImage = [UIImage imageNamed:indicatorImageName];
    self.backgroundImageView.image = _backgroundImage;
    self.indicatorImageView.image = _indicatorImage;
    [self setNeedsLayout];
}


- (BOOL)isAnimating
{
    return self.animating;
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}


- (id)initWithActivityIndicatorStyle:(TYMActivityIndicatorViewStyle)style
{
    if ((self = [self initWithFrame:CGRectZero])) {
        self.activityIndicatorViewStyle = style;
        [self sizeToFit];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
//    CGSize backgroundImageSize = self.backgroundImageView.image.size;
    CGSize indicatorImageSize = self.indicatorImageView.image.size;
    
    // Center
    if (IOS7_OR_LATER) {
        self.backgroundImageView.frame = CGRectMake(ScreenWidth/2-60, ScreenHeight/2-60, 120, 120);
    }else{
        self.backgroundImageView.frame = CGRectMake(ScreenWidth/2-40, ScreenHeight/2-40, 80, 80);
        
    }    self.indicatorImageView.frame = CGRectMake(roundf((size.width - indicatorImageSize.width) / 2.0f), roundf((size.height - indicatorImageSize.height) / 2.0f), indicatorImageSize.width, indicatorImageSize.height);
}


- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize backgroundImageSize = self.backgroundImageView.image.size;
    CGSize indicatorImageSize = self.indicatorImageView.image.size;
    
    return CGSizeMake(fmaxf(backgroundImageSize.width, indicatorImageSize.width), fmaxf(backgroundImageSize.height, indicatorImageSize.height));
}


#pragma mark - Public

- (void)startAnimating
{
    if (self.animating) return;
    
    self.animating = YES;
    self.hidden = NO;
    count = 1;
    timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(Changeimg:) userInfo:nil repeats:YES];
    [[NSRunLoop  currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    [self _rotateImageViewFrom:0.0f to:M_PI*2 duration:self.fullRotationDuration repeatCount:HUGE_VALF];
}

-(void)Changeimg:(NSTimer*)timer{//遮罩图片
    
    if (count<7) {
        count++;
        NSString*imgName = [NSString stringWithFormat:@"loading%d",count];
        self.backgroundImageView.image = [UIImage imageNamed:imgName];
    }else{
        count=1;
        NSString*imgName = [NSString stringWithFormat:@"loading%d",count];
        self.backgroundImageView.image = [UIImage imageNamed:imgName];
    }
}

- (void)stopAnimating
{
    if (!self.animating) return;
    
    self.animating = NO;
    
    [timer invalidate];
    
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}


- (void)setProgress:(CGFloat)progress
{
    if (progress < 0.0f || progress > 1.0f) return;
    if (fabsf(_progress - progress) < self.minProgressUnit) return;
    
    CGFloat fromValue = M_PI * 2 * _progress;
    CGFloat toValue = M_PI * 2 * progress;
    [self _rotateImageViewFrom:fromValue to:toValue duration:0.15f repeatCount:0];
    
    _progress = progress;
}

- (void)setShowTimeOut:(NSTimeInterval)interval {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromSuperview) object:nil];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:interval];
}


#pragma mark - Private

- (void)_initialize
{
    self.userInteractionEnabled = NO;
    
    _animating = NO;
    _hidesWhenStopped = YES;
    _fullRotationDuration = 1.0f;
    _minProgressUnit = 0.01f;
    _progress = 0.0f;
    self.backgroundColor = [UIColor colorWithRed:0.00f green:0.00f blue:0.00f alpha:0.50f];
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.indicatorImageView];
}


- (void)_rotateImageViewFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(CFTimeInterval)duration repeatCount:(CGFloat)repeatCount
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromValue];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toValue];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = repeatCount;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.indicatorImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

@end
