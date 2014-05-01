//
//  TwoSnakesGameController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/4/29.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TwoSnakesGameController.h"
#import "Snake.h"

@interface TwoSnakesGameController () <UIAlertViewDelegate>
{
    UIView *dotView;
    Snake *playerSnake;
    Snake *computerSnake;
    NSTimer *moveTimer;
}

@property (weak, nonatomic) IBOutlet UIView *snakeHeadView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIView *computerSnakeHead;

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
    playerSnake = [[Snake alloc]initWithSnakeHead:_snakeHeadView andDirection:kMoveDirectionRight];
    computerSnake = [[Snake alloc]initWithSnakeHead:_computerSnakeHead andDirection:kMoveDirectionUp];
    [self createDot];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    [playerSnake setTurningNode:location];
}

- (IBAction)startGame:(id)sender
{
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
    _startButton.hidden = YES;
}

-(void)changeDirection
{
    if ([playerSnake changeDirectionWithGameIsOver:NO moveTimer:moveTimer]) {
        
        UIAlertView *gameOverAlert = [[UIAlertView alloc]initWithTitle:@"Game Over" message:nil delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil , nil];
        [gameOverAlert show];
        
    } else {
        // Snake eat dot
        if ([playerSnake isEatingDot:dotView]) {
            // Add body to snake
            [self.view addSubview:[playerSnake addSnakeBody]];
            [dotView removeFromSuperview];
            [self createDot];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    for (UIView *v in [playerSnake snakeBody]) {
        [v removeFromSuperview];
    }
    [dotView removeFromSuperview];
    [self createDot];
    _snakeHeadView.frame = CGRectMake(144, 160, 16, 16);
    _computerSnakeHead.frame = CGRectMake(144,340, 16, 16);
    
    [playerSnake resetSnake:_snakeHeadView andDirection:kMoveDirectionRight];
    [self.view addSubview:_snakeHeadView];
//    playerSnake = [[Snake alloc]initWithSnakeHead:_snakeHeadView andDirection:kMoveDirectionRight];
//    computerSnake = [[Snake alloc]initWithSnakeHead:_computerSnakeHead andDirection:kMoveDirectionUp];
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
}

-(void)createDot
{
    CGFloat coordinateX = arc4random()%19;
    CGFloat coordinateY;
    CGSize screenSize = [[UIScreen mainScreen]bounds].size;
    if (screenSize.height == 568)
        coordinateY = arc4random()%34;
    else
        coordinateY = arc4random()%29;

    CGFloat dotPosX = coordinateX * 16;
    CGFloat dotPosY = coordinateY * 16;
    CGRect dotFrame = CGRectMake(dotPosX, dotPosY, 16, 16);
    
    BOOL createDone = NO;
    
    // Create the dot so it does not overlay with snake body
    while (!createDone) {

        if (![playerSnake isOverlayWithDotFrame:dotFrame])
            createDone = YES;
        else {
            coordinateX = arc4random()%19;
            coordinateY = arc4random()%29;
            dotPosX = coordinateX * 16;
            dotPosY = coordinateY * 16;
            dotFrame = CGRectMake(dotPosX, dotPosY, 16, 16);
        }
    }
    
    dotView = [[UIView alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 16, 16)];
    dotView.layer.cornerRadius = 8;
    dotView.backgroundColor = [UIColor redColor];
    [self.view addSubview:dotView];
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
