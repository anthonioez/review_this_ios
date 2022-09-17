//
//  ReviewThis.h
//  Reviewer
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

#define APP_TIMEOUT         60.0


#define APP_URL_REQUESTER_STREAM        @"http://review.webnyx.com/requester/videos"
#define APP_URL_REQUESTER_LOGIN         @"http://review.webnyx.com/requester/login.php"
#define APP_URL_REQUESTER_REGISTER      @"http://review.webnyx.com/requester/register.php"
#define APP_URL_REQUESTER_TOPIC         @"http://review.webnyx.com/requester/topic.php"
#define APP_URL_REQUESTER_VIDEO         @"http://review.webnyx.com/requester/video.php"
#define APP_URL_REQUESTER_LOGOUT        @"http://review.webnyx.com/requester/logout.php"

#define APP_URL_REVIEWER_STREAM         @"http://review.webnyx.com/reviewer/videos"
#define APP_URL_REVIEWER_LOGIN          @"http://review.webnyx.com/reviewer/login.php"
#define APP_URL_REVIEWER_REGISTER       @"http://review.webnyx.com/reviewer/register.php"
#define APP_URL_REVIEWER_TOPIC          @"http://review.webnyx.com/reviewer/topic.php"
#define APP_URL_REVIEWER_VIDEO          @"http://review.webnyx.com/reviewer/video.php"
#define APP_URL_REVIEWER_LOGOUT         @"http://review.webnyx.com/reviewer/logout.php"


typedef NS_ENUM(NSInteger, AppType) {
    AppRequester,
    AppReviewer
};

@interface ReviewThis : NSObject

@property NSString *mainDir;
@property NSString *tempDir;
@property int appType;

+ (ReviewThis *)sharedInstance;

@end
