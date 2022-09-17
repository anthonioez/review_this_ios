//
//  AppDelegate.h
//  Requester
//
//  Created by Anthonio Ez on 2/8/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SplashViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SplashViewDelegate, LoginViewDelegate, RegisterViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (UINavigationController *)rootController;

@end

