//
//  UITableViewCell+Image.m
//  MobileClient
//
//  Created by 杨楠 on 14-8-12.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "UITableViewCell+Image.h"
#import "CSIILabel.h"
#import "LWYGlobalVariable.h"
@implementation UITableViewCell (Image)

- (void)setText:(NSString *)text withImage:(NSString *)imageName {
    [self setText:text withImage:imageName needArrow:NO];
}

- (void)setText:(NSString *)text withImage:(NSString *)imageName needArrow:(BOOL)need {
    [self setText:text textSize:16 withImage:imageName needArrow:need];
}

- (void)setText:(NSString *)text textSize:(CGFloat)size withImage:(NSString *)imageName needArrow:(BOOL)need {
    UILabel* label = [[CSIILabel alloc]initWithFrame:CGRectMake(62, cellHight/2-40/2, 260, 40)];
    label.font=[UIFont boldSystemFontOfSize:size];
    label.text = text;
    label.textColor = [UIColor colorWithRed:0.35f green:0.35f blue:0.35f alpha:1.00f];
    [self.contentView addSubview:label];
    NSInteger height = self.frame.size.height;
    if (imageName) {
        UIImage* iconImage = [Context ImageName:imageName];//换肤
        if (iconImage == nil) {
            iconImage = [Context ImageName:@"tsfwimg"];
        }
        UIImageView* icon = [[UIImageView alloc]initWithFrame:CGRectMake(16, 10, 35, 35)];
        icon.image = iconImage;
        [self.contentView addSubview:icon];
    }
    
    if (need) {
        UIImage* arrowImage = [UIImage imageNamed:@"disclosure_right"];
        UIImageView* arrow = [[UIImageView alloc]initWithFrame:CGRectMake(296, (height - arrowImage.size.height)/2, arrowImage.size.width, arrowImage.size.height)];
        arrow.image = arrowImage;
        [self.contentView addSubview:arrow];
    }
}

@end
