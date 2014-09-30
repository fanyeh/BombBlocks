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

//-(void)startTutorial;
-(void)hideLevelLabel;
-(void)hideScoreLabel;
-(void)gameOver;
-(void)disableLevelCheck;
-(void)setScanSpeed:(NSTimeInterval)interval;
-(void)replayGame;
-(void)setBgImage:(UIImage *)image;
-(void)pauseGame;
-(void)playGame;
-(void)pauseGameFromBackground;
-(void)backToHome:(UIButton *)button;
-(void)pauseLayer:(CALayer*)layer;
-(void)resumeLayer:(CALayer*)layer;
-(void)stopMusic;
-(void)showScoreLabel;
-(void)continueGame;
-(void)showSetting:(UIButton *)button;

@end
