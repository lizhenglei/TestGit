//
//  CSIISinaContentController.h
//
//  Created by 胡中楷 on 14-11-1.
//  Copyright (c) 2014年 胡中楷. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 新浪自定义分享内容界面
 
 */

//#import "QREncoder.h"
//#import "DataMatrix.h"


@interface CSIISinaContentController : UIViewController

@property(nonatomic,strong)UIImage *erWeiMaImage;
@property(nonatomic,strong)NSString *WebShareName;
@property(nonatomic,strong)NSString *WebShareUrl;
@property(nonatomic,strong)NSString *WebShareText;
@end
