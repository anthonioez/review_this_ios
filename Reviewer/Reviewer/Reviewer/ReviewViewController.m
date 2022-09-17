//
//  ReviewViewController.m
//  Reviewer
//
//  Created by Anthonio Ez on 2/12/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ReviewThis.h"
#import "AppDelegate.h"
#import "ReviewViewController.h"
#import "Utils.h"
#import "Settings.h"

#define API_INFO        0
#define API_VIDEO       1
#define API_UPLOAD      2

#define ALERTVIEW_ABORT     10

@interface ReviewViewController ()
{
    int api_call;
    
    MBProgressHUD *hud;
    
    NSURL *videoURL;
    NSString *videoFile;
    long videoId;
    long videoSeq;
    
    NSMutableData *topicData;
    NSURLConnection *topicConnection;
}
@end

@implementation ReviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.removeFromSuperViewOnHide = NO;
    [self.navigationController.view addSubview:hud];
    
    
    self.backBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
    self.navItem.leftBarButtonItem = self.backBar;

    self.navItem.title = self.topic.name;
    
    [self.startButton setHidden: YES];
    
    [self loadInfo];
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
    [topicConnection cancel];
    
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

- (IBAction)onStart:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        [Utils message:nil :@"Video camera feature not available on this device!"];
        return;
    }
    
    [self.startButton setHidden: YES];
    
    [self.backBar setEnabled: NO];
    
    [self loadVideo];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    //[hud removeFromSuperview];
    //hud = nil;
}

#pragma mark - NSConn
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [hud hide: YES];
    [Utils message:@"Topic Error" : [error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [topicData appendData:data];
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
    NSString *response = [[NSString alloc]initWithData: topicData encoding:NSUTF8StringEncoding];
    NSLog(@"topic response: %@", response);
    
    if(api_call == API_INFO)
        [self processInfo];
    else if(api_call == API_VIDEO)
        [self processVideo];
    else if(api_call == API_UPLOAD)
        [self processUpload];
}

#pragma mark - Functions
- (void) cancel
{
    [self.startButton setHidden: NO];
    [self.infoText setHidden: NO];
    [self.backBar setEnabled: YES];
    
}

- (void) loadInfo
{
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud show: YES];

    api_call = API_INFO;
    
    NSString *url = [NSString stringWithFormat: @"%@?id=%ld&stamp=%ld", APP_URL_REVIEWER_TOPIC, self.topic.index, (long)[[NSDate new] timeIntervalSince1970]];
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

- (void) loadVideo
{
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [hud show: YES];
    
    api_call = API_VIDEO;
    
    NSString *url = [NSString stringWithFormat: @"%@?topic_id=%ld&stamp=%ld", APP_URL_REVIEWER_VIDEO, self.topic.index, (long)[[NSDate new] timeIntervalSince1970]];
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

- (void) uploadVideo
{
    hud.mode = MBProgressHUDModeDeterminate;

    [hud show: YES];

    api_call = API_UPLOAD;
    
    NSString *filename = [NSString stringWithFormat: @"video%ld.mov", self.topic.index];
    NSString *url = [NSString stringWithFormat: @"%@?topic_id=%ld&video_id=%ld&video_snum=%ld", APP_URL_REVIEWER_VIDEO, self.topic.index, videoId, videoSeq];
    NSLog(@"url : %@", url);
    
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSData *movieData = [NSData dataWithContentsOfURL: videoURL];
    
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
    
    topicData = [NSMutableData new];
    topicConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - Processors
- (void) processInfo
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:topicData options:0 error:&localError];
    
    [hud hide: YES];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Topic Error" : @"Invalid data from server!"];
        return;
    }
    
    NSString *status  = [parsedObject valueForKey:@"status"];
    NSString *msg  = [parsedObject valueForKey:@"message"];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to load topic info!";
        [Utils message:nil : msg];
        
        return;
    }
    
    NSString *info  = [parsedObject valueForKey:@"info"];

    //[self.infoText setText: info];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[info dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [self.infoText setAttributedText: attributedString];
    
    [self.startButton setHidden: NO];
}

