//
//  ClassicGameController.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "ParticleView.h"
#import "CustomLabel.h"

@interface ClassicGameController : UIViewController

@property (strong,nonatomic)ParticleView *particleView;
@property (assign,nonatomic) BOOL gameIsPaused;
@property (strong,nonatomic) CustomLabel *scoreLabel;
@property (strong,nonatomic) CustomLabel *chainLabel;
@property (strong,nonatomic) CustomLabel *levelLabel;
@property (nonatomic,assign) BOOL timeMode;

-(void)hideLevelLabel;
-(void)showLevelLabel;
-(void)hideScoreLabel;
-(void)showScoreLabel;
-(void)gameOver;
-(void)disableLevelCheck;
-(void)setScanSpeed:(NSTimeInterval)interval;
-(void)replayGame;
-(void)setBgImage:(UIImage *)image;
-(void)pauseGamePress;
-(void)playGame;
-(void)pauseGameFromBackground;
-(void)backToHome:(UIButton *)button;
-(void)pauseLayer:(CALayer*)layer;
-(void)resumeLayer:(CALayer*)layer;
-(void)stopMusic;
-(void)continueGame;
-(void)showSetting:(UIButton *)button;
-(void)resumeGameFromBackground;

@end
