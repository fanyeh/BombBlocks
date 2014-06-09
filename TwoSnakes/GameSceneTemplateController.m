//
//  GameSceneTemplateController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameSceneTemplateController.h"
#import "MenuController.h"
#import "GameAsset.h"

@interface GameSceneTemplateController ()

@end

@implementation GameSceneTemplateController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _stateSign =  [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    _stateSign.image = [UIImage imageNamed:@"play.png"];
    
    // Setup game state label
    _pauseLabel = [[UILabel alloc]initWithFrame:CGRectMake(135, 508, 50, 40)];
    _pauseLabel.layer.cornerRadius = 5;
    //_pauseLabel.text = @"Pl";
    //_pauseLabel.textAlignment = NSTextAlignmentCenter;
    _pauseLabel.backgroundColor =  [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    _pauseLabel.layer.masksToBounds = YES;
    _pauseLabel.userInteractionEnabled = YES;
    
    [_pauseLabel addSubview:_stateSign];
    
    [self.view addSubview:_pauseLabel];

    
    // Game Settings
    self.gamePad.userInteractionEnabled = NO;
    _gameState = kCurrentGameStatePause;
}

-(void)directionChange:(UITapGestureRecognizer *)sender
{
    if (_gamePad.userInteractionEnabled) {
        CGPoint location = [sender locationInView:_gamePad];
        [_snake setTurningNode:location];
        _gamePad.userInteractionEnabled = NO;

    }
    
    //    CGPoint location = [sender locationInView:newGamePad];
    //
    //    // Show tap point
    //        UIView *tapDot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    //        tapDot.center = location;
    //        tapDot.layer.cornerRadius = 5;
    //        tapDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    //        tapDot.alpha = 0;
    //        tapDot.layer.borderColor = [[UIColor colorWithWhite:0.400 alpha:1.000]CGColor];
    //        tapDot.layer.borderWidth = 1.5;
    //        [newGamePad addSubview:tapDot];
    //
    //        [UIView animateWithDuration:0.3 animations:^{
    //            tapDot.alpha = 1;
    //        } completion:^(BOOL finished) {
    //            [UIView animateWithDuration:0.3 animations:^{
    //                tapDot.alpha = 0;
    //
    //            } completion:^(BOOL finished) {
    //                [tapDot removeFromSuperview];
    //            }];
    //        }];
    
}

- (void)changeGameState
{
    
    switch (_gameState) {
        case kCurrentGameStatePlay:
            _gameState = kCurrentGameStatePause;
            _stateSign.image = [UIImage imageNamed:@"play.png"];
            break;
        case kCurrentGameStatePause:
            _gameState = kCurrentGameStatePlay;
            _stateSign.image = [UIImage imageNamed:@"stop.png"];
            break;
        case kCurrentGameStateReplay:
            _stateSign.image = [UIImage imageNamed:@"stop.png"];
            break;
    }
    
}

#pragma change direction

-(void)changeDirection
{
    self.gamePad.userInteractionEnabled = YES;
}


- (void)startMoveTimer
{
    self.gamePad.userInteractionEnabled = YES;
    _gameState = kCurrentGameStatePlay;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Hide statu bar

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
