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

@interface MenuController ()
{
    ClassicGameController *classicGameController;
    SnakeButton *button;
}

@property (weak, nonatomic) IBOutlet UILabel *newgameLabel;

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

    button = [[SnakeButton alloc]initWithTitle:@"Not A "];
    [self.view addSubview:button];

    _newgameLabel.layer.cornerRadius = _newgameLabel.frame.size.width/2;
    _newgameLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    _newgameLabel.backgroundColor = [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    UITapGestureRecognizer *newgameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showNewGame)];
    [_newgameLabel addGestureRecognizer:newgameTap];
    
    [button showHead:^{
        
        [UIView animateWithDuration:1.0 animations:^{
            _newgameLabel.alpha = 1;
        }];
        
    }];
}

- (void)pauseGameOnBackground
{
    if (classicGameController && classicGameController.gameState == kCurrentGameStatePlay)
        [classicGameController changeGameState];
}

//#pragma mark - Game center
//
//- (void)showGameCenter
//{
//    [[GCHelper sharedInstance] showGameCenterViewController:self];
//}

#pragma mark - New Game

- (void)showNewGame
{
    classicGameController =  [[ClassicGameController alloc]init];
    classicGameController.newGame = YES;
    [self presentViewController:classicGameController animated:YES completion:nil];

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

@end
