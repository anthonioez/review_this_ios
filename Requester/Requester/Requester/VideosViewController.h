//
//  VideosViewController.h
//  Requester
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import "VideoViewCell.h"
#import "TopicItem.h"

@interface VideosViewController : UIViewController<UINavigationControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UIActionSheetDelegate, SWTableViewCellDelegate, VideoViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITableView *videoTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBar;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (IBAction)onAdd:(id)sender;

@property TopicItem *topic;
@property NSMutableArray *videoList;

@end
