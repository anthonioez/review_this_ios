//
//  VideosViewController.m
//  Requester
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "ReviewThis.h"
#import "VideoItem.h"
#import "AppDelegate.h"
#import "VideoViewCell.h"
#import "VideosViewController.h"
#import "Settings.h"
#import "Utils.h"

#define ACTIONSHEET_ADD         1
#define ACTIONSHEET_DELETE      2

#define VIDEO_CELL              @"VideoViewCell"

#define API_LIST        0
#define API_ADD         1
#define API_DELETE      2

@interface VideosViewController ()
{
    int api_call;
    
    NSURL *videoURL;
    NSMutableData *videoData;
    NSURLConnection *videoConnection;

    MBProgressHUD *hud;
    NSIndexPath *selectedIndexPath;
}
@end

@implementation VideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.removeFromSuperViewOnHide = NO;
    [self.navigationController.view addSubview:hud];
    
    UIBarButtonItem *navButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
    self.navItem.leftBarButtonItem = navButtonItem;
    
    self.navItem.title = self.topic.name;
    [self.infoLabel setText: @""];
    [self.infoLabel setHidden: NO];
    
    self.videoList = [NSMutableArray new];
    
    [self.videoTable registerNib:[UINib nibWithNibName: VIDEO_CELL bundle:nil] forCellReuseIdentifier: VIDEO_CELL];
    
    [self.videoTable setDelegate:self];
    [self.videoTable setDataSource:self];
    
    [self loadVideos];
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
- (IBAction)onClose:(id)sender
{
    [videoConnection cancel];
    
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

- (IBAction)onAdd:(id)sender
{
    [self addConfirm];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if((int) buttonIndex == 1)
    {
        UITextField * textField = [alertView textFieldAtIndex:0];
        
        NSString* name = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([name length] > 0)
        {
            [self addVideo: name];
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == ACTIONSHEET_ADD)
    {
        if(buttonIndex == 1)
        {
            [self videoCamera];
        }
        else if(buttonIndex == 2)
        {
            [self videoPicker];
        }
    }
    else if(actionSheet.tag == ACTIONSHEET_DELETE)
    {
        if(buttonIndex == 1)
        {
            [self deleteVideo];
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
    return [self.videoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoViewCell *cell = (VideoViewCell *)[self.videoTable dequeueReusableCellWithIdentifier: VIDEO_CELL];
    cell.delegate = self;
    cell.actiondelegate = self;
    cell.indexPath = indexPath;
    
    VideoItem *item = [self.videoList objectAtIndex:indexPath.row];
    
    if (item != nil)
    {
        [cell.titleLabel setText: [NSString stringWithFormat: @"%d%@ %@", (int)(indexPath.row + 1), @".", item.name]];   //TODOseq
    }

    
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:64.0f];
    
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self openVideo: indexPath];
    
    [self.videoTable deselectRowAtIndexPath:indexPath animated:NO];
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
            selectedIndexPath = [self.videoTable indexPathForCell:cell];
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

#pragma mark - VideoViewDelegate
- (void) videoPlay:(NSIndexPath *)indexPath
{
    [self openVideo: indexPath];
}

#pragma mark - NSConn
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopUI];
    [Utils message:@"Video Error" : [error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [videoData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    hud.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    hud.labelText = [NSString stringWithFormat:@"%d%@", (int)(((float)totalBytesWritten / (float)totalBytesExpectedToWrite) * 100.0), @"%"];
    
    if(totalBytesExpectedToWrite == totalBytesWritten)
    {
        hud.labelText = nil;
        hud.mode = MBProgressHUDModeIndeterminate;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc]initWithData: videoData encoding:NSUTF8StringEncoding];
    NSLog(@"video response: %@", response);
    
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
}

#pragma mark - Functions
- (void) add
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Video" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Video Name";
    
    alertTextField.backgroundColor = [UIColor whiteColor];
    //    alertTextField.delegate = self;
    alertTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    [alertTextField becomeFirstResponder];
    
    [alert show];
}

- (void) addConfirm
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = ACTIONSHEET_ADD;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet addButtonWithTitle:@"Camera"];
    [actionSheet addButtonWithTitle:@"Existing Video"];
    
    [actionSheet showFromBarButtonItem: self.addBar animated:YES];
//    [actionSheet showInView:self.view];
}

- (void) deleteConfirm
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = ACTIONSHEET_DELETE;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet addButtonWithTitle:@"Delete Video"];
    
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
    [hud show:YES];
    [self.infoLabel setHidden: YES];
    [self.addBar setEnabled: NO];
}

