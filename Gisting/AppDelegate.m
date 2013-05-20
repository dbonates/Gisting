//
//  AppDelegate.m
//  Gisting
//
//  Created by Daniel Bonates on 5/8/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import "AppDelegate.h"
#import "PonyDebugger.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        
    UIStoryboard *storyboard = [self storyboard];
    [self.window setRootViewController:[storyboard instantiateInitialViewController]];

    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"gists.sqlite"];
    
    /*
     Pony DEBUG: #import "PonyDebugger.h"
     */
    PDDebugger *debugger = [PDDebugger defaultInstance];
    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
    [debugger enableNetworkTrafficDebugging];
    [debugger enableCoreDataDebugging];
    [debugger addManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [debugger forwardAllNetworkTraffic];
    [debugger enableViewHierarchyDebugging];

    
    return YES;
}

- (UIStoryboard *)storyboard
{
    NSString *sbName = @"Storyboard_";
    if (isPad) {
        sbName = [sbName stringByAppendingString:@"iPad"];
    }
    else
    {
        sbName = [sbName stringByAppendingString:@"iPhone"];
    }
    
    return [UIStoryboard storyboardWithName:sbName bundle:nil];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

@end
