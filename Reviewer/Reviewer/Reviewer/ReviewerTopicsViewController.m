//
//  ReviewerTopicsViewController.m
//  Reviewer
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "ReviewThis.h"
#import "TopicItem.h"
#import "TopicSectionItem.h"
#import "AppDelegate.h"
#import "TopicViewCell.h"
#import "ReviewViewController.h"
#import "ReviewerTopicsViewController.h"

#import "Settings.h"
#import "Utils.h"

#define ACTIONSHEET_MENU        1
#define ACTIONSHEET_DELETE      2

#define TOPIC_CELL              @"TopicViewCell"

#define API_LIST        0
#define API_ADD         1
#define API_LOGOUT      4

@interface ReviewerTopicsViewController ()
{
    MBProgressHUD *hud;

    int api_call;
    NSMutableData *topicData;
    NSURLConnection *topicConnection;

    NSIndexPath *selectedIndexPath;
}
@end

@implementation ReviewerTopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.removeFromSuperViewOnHide = NO;
    [self.navigationController.view addSubview:hud];

    UIBarButtonItem *navButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu:)];
    self.navItem.leftBarButtonItem = navButtonItem;
    
    self.sectionList = [NSMutableArray new];
    
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

- (IBAction)onRefresh:(id)sender
{
    [self loadTopics];
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    TopicSectionItem *secItem = [self.sectionList objectAtIndex: section];
    if(secItem == nil)
        return 0;
    else
        return secItem.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TopicSectionItem *secItem = [self.sectionList objectAtIndex: section];
    if(secItem == nil)
        return 0;
    else
        return [secItem.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicViewCell *cell = (TopicViewCell *)[self.topicTable dequeueReusableCellWithIdentifier: TOPIC_CELL];
    cell.indexPath = indexPath;
    
    TopicItem *item = nil;
    TopicSectionItem *secItem = [self.sectionList objectAtIndex: indexPath.section];
    if(secItem != nil)
    {
        item = [secItem.data objectAtIndex: indexPath.row];
    }
    
    if (item != nil)
    {
        [cell.titleLabel setText: item.name];
    }
    else
    {
        [cell.titleLabel setText: @""];
    }
    
    return cell;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self openTopic: indexPath];
    
    [self.topicTable deselectRowAtIndexPath:indexPath animated:NO];
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

- (void) startUI
{
    [self.refreshBar setEnabled: NO];
    [hud show:YES];
}

- (void) stopUI
{
    [self.refreshBar setEnabled: YES];
    [hud hide: YES];
}

- (void) logout
{
    [topicConnection cancel];

    [self startUI];
    
    api_call = API_LOGOUT;
    
    NSString *url = [NSString stringWithFormat: @"%@?stamp=%ld", APP_URL_REVIEWER_LOGOUT, (long)[[NSDate new] timeIntervalSince1970]];
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
    TopicSectionItem *secItem = [self.sectionList objectAtIndex: indexPath.section];
    if(secItem != nil)
    {
        TopicItem *item = [secItem.data objectAtIndex: indexPath.row];
        if([secItem.key isEqualToString:@"active"])
        {
            [self openReview: item];
        }
        else
        {
            [self openVideos: item];
        }
    }
}

- (void) openReview: (TopicItem *) item
{
    ReviewViewController *reviewController = [[ReviewViewController alloc] initWithNibName:@"ReviewViewController" bundle:nil];
    reviewController.topic = item;
    reviewController.delegate = self;
    [[AppDelegate rootController] pushViewController:reviewController animated:YES];
}

- (void) openVideos: (TopicItem *) item
{
}

- (void) loadTopics
{
    [self startUI];
    
    api_call = API_LIST;

    NSString *url = [NSString stringWithFormat: @"%@?stamp=%ld", APP_URL_REVIEWER_TOPIC, (long)[[NSDate new] timeIntervalSince1970]];
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
    
    if(msg == nil || [msg length] == 0) msg = @"Topic successfully added!";
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
        [self.sectionList removeAllObjects];
        
        TopicSectionItem *sectionItem;
        NSDictionary *dataObject = [parsedObject valueForKey: @"data"];
        if(dataObject != nil)
        {
            sectionItem = [TopicSectionItem new];
            sectionItem.key = @"active";
            sectionItem.title = @"Active";
            sectionItem.data = [NSMutableArray new];
            
            NSDictionary *actObject = [dataObject valueForKey: @"active"];
            for (NSDictionary *dic in actObject)
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
                
                [sectionItem.data addObject: item];
            }
            
            if([sectionItem.data count] > 0)
            {
                [self.sectionList addObject: sectionItem];
            }
            
            sectionItem = [TopicSectionItem new];
            sectionItem.key = @"history";
            sectionItem.title = @"History";
            sectionItem.data = [NSMutableArray new];
            
            NSDictionary *hstObject = [dataObject valueForKey: @"history"];
            for (NSDictionary *dic in hstObject)
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
                
                [sectionItem.data addObject: item];
            }
            
            if([sectionItem.data count] > 0)
            {
                [self.sectionList addObject: sectionItem];
            }
        }
        
        [self.topicTable reloadData];
        

        if([self.sectionList count] == 0)
        {
            [Utils message: nil : @"No topics available!"];
        }
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

#pragma mark - ReviewViewDelegate
- (void) reviewSuccessful
{
    [self loadTopics];
}

@end
