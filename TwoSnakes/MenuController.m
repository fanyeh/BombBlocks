//
//  MenuController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/16.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "MenuController.h"
#import "ClassicGameController.h"
#import "SnakeButton.h"
#import "GameRecordController.h"
#import "LevelListController.h"
#import "LevelMakerController.h"

@interface MenuController ()
{
    ClassicGameController *classicGameController;
}
@property (weak, nonatomic) IBOutlet UIView *leftEye;
@property (weak, nonatomic) IBOutlet UIView *rightEye;
@property (weak, nonatomic) IBOutlet UIView *mouth;
@property (weak, nonatomic) IBOutlet UILabel *gamecenterLabel;
@property (weak, nonatomic) IBOutlet UILabel *newgameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordsLabel;
@property (weak, nonatomic) IBOutlet UIView *snakeHead;
@property (weak, nonatomic) IBOutlet UILabel *puzzleLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelmakerLabel;

@end

@implementation MenuController

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
    // Do any additional setup after loading the view from its nib.
    
    _snakeHead.layer.cornerRadius = _snakeHead.frame.size.width/4;
    
    _leftEye.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    _leftEye.layer.cornerRadius = _leftEye.frame.size.width/2;
    _leftEye.layer.borderWidth = 30;
    _leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    _rightEye.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    _rightEye.layer.cornerRadius = _rightEye.frame.size.width/2;
    _rightEye.layer.borderWidth = 30;
    _rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    _mouth.layer.cornerRadius = _mouth.frame.size.width/2;
    _mouth.frame = CGRectInset(_mouth.frame, 0 , -20);
    _gamecenterLabel.layer.cornerRadius = _gamecenterLabel.frame.size.width/2;
    UITapGestureRecognizer *gamecenterTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showGameCenter)];
    [_gamecenterLabel addGestureRecognizer:gamecenterTap];
    
    _newgameLabel.layer.cornerRadius = _newgameLabel.frame.size.width/2;
    UITapGestureRecognizer *newgameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showNewGame)];
    [_newgameLabel addGestureRecognizer:newgameTap];
    
    _recordsLabel.layer.cornerRadius = _recordsLabel.frame.size.width/2;
    UITapGestureRecognizer *gamerecordTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showGameRecord)];
    [_recordsLabel addGestureRecognizer:gamerecordTap];
    
    _puzzleLabel.layer.cornerRadius = _puzzleLabel.frame.size.width/2;
    UITapGestureRecognizer *levelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(listLevels)];
    [_puzzleLabel addGestureRecognizer:levelTap];
    
    _levelmakerLabel.layer.cornerRadius = _levelmakerLabel.frame.size.width/2;
    UITapGestureRecognizer *levemakerlTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLevelMaker)];
    [_levelmakerLabel addGestureRecognizer:levemakerlTap];


    if (_state == kGameStateContinue)
        _newgameLabel.text = @"Continue";
    else
        _newgameLabel.text = @"New Game";
}

- (void)listLevels
{
    LevelListController *controller = [[LevelListController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showLevelMaker
{
    LevelMakerController *controller = [[LevelMakerController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Hide statu bar

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Game center

- (void)showGameCenter
{
    [[GCHelper sharedInstance] showGameCenterViewController:self];
}

#pragma mark - New Game

- (void)showNewGame
{
    if (_state == kGameStateContinue) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        classicGameController =  [[ClassicGameController alloc]init];
        [self presentViewController:classicGameController animated:YES completion:nil];
        
    }
}

#pragma mark - Background pause game
- (void)pauseGameOnBackground
{
//    [snakeGameController backgroundPauseGame];

//    if (snakeGameController && snakeGameController.snakeButton.state == kSnakeButtonPause) {
//        [snakeGameController backgroundPauseGame];
//        NSLog(@"pause");
//    } else {
//        NSLog(@"Not pause");
//    }
}

#pragma mark - Show game record

-(void)showGameRecord
{
    GameRecordController *controller = [[GameRecordController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
}


@end
