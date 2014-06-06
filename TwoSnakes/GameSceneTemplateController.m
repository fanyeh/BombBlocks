//
//  GameSceneTemplateController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameSceneTemplateController.h"
#import "MenuController.h"
#import "GameMenu.h"
#import "GameAsset.h"
#import "LevelListController.h"



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
    
    UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(13.5, 5, 50, 30)];
    backLabel.backgroundColor = [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    backLabel.text = @"Back";
    backLabel.layer.cornerRadius = 5;
    backLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15];
    backLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    backLabel.textAlignment = NSTextAlignmentCenter;
    backLabel.layer.masksToBounds = YES;
    backLabel.userInteractionEnabled = YES;
    [self.view addSubview:backLabel];
    
    UITapGestureRecognizer *homeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMenu)];
    [backLabel addGestureRecognizer:homeTap];
    
    UILabel *menuLabel = [[UILabel alloc]initWithFrame:CGRectMake(320-13.5-50, 5, 50, 30)];
    menuLabel.backgroundColor = [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    menuLabel.text = @"Menu";
    menuLabel.layer.cornerRadius = 5;
    menuLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15];
    menuLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    menuLabel.textAlignment = NSTextAlignmentCenter;
    menuLabel.layer.masksToBounds = YES;
    [self.view addSubview:menuLabel];
    
    // Setup score label
    CGFloat labelWidth = 120;
    _scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2, 27, labelWidth, 30)];
    _scoreLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
    _scoreLabel.text = @"Score";
    _scoreLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.backgroundColor =  [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    _scoreLabel.layer.cornerRadius = 15;
    _scoreLabel.layer.masksToBounds = YES;
    [self.view addSubview:_scoreLabel];
    
    _pauseLabel = [[UILabel alloc]initWithFrame:CGRectMake(145, 508, 30, 30)];
    UIView *pauseLeft = [[UIView alloc]initWithFrame:CGRectMake(10, 7, 4, 16)];
    pauseLeft.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    UIView *pauseRight= [[UIView alloc]initWithFrame:CGRectMake(16, 7, 4, 16)];
    pauseRight.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    
    //[pauseLabel addSubview:pauseLeft];
    //[pauseLabel addSubview:pauseRight];
    _pauseLabel.layer.cornerRadius = 5;
    _pauseLabel.text = @"Pl";
    _pauseLabel.textAlignment = NSTextAlignmentCenter;
    _pauseLabel.backgroundColor =  [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    _pauseLabel.layer.masksToBounds = YES;
    _pauseLabel.userInteractionEnabled = YES;
    [self.view addSubview:_pauseLabel];
    
    // Game Settings
    self.gamePad.userInteractionEnabled = NO;
    _gameState = kCurrentGameStatePause;
}

- (void)listLevels
{
    LevelListController *controller = [[LevelListController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
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
            _pauseLabel.text = @"Pl";
            
            break;
        case kCurrentGameStatePause:
            _gameState = kCurrentGameStatePlay;
            _pauseLabel.text = @"Pa";

            break;
        case kCurrentGameStateReplay:
            _gameState = kCurrentGameStatePlay;
            _pauseLabel.text = @"Rp";

            break;
    }
    
}

- (void)backToMenu
{
    _gameState = kCurrentGameStatePause;
    
    MenuController *controller = [[MenuController alloc]init];
    controller.state = kGameStateContinue;
    [self presentViewController:controller animated:YES completion:nil];
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
