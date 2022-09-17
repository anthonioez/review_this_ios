//
//  TopicViewCell.m
//  Requester
//
//  Created by Anthonio Ez on 6/20/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import "TopicViewCell.h"

@implementation TopicViewCell

- (void)awakeFromNib
{
    [self awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];        
}

- (IBAction)onMail:(id)sender
{
    [self.actiondelegate topicMail: self.indexPath];
}
@end
