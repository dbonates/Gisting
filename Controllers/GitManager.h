//
//  GitManager.h
//  Gisting
//
//  Created by Daniel Bonates on 5/9/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitManager : NSObject

+ (id)sharedManager;
- (void)setupForGists:(BOOL)syncing;
- (void)syncGists;

@end
