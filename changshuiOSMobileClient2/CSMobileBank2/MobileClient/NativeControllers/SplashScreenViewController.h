//
//  SplashScreenViewController.h
//  MobileClient
//
//  Created by 张海亮 on 13-7-11.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "MobileBankSession.h"
#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
#define IPHONE ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)

@interface SplashScreenViewController : UIViewController
{
   MPMoviePlayerController *movie;
}

@property (nonatomic,strong) MPMoviePlayerController *movie;
@property (assign) BOOL localStorageSplash;

@end
