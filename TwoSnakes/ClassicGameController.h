//
//  ClassicGameController.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

@interface ClassicGameController : UIViewController
-(void)startTutorial;
-(void)hideLevelLabel;
-(void)hideScoreLabel;
-(void)gameOver;
-(void)disableLevelCheck;
-(void)setScanSpeed:(NSTimeInterval)interval;
-(void)replayGame;

@end
