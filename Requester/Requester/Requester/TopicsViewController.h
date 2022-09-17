//
//  TopicsViewController.h
//  Requester
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicViewCell.h"

@interface TopicsViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, SWTableViewCellDelegate, TopicViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITableView *topicTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBar;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (IBAction)onAdd:(id)sender;

@property NSMutableArray *topicList;

@end