- (void) processVideo
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:topicData options:0 error:&localError];
    
    [hud hide: YES];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Topic Error" : @"Invalid data from server!"];
        
        [self.startButton setHidden: NO];
        //TODO ask to try again or abort?
        return;
    }
    
    NSString *status    = [parsedObject valueForKey:@"status"];
    NSString *msg       = [parsedObject valueForKey:@"message"];
    NSString *file      = [parsedObject valueForKey:@"next_video_file"];
    
    long snum           = [[parsedObject valueForKey:@"next_video_snum"] longValue];
    long vid            = [[parsedObject valueForKey:@"next_video_id"] longValue];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to load next video!";
        [Utils message:nil : msg];
        
        [self cancel];

        //TODO ask to try again or abort or continue?
        return;
    }
    
    if(file == nil || vid == 0)
    {
        if(msg == nil || [msg length] == 0) msg = @"Invalid video data from server!";

        [Utils message:nil : msg];

        [self cancel];
        
        //TODO ask to try again or abort or continue?
        return;
    }
    
    [self.startButton setHidden: YES];
    [self.backBar setEnabled: NO];
    [self.infoText setHidden: YES];

    videoId = vid;
    videoSeq = snum;
    videoFile = file;
    
    [self playVideo];
}

- (void) processUpload
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:topicData options:0 error:&localError];
    
    [hud hide: YES];
    if (localError != nil || parsedObject == nil)
    {
        [Utils message:@"Upload Error" : @"Invalid data from server!"];
        
        [self cancel];
        
        [self.startButton setHidden: NO];

        //TODO ask to try again or abort?
        return;
    }
    
    NSString *status    = [parsedObject valueForKey:@"status"];
    NSString *msg       = [parsedObject valueForKey:@"message"];
    NSString *file      = [parsedObject valueForKey:@"next_video_file"];
    
    long vid            = [[parsedObject valueForKey:@"next_video_id"] longValue];
    long snum           = [[parsedObject valueForKey:@"next_video_snum"] longValue];
    
    if(status == nil || ![status isEqual: @"OK"])
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to load topic info!";
        [Utils message:nil : msg];
        
        [self cancel];
        
        [self.startButton setHidden: NO];
        //TODO ask to try again or abort or continue?
        
        return;
    }
    
    if(file == nil || vid == 0)
    {
        if(msg == nil)
        {
            [Utils message:nil : @"Invalid video data from server!"];
            
            [self cancel];
            
            //TODO ask to try again or abort or continue?
            
            return;
        }
        else
        {
            [Utils message:nil : msg];
            
            [self cancel];
            
            [self onClose:self];
            
            [self.delegate reviewSuccessful];
            
            return;
        }
    }
    
    [self.startButton setHidden: YES];
    [self.backBar setEnabled: NO];
    [self.infoText setHidden: YES];
    
    videoId = vid;
    videoSeq = snum;
    videoFile = file;
    
    [self playVideo];
}

#pragma mark - Player
- (void) playVideo
{
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/%@", APP_URL_REQUESTER_STREAM, videoFile]];

    NSLog(@"video url: %@", url);

    MPMoviePlayerViewController *mediaController = [[MPMoviePlayerViewController alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:mediaController.moviePlayer];
    
    [mediaController.moviePlayer setMovieSourceType: MPMovieSourceTypeStreaming];
    [mediaController.moviePlayer setContentURL: url];    
    [self presentMoviePlayerViewControllerAnimated:mediaController];
}

-(void) playFinished: (NSNotification*) notification
{
//    [self dismissMoviePlayerViewControllerAnimated];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMoviePlayerPlaybackDidFinishNotification object: [notification object]];
    
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded)
    {
        [self recordVideo];
    }
    else if (reason == MPMovieFinishReasonUserExited)
    {
        [self askReplay: nil];
    }
    else if (reason == MPMovieFinishReasonPlaybackError)
    {
        [self askReplay: @"An error occurred!"];
    }
}

- (void) askReplay: (NSString *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error message:@"Do you want to cancel the Review?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertView.delegate = self;
    alertView.tag = ALERTVIEW_ABORT;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERTVIEW_ABORT)
    {
        if(buttonIndex == 0)
        {
            [self onClose:self];
        }
        else
        {
            [self playVideo];
        }
    }
}

- (void) recordVideo
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    picker.videoQuality = UIImagePickerControllerQualityTypeLow;//you can change the quality here

    picker.allowsEditing = NO;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion: nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"movie: %@", [videoURL absoluteString]);
    
    [self uploadVideo];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[AppDelegate rootController] dismissViewControllerAnimated:YES completion:NULL];

    [self cancel];
}

@end
