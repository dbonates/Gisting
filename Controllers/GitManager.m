//
//  GitManager.m
//  Gisting
//
//  Created by Daniel Bonates on 5/9/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import "GitManager.h"
#import <UAGithubEngine/UAGithubEngine.h>
#import "Gist.h"


#define USER_NAME @"dbonates"
#define PASSWORD @"sdtl2302"

@interface GitManager ()
@property (nonatomic, strong) UAGithubEngine *gitEngine;
@property (nonatomic, strong) NSArray *remoteGists;
@end

@implementation GitManager

@synthesize gitEngine, remoteGists;

+ (id)sharedManager
{
    static dispatch_once_t onceQueue;
    static GitManager *gitManager = nil;
    
    dispatch_once(&onceQueue, ^{
        
        gitManager = [[self alloc] initWithEngine];
    });
    return gitManager;
}


#pragma mark -
#pragma mark Git Engine


- (id)initWithEngine
{
    self = [super init];
    
    if (self) {
        //    [Gist MR_truncateAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        //    Gist * gTest = [Gist MR_findFirst];
        //    if (gTest) [gTest  MR_deleteEntity];
        gitEngine = [[UAGithubEngine alloc] initWithUsername:USER_NAME password:PASSWORD withReachability:YES];
        //    [self setupForGists:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"UAGithubReachabilityStatusDidChangeNotification" object:nil];
    }
    
    
    return self;
}

#pragma mark Github

- (void)setupForRepositories
{
    
    [gitEngine repositoriesWithSuccess:^(id response) {
        //        sLOG(@"repositorios!!!");
    } failure:^(NSError *error) {
        //        dLOG(@"deu ruim!");
    }];
}

#pragma mark Gist

- (void)setupForGists:(BOOL)syncing
{
    
    [gitEngine gistsForUser:USER_NAME success:^(id response) {
        
        sLOG(@"gists baixados");
        
        remoteGists   = response;
        NSArray *localGists    = [Gist MR_findAll];
        
        iLOG(@"remoteGists: %d", [remoteGists count]);
        iLOG(@"localGists: %d", [localGists count]);
        
        if ([remoteGists count] < 1) return; // No gist at all, return
        
        if ([localGists count] < 1) { // No local gist, so save all
            [self saveAllGists:remoteGists];
        }
        // adicionar novos, ignorar os velhos
        // qualquer gist no repositório que não esteja local, será adicionado
        else if ([remoteGists count] != [[Gist MR_numberOfEntities] intValue]) {
            for (int i=0; i< [remoteGists count]; i++) {
                
                Gist *localExistingGist = [Gist MR_findFirstByAttribute:@"id" withValue:[[remoteGists objectAtIndex:i] valueForKey:@"id"]];
                
                NSDictionary *remoteGist = [remoteGists objectAtIndex:i];
                
                if (!localExistingGist) { // Not found on local, then save
                    wLOG(@"Saving gist: %@", [remoteGist valueForKey:@"id"]);
                    [self persistGist: [remoteGists objectAtIndex:i]];
                }
            }
        }
        else
        {
            iLOG(@"total gists local == total remote. Sync and Show");
        }
        
        if (syncing) {
            [self syncGists];
        }
        
    } failure:^(NSError *error) {
        dLOG(@"Não foi possível recuperar gists do repositório!");
    }];
}


