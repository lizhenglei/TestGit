//
//  DoActionSheet.m
//  TestActionSheet
//
//  Created by Donobono on 2014. 01. 01..
//

#import "DoActionSheet.h"

#pragma mark - DoAlertViewController

@interface DoActionSheetController : UIViewController

@property (nonatomic, strong) DoActionSheet *actionSheet;
@end

@implementation DoActionSheetController

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = _actionSheet;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [UIApplication sharedApplication].statusBarStyle;
}

@end

@interface DoActionSheet ()

{
    CGFloat _fromLocationW;
    CGFloat _fromLocationJ;
    CGFloat _toLocationW;
    CGFloat _toLocationJ;
}
@end

@implementation DoActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
           }
    return self;
}
- (instancetype)initWithFromLocation:(CGFloat )fromLocationW and:(CGFloat)fromLocationJ toLocation:(CGFloat)toLocationW and:(CGFloat)toLocationJ
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        _nDestructiveIndex = -1;
        _fromLocationW = fromLocationW;
        _fromLocationJ = fromLocationJ;
        _toLocationW = toLocationW;
        _toLocationJ = toLocationJ;
    }
    return self;
}
// with cancel button and other buttons
- (void)showC:(NSString *)strTitle
       cancel:(NSString *)strCancel
      buttons:(NSArray *)aButtons
       result:(DoActionSheetHandler)result
{
    _strTitle   = strTitle;
    _strCancel  = strCancel;
    _aButtons   = aButtons;
    _result     = result;
    
    [self showActionSheet];
}

// with cancel button and other buttons, without title
- (void)showC:(NSString *)strCancel
      buttons:(NSArray *)aButtons
       result:(DoActionSheetHandler)result
{
    _strTitle   = nil;
    _strCancel  = strCancel;
    _aButtons   = aButtons;
    _result     = result;
    
    [self showActionSheet];
}

// with only buttons
- (void)show:(NSString *)strTitle
     buttons:(NSArray *)aButtons
      result:(DoActionSheetHandler)result
{
    _strTitle   = strTitle;
    _strCancel  = nil;
    _aButtons   = aButtons;
    _result     = result;
    
    [self showActionSheet];
}

// with only buttons, without title
- (void)show:(NSArray *)aButtons
      result:(DoActionSheetHandler)result
{
    _strTitle   = nil;
    _strCancel  = nil;
    _aButtons   = aButtons;
    _result     = result;
    
    [self showActionSheet];
}

