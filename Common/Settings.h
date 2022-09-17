//
//  Settings.h
//
//
//  Created by Anthonio Ez on 18/Nov/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SETTING_ACTIVE         @"active"
#define SETTING_USER_ID        @"user_id"
#define SETTING_USER_HASH      @"user_hash"

@interface Settings : NSObject

+ (void) setActive: (BOOL) active;
+ (BOOL) getActive;

+ (void) setUserId:(long)userid;
+ (long) getUserId;
+ (NSString *) getUser;

+ (void) setUserHash:(NSString*)hash;
+ (NSString*) getUserHash;

@end
