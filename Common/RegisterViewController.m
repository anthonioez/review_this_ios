//
//  RegisterViewController.m
//  Requester
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "ReviewThis.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "Utils.h"
#import "Settings.h"

@interface RegisterViewController ()
{
    ReviewThis *app;
    NSString *username;
    NSString *password;
    
    NSURLConnection *registerConnection;
    NSMutableData *registerData;
    MBProgressHUD *hud;
    UITapGestureRecognizer *tapGesture;
    
}
@end

@implementation RegisterViewController

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
    [self.passText addTarget:self.pass2Text  action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.pass2Text addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    
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

#pragma mark - Actions
- (IBAction)onClose:(id)sender
{
    [registerConnection cancel];
    
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}


- (IBAction)onRegister:(id)sender
{
    if(![self validate])
    {
        return;
    }
    
    [self hideKeyboard];
    [self startUI];
    
    [self signup];
}

-(BOOL) validate
{
    NSString *password2;
    
    username = [self.userText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    password = [self.passText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    password2 = [self.pass2Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (![Utils isValidEmail: username])
    {
        [Utils message:@"Signup" : @"Please enter your email address!"];
        
        [self.userText becomeFirstResponder];
        return false;
    }
    
    if ([password length] < 6)
    {
        [Utils message:@"Signup" : @"Please enter your password (minimum of 6 characters)!"];
        
        [self.passText becomeFirstResponder];
        return false;
    }
    
    if ([password2 length] < 6)
    {
        [Utils message:@"Signup" : @"Please re-enter your password (minimum of 6 characters)!"];
        
        [self.pass2Text becomeFirstResponder];
        return false;
    }
    
    if (![password2 isEqualToString: password])
    {
        [Utils message:@"Signup" : @"Password mismatch, please re-enter your password (minimum of 6 characters)!"];
        
        [self.pass2Text becomeFirstResponder];
        return false;
    }
    
    return true;
}


- (void) startUI
{
    [hud show:YES];
    [self.registerButton setEnabled: NO];
}

- (void) stopUI
{
    [hud hide:YES];
    [self.registerButton setEnabled: YES];
}

- (void) hideKeyboard
{
    [self.userText resignFirstResponder];
    [self.passText resignFirstResponder];
    [self.pass2Text resignFirstResponder];
    
    CGPoint pt = CGPointZero;
    [self.scrollView setContentOffset:pt animated:YES];
}

- (void) signup
{
    NSString *url = ([app appType] == AppRequester ? APP_URL_REQUESTER_REGISTER : APP_URL_REVIEWER_REGISTER);
    
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
    
    registerData = [NSMutableData new];
    registerConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopUI];
    [Utils message:@"Signup Error" : [error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [registerData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc]initWithData: registerData encoding:NSUTF8StringEncoding];
    NSLog(@"signup response: %@", response);
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:registerData options:0 error:&localError];
    
    if (localError != nil && parsedObject != nil)
    {
        [self stopUI];
        [Utils message:@"Signup Error" : @"Invalid data from server!"];
        return;
    }
    
    NSString *status = [parsedObject valueForKey:@"status"];
    NSString *msg = [parsedObject valueForKey:@"message"];
    NSString *hash = [parsedObject valueForKey:@"hash"];
    long userid = [[parsedObject valueForKey:@"user_id"] longValue];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to signup!";
        [Utils message:@"Signup Error" : msg];
        
        [self stopUI];
        return;
    }
    
    [self stopUI];
    
    [[AppDelegate rootController] popViewControllerAnimated: NO];
    
    if(hash == nil || userid == 0)
    {
        if(msg == nil || [msg length] == 0) msg = @"Signup successful!";
        [Utils message: nil : msg];
        
        [self.delegate registerSuccessful: false];
    }
    else
    {
        [Settings setUserHash: hash];
        [Settings setUserId: userid];
        [Settings setActive: YES];

        [self.delegate registerSuccessful: true];
    }
}

@end
