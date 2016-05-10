//
//  CommercialViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/4/29.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "CommercialViewController.h"
#import "DoActionSheet.h"
@interface CommercialViewController ()
{
    int MAUserTrackingModeNum;
    CLLocationDegrees _latitude;// 纬度
    CLLocationDegrees _longitude;//经度
    NSString *_locationName;
    NSString *_locationPlace;
    NSString *_telephoneNum;
    NSString *_distance;
    CLLocationCoordinate2D _center;
    NSString *_BranchType;
}
@property (nonatomic, retain)UISegmentedControl *showSegment;

@property (nonatomic, retain)UISegmentedControl *modeSegment;

@end

@implementation CommercialViewController
@synthesize showSegment, modeSegment;


- (id)initWithDetailMessage:(NSMutableDictionary *)MessageDic
{
    self = [super init];
    if (self) {
        _latitude = [[MessageDic objectForKey:@"Latitude"] doubleValue];
        _longitude = [[MessageDic objectForKey:@"Longitude"]doubleValue];
        _locationName = [MessageDic objectForKey:@"LocationName"];
        _locationPlace = [MessageDic objectForKey:@"LocationPlace"];
        _telephoneNum = [MessageDic objectForKey:@"Telephone"];
        _distance = [MessageDic objectForKey:@"Distance"];
        _BranchType = [MessageDic objectForKey:@"BranchType"];
        NSLog(@"纬度－－－－%f经度----%f",_latitude,_longitude);
        [MobileBankSession sharedInstance].isMapPosition = YES;
    }
    return self;
}



#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
}

#pragma mark - Action Handle

- (void)showsSegmentAction:(UIButton *)sender
{
    self.mapView.userTrackingMode = MAUserTrackingModeNum;
    
    [self createPointAnnotation];
}

- (void)modeAction:(UIButton *)sender
{
    if (MAUserTrackingModeNum<2) {
        MAUserTrackingModeNum++;
    }else{
        MAUserTrackingModeNum=0;
    }
    self.mapView.userTrackingMode = MAUserTrackingModeNum;
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate =self;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    self.mapView.userTrackingMode = MAUserTrackingModeNum;
    
    [self.view addSubview:self.mapView];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

#pragma mark - NSKeyValueObservering

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"showsUserLocation"])
    {
        NSNumber *showsNum = [change objectForKey:NSKeyValueChangeNewKey];
        self.showSegment.selectedSegmentIndex = ![showsNum boolValue];
    }
    
}

//- (void)initObservers
//{
/* Add observer for showsUserLocation. */
//    [self.mapView addObserver:self forKeyPath:@"showsUserLocation" options:NSKeyValueObservingOptionNew context:nil];
//}

#pragma mark - Utility

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}


#pragma mark - Handle Action
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearMapView];
    
    self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    
    //    [self.mapView removeObserver:self forKeyPath:@"showsUserLocation"];
}



