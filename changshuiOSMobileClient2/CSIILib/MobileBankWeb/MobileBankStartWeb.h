//
//  MobileBankStartWeb.h
//  MobileBankWeb
//
//  Created by Yuxiang on 13-6-8.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> 

@interface MobileBankStartWeb : NSObject
-(UIWebView *)startActionUrl:(NSString *)urlString WithFrame:(CGRect)rect;
@end
