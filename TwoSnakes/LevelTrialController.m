//
//  LevelTrialController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/26.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "LevelTrialController.h"
#import "GameAsset.h"

@interface LevelTrialController ()

@end

@implementation LevelTrialController

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
    
    self.gamePad = [[GamePad alloc]initGamePadWithAsset:_assetArray];
    self.gamePad.center = self.view.center;
    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [self.gamePad addGestureRecognizer:gamePadTap];
    [self.view addSubview:self.gamePad];
    
    // Setup snake head
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionUp gamePad:self.gamePad headFrame:CGRectMake(147, 441, 20, 20)];
    [self.snake setWallBounds:[self walls]];
    [self.gamePad addSubview:self.snake];

    UIButton *exitButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
    [exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    exitButton.titleLabel.textColor = [UIColor blackColor];
    [exitButton addTarget:self action:@selector(exitTrial) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:exitButton];
    
}

- (void)exitTrial
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)walls
{
    NSMutableArray *wallBounds = [[NSMutableArray alloc]init];
    for (GameAsset *asset in _assetArray) {
        if (asset.gameAssetType == kAssetTypeWall)
           [wallBounds addObject:asset];
    }
    return wallBounds;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
