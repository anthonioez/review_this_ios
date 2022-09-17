//
//  SWSplashViewController.h
//  
//
//  Created by Anthonio Ez on 6/11/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SplashViewDelegate <NSObject>

@required
- (void) splashReady;
- (void) splashLogin;
- (void) splashRegister;

@end


@interface SplashViewController : UIViewController

@property (nonatomic,strong) id <SplashViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)onLogin:(id)sender;
- (IBAction)onRegister:(id)sender;

- (void) ready;
@end