- (double)getTextHeight:(UILabel *)lbText
{
    NSDictionary *attributes = @{NSFontAttributeName:lbText.font};
    CGRect rect = [lbText.text boundingRectWithSize:CGSizeMake(lbText.frame.size.width, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil];
    
    return ceil(rect.size.height);
}

- (void)setLabelAttributes:(UILabel *)lb
{
    lb.backgroundColor = [UIColor clearColor];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.numberOfLines = 0;
    
    lb.font = DO_TITLE_FONT;
    lb.textColor = DO_TITLE_TEXT_COLOR;
}

- (void)setButtonAttributes:(UIButton *)bt cancel:(BOOL)bCancel
{
    bt.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    if (bCancel)
    {
        bt.backgroundColor = [UIColor whiteColor];
        [bt setBackgroundImage:[UIImage imageNamed:@"ActionSheetBG"] forState:UIControlStateNormal];
        bt.titleLabel.font = DO_TITLE_FONT;
//        bt.titleLabel.textColor = DO_CANCEL_TEXT_COLOR;
        [bt setTitleColor:DO_CANCEL_TEXT_COLOR forState:UIControlStateNormal];
    }
    else
    {
        bt.backgroundColor = [UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f];
        [bt setBackgroundImage:[UIImage imageNamed:@"ActionSheetBG"] forState:UIControlStateNormal];
        bt.titleLabel.font = DO_BUTTON_FONT;
//        bt.titleLabel.textColor = DO_BUTTON_TEXT_COLOR;
        [bt setTitleColor:DO_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
//        for (int i=0; i<_aButtons.count; i++) {
//            bt.tag = i;
//        }
    }
    if (_dButtonRound > 0)
    {
        CALayer *layer = [bt layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:_dButtonRound];
    }

    [bt addTarget:self action:@selector(buttonTarget:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showActionSheet
{
    double dHeight = 0;
    self.backgroundColor = DO_DIMMED_COLOR;  //整个背景图

    // make back view -----------------------------------------------------------------------------------------------
    _vActionSheet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];  //底部背景图
    _vActionSheet.backgroundColor = [UIColor grayColor];//DO_BACK_COLOR;
    [self addSubview:_vActionSheet];
    
    // Title --------------------------------------------------------------------------------------------------------
    if (_strTitle != nil && _strTitle.length > 0)
    {//不需要标题
//        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(DO_TITLE_INSET.left, DO_TITLE_INSET.top,
//                                                                     _vActionSheet.frame.size.width - (DO_TITLE_INSET.left + DO_TITLE_INSET.right) , 0)];
//        lbTitle.text = _strTitle;
//        [self setLabelAttributes:lbTitle];
//        lbTitle.frame = CGRectMake(DO_TITLE_INSET.left, DO_TITLE_INSET.top, lbTitle.frame.size.width, [self getTextHeight:lbTitle]);
//        lbTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [_vActionSheet addSubview:lbTitle];
//        
//        dHeight = lbTitle.frame.size.height + DO_TITLE_INSET.bottom;
//        
//        // underline
//        UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(lbTitle.frame.origin.x, lbTitle.frame.origin.y + lbTitle.frame.size.height - 3, lbTitle.frame.size.width, 0.5)];
//        vLine.backgroundColor = DO_TITLE_TEXT_COLOR;
//        vLine.alpha = 0.2;
//        vLine.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//        [_vActionSheet addSubview:vLine];
    }
    else
        dHeight += DO_TITLE_INSET.bottom;

    // add scrollview for many buttons and content
    UIScrollView *sc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, dHeight + DO_BUTTON_INSET.top, 320, 370)];
    sc.backgroundColor = [UIColor clearColor];
    [_vActionSheet addSubview:sc];
    sc.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    double dYContent = 0;

    dYContent += [self addContent:sc];
    if (dYContent > 0)
        dYContent += DO_BUTTON_INSET.bottom + DO_BUTTON_INSET.top;

    // add buttons
    int nTagIndex = 0;
    for (NSString *str in _aButtons)
    {
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        bt.tag = nTagIndex;
        [bt setTitle:str forState:UIControlStateNormal];
        
        [self setButtonAttributes:bt cancel:NO];
        
        bt.frame = CGRectMake(ScreenWidth/2-614/4, dYContent+10,614/2, DO_BUTTON_HEIGHT);  //功能按钮坐标  上边的两个
        
        dYContent += DO_BUTTON_HEIGHT + 10;
        
        [sc addSubview:bt];
        
        if (nTagIndex == _nDestructiveIndex)
            bt.backgroundColor = DO_DESTRUCTIVE_COLOR;

        nTagIndex += 1;
   }
    
    sc.contentSize = CGSizeMake(sc.frame.size.width, dYContent);
    dHeight += DO_BUTTON_INSET.bottom + MIN(dYContent, sc.frame.size.height);
    
    // add Cancel button
    if (_strCancel != nil && _strCancel.length > 0)
    {
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        bt.tag = DO_CANCEL_TAG;
        [bt setTitle:_strCancel forState:UIControlStateNormal];
        
        [self setButtonAttributes:bt cancel:YES];
        bt.frame = CGRectMake(ScreenWidth/2-614/4, dHeight + DO_BUTTON_INSET.top + DO_BUTTON_INSET.bottom,      //返回菜单按钮坐标
                              614/2, DO_BUTTON_HEIGHT);
        
        dHeight += DO_BUTTON_HEIGHT + (DO_BUTTON_INSET.top + DO_BUTTON_INSET.bottom) * 2;
        
        [_vActionSheet addSubview:bt];
    }
    else
        dHeight += DO_BUTTON_INSET.bottom;
    
    _vActionSheet.frame = CGRectMake(0, 0, _vActionSheet.frame.size.width, dHeight + 51);

    DoActionSheetController *viewController = [[DoActionSheetController alloc] initWithNibName:nil bundle:nil];
    viewController.actionSheet = self;
    
    if (!_actionWindow)
    {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelAlert;
        window.rootViewController = viewController;
        _actionWindow = window;
        
        self.frame = window.frame;
        _vActionSheet.center = window.center;
    }
    [_actionWindow makeKeyAndVisible];
    
    if (_dRound > 0)
    {
        CALayer *layer = [_vActionSheet layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:_dRound];
    }

    [self showAnimation];
}

- (void)buttonTarget:(UIButton *)sender
{
    
    if (sender.tag ==0) {
        NSLog(@"百度地图");
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]) {
            
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:终点&mode=driving",_fromLocationW, _fromLocationJ,_toLocationW,_toLocationJ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
            
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
            [self hideAnimation];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您没有安装百度地图，请先安装百度地图" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    else if (sender.tag ==1)
    {
//        NSLog(@"高德地图");
//        if ( ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"iosamap://"]])) {
//            
//            NSString *urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%f&slon=%f&sname=A&did=BGVIS2&dlat=%f&dlon=%f&dname=B&dev=0&m=0&t=0",_fromLocationW,_fromLocationJ,_toLocationW,_toLocationJ];
//            
//            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
//            [self hideAnimation];
//        }
//        else{
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您没有安装高德地图，请先安装高德地图" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        }
        NSLog(@"系统地图");
        NSString *urlString = nil;
        if ([[[UIDevice currentDevice]systemVersion]floatValue] <= 6.0f) {
            urlString = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d",_fromLocationW,_fromLocationJ,_toLocationW,_toLocationJ];
        }else{
            urlString = [[NSString alloc] initWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d",_fromLocationW,_fromLocationJ,_toLocationW,_toLocationJ];
        }
        NSURL *aURL = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:aURL];
        
    }
    else{
    [self hideAnimation];
    }
}

- (double)addContent:(UIScrollView *)sc
{
    double dContentOffset = 0;
    
    switch (_nContentMode) {
        case DoContentImage:
        {
//            UIImageView *iv     = nil;
            if (_iImage != nil)
            {

            }
        }
            break;
            
        case DoContentMap:
        {
            if (_dLocation == nil)
            {
                dContentOffset = 0;
                break;
            }
            
            MAMapView *vMap = [[MAMapView alloc] initWithFrame:CGRectMake(DO_BUTTON_INSET.left, DO_BUTTON_INSET.top,
                                                                          240, 180)];
            vMap.center = CGPointMake(sc.center.x, vMap.center.y);
            
            vMap.delegate = self;
            vMap.centerCoordinate = CLLocationCoordinate2DMake([_dLocation[@"latitude"] doubleValue], [_dLocation[@"longitude"] doubleValue]);
//            vMap.camera.altitude = [_dLocation[@"altitude"] doubleValue];
//            vMap.camera.pitch = 70;
//            vMap.showsBuildings = YES;
            vMap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

            [sc addSubview:vMap];
            dContentOffset = 180 + DO_BUTTON_INSET.bottom;
            
//            [vMap showAnnotations:@[pointRavens,pointSteelers,pointBengals, pointBrowns] animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    return dContentOffset;
}

- (void)hideActionSheet
{
    [self removeFromSuperview];
    [_actionWindow removeFromSuperview];
    _actionWindow = nil;
}

- (void)showAnimation
{
    self.alpha = 0.0;

    switch (_nAnimationType) {
        case DoTransitionStyleNormal:
        case DoTransitionStylePop:
            _vActionSheet.frame = CGRectMake(0, self.bounds.size.height,
                                             self.bounds.size.width, _vActionSheet.frame.size.height + _dRound + 5);
            break;

        case DoTransitionStyleFade:
            _vActionSheet.alpha = 0.0;
            _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 5,
                                             self.bounds.size.width, _vActionSheet.frame.size.height + _dRound + 5);
            break;

        default:
            break;
    }
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.alpha = 1.0;

        [UIView setAnimationDelay:0.1];

        switch (_nAnimationType) {
            case DoTransitionStyleNormal:
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 15,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);
                
                break;
                
            case DoTransitionStyleFade:
                _vActionSheet.alpha = 1.0;
                break;
                
            case DoTransitionStylePop:
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 10,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);
                
                break;
                
            default:
                break;
        }
    } completion:^(BOOL finished) {

        if (_nAnimationType == DoTransitionStylePop)
        {
            [UIView animateWithDuration:0.1 animations:^(void) {

                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 18,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);

            } completion:^(BOOL finished) {

                [UIView animateWithDuration:0.1 animations:^(void) {
                    _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 15,
                                                     self.bounds.size.width, _vActionSheet.frame.size.height);
                    
                }];
            }];
        }
    }];
}

