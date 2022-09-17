//
//  Utils.h
//
//
//  Created by Anthonio Ez on 6/12/14.
//  Copyright (c) 2014 Freelancer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <CommonCrypto/CommonDigest.h>

@interface Utils : NSObject

+ (BOOL) connected;

+ (void) message:(NSString *)title :(NSString *)message;

+ (BOOL) isValidEmail:(NSString *)checkString;

+ (NSString *) md5: (NSString *)input;
@end
