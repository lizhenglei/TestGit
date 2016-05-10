//
//  UITableViewCell+Image.h
//  MobileClient
//
//  Created by 杨楠 on 14-8-12.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Image)

- (void)setText:(NSString *)text withImage:(NSString *)imageName;
- (void)setText:(NSString *)text withImage:(NSString *)imageName needArrow:(BOOL)need;
- (void)setText:(NSString *)text textSize:(CGFloat)size withImage:(NSString *)imageName needArrow:(BOOL)need;

@end