- (void) stopUI
{
    [hud hide:YES];
    [self.addBar setEnabled: YES];
}

- (void) openVideo:(NSIndexPath *)indexPath
{
    VideoItem *item = [self.videoList objectAtIndex: indexPath.row];
    if(item == nil)
    {
        [Utils message:nil :@"Missing video!"];
        return;
    }
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/%@", APP_URL_REQUESTER_STREAM, item.file]];
    
    NSLog(@"video url: %@", url);
    
    MPMoviePlayerViewController *mediaController = [[MPMoviePlayerViewController alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mediaController.moviePlayer];
    
    [mediaController.moviePlayer setMovieSourceType: MPMovieSourceTypeStreaming];
    [mediaController.moviePlayer setContentURL: url];
    [self presentMoviePlayerViewControllerAnimated:mediaController];
}

// When the movie is done, release the controller.
-(void) moviePlaybackDidFinish: (NSNotification*) notification
{
    //[self dismissMoviePlayerViewControllerAnimated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMoviePlayerPlaybackDidFinishNotification object: [notification object]];
}

- (void) loadVideos
{
    hud.mode = MBProgressHUDModeIndeterminate;
    [self startUI];
    
    api_call = API_LIST;

    NSString *url = [NSString stringWithFormat: @"%@?id=%ld&stamp=%ld", APP_URL_REQUESTER_TOPIC, self.topic.index, (long)[[NSDate new] timeIntervalSince1970]];
    NSLog(@"url: %@", url);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];

    [request setHTTPMethod:@"GET"];
    [request setValue:[Settings getUserHash]    forHTTPHeaderField: @"X-Auth-Hash"];
    [request setValue:[Settings getUser]        forHTTPHeaderField: @"X-Auth-UserId"];

    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    videoData = [NSMutableData new];
    videoConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) deleteVideo
{
    if(selectedIndexPath == nil)
    {
        [Utils message:nil :@"Invalid video!"];
        return;
    }
    
    VideoItem *item = [self.videoList objectAtIndex: selectedIndexPath.row];
    if(item == nil)
    {
        [Utils message:nil :@"Missing video!"];
        return;
    }
    
    hud.mode = MBProgressHUDModeIndeterminate;
    [self startUI];
    
    api_call = API_DELETE;
    
    NSString *url = [NSString stringWithFormat: @"%@?id=%ld", APP_URL_REQUESTER_VIDEO, item.index];
    NSLog(@"url: %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"OPTIONS"];     //TODO DELETE"];
    [request setValue:[Settings getUserHash]    forHTTPHeaderField: @"X-Auth-Hash"];
    [request setValue:[Settings getUser]        forHTTPHeaderField: @"X-Auth-UserId"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    videoData = [NSMutableData new];
    videoConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) addVideo: (NSString *)name
{
    hud.mode = MBProgressHUDModeDeterminate;
    [self startUI];
    
    api_call = API_ADD;
    
    NSString *filename = [NSString stringWithFormat: @"video%ld.mov", self.topic.index];
    NSString *url = [NSString stringWithFormat: @"%@?topic_id=%ld&video_title=%@", APP_URL_REQUESTER_VIDEO, self.topic.index, [name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSLog(@"url : %@", url);
    
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSData *movieData = [NSData dataWithContentsOfURL: videoURL];
    NSLog(@"data size: %ld", (long)[movieData length]);
    
    //NSData *movieData = [url dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *contenttype = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSMutableData *postData = [NSMutableData data];
    [postData appendData: [[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"video\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData: [[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"video/quicktime"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData: movieData];
    
    [postData appendData: [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *postSize = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL: [NSURL URLWithString:url]];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: postData];
    [request setValue: postSize                 forHTTPHeaderField:@"Content-Length"];
    [request setValue: [Settings getUserHash]   forHTTPHeaderField: @"X-Auth-Hash"];
    [request setValue: [Settings getUser]       forHTTPHeaderField: @"X-Auth-UserId"];
    [request setValue: contenttype              forHTTPHeaderField:@"Content-Type"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:APP_TIMEOUT];
    
    videoData = [NSMutableData new];
    videoConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - Processors
- (void) processAdd
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:videoData options:0 error:&localError];
    
    [self stopUI];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Video Error" : @"Invalid data from server!"];
        return;
    }

    NSString *status  = [parsedObject valueForKey:@"status"];
    NSString *msg  = [parsedObject valueForKey:@"message"];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to add video!";
        [Utils message:@"Video Error" : msg];
        
        return;
    }
    
    if(msg == nil || [msg length] == 0) msg = @"Video successfully added!";
    [Utils message: nil : msg];
    
    [self updateStatus];
    [self loadVideos];
}

- (void) processDelete
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:videoData options:0 error:&localError];
    
    [self stopUI];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Video Error" : @"Invalid data from server!"];
        return;
    }
    
    NSString *status  = [parsedObject valueForKey:@"status"];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        [Utils message:@"Video Error" : @"Unable to delete video!"];
        return;
    }
    
    //[Utils message: nil : @"Video successfully deleted!"];
    
    [self.videoList removeObjectAtIndex: selectedIndexPath.row];
    [self.videoTable reloadData];
    
    [self updateStatus];

    //[self loadVideos];
}


