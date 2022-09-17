//
//  ReviewerTopicsViewController.h
//  Reviewer
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicViewCell.h"
#import "ReviewViewController.h"

@interface ReviewerTopicsViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ReviewViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITableView *topicTable;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBar;
@property NSMutableArray *titleList;
@property NSMutableArray *sectionList;

- (IBAction)onRefresh:(id)sender;

@end