- (void)syncGists
{
    iLOG(@"syncGists");
    
    int gistsUpdateds = 0;
    
    if(!remoteGists)
    {
        wLOG(@"ERRO! Não encontrei referência para gists remotos, buscando agora...");
        
        [gitEngine gistsForUser:USER_NAME success:^(id response) {
            remoteGists   = response;
        } failure:^(NSError *error) {
            dLOG(@"Não foi possível recuperar gists do repositório!");
        }];
        
    }
    
    for (int i=0; i< [remoteGists count]; i++) {
        
        Gist *localExistingGist = [Gist MR_findFirstByAttribute:@"id" withValue:[[remoteGists objectAtIndex:i] valueForKey:@"id"]];
        NSDictionary *remoteGist = [remoteGists objectAtIndex:i];
        
        NSDate *remoteUpdatedDate = [self dateFromString:[remoteGist valueForKey:@"updated_at"]];
        NSDate *localUpdatedDate = [localExistingGist valueForKey:@"updated_at"];
        
        if (![remoteUpdatedDate isEqualToDate:localUpdatedDate]
            && [remoteUpdatedDate laterDate:localUpdatedDate] == remoteUpdatedDate) {
            wLOG(@"Update gist: %@", [localExistingGist valueForKey:@"id"]);
            [self updateGist:[localExistingGist valueForKey:@"id"] withGist:remoteGist];
            gistsUpdateds++;
        }
    }
    
    iLOG(@"Gists updated: %d", gistsUpdateds);
    
}

- (void)saveAllGists:(NSArray *)gistArray
{
    wLOG(@"saveAllGists");
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Gist *gist;
    for (int i=0; i< [gistArray count]; i++) {
        
        gist = [Gist MR_createInContext:localContext];
        
        gist.created_at =   [self dateFromString:[(NSDictionary *)[gistArray objectAtIndex:i] valueForKey:@"created_at"]];
        gist.updated_at =   [self dateFromString:[(NSDictionary *)[gistArray objectAtIndex:i] valueForKey:@"updated_at"]];
        gist.desc =         [(NSDictionary *)[gistArray objectAtIndex:i] valueForKey:@"description"];
        gist.html_url =     [(NSDictionary *)[gistArray objectAtIndex:i] valueForKey:@"html_url"];
        gist.id =           [(NSDictionary *)[gistArray objectAtIndex:i] valueForKey:@"id"];
        gist.public =       [(NSDictionary *)[gistArray objectAtIndex:i] valueForKey:@"public"];
    }
    
    [localContext MR_saveToPersistentStoreAndWait];
    
    
}


- (void)updateGist:(NSString *)localGistId withGist:(NSDictionary *)remoteGist
{
    iLOG(@"updateGist");
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Gist *gistFounded = [Gist MR_findFirstByAttribute:@"id" withValue:localGistId];
    if (gistFounded) {
        gistFounded.created_at =   [self dateFromString:[remoteGist valueForKey:@"created_at"]];
        gistFounded.updated_at =   [self dateFromString:[remoteGist valueForKey:@"updated_at"]];
        gistFounded.desc =         [remoteGist valueForKey:@"description"];
        gistFounded.html_url =     [remoteGist valueForKey:@"html_url"];
        gistFounded.id =           [remoteGist valueForKey:@"id"];
        gistFounded.public =       [remoteGist valueForKey:@"public"];
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

- (void)persistGist:(NSDictionary *)gistDict
{
    wLOG(@"persistGist: %@", [gistDict valueForKey:@"id"]);
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Gist *gist = [Gist MR_createInContext:localContext];
    gist.created_at =   [self dateFromString:[gistDict valueForKey:@"created_at"]];
    gist.updated_at =   [self dateFromString:[gistDict valueForKey:@"updated_at"]];
    gist.desc =         [gistDict valueForKey:@"description"];
    gist.html_url =     [gistDict valueForKey:@"html_url"];
    gist.id =           [gistDict valueForKey:@"id"];
    gist.public =       [gistDict valueForKey:@"public"];
    [localContext MR_saveToPersistentStoreAndWait];
}

#pragma mark tools

- (void)reachabilityChanged:(NSNotification *)notification
{
    //    iLOG(@"%@", notification.description);
}

- (NSDate *)dateFromString:(NSString *)dateString
{
    // "2013-05-06T16:38:54Z"
    // wLOG(@"String data: %@, tipo:%@", dateString, NSStringFromClass([dateString class]));
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    
    return [dateFormatter dateFromString:dateString];
}

@end
