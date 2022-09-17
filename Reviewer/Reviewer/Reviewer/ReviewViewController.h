//
//  ReviewViewController.h
//  Reviewer
//
//  Created by Anthonio Ez on 2/12/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicItem.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol ReviewViewDelegate <NSObject>

@optional
- (void) reviewSuccessful;

@end

@interface ReviewViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) id <ReviewViewDelegate> delegate;

@property UIBarButtonItem *backBar;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITextView *infoText;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)onStart:(id)sender;

@property TopicItem *topic;
@end
