//
//  TopicViewCell.h
//  Requester
//
//  Created by Anthonio Ez on 6/20/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@protocol TopicViewDelegate <NSObject>

@required
- (void) topicMail:(NSIndexPath *)indexPath;


@end

@interface TopicViewCell : SWTableViewCell

@property (nonatomic,strong) id <TopicViewDelegate> actiondelegate;

@property NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)onMail:(id)sender;

@end
