//
//  TopicsViewController.m
//  Requester
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "ReviewThis.h"
#import "TopicItem.h"
#import "AppDelegate.h"
#import "TopicViewCell.h"
#import "TopicsViewController.h"
#import "VideosViewController.h"

#import "Settings.h"
#import "Utils.h"

#define ACTIONSHEET_MENU        1
#define ACTIONSHEET_DELETE      2

#define ALERTVIEW_TOPIC         1
#define ALERTVIEW_INVITE        2


#define TOPIC_CELL              @"TopicViewCell"

#define API_LIST        0
#define API_ADD         1
#define API_DELETE      2
#define API_INVITE      3
#define API_LOGOUT      4

@interface TopicsViewController ()
{
    int api_call;
    NSMutableData *topicData;
    NSURLConnection *topicConnection;

    MBProgressHUD *hud;
    NSIndexPath *selectedIndexPath;
}
@end

@implementation TopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.removeFromSuperViewOnHide = NO;
    [self.navigationController.view addSubview:hud];
    
    UIBarButtonItem *navButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu:)];
    self.navItem.leftBarButtonItem = navButtonItem;
    
    [self.infoLabel setText: @""];
    [self.infoLabel setHidden: NO];
    
    self.topicList = [NSMutableArray new];
    
    [self.topicTable registerNib:[UINib nibWithNibName: TOPIC_CELL bundle:nil] forCellReuseIdentifier: TOPIC_CELL];
    
    [self.topicTable setDelegate:self];
    [self.topicTable setDataSource:self];
    
    [self loadTopics];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return false;
}

#pragma mark - IBActions
- (IBAction)onMenu:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = ACTIONSHEET_MENU;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet addButtonWithTitle:@"Logout"];
    
    [actionSheet showInView:self.view];
}

- (IBAction)onAdd:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Topic" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = ALERTVIEW_TOPIC;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Topic Name";

    alertTextField.backgroundColor = [UIColor whiteColor];
//    alertTextField.delegate = self;
    alertTextField.keyboardAppearance = UIKeyboardAppearanceDark;

    [alertTextField becomeFirstResponder];

    [alert show];
}

- (IBAction)onRefresh:(id)sender {
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERTVIEW_TOPIC)
    {
        if((int) buttonIndex == 1)
        {
            UITextField * textField = [alertView textFieldAtIndex:0];
            
            NSString* name = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([name length] > 0)
            {
                [self addTopic: name];
            }
        }
    }
    else
    {
        if((int) buttonIndex == 1)
        {
            UITextField * textField = [alertView textFieldAtIndex:0];
            
            NSString* names = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([names length] > 0)
            {
                [self inviteReviewer: names];
            }
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == ACTIONSHEET_MENU)
    {
        if(buttonIndex == 1)
        {
            [self logout];
        }
    }
    else if(actionSheet.tag == ACTIONSHEET_DELETE)
    {
        if(buttonIndex == 1)
        {
            [self deleteTopic];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topicList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicViewCell *cell = (TopicViewCell *)[self.topicTable dequeueReusableCellWithIdentifier: TOPIC_CELL];
    cell.delegate = self;
    cell.actiondelegate = self;
    cell.indexPath = indexPath;
    
    TopicItem *item = [self.topicList objectAtIndex:indexPath.row];
    
    if (item != nil)
    {
        [cell.titleLabel setText: [NSString stringWithFormat: @"%d%@ %@", (int)(indexPath.row + 1), @".", item.name]];
    }

    
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:64.0f];
    
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self openTopic: indexPath];
    
    [self.topicTable deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            //NSLog(@"utility buttons closed");
            break;
        case 1:
            //NSLog(@"left utility buttons open");
            break;
        case 2:
            // NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            selectedIndexPath = [self.topicTable indexPathForCell:cell];
            [self deleteConfirm];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

#pragma mark - TopicViewDelegate
- (void) topicMail:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    TopicItem *item = [self.topicList objectAtIndex: selectedIndexPath.row];
    if(item == nil)
    {
        [Utils message:nil :@"Missing topic!"];
        return;
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"Invite Reviewers for '%@'", item.name] message: @"Enter email addresses, separated by a comma" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = ALERTVIEW_INVITE;
    
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Email addresses";
    
    alertTextField.backgroundColor = [UIColor whiteColor];
    alertTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    [alertTextField becomeFirstResponder];
    
    [alert show];
}

#pragma mark - NSConn
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopUI];
    [Utils message:@"Topic Error" : [error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [topicData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc]initWithData: topicData encoding:NSUTF8StringEncoding];
    NSLog(@"topic response: %@", response);
    
    if(api_call == API_LIST)
    {
        [self processList];
    }
    else if(api_call == API_ADD)
    {
        [self processAdd];
    }
    else if(api_call == API_DELETE)
    {
        [self processDelete];
    }
    else if(api_call == API_INVITE)
    {
        [self processInvite];
    }
    else if(api_call == API_LOGOUT)
    {
        [self processLogout];
    }
}

