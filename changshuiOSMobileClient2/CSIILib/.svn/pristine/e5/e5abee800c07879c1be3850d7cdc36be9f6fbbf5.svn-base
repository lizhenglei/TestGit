//
//  MapDetailTableViewCell.m
//  MobileClient
//
//  Created by 李正雷 on 15/5/20.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "MapDetailTableViewCell.h"

@implementation MapDetailTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self createUI];
        
    }
    return self;
}

- (void)createUI {
    // Initialization code
    self.contentView.backgroundColor = [UIColor whiteColor];
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.contentView.frame.size.width/2+50, 30)];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.text = @"名称";
//    CGSize size = CGSizeMake(200, 30);
//    CGSize labelSize = [_nameLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
//    _nameLabel.frame = CGRectMake(10, 0, labelSize.width, 30);
    [self.contentView addSubview:_nameLabel];
    
    _distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width-80, 5, 50, 20)];
    _distanceLabel.font = [UIFont systemFontOfSize:13];
    _distanceLabel.text = @"2km";
    [self.contentView addSubview:_distanceLabel];
    _locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, _nameLabel.frame.size.height+_nameLabel.frame.origin.y, self.contentView.frame.size.width-30, 30)];
    _locationLabel.font = [UIFont systemFontOfSize:13];
    _locationLabel.text = @"门牌号";
    [self.contentView addSubview:_locationLabel];
    _view = [[UIView alloc]initWithFrame:CGRectMake(5, _locationLabel.frame.origin.y+_locationLabel.frame.size.height-2, self.contentView.frame.size.width-30, 0.5)];
    _view.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_view];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
