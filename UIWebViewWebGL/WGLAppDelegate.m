//
//  WGLAppDelegate.m
//  UIWebViewWebGL
//
//  Created by Nathan de Vries on 27/10/11.
//  Copyright (c) 2011 Nathan de Vries. All rights reserved.
//

#import "WGLAppDelegate.h"

#import "Datastore.h"
#import "RootViewController.h"

@implementation WGLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[Datastore sharedDatastore] open:@"bookmark.db"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    RootViewController *rootViewController = [RootViewController.alloc init];
    self.navigationController = [UINavigationController.alloc initWithRootViewController:rootViewController];
    self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