#pragma mark - Functions
- (void) close
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
    
}
- (void) deleteConfirm
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = ACTIONSHEET_DELETE;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet addButtonWithTitle:@"Delete Topic"];
    
    [actionSheet showInView:self.view];
}

- (NSArray *)rightButtons
{
    NSMutableArray *buttons = [NSMutableArray new];
    
    [buttons sw_addUtilityButtonWithColor:  [UIColor clearColor] icon:[UIImage imageNamed:@"bar_delete.png"]];
    
    return buttons;
}

- (void) startUI
{
    [self.infoLabel setHidden:YES];
    [self.addBar setEnabled: NO];
    [hud show:YES];
}

- (void) stopUI
{
    [self.addBar setEnabled: YES];
    [hud hide:YES];
}

- (void) logout
{
    [topicConnection cancel];

    [self startUI];
    
    api_call = API_LOGOUT;
    
    NSString *url = [NSString stringWithFormat:@"%@?stamp=%ld", APP_URL_REQUESTER_LOGOUT, (long)[[NSDate new] timeIntervalSince1970]];
    NSLog(@"url: %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[Settings getUserHash]    forHTTPHeaderField: @"X-Auth-Hash"];
    [request setValue:[Settings getUser]        forHTTPHeaderField: @"X-Auth-UserId"];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    topicData = [NSMutableData new];
    topicConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) openTopic:(NSIndexPath *)indexPath
{
    TopicItem *item = [self.topicList objectAtIndex: indexPath.row];
    if(item == nil)
    {
        [Utils message:nil :@"Missing topic!"];
        return;
    }
    
    VideosViewController *videoController = [[VideosViewController alloc] initWithNibName:@"VideosViewController" bundle:nil];
    videoController.topic = item;
    [[AppDelegate rootController] pushViewController:videoController animated:YES];
}

- (void) loadTopics
{
    [self startUI];
    
    api_call = API_LIST;

    NSString *url = [NSString stringWithFormat:@"%@?stamp=%ld", APP_URL_REQUESTER_TOPIC, (long)[[NSDate new] timeIntervalSince1970]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    NSLog(@"url: %@", url);

    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[Settings getUserHash]    forHTTPHeaderField: @"X-Auth-Hash"];
    [request setValue:[Settings getUser]        forHTTPHeaderField: @"X-Auth-UserId"];
    
    //[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    topicData = [NSMutableData new];
    topicConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void) addTopic: (NSString *)name
{
    [self startUI];
    
    api_call = API_ADD;
    
    NSString *url = APP_URL_REQUESTER_TOPIC;
    
    NSString *post =[[NSString alloc] initWithFormat:@"name=%@", [name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSLog(@"url: %@ post: %@", url, post);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postSize = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[Settings getUserHash]    forHTTPHeaderField: @"X-Auth-Hash"];
    [request setValue:[Settings getUser]        forHTTPHeaderField: @"X-Auth-UserId"];
    [request setHTTPBody:postData];
    [request setValue:postSize forHTTPHeaderField:@"Content-Length"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    topicData = [NSMutableData new];
    topicConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) deleteTopic
{
    if(selectedIndexPath == nil)
    {
        [Utils message:nil :@"Invalid topic!"];
        return;
    }
    
    TopicItem *item = [self.topicList objectAtIndex: selectedIndexPath.row];
    if(item == nil)
    {
        [Utils message:nil :@"Missing topic!"];
        return;
    }
    
    [self startUI];
    
    api_call = API_DELETE;
    
    NSString *url = [NSString stringWithFormat: @"%@?id=%ld", APP_URL_REQUESTER_TOPIC, item.index];
    NSLog(@"url: %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"OPTIONS"];  //TODO @"DELETE"];
    [request setValue:[Settings getUserHash]    forHTTPHeaderField: @"X-Auth-Hash"];
    [request setValue:[Settings getUser]        forHTTPHeaderField: @"X-Auth-UserId"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    topicData = [NSMutableData new];
    topicConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) inviteReviewer: (NSString *)addresses
{
    if(selectedIndexPath == nil)
    {
        [Utils message:nil : @"Invalid topic!"];
        return;
    }
    
    TopicItem *item = [self.topicList objectAtIndex: selectedIndexPath.row];
    if(item == nil)
    {
        [Utils message:nil :@"Missing topic!"];
        return;
    }
    
    [self startUI];
    
    api_call = API_INVITE;
    
    NSString *url = [NSString stringWithFormat: @"%@?id=%ld&email=%@", APP_URL_REQUESTER_TOPIC, item.index, [addresses stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSLog(@"url: %@", url);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[Settings getUserHash]    forHTTPHeaderField: @"X-Auth-Hash"];
    [request setValue:[Settings getUser]        forHTTPHeaderField: @"X-Auth-UserId"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    topicData = [NSMutableData new];
    topicConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - Processors
- (void) processAdd
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:topicData options:0 error:&localError];
    
    [self stopUI];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Topic Error" : @"Invalid data from server!"];
        return;
    }
    
    NSString *status  = [parsedObject valueForKey:@"status"];
    NSString *msg  = [parsedObject valueForKey:@"message"];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to add topic!";
        [Utils message:@"Topic Error" : msg];
        return;
    }
    
    [self loadTopics];
    
    //if(msg == nil || [msg length] == 0) msg = @"Topic successfully added!";
    //[Utils message: nil : msg];
}

- (void) processDelete
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:topicData options:0 error:&localError];
    
    [self stopUI];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Topic Error" : @"Invalid data from server!"];
        return;
    }
    
    NSString *status  = [parsedObject valueForKey:@"status"];
    NSString *msg  = [parsedObject valueForKey:@"message"];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to add topic!";
        [Utils message:@"Topic Error" : msg];
        
        return;
    }
    
    if(msg == nil || [msg length] == 0) msg = @"Topic successfully deleted!";
    [Utils message: nil : msg];
    
    [self.topicList removeObjectAtIndex: selectedIndexPath.row];
    [self.topicTable reloadData];
    
//    [self loadTopics];
}

