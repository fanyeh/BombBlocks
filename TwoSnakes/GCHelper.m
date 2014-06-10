//
//  GCHelper.m
//  BrickWar
//
//  Created by Jack Yeh on 2014/4/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper 

#pragma mark Initialization

static GCHelper *sharedHelper = nil;

+ (GCHelper *) sharedInstance
{
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init
{
    if ((self = [super init])) {
        _gameCenterAvailable = [self isGameCenterAvailable];
        if (_gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
            
        }
    }
    return self;
}

- (void)authenticationChanged
{
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;

    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
}

#pragma mark User functions

- (void)authenticateLocalUser:(UIViewController *)gameViewcontroller
{
    
    if (!_gameCenterAvailable)
        return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        
        __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

        [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error) {
            
            // If Player has not signed in game center viewController will be game center sign in view controller
            // Otherwise viewController = nil
            
//            NSLog(@"Game center controller %@",viewController);
            
            if (viewController != nil) {
                
                if (gameViewcontroller.presentedViewController != nil) {
                
                    [gameViewcontroller.presentedViewController presentViewController:viewController
                                                     animated:YES
                                                   completion:nil];
                } else {
                    
                    [gameViewcontroller presentViewController:viewController
                                                     animated:YES
                                                   completion:nil];
                    
                }
            }

            [localPlayer registerListener:self];

      };
    } else {

        NSLog(@"Already authenticated!");
    }
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)theDelegate {
    
    if (!_gameCenterAvailable) return;
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    _delegate = theDelegate;
    
    if (_pendingInvite != nil) {
        
        [_presentingViewController dismissViewControllerAnimated:NO completion:nil];
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:_pendingInvite];
        mmvc.matchmakerDelegate = self;
        [_presentingViewController presentViewController:mmvc animated:YES completion:nil];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
        
    } else {
        
        [_presentingViewController dismissViewControllerAnimated:NO completion:nil];
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = minPlayers;
        request.maxPlayers = maxPlayers;
        request.playersToInvite = _pendingPlayersToInvite;
        
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
        mmvc.matchmakerDelegate = self;
        
        [_presentingViewController presentViewController:mmvc animated:YES completion:nil];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
        
    }
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [_presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [_presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch
{
    [_presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.match = theMatch;
    _match.delegate = self;
    if (!matchStarted && _match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        // Add inside matchmakerViewController:didFindMatch, right after @"Ready to start match!":
        [self lookupPlayers];
    }
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    if (_match != theMatch) return;
    
    [_delegate match:theMatch didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if (_match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                // Add inside match:playerdidChangeState, right after @"Ready to start match!":
                [self lookupPlayers];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            matchStarted = NO;
            [_delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error
{
    
    if (_match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [_delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error
{
    
    if (_match != theMatch) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [_delegate matchEnded];
}

// Add new method after authenticationChanged
- (void)lookupPlayers {
    
    NSLog(@"Looking up %lu players...", (unsigned long)_match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:_match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error)
    {
        
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            matchStarted = NO;
            [_delegate matchEnded];
        } else {
            
            // Populate players dict
            _playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [_playersDict setObject:player forKey:player.playerID];
            }
            
            // Notify delegate match can begin
            matchStarted = YES;
            [_delegate matchStarted];
            
        }
    }];
}

#pragma mark - Game Center UI method
-(void) showGameCenterViewController:(UIViewController *)viewcontroller
{

//    if ([GKLocalPlayer localPlayer].authenticated == NO) {
//        [self authenticateLocalUser:viewcontroller];
//    } else {
        GKGameCenterViewController *gameCenterViewController= [[GKGameCenterViewController alloc] init];
        gameCenterViewController.gameCenterDelegate = self;
        gameCenterViewController.viewState = GKGameCenterViewControllerStateDefault;
        [viewcontroller presentViewController: gameCenterViewController
                                     animated:YES
                                   completion:nil];
//    }
}

#pragma mark - GKGameCenterControllerDelegate method

- (void)gameCenterViewControllerDidFinish: (GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GKLocalPlayerListener

-(void)player:(GKPlayer *)player didAcceptInvite:(GKInvite *)invite
{
    NSLog(@"Received invite");
    self.pendingInvite = invite;
    [_delegate inviteReceived];
}

-(void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite
{
    NSLog(@"Request invite");
    self.pendingPlayersToInvite = playerIDsToInvite;
    [_delegate inviteReceived];
}


-(void) submitScore:(int64_t)score leaderboardId:(NSString*)leaderboardId {
    //1: Check if Game Center
    // features are enabled
    if (!_gameCenterAvailable) {
        NSLog(@"Player not authenticated");
        return;
    }
    //2: Create a GKScore object
    GKScore* gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardId];
    
    //3: Set the score value
    gkScore.value = score;
    gkScore.context = 0;
    
    //4: Send the score to Game Center
    [GKScore reportScores:@[gkScore] withCompletionHandler:^(NSError *error) {
        [self setLastError:error];
        BOOL success = (error == nil);
        [_delegate onScoresSubmitted:success];
    }];
}

- (void)getScoreRankFromLeaderboard:(void(^)(NSArray *topScores))completeBlock
{
    // features are enabled
    if (!_gameCenterAvailable) {
        NSLog(@"Player not authenticated");
        return;
    }
    
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        
        for (GKLeaderboard *board in leaderboards) {
            
            if ([board.identifier isEqualToString:kHighScoreLeaderboardId]) {
                
                [board loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                    
                    completeBlock(scores);
                    
                }];
                
            }
        }
    
    }];
}

#pragma mark Property setters
-(void) setLastError:(NSError*)error {
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
    }
}

@end
