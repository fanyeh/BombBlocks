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
{
    UILabel *pauseLabel;
    GameMenu *menu;
}

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
    menu = [[GameMenu alloc]initWithFrame:self.view.frame];
    menu.frame = CGRectOffset(menu.frame, 0, -568);
    [self.view addSubview:menu];
    
    UITapGestureRecognizer *homeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMenu)];
    [menu.homeLabel addGestureRecognizer:homeTap];
    
    UITapGestureRecognizer *resumeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resumeGame)];
    [menu.resumeLabel addGestureRecognizer:resumeTap];
    
    UITapGestureRecognizer *retryTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retryGame)];
    [menu.retryLabel addGestureRecognizer:retryTap];
    
    UITapGestureRecognizer *levelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(listLevels)];
    [menu.levelLabel addGestureRecognizer:levelTap];
    
    pauseLabel = [[UILabel alloc]initWithFrame:CGRectMake(145, 508, 30, 30)];
//    pauseLabel.text = @"P";
    pauseLabel.backgroundColor = [UIColor blackColor];
    UIView *pauseLeft = [[UIView alloc]initWithFrame:CGRectMake(10, 7, 4, 16)];
    pauseLeft.backgroundColor = [UIColor whiteColor];
    UIView *pauseRight= [[UIView alloc]initWithFrame:CGRectMake(16, 7, 4, 16)];
    pauseRight.backgroundColor = [UIColor whiteColor];
    
    [pauseLabel addSubview:pauseLeft];
    [pauseLabel addSubview:pauseRight];

    pauseLabel.layer.cornerRadius = 30/4;
    pauseLabel.layer.masksToBounds = YES;
    pauseLabel.userInteractionEnabled = YES;
    [self.view addSubview:pauseLabel];
    
    UITapGestureRecognizer *pauseTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pauseGame)];
    [pauseLabel addGestureRecognizer:pauseTap];
    
    // Game Settings
    self.gamePad.userInteractionEnabled = NO;
    _gamePause = YES;
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

#pragma mark - menu controls

- (void)pauseGame
{

}

- (void)backgroundPauseGame
{
    [self menuFade:NO];
    _gamePause = YES;
}

- (void)resumeGame
{
    [self menuFade:YES];
    _gamePause = NO;
}

- (void)retryGame
{
    [self menuFade:YES];
    _gamePause = NO;
}

- (void)backToMenu
{
    [self menuFade:YES];
    _gamePause = YES;
    
    MenuController *controller = [[MenuController alloc]init];
    controller.state = kGameStateContinue;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)menuFade:(BOOL)fade
{
    if (fade) {
        [UIView animateWithDuration:0.5 animations:^{
            menu.frame = CGRectOffset(menu.frame, 0, -568);
        }];
    } else {
        [self.view bringSubviewToFront:menu];
        [UIView animateWithDuration:0.5 animations:^{
            menu.frame = CGRectOffset(menu.frame, 0, 568);
        }];
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
    _gamePause = NO;
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
