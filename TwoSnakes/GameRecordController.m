//
//  GameRecordController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/16.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameRecordController.h"

@interface GameRecordController ()
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxChainLabel;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@end

@implementation GameRecordController

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
    // Set score record
    
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMenu)];
    [_menuView addGestureRecognizer:menuTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    _scoreLabel.text = [NSString stringWithFormat:@"%ld" , [[NSUserDefaults standardUserDefaults]integerForKey:@"highestScore"] ];
    _maxChainLabel.text =  [NSString stringWithFormat:@"%ld" ,[[NSUserDefaults standardUserDefaults]integerForKey:@"maxCombo"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backToMenu
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Hide statu bar

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
