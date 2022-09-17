//
//  TopicViewCell.h
//  Requester
//
//  Created by Anthonio Ez on 6/20/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicViewCell : UITableViewCell

@property NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;

@end