#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    
    MAUserTrackingModeNum = 0;
    [self initMapView];
}
-(void)createPointAnnotation
{
    MAPointAnnotation *ma = [[MAPointAnnotation alloc]init];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(_latitude, _longitude);
    MACoordinateSpan span;
    if (![_distance isEqualToString:@"未知"]&&[_distance floatValue] <=5.0f) {
        span = MACoordinateSpanMake(0.1, 0.1);//值越小地图越精细
    }else{
        span = MACoordinateSpanMake(0.01, 0.01);//值越小地图越精细
    }
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    //    设置显示区域
    MACoordinateRegion region = MACoordinateRegionMake(coord, span);
    ma.coordinate = coord;
    [self.mapView addAnnotation:ma];
    [self.mapView setRegion:region];
}
-(void)createUI
{
    self.mapView.showsUserLocation = YES;
    
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self createPointAnnotation];
    UIView *bgView= [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight-64-72-75, ScreenWidth, 90)];
    [self.view addSubview:bgView];
    [self.view insertSubview:bgView aboveSubview:self.mapView];
    bgView.backgroundColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.00f];
    
    UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, bgView.frame.size.width/2+100, 30)];
    nameLabel.font = [UIFont systemFontOfSize:17];
    if ([_BranchType isEqualToString:@"1"]) {
        _locationName = [NSString stringWithFormat:@"%@%@",_locationName,@"(网点)"];
    }
    if ([_BranchType isEqualToString:@"2"]) {
        _locationName = [NSString stringWithFormat:@"%@%@",_locationName,@"(ATM)"];
    }
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = _locationName;
    [bgView addSubview:nameLabel];
    
    UILabel * distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(bgView.frame.size.width-80, 5, 80, 20)];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.font = [UIFont systemFontOfSize:15];
    distanceLabel.text = [NSString stringWithFormat:@"%@km",_distance];
    [bgView addSubview:distanceLabel];
    
    //    UIImageView *typeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(distanceLabel.frame.origin.x-45,7,40,16)];
    //    [bgView addSubview:typeImageView];
    UILabel *locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, nameLabel.frame.size.height+nameLabel.frame.origin.y-5, ScreenWidth-30, 30)];
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.font = [UIFont systemFontOfSize:15];
    locationLabel.text = _locationPlace;
    [bgView addSubview:locationLabel];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(5, locationLabel.frame.origin.y+locationLabel.frame.size.height-3, bgView.frame.size.width-10, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [bgView addSubview:lineView];
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(bgView.frame.size.width/2, lineView.frame.origin.y+5, 1, 40)];
    lineView2.backgroundColor = [UIColor grayColor];
    [bgView addSubview:lineView2];
    UIButton *daoHhangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    daoHhangBtn.frame = CGRectMake(bgView.frame.size.width/2-120, lineView.frame.origin.y+3, 70, 30);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 3, 23, 23)];
    imageView.image = [UIImage imageNamed:@"navi_icon"];
    [daoHhangBtn addSubview:imageView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 45, 30)];
    label.text = @"导航";
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:15];
    [daoHhangBtn addSubview:label];
    [daoHhangBtn addTarget:self action:@selector(mapBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [daoHhangBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    daoHhangBtn.tag = 100;
    [bgView addSubview:daoHhangBtn];
    UIButton *telephone = [UIButton buttonWithType:UIButtonTypeCustom];
    telephone.frame = CGRectMake(bgView.frame.size.width/2+50,lineView.frame.origin.y+3, 100, 30);
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 3, 23, 23)];
    if (_telephoneNum.length==0) {
        imageView2.image = [UIImage imageNamed:@"telephone2"];
        telephone.enabled = NO;
    }else{
        imageView2.image = [UIImage imageNamed:@"telephone"];
    }
    [telephone addSubview:imageView2];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 75, 30)];
    label2.text = @"电话";
    label2.backgroundColor = [UIColor clearColor];
    label2.font = [UIFont systemFontOfSize:15];
    [telephone addSubview:label2];
    telephone.tag = 101;
    [telephone addTarget:self action:@selector(mapBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [telephone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    telephone.titleLabel.font = [UIFont systemFontOfSize:18];
    [bgView addSubview:telephone];
    
    
    /*  UIButton*button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake( 20, ScreenHeight-20-44-72-80-30, 60, 30);
     [button setTitle:@"查询地点" forState:UIControlStateNormal];
     button.backgroundColor = [UIColor whiteColor];
     [button setTitleColor:[UIColor colorWithRed:0.00f green:0.56f blue:0.99f alpha:1.00f] forState:UIControlStateNormal];
     button.titleLabel.font = [UIFont systemFontOfSize:13];
     button.layer.cornerRadius = 5.0f;
     button.layer.masksToBounds =  YES;
     button.layer.borderWidth = 1.0f;
     button.layer.borderColor = [[UIColor colorWithRed:0.00f green:0.56f blue:0.99f alpha:1.00f] CGColor];
     [button addTarget:self action:@selector(showsSegmentAction:) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:button];
     
     
     UIButton*centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
     centerButton.frame = CGRectMake( ScreenWidth - 80, ScreenHeight-20-44-72-80-30, 60, 30);
     [centerButton setTitle:@"我的位置" forState:UIControlStateNormal];
     centerButton.backgroundColor = [UIColor whiteColor];
     [centerButton setTitleColor:[UIColor colorWithRed:0.00f green:0.56f blue:0.99f alpha:1.00f] forState:UIControlStateNormal];
     centerButton.titleLabel.font = [UIFont systemFontOfSize:13];
     centerButton.layer.cornerRadius = 5.0f;
     centerButton.layer.masksToBounds =  YES;
     centerButton.layer.borderWidth = 1.0f;
     centerButton.layer.borderColor = [[UIColor colorWithRed:0.00f green:0.56f blue:0.99f alpha:1.00f] CGColor];
     [centerButton addTarget:self action:@selector(modeAction:) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:centerButton];
     */
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"网点查询";
    
    //    [self initObservers];
    
    [self.mapView setCompassImage:[UIImage imageNamed:@"compass"]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createUI];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [self.mapView removeObserver:self forKeyPath:@"showsUserLocation"];
}
-(void)mapBtnClick:(UIButton *)sender
{
    if (sender.tag == 101) {
        [self makeACall:_telephoneNum];
    }else{
        NSLog(@"自己的纬度%f自己的经度%f",self.mapView.userLocation.coordinate.latitude,self.mapView.userLocation.coordinate.longitude);
        //         自己的纬度31.649364自己的经度120.776430
        DoActionSheet *actionSheet = [[DoActionSheet alloc]initWithFromLocation:self.mapView.userLocation.coordinate.latitude and:self.mapView.userLocation.coordinate.longitude toLocation:_latitude and:_longitude];
        [actionSheet showC:nil cancel:@"取消" buttons:@[@"百度地图",@"系统地图"] result:nil];
    }
}
- (void) makeACall:(NSString *)phoneNum {//打电话，先弹框再打电话
    NSString *num = [[NSString alloc] initWithFormat:@"telprompt:%@",phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self returnAction];
    [self.mapView setCompassImage:nil];
    [self.mapView removeFromSuperview];
}

@end
