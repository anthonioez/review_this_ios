//
//  LoginViewController.m
//  Requester
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "ReviewThis.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Utils.h"
#import "Settings.h"

@interface LoginViewController ()
{
    NSString *username;
    NSString *password;

    NSURLConnection *loginConnection;
    NSMutableData *loginData;
    
    ReviewThis *app;
    
    MBProgressHUD *hud;
    UITapGestureRecognizer *tapGesture;
}
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    app = [ReviewThis sharedInstance];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.removeFromSuperViewOnHide = NO;
    [self.navigationController.view addSubview:hud];
    
    UIBarButtonItem *navButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
    self.navItem.leftBarButtonItem = navButtonItem;
    
    [self.userText addTarget:self.passText  action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passText addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //[self.userText setText: @"abc@domain.com"];
    //[self.passText setText: @"secret"];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navBar addGestureRecognizer:tapGesture];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navBar removeGestureRecognizer:tapGesture];
    [self.view removeGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return false;
}

- (IBAction)onClose:(id)sender
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

-(BOOL) validate
{
    username = [self.userText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    password = [self.passText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![Utils isValidEmail: username])
    {
        [Utils message:@"Login" : @"Please enter your email address!"];

        [self.userText becomeFirstResponder];
        return false;
    }
    
    if ([password length] < 6)
    {
        [Utils message:@"Login" : @"Please enter your password (minimum of 6 characters)!"];
        
        [self.passText becomeFirstResponder];
        return false;
    }
    
    return true;
}


- (IBAction)onLogin:(id)sender
{
    if(![self validate])
    {
        return;
    }

    [self hideKeyboard];
    [self startUI];

    [self login];
}

- (void) startUI
{
    [hud show:YES];
    [self.loginButton setEnabled: NO];
}

- (void) stopUI
{
    [hud hide:YES];

    [self.loginButton setEnabled: YES];
}

- (void) hideKeyboard
{
    [self.userText resignFirstResponder];
    [self.passText resignFirstResponder];
    
    CGPoint pt = CGPointZero;
    [self.scrollView setContentOffset:pt animated:YES];
}

- (void) login
{
    NSString *url = ([app appType] == AppRequester ? APP_URL_REQUESTER_LOGIN : APP_URL_REVIEWER_LOGIN);
    
    NSString *post =[[NSString alloc] initWithFormat:@"email=%@&password=%@", username, [Utils md5: password]];
    NSLog(@"url: %@ post: %@", url, post);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postSize = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue:postSize forHTTPHeaderField:@"Content-Length"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    loginData = [NSMutableData new];
    loginConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopUI];
    [Utils message:@"Login Error" : [error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [loginData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc]initWithData: loginData encoding:NSUTF8StringEncoding];
    NSLog(@"login response: %@", response);
 
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:loginData options:0 error:&localError];
    
    if (localError != nil && parsedObject != nil)
    {
        [self stopUI];
        [Utils message:@"Login Error" : @"Invalid data from server!"];
        return;
    }
    
    NSString *hash = [parsedObject valueForKey:@"hash"];
    NSString *status = [parsedObject valueForKey:@"status"];
    NSString *msg = [parsedObject valueForKey:@"message"];

    long userid = [[parsedObject valueForKey:@"user_id"] longValue];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to login!";
        [Utils message:@"Login Error" : msg];

        [self stopUI];
        return;
    }
    
    [self stopUI];
    [Settings setUserHash: hash];
    [Settings setUserId: userid];
    [Settings setActive: YES];
    
    [[AppDelegate rootController] popViewControllerAnimated: NO];
    
    [self.delegate loginSuccessful];
}
@end
