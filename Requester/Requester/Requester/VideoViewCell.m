//
//  VideoViewCell.m
//  NotePlus
//
//  Created by Anthonio Ez on 6/20/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import "VideoViewCell.h"

@implementation VideoViewCell

- (void)awakeFromNib
{
    [self awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];        
}

- (IBAction)onPlay:(id)sender
{
    [self.actiondelegate videoPlay: self.indexPath];
}
@end
