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
    _stateSign.image = [UIImage imageNamed:@"replay.png"];
    
    // Setup game state label
    _pauseLabel = [[UILabel alloc]initWithFrame:CGRectMake(320-5-50, 508, 50, 40)];
    //_pauseLabel.layer.cornerRadius = 5;
    //_pauseLabel.text = @"Pl";
    //_pauseLabel.textAlignment = NSTextAlignmentCenter;
    _pauseLabel.backgroundColor =  PadBackgroundColor;
    _pauseLabel.layer.masksToBounds = YES;
    _pauseLabel.userInteractionEnabled = YES;
    
    [_pauseLabel addSubview:_stateSign];
    
    [self.view addSubview:_pauseLabel];
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