- (void) processList
{
    NSError *localError = nil;
    NSDictionary* parsedObject = [NSJSONSerialization JSONObjectWithData: videoData options:0 error:&localError];
    
    [self stopUI];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Video Error" : @"Invalid data from server!"];
        return;
    }
    
    if ([parsedObject count] == 0)
    {
        [Utils message:@"Video Error" : @"No data from server!"];
        return;
    }
    
    NSString *status  = [parsedObject valueForKey:@"status"];
    NSString *msg  = [parsedObject valueForKey:@"message"];
    
    if(status != nil && [status isEqual: @"OK"])
    {
        [self.videoList removeAllObjects];
        
        NSDictionary *dataObject = [parsedObject valueForKey: @"data"];
        for (NSDictionary *dic in dataObject)
        {
            long index      = [[dic valueForKey:@"id"] longValue];
            long snum      = [[dic valueForKey:@"snum"] longValue];
            NSString *name  = [dic valueForKey:@"name"];
            NSString *file  = [dic valueForKey:@"file"];
            
            if(name == nil || file == nil)
            {
                continue;
            }
            
            VideoItem *item = [VideoItem new];
            item.index = index;
            item.name = name;
            item.snum = snum;
            item.file = file;
            
            [self.videoList addObject: item];

        }
        
        [self.videoTable reloadData];
        
        if([self.videoList count] > 0)
        {
            if(msg != nil)  [Utils message: nil : msg];
        }
    }
    else
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to load topic videos!";
        
        [Utils message:@"Video Error" : msg];
        
    }
    
    [self updateStatus];
}

- (void) updateStatus
{
    if([self.videoList count] == 0)
    {
        [self.infoLabel setText: @"No videos available for this topic!"];
        [self.infoLabel setHidden: NO];
    }
    else
    {
        [self.infoLabel setText: @""];
        [self.infoLabel setHidden: YES];
    }
}

#pragma mark - Video
- (void) videoCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        [Utils message:nil :@"Video camera feature not available on this device!"];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    picker.videoQuality = UIImagePickerControllerQualityTypeLow;//you can change the quality here
    
    picker.allowsEditing = NO;
    picker.delegate = self;

    [self presentViewController:picker animated:YES completion: nil];
}

- (void) videoPicker
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
    {
        [Utils message:nil :@"Video picker feature not available on this device!"];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    picker.videoQuality = UIImagePickerControllerQualityTypeLow;//you can change the quality here

    picker.allowsEditing = NO;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion: nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
//    [[AppDelegate rootController] dismissViewControllerAnimated: YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"movie: %@", [videoURL absoluteString]);
    
    [self add];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[AppDelegate rootController] dismissViewControllerAnimated:YES completion:NULL];
}

@end
