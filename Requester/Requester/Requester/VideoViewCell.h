//
//  VideoViewCell.h
//  Requester
//
//  Created by Anthonio Ez on 6/20/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@protocol VideoViewDelegate <NSObject>

@required
- (void) videoPlay:(NSIndexPath *)indexPath;


@end

@interface VideoViewCell : SWTableViewCell

@property (nonatomic,strong) id <VideoViewDelegate> actiondelegate;

@property NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)onPlay:(id)sender;

@end
