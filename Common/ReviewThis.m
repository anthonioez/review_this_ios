//
//  ReviewThis.m
//  Reviewer
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "ReviewThis.h"

static ReviewThis *reviewthis;

@implementation ReviewThis

+ (ReviewThis *)sharedInstance
{
    if(reviewthis == nil)
    {
        reviewthis = [ReviewThis new];
        [reviewthis initApp];
    }
    return reviewthis;
}

- (void) initApp
{
    //create local path
    NSString *docsDir = nil;
    NSArray *dirPaths = nil;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  //NSPicturesDirectory
    docsDir = dirPaths[0];
    
    self.mainDir = [docsDir stringByAppendingPathComponent:@"/reviewthis"];
    if(![filemgr fileExistsAtPath:self.mainDir])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath: self.mainDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    // Get the 'Library/Caches/' directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    self.tempDir = [docsDir stringByAppendingPathComponent:@"/reviewthis"];
    if(![filemgr fileExistsAtPath: self.tempDir])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath: self.tempDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
}
@end
