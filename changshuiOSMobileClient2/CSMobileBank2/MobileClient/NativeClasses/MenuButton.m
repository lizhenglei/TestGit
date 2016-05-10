//
//  MenuButton.m
//  MobileClient
//
//  Created by 杨楠 on 14-8-14.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "MenuButton.h"
#import "CSIIUtility.h"
#import "CSIILabel.h"

@interface MenuButton ()
{
    UIImageView* _buttomImage;
    UIImage* _selectImage;
    UIImage* _unselectImage;
    BOOL _selected;
}
@end

@implementation MenuButton

- (id)initWithFrame:(CGRect)frame title:(NSString *)title imageName:(NSString *)image iconKey:(NSInteger)key {
    self = [super initWithFrame:frame];
    if (self) {
        NSString* black = nil;
        NSString* red = nil;
        if (key < 1) {
            black = [NSString stringWithFormat:@"%@3",image];
            red = [NSString stringWithFormat:@"%@4",image];
        } else {
            black = [NSString stringWithFormat:@"%@7",image];
            red = [NSString stringWithFormat:@"%@8",image];
        }
        _selectImage = [UIImage imageNamed:red];
        _unselectImage = [UIImage imageNamed:black];
        
        _buttomImage = [[UIImageView alloc]initWithFrame:[CSIIUtility getCentreRect:self.frame innerSize:_selectImage.size top:2]];
        _buttomImage.image = _unselectImage;
        [self addSubview:_buttomImage];
        
        NSInteger height = title.length < 5 ? 26: 40;
        UILabel* label = [[CSIILabel alloc]initWithFrame:[CSIIUtility getCentreRect:self.frame innerSize:CGSizeMake(self.frame.size.width - 10, height) top:self.imageView.frame.size.height + 34]];
        if (title.length > 4) {
            label.numberOfLines = 0;
        }
        label.text = title;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        _buttomImage.image = _selectImage;
    } else {
        _buttomImage.image = _unselectImage;
    }
    _selected = selected;
}

- (BOOL)isSelected {
    return _selected;
}

@end