- (void) processInvite
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:topicData options:0 error:&localError];
    
    [self stopUI];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Invite Error" : @"Invalid data from server!"];
        return;
    }
    
    NSString *status  = [parsedObject valueForKey:@"status"];
    NSString *msg  = [parsedObject valueForKey:@"message"];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to send invites!";
        [Utils message:@"Invite Error" : msg];
        
        return;
    }
    
    if(msg == nil || [msg length] == 0) msg = @"Invitation sent!";
    [Utils message: nil : msg];
}

- (void) processList
{
    NSError *localError = nil;
    NSDictionary* parsedObject = [NSJSONSerialization JSONObjectWithData:topicData options:0 error:&localError];
    
    [self stopUI];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Topic Error" : @"Invalid data from server!"];
        return;
    }

    if ([parsedObject count] == 0)
    {
        [Utils message:@"Topic Error" : @"No data from server!"];
        return;
    }
    
    NSString *status  = [parsedObject valueForKey:@"status"];
    NSString *msg  = [parsedObject valueForKey:@"message"];
    
    if(status != nil && [status isEqual: @"OK"])
    {
        [self.topicList removeAllObjects];
        
        NSDictionary *dataObject = [parsedObject valueForKey: @"data"];
        for (NSDictionary *dic in dataObject)
        {
            long index      = [[dic valueForKey:@"id"] longValue];
            int count       = [[dic valueForKey:@"count"] intValue];
            NSString *name  = [dic valueForKey:@"name"];
            
            if(name == nil)
            {
                continue;
            }
            
            TopicItem *item = [TopicItem new];
            item.index = index;
            item.count = count;
            item.name = name;
            
            [self.topicList addObject: item];
        }

        [self.topicTable reloadData];
        
        if([self.topicList count] > 0)
        {
            [self.infoLabel setHidden: YES];
            
        }

        if(msg != nil)  [Utils message: nil : msg];
    }
    else
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to load topics!";
        
        [Utils message:@"Topic Error" : msg];

    }
}

- (void) processLogout
{
    [Settings setActive: NO];

    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:topicData options:0 error:&localError];
    
    [self stopUI];
    if (localError != nil || parsedObject == nil)
    {
        //[Utils message:@"Logout Error" : @"Invalid data from server!"];
        
        [self close];
        return;
    }
    
    NSString *status  = [parsedObject valueForKey:@"status"];
    //NSString *msg  = [parsedObject valueForKey:@"message"];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        //if(msg == nil || [msg length] == 0) msg = @"Unable to add topic!";
        //[Utils message:@"Logout Error" : msg];
        
        [self close];
        return;
    }
    
    [self close];
}

@end
