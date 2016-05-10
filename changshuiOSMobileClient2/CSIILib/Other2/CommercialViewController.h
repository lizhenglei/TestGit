//
//  CommercialViewController.h
//  MobileClient
//
//  Created by xiaoxin on 15/4/29.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "CSIISuperViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface CommercialViewController : CSIISuperViewController<MAMapViewDelegate> {
}
@property(nonatomic,strong)MAMapView*mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
- (id)initWithDetailMessage:(NSMutableDictionary *)MessageDic;


@end
