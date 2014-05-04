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
}

@property (weak, nonatomic) IBOutlet UIView *snakeHeadView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *dots;
@property (weak, nonatomic) IBOutlet UIView *gamePad;

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
    timeInterval = 0.15;
    numDotAte = 0;
    chain = 2;
    playerSnake = [[Snake alloc]initWithSnakeHead:_snakeHeadView andDirection:kMoveDirectionRight];
    [self createAllDots];
    level = 1;
    _gamePad.layer.borderWidth = 1;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
//    [playerSnake setTurningNode:location];
}

- (IBAction)startGame:(id)sender
{
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
    dotTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showDots) userInfo:nil repeats:YES];

    _startButton.hidden = YES;
}

- (void)showDots
{
    for (SnakeDot *d in dotArray) {
        if (d.hidden) {
            d.smallDot.backgroundColor = [self dotColor];
            d.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
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
            if ([[NSValue valueWithCGRect:[playerSnake snakeHead].frame] isEqualToValue:[NSValue valueWithCGRect:d.frame]]) {
                d.hidden = YES;
                [_gamePad addSubview:[playerSnake addSnakeBodyWithColor:d.smallDot.backgroundColor]];
                // Check if any snake body can be cancelled
                if ([self checkCombo] ) {
                    if (level%2 == 0) {
                        chain++;
                    } else {
                        timeInterval -= 0.02;
//                        [moveTimer invalidate];
                    }
                    level++;
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
            // Remove body
            [moveTimer invalidate];
            [self cancelSnakeBodyByColor:v.backgroundColor];
            return YES;
        }
    }
    return NO;
}


- (void)cancelSnakeBodyByColor:(UIColor *)color
{
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    for (UIView *v in snakeBody) {
        if ([v.backgroundColor isEqual:color]) {
            NSInteger index = [snakeBody indexOfObject:v];
            [self removeSnakeBodyByIndex:index andBody:v andColor:v.backgroundColor];
            break;
        }
    }
    
//    [self checkCombo];
}

-(void)removeSnakeBodyByIndex:(NSInteger)index andBody:(UIView *)removingBody andColor:(UIColor *)color
{
    NSMutableArray *snakeBody = [playerSnake snakeBody];

    for (NSInteger i=index; i < [snakeBody count];i++) {
        if (i < [snakeBody count] -1) {
            // Next body
            UIView *currentBody = [snakeBody objectAtIndex:i];
            UIView *nextBody = [snakeBody objectAtIndex:i+1];
            [UIView animateWithDuration:2 animations:^{
                currentBody.backgroundColor = nextBody.backgroundColor;

            }];
//            currentBody.backgroundColor = nextBody.backgroundColor;
        }
    }
    [playerSnake.snakeTail removeFromSuperview];
    [playerSnake updateTurningNode];
    [playerSnake.snakeBody removeLastObject];
    
    [self cancelSnakeBodyByColor:color];
}

#pragma mark -  Reset game

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    for (UIView *v in [playerSnake snakeBody]) {
        [v removeFromSuperview];
    }
    _snakeHeadView.frame = CGRectMake(140, 140, 20, 20);
    
    [playerSnake resetSnake:_snakeHeadView andDirection:kMoveDirectionRight];
    [_gamePad addSubview:_snakeHeadView];
    timeInterval = 0.15;
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
    
    for (SnakeDot *d in dotArray) {
        d.hidden = NO;
        d.smallDot.backgroundColor = [self dotColor];
    }
    
    numDotAte = 0;
    _dots.text = [NSString stringWithFormat:@"%ld",(long)numDotAte];
    chain = 2;
    level = 1;
}

- (void)createAllDots
{
    dotArray = [[NSMutableArray alloc]init];
    CGFloat dotPosX;
    CGFloat dotPosY;
    for (int i = 0 ; i < 14; i ++ ) {
        for (int j = 0 ; j < 14 ; j++) {
            if (i%2==1 && j%2==1) {
                
                dotPosX = i * 20;
                dotPosY = j * 20;
                
                SnakeDot *dot = [[SnakeDot alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 20, 20)];
                dot.layer.cornerRadius = 8;
                dot.smallDot.backgroundColor = [self dotColor];
                [_gamePad addSubview:dot];
                [dotArray addObject:dot];
            }
        }
    }
}

-(UIColor *)dotColor
{
    int index = arc4random()%3;
    UIColor *color;
    switch (index) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor blueColor];
            break;
        case 2:
            color = [UIColor greenColor];

            break;
        case 3:
            color = [UIColor orangeColor];

            break;
    }
    
    return color;
}

- (IBAction)moveUp:(id)sender {
    if ([playerSnake headDirection] != kMoveDirectionUp && [playerSnake headDirection] != kMoveDirectionDown)
        [playerSnake setTurningNodeWithDirection:kMoveDirectionUp];
}

- (IBAction)moveDown:(id)sender {
    if ([playerSnake headDirection] != kMoveDirectionUp &&  [playerSnake headDirection] != kMoveDirectionDown)

    [playerSnake setTurningNodeWithDirection:kMoveDirectionDown];

}

- (IBAction)moveLeft:(id)sender {
    if ([playerSnake headDirection] != kMoveDirectionLeft &&  [playerSnake headDirection] != kMoveDirectionRight)

    [playerSnake setTurningNodeWithDirection:kMoveDirectionLeft];

}

- (IBAction)moveRight:(id)sender {
    
    if ([playerSnake headDirection] != kMoveDirectionLeft &&  [playerSnake headDirection] != kMoveDirectionRight)

    [playerSnake setTurningNodeWithDirection:kMoveDirectionRight];

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
