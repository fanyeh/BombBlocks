//
//  TwoSnakesGameController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/4/29.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TwoSnakesGameController.h"
#import "Snake.h"
#import "SnakeDot.h"

@interface TwoSnakesGameController () <UIAlertViewDelegate>
{
    Snake *playerSnake;
    NSTimer *moveTimer;
    NSTimer *dotTimer;
    NSMutableArray *dotArray;
    float timeInterval;
    NSInteger numDotAte;
    NSInteger chain;
    NSInteger level;
    NSInteger combos;
    NSMutableArray *colorArray;
    BOOL pauseGame;
}

@property (weak, nonatomic) IBOutlet UIView *snakeHeadView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *dots;
@property (weak, nonatomic) IBOutlet UIView *gamePad;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIView *leftEye;
@property (weak, nonatomic) IBOutlet UIView *rightEye;
@property (weak, nonatomic) IBOutlet UILabel *comboLabel;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@end

@implementation TwoSnakesGameController

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
    timeInterval = 0.2;
    numDotAte = 0;
    chain = 3;
    playerSnake = [[Snake alloc]initWithSnakeHead:_snakeHeadView andDirection:kMoveDirectionLeft];
    [self createAllDots];
    level = 1;
    _levelLabel.text = [NSString stringWithFormat:@"Levle : %ld",level];

    _leftEye.layer.cornerRadius = _leftEye.frame.size.width/2;
    _rightEye.layer.cornerRadius = _rightEye.frame.size.width/2;
    
    _leftEye.layer.borderWidth = 1.5;
    _leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    _rightEye.layer.borderWidth = 1.5;
    _rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    playerSnake.gamePad = _gamePad;
//    _gamePad.layer.borderWidth = 1;

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(restartTimer:)
                                                name:@"comboComplete" object:nil];
    
    colorArray = [[NSMutableArray alloc]init];
    [colorArray addObject:[UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000]];
    [colorArray addObject:[UIColor colorWithRed:0.004 green:0.690 blue:0.941 alpha:1.000]];
    [colorArray addObject:[UIColor colorWithRed:0.682 green:0.933 blue:0.000 alpha:1.000]];
    
    pauseGame = NO;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    [playerSnake setTurningNode:location];
}
- (IBAction)pauseGame:(id)sender
{
    if (!pauseGame) {
        pauseGame = YES;
        [moveTimer invalidate];
        [_pauseButton setTitle:@"Continue" forState:UIControlStateNormal];
    } else {
        pauseGame = NO;

        moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
        [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }

    
}

- (IBAction)startGame:(id)sender
{
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
    dotTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showDots) userInfo:nil repeats:YES];

    _startButton.hidden = YES;
}

- (void)restartTimer:(NSNotification *)notif
{
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
}

- (void)showDots
{
    for (SnakeDot *d in dotArray) {
        if (d.hidden) {
            d.smallDot.backgroundColor = [self dotColor];
            d.alpha = 0;
            [UIView animateWithDuration:1 animations:^{
                d.alpha = 1;
            }];
            d.hidden = NO;
        }
    }
}

-(void)changeDirection
{
    if ([playerSnake changeDirectionWithGameIsOver:NO moveTimer:moveTimer]) {
        
        UIAlertView *gameOverAlert = [[UIAlertView alloc]initWithTitle:@"Game Over" message:nil delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil , nil];
        [gameOverAlert show];
        
    } else {
        [self isEatingDot];
    }
}

- (void)isEatingDot
{
    for (SnakeDot *d in dotArray) {
        if (!d.hidden) {
            if (CGRectIntersectsRect([playerSnake snakeHead].frame, d.frame)) {
                d.hidden = YES;
                [_gamePad addSubview:[playerSnake addSnakeBodyWithColor:d.smallDot.backgroundColor]];
                // Check if any snake body can be cancelled
                
                combos = 0;
                [self checkCombo];

                if (numDotAte%30==0 && numDotAte != 0) {
                    level++;
                    _levelLabel.text = [NSString stringWithFormat:@"Levle : %ld",level];
                    timeInterval -= 0.01;
                    [moveTimer invalidate];
                    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
                }
                numDotAte++;
                _dots.text = [NSString stringWithFormat:@"%ld",numDotAte];


                break;


            }
        }
    }
}

