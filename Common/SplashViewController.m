//
//  SplashViewController.m
//  
//
//  Created by Anthonio Ez on 21/Nov/2014
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashViewController.h"

@interface SplashViewController ()
{
}
@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"SplashViewController::initWithNibName");

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"SplashViewController::viewDidLoad");
    
    self.loginButton.alpha = 0.0;
    self.registerButton.alpha = 0.0;
    
    [self performSelector:@selector(nextView) withObject:nil afterDelay: 0.50];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

    self.view.alpha = 1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return false;
}

- (void) ready
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(nextView)];
    
    self.loginButton.alpha = 1.0;
    self.registerButton.alpha = 1.0;
    
	[UIView commitAnimations];
}

- (void) nextView
{
    NSLog(@"SplashViewController::nextView");

    [self.delegate splashReady];
}

- (IBAction)onLogin:(id)sender
{
//    self.view.alpha = 0.5;
    [self.delegate splashLogin];
}

- (IBAction)onRegister:(id)sender
{
//    self.view.alpha = 0.5;
    [self.delegate splashRegister];
}
@end
