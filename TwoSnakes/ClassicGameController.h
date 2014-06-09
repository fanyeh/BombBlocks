//
//  ClassicGameController.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameSceneTemplateController.h"

@interface ClassicGameController : GameSceneTemplateController

@property(strong,nonatomic) UILabel *scoreLabel;
@property(nonatomic) BOOL newGame;

@end
