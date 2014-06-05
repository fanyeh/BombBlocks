//
//  BossFightController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/6/5.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "BossFightController.h"
#import "Snake.h"

@interface BossFightController ()
{
    UILabel *scoreLabel;
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    NSInteger numDotAte;
    NSInteger maxCombos;
    float timeInterval; // Movement speed of snake
    BOOL isCheckingCombo;
    NSTimer *enemyTimer;
    Snake *enemySnake;
    NSMutableArray *enemyPath;
    
    CGRect startFrame;
    
    NSTimer *refillTimer;
    UILabel *floatingLabel;
    
    CGRect floatingFrame;
}
@end

@implementation BossFightController

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
    scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2, 30, labelWidth, 30)];
    scoreLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
    scoreLabel.text = @"Score";
    scoreLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.backgroundColor =  [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    scoreLabel.layer.cornerRadius = 10;
    scoreLabel.layer.masksToBounds = YES;
    [self.view addSubview:scoreLabel];
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 293, 461)];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    backgroundView.layer.cornerRadius = 10;
    backgroundView.center = self.view.center;
    [self.view addSubview:backgroundView];
    
    // Setup game pad
    self.gamePad = [[GamePad alloc]initBossGamePad];
    self.gamePad.center = self.view.center;
    self.gamePad.frame = CGRectOffset(self.gamePad.frame, 0, 84);
    self.gamePad.backgroundColor = [UIColor whiteColor];
    self.gamePad.layer.cornerRadius = 10;
    self.gamePad.layer.masksToBounds = YES;
    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [self.gamePad addGestureRecognizer:gamePadTap];
    [self.view addSubview:self.gamePad];
    
    startFrame = CGRectMake(128, 128, 20, 20);
    // Setup snake head
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:startFrame];
    [self.gamePad addSubview:self.snake];
    UIView *boss = [[UIView alloc]initWithFrame:CGRectMake(84+8, 42 + 8, 105, 105)];
    boss.layer.borderWidth = 5;
    boss.layer.cornerRadius = 5;
    [backgroundView addSubview:boss];
    
    floatingFrame = CGRectMake((backgroundView.frame.size.width - 100)/2, 20, 100, 20);
    floatingLabel = [[UILabel alloc]initWithFrame:floatingFrame];
    floatingLabel.textColor = [UIColor blackColor];
    floatingLabel.text = @"-100";
    floatingLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15];
    floatingLabel.textColor = [UIColor redColor];
    floatingLabel.textAlignment = NSTextAlignmentCenter;
    [backgroundView addSubview:floatingLabel];
    //refillTimer  = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(refill) userInfo:nil repeats:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)refill
//{
//    CGRect frame = _hitPointBar.frame;
//    
//    if (frame.size.height == 0) {
//        [refillTimer invalidate];
//        
//    } else {
//        frame.size.height -= 0.5;
//        _hitPointBar.frame = frame;
//    }
//}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [UIView animateWithDuration:0.3 animations:^{
        
        floatingLabel.alpha = 0 ;
        floatingLabel.frame = floatingFrame;
        
    } completion:^(BOOL finished) {
        
        floatingLabel.alpha = 1 ;

    }];
}

-(void)moveAnimationFrom:(CALayer *)startLayer
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    
    CGPoint endPoint = CGPointMake(startLayer.position.x, startLayer.position.y -20);
    
    anim.fromValue = [startLayer valueForKey:@"position"];
    
    anim.toValue =[NSValue valueWithCGPoint:endPoint];
    
    // Update the layer's position so that the layer doesn't snap back when the animation completes.
    
    anim.duration = 0.8;
    
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    anim.delegate = self;
    
    // Add the animation, overriding the implicit animation.
    [startLayer addAnimation:anim forKey:@"position"];
    
    startLayer.position = endPoint;
    
}

@end
