//
//  GameStatsViewController.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/9/2.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol replayDelegate <NSObject>
@required

- (void)replayGame;

@end

@interface GameStatsViewController : UIViewController

@property (nonatomic,assign) NSInteger combos;
@property (nonatomic,assign) NSInteger bombs;
@property (nonatomic,assign) NSInteger score;
@property (nonatomic,assign) NSInteger level;
@property (nonatomic,assign) NSInteger maxBombChain;
@property (nonatomic,assign) BOOL timeMode;
@property (nonatomic,strong) UIImage *gameImage;
@property (nonatomic,strong) UIImage *bgImage;

@property (weak,nonatomic) id<replayDelegate>delegate;

@end
