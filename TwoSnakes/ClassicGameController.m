//
//  ClassicGameController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "ClassicGameController.h"
#import "MenuController.h"

@interface ClassicGameController ()
{
    NSInteger numDotAte;
    NSInteger maxCombos;
    NSInteger score;
    UILabel *scoreLabel;
    NSNumberFormatter *numFormatter; //Formatter for score

}
@end

@implementation ClassicGameController

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
    
    // Setup game pad
    self.gamePad = [[GamePad alloc]initGamePad];
    self.gamePad.center = self.view.center;
    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [self.gamePad addGestureRecognizer:gamePadTap];
    [self.view addSubview:self.gamePad];
    
    // Setup snake head
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:CGRectMake(147, 189, 20, 20)];
    [self.gamePad addSubview:self.snake];
    
    // Setup score label
    CGFloat labelWidth = 100;
    scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2, 10, labelWidth, 50)];
    scoreLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
    scoreLabel.text = @"Score";
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:scoreLabel];
    
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // Game Settings
    numDotAte = 0;
    maxCombos = 0;
    score = 0;
//    self.gamePad.userInteractionEnabled = NO;
    
//    [self startCoundDown];
}

#pragma mark - Setscore

- (void)setScore
{
    NSInteger comboAdder = 50;
    for (int i = 0 ; i < [self.snake combos] ; i ++) {
        score += comboAdder;
        comboAdder *= 2;
    }
    self.snake.combos = 0;
    numDotAte++;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
