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
#import "GADInterstitial.h"


@interface MenuController ()
{
    ClassicGameController *classicGameController;
    SnakeButton *button;
    GADInterstitial *interstitial_;

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
    UITapGestureRecognizer *newgameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showNewGame)];
    [_newgameLabel addGestureRecognizer:newgameTap];
    
    [button showHead:^{
        
        [UIView animateWithDuration:1.0 animations:^{
            _newgameLabel.alpha = 1;
        }];
        
    }];
    
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"ca-app-pub-5576864578595597/8891080263";
    [interstitial_ loadRequest:[GADRequest request]];
}

- (void)pauseGameOnBackground
{
    if (classicGameController && classicGameController.gameState == kCurrentGameStatePlay)
        [classicGameController changeGameState];
}

#pragma mark - Show Ad
- (IBAction)showAd:(id)sender 
{
    [interstitial_ presentFromRootViewController:self];
}

#pragma mark - New Game

- (void)showNewGame
{
    classicGameController =  [[ClassicGameController alloc]init];
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