- (void)hideAnimation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

    [UIView animateWithDuration:0.2 animations:^(void) {

        switch (_nAnimationType) {
            case DoTransitionStyleNormal:
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);
                break;

            case DoTransitionStyleFade:
                _vActionSheet.alpha = 0.0;
                break;
                
            case DoTransitionStylePop:
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 10,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);

                break;
        }

        [UIView setAnimationDelay:0.1];
        if (_nAnimationType != DoTransitionStylePop)
        {
            _vActionSheet.alpha = 0.0;
            self.alpha = 0.0;
        }
        
    } completion:^(BOOL finished) {
        
        if (_nAnimationType == DoTransitionStylePop)
        {
            [UIView animateWithDuration:0.1 animations:^(void) {
                
                [UIView setAnimationDelay:0.1];
                _vActionSheet.frame = CGRectMake(0, self.bounds.size.height,
                                                 self.bounds.size.width, _vActionSheet.frame.size.height);
                
            } completion:^(BOOL finished) {

                [UIView animateWithDuration:0.1 animations:^(void) {
                    
                    [UIView setAnimationDelay:0.1];
                    self.alpha = 0.0;

                } completion:^(BOOL finished) {

                    [self hideActionSheet];
                
                }];
            }];
        }
        else
        {
            [self hideActionSheet];
        }
    }];
}

-(void)receivedRotate: (NSNotification *)notification
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [UIView animateWithDuration:0.2 animations:^(void) {
            _vActionSheet.frame = CGRectMake(0, self.bounds.size.height - _vActionSheet.frame.size.height + 15,
                                             self.bounds.size.width, _vActionSheet.frame.size.height);
        }];
    });
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_vActionSheet.frame, pt))
        return;

//    _result(DO_CANCEL_TAG);
    [self hideAnimation];
}

@end
