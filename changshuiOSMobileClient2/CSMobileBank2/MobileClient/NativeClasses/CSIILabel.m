//
//  CSIILabel.m
//  MobileClient
//
//  Created by 杨楠 on 14/8/27.
//  Copyright (c) 2014年 pro. All rights reserved.
//

#import "CSIILabel.h"

@implementation CSIILabel

- (id)init {
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    self.backgroundColor = [UIColor clearColor];
    self.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
}

@end
