//
//  GCHelper.h
//  BrickWar
//
//  Created by Jack Yeh on 2014/4/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
- (void)inviteReceived;
- (void)onScoresSubmitted:(bool)success;
@end

@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate ,GKGameCenterControllerDelegate,GKLocalPlayerListener>
{
    BOOL userAuthenticated;
    BOOL matchStarted;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (assign) id <GCHelperDelegate> delegate;
@property (retain) NSMutableDictionary *playersDict;
@property (retain) GKInvite *pendingInvite;
@property (retain) NSArray *pendingPlayersToInvite;
@property (strong,nonatomic) NSError *lastError;
@property (nonatomic,strong) NSArray *leaderboardSets;

+ (GCHelper *)sharedInstance;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)theDelegate;

- (void)authenticateLocalUser:(UIViewController *)gameViewcontroller;

// Game Center UI
//-(void) showGameCenterViewController:(UIViewController*)viewController;
-(void) showGameCenterViewController:(UIViewController *)viewcontroller leaderboardID:(NSString *)leaderboardID;


// Scores
- (void) submitScore:(int64_t)score leaderboardId:(NSString*)leaderboardId;
- (void)getClassicScoreRankFromLeaderboard:(void(^)(NSArray *topScores))completeBlock;
- (void)getFasthandScoreRankFromLeaderboard:(void(^)(NSArray *topScores))completeBlock;

@end