//
//  Settings.m
//
//
//  Created by Anthonio Ez on 18/Nov/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import "Settings.h"


@implementation Settings

+ (BOOL) getActive
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *data = [defaults valueForKey: SETTING_ACTIVE];
    if(data == nil)
        return false;
    else
        return [data boolValue];
}
+ (void) setActive:(BOOL)state
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:state] forKey:SETTING_ACTIVE];
}

+ (NSString *) getUser
{
    return [NSString stringWithFormat: @"%ld", [Settings getUserId]];
}
+ (long) getUserId
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *data = [defaults valueForKey: SETTING_USER_ID];
    if(data == nil)
        return 0;
    else
        return [data longValue];
}
+ (void) setUserId:(long)uid
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: [NSNumber numberWithLong: uid] forKey: SETTING_USER_ID];
}

+ (NSString*) getUserHash
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *data = [defaults valueForKey: SETTING_USER_HASH];
    if(data == nil)
        return @""; 
    else
        return data;
}
+ (void) setUserHash:(NSString *)hash
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: hash forKey: SETTING_USER_HASH];
}


@end
