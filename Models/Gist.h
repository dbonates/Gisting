//
//  Gist.h
//  Gisting
//
//  Created by Daniel Bonates on 5/8/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Gist : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * html_url;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * public;

@end