- (BOOL)checkCombo
{
    UIColor *repeatColor;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    for (UIView *v in snakeBody) {
        if (![repeatColor isEqual:v.backgroundColor]) {
            repeatColor = v.backgroundColor;
            startIndex = [snakeBody indexOfObject:v];
            endIndex = startIndex;
        } else {
            endIndex = [snakeBody indexOfObject:v];
        }
        
        if (endIndex - startIndex == chain) {
            [moveTimer invalidate];
            _leftEye.alpha = 0;
            _rightEye.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                _leftEye.alpha = 1;
                _rightEye.alpha = 1;


            }];
            [self cancelSnakeBodyByColor:v.backgroundColor];
            combos++;
            _comboLabel.hidden = NO;

            _comboLabel.text =  [NSString stringWithFormat:@"Combo : %ld",combos];

            return YES;
        }
    }
    return NO;
}

// Single body color check
- (void)cancelSnakeBodyByColor:(UIColor *)color
{
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    BOOL completeCheck = YES;
    for (UIView *v in snakeBody) {
        if ([v.backgroundColor isEqual:color]) {
            NSInteger index = [snakeBody indexOfObject:v];
            [self removeSnakeBodyByIndex:index andColor:v.backgroundColor];
            completeCheck = NO;
            break;
        }
    }
    
    // Check if there is other combos
    if (completeCheck) {
        if (![self checkCombo]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"comboComplete" object:nil];
            _comboLabel.hidden = YES;
            combos = 0;
        } 
    }
}

// Single body removal
-(void)removeSnakeBodyByIndex:(NSInteger)index andColor:(UIColor *)color
{
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    for (NSInteger i=index; i < [snakeBody count];i++) {
        if (i < [snakeBody count] -1) {
            // Next body
            UIView *currentBody = [snakeBody objectAtIndex:i];
            UIView *nextBody = [snakeBody objectAtIndex:i+1];
            [UIView animateWithDuration:0.0 animations:^{
                currentBody.backgroundColor = nextBody.backgroundColor;

            }];
        }
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        playerSnake.snakeTail.alpha = 0;
    } completion:^(BOOL finished) {
        
        [playerSnake.snakeTail removeFromSuperview];
        [playerSnake updateTurningNode];
        [playerSnake.snakeBody removeLastObject];
        [self cancelSnakeBodyByColor:color];
    }];

}

#pragma mark -  Reset game

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    for (UIView *v in [playerSnake snakeBody]) {
        [v removeFromSuperview];
    }
    _snakeHeadView.frame = CGRectMake(147, 147, 20, 20);
    
    [playerSnake resetSnake:_snakeHeadView andDirection:[playerSnake headDirection]];
    [_gamePad addSubview:_snakeHeadView];
    timeInterval = 0.2;
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
    
    for (SnakeDot *d in dotArray) {
        d.hidden = NO;
        d.smallDot.backgroundColor = [self dotColor];
    }
    
    numDotAte = 0;
    _dots.text = [NSString stringWithFormat:@"%ld",(long)numDotAte];
    chain = 3;
    level = 1;
    _levelLabel.text = [NSString stringWithFormat:@"Levle : %ld",level];
}

- (void)createAllDots
{
    dotArray = [[NSMutableArray alloc]init];
    CGFloat dotPosX;
    CGFloat dotPosY;
    for (int i = 0 ; i < 14; i ++ ) {
        for (int j = 0 ; j < 19 ; j++) {
            if (i%2==1 && j%2==1) {
                
                dotPosX = i * 21;
                dotPosY = j * 21;
                
                SnakeDot *dot = [[SnakeDot alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 20, 20)];
                dot.layer.cornerRadius = 8;
                dot.smallDot.backgroundColor = [self dotColor];
                [_gamePad addSubview:dot];
                [_gamePad sendSubviewToBack:dot];
                [dotArray addObject:dot];
            }
        }
    }
    
    [self.view bringSubviewToFront:_snakeHeadView];

}

-(UIColor *)dotColor
{
    int index = arc4random()%4;


    UIColor *color;
    switch (index) {
        case 0:
            color = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
            break;
        case 1:
            color = [UIColor colorWithRed:0.004 green:0.690 blue:0.941 alpha:1.000];
            break;
        case 2:
            color = [UIColor colorWithRed:0.682 green:0.933 blue:0.000 alpha:1.000];
            break;
        case 3:
            color = [UIColor colorWithRed:1.000 green:0.733 blue:0.125 alpha:1.000];
            break;
    }
    
    return color;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
