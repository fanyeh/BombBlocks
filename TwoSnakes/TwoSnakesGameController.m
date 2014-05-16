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
#import <Social/Social.h>
#import "MenuController.h"
#import "CircleLabel.h"

@interface TwoSnakesGameController ()
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
    NSTimer *countDownTimer;
    NSInteger counter;
    NSInteger maxCombos;
    NSInteger score;
    UITapGestureRecognizer *snakeButtonTap;
    NSNumberFormatter *numFormatter;
}

@property (weak, nonatomic) IBOutlet UIView *snakeHeadView;
@property (weak, nonatomic) IBOutlet UIView *gamePad;
@property (weak, nonatomic) IBOutlet UIView *leftEye;
@property (weak, nonatomic) IBOutlet UIView *rightEye;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIView *snakeMouth;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;


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
    
    // View Settings
    _snakeHeadView.layer.cornerRadius = _snakeHeadView.frame.size.width/4;
    playerSnake = [[Snake alloc]initWithSnakeHead:_snakeHeadView direction:kMoveDirectionLeft gamePad:_gamePad];
    
//    [self createGamerOverSquares];
   [self createAllDots];
    
    
    _leftEye.layer.cornerRadius = _leftEye.frame.size.width/2;
    _rightEye.layer.cornerRadius = _rightEye.frame.size.width/2;
    
    _leftEye.layer.borderWidth = 1.5;
    _leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    _rightEye.layer.borderWidth = 1.5;
    _rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    _snakeMouth.layer.cornerRadius = _snakeMouth.frame.size.width/2;
    _snakeMouth.layer.borderColor = [[UIColor whiteColor]CGColor];
  
    
    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [_gamePad addGestureRecognizer:gamePadTap];
    
//    _gamePad.layer.borderWidth = 1;

    _gamePad.layer.cornerRadius = 5;
    
    
    snakeButtonTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startCoundDown)];
    _snakeButton = [[SnakeButton alloc]initWithTitle:@"play" gesture:snakeButtonTap];
    
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    [_gamePad sendSubviewToBack:_snakeHeadView];
    
    [self.view addSubview:_snakeButton];

    // Game Settings
    timeInterval = 0.2;
    numDotAte = 0;
    chain = 2;
    level = 1;
    counter =  3;
    maxCombos = 0;
    score = 0;
    
    _gamePad.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMenu)];
    [_menuView addGestureRecognizer:menuTap];
    
    _facebookButton.layer.cornerRadius = _facebookButton.frame.size.width/2;
    _facebookButton.layer.masksToBounds = YES;
    _twitterButton.layer.cornerRadius = _twitterButton.frame.size.width/2;
    _twitterButton.layer.masksToBounds = YES;


}

-(void)directionChange:(UITapGestureRecognizer *)sender
{
    if (_gamePad.userInteractionEnabled) {
        CGPoint location = [sender locationInView:_gamePad];
        [playerSnake setTurningNode:location];
        _gamePad.userInteractionEnabled = NO;
    }
    
    // Show tap point
//    UIView *tapDot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
//    tapDot.center = location;
//    tapDot.layer.cornerRadius = 5;
//    tapDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
//    tapDot.alpha = 0;
//    tapDot.layer.borderColor = [[UIColor colorWithWhite:0.400 alpha:1.000]CGColor];
//    tapDot.layer.borderWidth = 1.5;
//    [_gamePad addSubview:tapDot];
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        tapDot.alpha = 1;
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.3 animations:^{
//            tapDot.alpha = 0;
//            
//        } completion:^(BOOL finished) {
//            [tapDot removeFromSuperview];
//        }];
//    }];

}

-(void)changeDirection
{
    _gamePad.userInteractionEnabled = YES;

    if ([playerSnake changeDirectionWithGameIsOver:NO]) {
        
        [moveTimer invalidate];
        
        // Submit score to game center
        [[GCHelper sharedInstance] submitScore:score leaderboardId:kHighScoreLeaderboardId];
        
        NSString *alertTitle = @"Game Over";

        // Set score record
        if (score > [[NSUserDefaults standardUserDefaults]integerForKey:@"highestScore"]) {
            [[NSUserDefaults standardUserDefaults]setInteger:score forKey:@"highestScore"];
            alertTitle = @"New Score Record";
        }
        
        if (maxCombos > [[NSUserDefaults standardUserDefaults]integerForKey:@"maxCombo"]) {
            [[NSUserDefaults standardUserDefaults]setInteger:maxCombos forKey:@"maxCombo"];
            alertTitle = @"New Combo Record";
        }
        
        
        UIColor *gameOverColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
        
        [playerSnake gameOver];


        [UIView animateWithDuration:1 animations:^{
            
            for (SnakeDot *d in dotArray) {
                d.smallDot.backgroundColor = gameOverColor;
            }
            
            for (UIView *v in [playerSnake snakeBody]) {
                if (v.tag > 0) {
                    v.backgroundColor = gameOverColor;
                }
            }
            
        } completion:^(BOOL finished) {
            [_snakeButton changeState:kSnakeButtonReplay];
            [snakeButtonTap removeTarget:self action:@selector(pauseGame)];
            [snakeButtonTap addTarget:self action:@selector(replayGame)];
            
            _menuView.hidden = NO;
            
        }];

    } else {
        for (SnakeDot *d in dotArray) {
            if (d.hidden) {
                d.hidden = NO;
            }
        }
        [self isEatingDot];
    }
}

#pragma mark - Game state

- (void)countDown
{
    if (counter == 0) {
        _gamePad.userInteractionEnabled = YES;
        [countDownTimer invalidate];
        counter = 3;

        for (SnakeDot *d in dotArray) {
            d.alpha = 0;
        }
        
        _gamePad.alpha = 0;
        
        [UIView animateWithDuration:1 animations:^{
            _snakeHeadView.alpha = 1;
            _gamePad.alpha = 1;
            for (SnakeDot *d in dotArray) {
                d.smallDot.backgroundColor = [self dotColor];
                d.alpha = 1;
                if (CGRectIntersectsRect(d.frame, _snakeHeadView.frame))
                    d.hidden = YES;
            }
            
        } completion:^(BOOL finished) {
            moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
//            dotTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showDots) userInfo:nil repeats:YES];
        }];
    }
    else {
        [self counterDots:counter];
        counter--;
    }
}

- (void)startCoundDown
{
    _menuView.hidden = YES;
    [_snakeButton changeState:kSnakeButtonPause];
    [snakeButtonTap removeTarget:self action:@selector(startCoundDown)];
    [snakeButtonTap addTarget:self action:@selector(pauseGame)];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
}

- (void)pauseGame
{
    [_snakeButton changeState:kSnakeButtonResume];
    [moveTimer invalidate];
    [snakeButtonTap removeTarget:self action:@selector(pauseGame)];
    [snakeButtonTap addTarget:self action:@selector(resumeGame)];
}

- (void)backgroundPauseGame
{
    [_snakeButton backgroundPause:kSnakeButtonResume];
    [moveTimer invalidate];
    [snakeButtonTap removeTarget:self action:@selector(pauseGame)];
    [snakeButtonTap addTarget:self action:@selector(resumeGame)];
}

- (void)resumeGame
{
    [_snakeButton changeState:kSnakeButtonPause];
    [snakeButtonTap removeTarget:self action:@selector(resumeGame)];
    [snakeButtonTap addTarget:self action:@selector(pauseGame)];
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
}

- (void)replayGame
{
    // Game settings
    _menuView.hidden = YES;
    timeInterval = 0.2;
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    numDotAte = 0;
    chain = 2;
    level = 1;
    score = 0;
    
    // View settings
    for (SnakeDot *d in dotArray) {
        d.smallDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000] ;
    }
    
    for (UIView *v in [playerSnake snakeBody]) {
        [v removeFromSuperview];
    }
    
    
    _snakeHeadView.frame = CGRectMake(147, 189, 20, 20);
    [_snakeHeadView.layer removeAllAnimations];
    
    _snakeHeadView.alpha = 0;

    _scoreLabel.text =  [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];


    [playerSnake resetSnake:_snakeHeadView andDirection:[playerSnake headDirection]];
    [_gamePad addSubview:_snakeHeadView];
    
    [_snakeButton changeState:kSnakeButtonPause];
    [snakeButtonTap removeTarget:self action:@selector(replayGame)];
    [snakeButtonTap addTarget:self action:@selector(pauseGame)];
}

#pragma mark - Combo

- (BOOL)checkCombo:(void(^)(void))completeBlock
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
            
            // Shake snake head
            if (!playerSnake.isRotate)
                [playerSnake startRotate];
            
            [self comboAnimationStartIndex:startIndex endIndex:endIndex completeBlock:completeBlock mouthColor:v.backgroundColor otherCombo:NO];

            return YES;
        }
    }
    completeBlock();
    return NO;
}

// Single body color check
- (void)cancelSnakeBodyByColor:(UIColor *)color complete:(void(^)(void))completeBlock
{
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    BOOL completeCheck = YES;
    
    // Remove each body with same color
    for (UIView *v in snakeBody) {
        if ([v.backgroundColor isEqual:color]) {
            NSInteger index = [snakeBody indexOfObject:v];
            [self removeSnakeBodyByIndex:index andColor:v.backgroundColor complete:completeBlock];
            completeCheck = NO;
            break;
        }
    }
    
    // Check if there is other combos
    if (completeCheck)
        [self otherCombo:completeBlock];
}

// Single body removal
-(void)removeSnakeBodyByIndex:(NSInteger)index andColor:(UIColor *)color complete:(void(^)(void))completeBlock
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
        [self cancelSnakeBodyByColor:color complete:completeBlock];
    }];
}

-(BOOL)otherCombo:(void(^)(void))completeBlock
{
    UIColor *mouthColor;
    UIColor *repeatColor;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    BOOL hasCombo = NO;
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    
    for (UIView *v in snakeBody) {
        
        if (![repeatColor isEqual:v.backgroundColor]) {
            
            if (hasCombo) {
                // Invalidate timer if there combo
                
                [self comboAnimationStartIndex:startIndex endIndex:endIndex completeBlock:completeBlock mouthColor:mouthColor otherCombo:YES];

                return YES;
            } else {
                repeatColor = v.backgroundColor;
                startIndex = [snakeBody indexOfObject:v];
                endIndex = startIndex;
            }
        } else {
            endIndex = [snakeBody indexOfObject:v];

            if (endIndex - startIndex == chain) {
                mouthColor = repeatColor;
                hasCombo = YES;
            }
            
            if ([v isEqual:[snakeBody lastObject]] && hasCombo) {

                [self comboAnimationStartIndex:startIndex endIndex:endIndex completeBlock:completeBlock mouthColor:mouthColor otherCombo:YES];

                return YES;
                
            }
        }
    }
    // If no other combo call the complete block
    completeBlock();
    return NO;
}

-(void)removeSnakeBodyByRangeStart:(NSInteger)start andRange:(NSInteger)range complete:(void(^)(void))completeBlock
{
    if (range == 0) {
        [self otherCombo:completeBlock];
    } else {
        NSMutableArray *snakeBody = [playerSnake snakeBody];
        for (NSInteger i=start; i < [snakeBody count] -1 ;i++) {
            
            if (i < [snakeBody count] -1) {
            
                // Next body
                UIView *currentBody = [snakeBody objectAtIndex:i];
                UIView *nextBody = [snakeBody objectAtIndex:i+1];
                currentBody.backgroundColor = nextBody.backgroundColor;
            }
        }
        
        [UIView animateWithDuration:0.1 animations:^{
            
            playerSnake.snakeTail.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [playerSnake.snakeTail removeFromSuperview];
            [playerSnake updateTurningNode];
            [playerSnake.snakeBody removeLastObject];
            [self removeSnakeBodyByRangeStart:start andRange:range-1 complete:completeBlock];
        }];

    }
}

- (void)comboAnimationStartIndex:(NSInteger)start endIndex:(NSInteger)end
                   completeBlock:(void(^)(void))completeBlock
                      mouthColor:(UIColor *)color
                      otherCombo:(BOOL)other
{

    NSMutableArray *snakeBody = [playerSnake snakeBody];
    _leftEye.alpha = 0;
    _rightEye.alpha = 0;
    _snakeMouth.backgroundColor = color;
    combos++;
    [playerSnake updateExclamationText:combos];
    
    for (NSInteger i = start ; i < end +1 ; i ++) {
        UIView *u = snakeBody[i];
        
        CGFloat toAngle;
        CGFloat fromAngle;
        
        if (i%2 == 0) {
            toAngle = -M_PI/6;
            fromAngle = M_PI/6;
        } else {
            toAngle = M_PI/6;
            fromAngle = -M_PI/6;
        }
        
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [anim setToValue:[NSNumber numberWithFloat:toAngle]]; // satrt angle
        [anim setFromValue:[NSNumber numberWithDouble:fromAngle]]; // rotation angle
        [anim setDuration:0.1]; // rotate speed
        [anim setRepeatCount:HUGE_VAL];
        [anim setAutoreverses:YES];
        
        [u.layer addAnimation:anim forKey:nil];
    }
    
    [UIView animateWithDuration:1 animations:^{
        
        _leftEye.alpha = 1;
        _rightEye.alpha = 1;
        _leftEye.layer.borderWidth = 0.5;
        _rightEye.layer.borderWidth = 0.5;
        
    } completion:^(BOOL finished) {
        
        for (NSInteger i = start ; i < end +1 ; i ++) {
            UIView *u = snakeBody[i];
            [u.layer removeAllAnimations];
        }
        
        _leftEye.layer.borderWidth = 1.5;
        _rightEye.layer.borderWidth = 1.5;

        if (other)
            [self removeSnakeBodyByRangeStart:start andRange:(end - start) + 1 complete:completeBlock];
        else
            [self cancelSnakeBodyByColor:color complete:completeBlock];
    }];

}

#pragma mark - Dot

- (void)isEatingDot
{
    for (SnakeDot *d in dotArray) {
        if (!d.hidden && CGRectIntersectsRect([playerSnake snakeHead].frame, d.frame)) {

            _snakeMouth.hidden = NO;
            
            d.hidden = YES;
            
            [_gamePad bringSubviewToFront:_snakeHeadView];
            score += 10;

            _scoreLabel.text =  [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
            
            [_gamePad addSubview:[playerSnake addSnakeBodyWithColor:d.smallDot.backgroundColor]];
            
            [moveTimer invalidate];
            
            _gamePad.userInteractionEnabled = NO;
            
            [self checkCombo:^{
                
                _gamePad.userInteractionEnabled = YES;

                if (playerSnake.isRotate)
                    [playerSnake stopRotate];

                [self mouthAnimation];

                _snakeMouth.backgroundColor = [UIColor whiteColor];
                
                // Increase speed for every 30 dots eaten
                if (numDotAte%30==0 && numDotAte != 0) {
                    level++;
                    timeInterval -= 0.005;
                    
                    if (moveTimer.isValid)
                        [moveTimer invalidate];
                    
                    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
                } else {
                    // If moveTimer is not valid (means there's combo) , restart the timer again
                    if (!moveTimer.isValid)
                        moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
                }
                [self setScore];
                [playerSnake updateExclamationText:combos];
                d.smallDot.backgroundColor = [self dotColor];
            }];
            
            break;
        }
    }
    [_gamePad sendSubviewToBack:_snakeHeadView];
}

- (void)mouthAnimation
{
    float duration = timeInterval;
    float closeInsetSize =  _snakeMouth.frame.size.width/3;


    [UIView animateWithDuration:duration animations:^{
        
        // Mouth Close
        _snakeMouth.frame = CGRectInset(_snakeMouth.frame, closeInsetSize, closeInsetSize);

    } completion:^(BOOL finished) {

        _snakeMouth.hidden = YES;

        // Mouth Open
        _snakeMouth.frame = CGRectInset(_snakeMouth.frame, -closeInsetSize, -closeInsetSize);

    }];
}

- (void)setScore
{
    NSInteger comboAdder = 50;
    for (int i = 0 ; i < combos ; i ++) {
        score += comboAdder;
        comboAdder *= 2;
    }
    combos = 0;
    numDotAte++;
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
                
                SnakeDot *dot = [[SnakeDot alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 20, 20) dotShape:kDotShapeCircle];
                dot.smallDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000] ; //[self dotColor];
                [_gamePad addSubview:dot];
                [_gamePad sendSubviewToBack:dot];
                [dotArray addObject:dot];
            }
        }
    }
    
    [self.view bringSubviewToFront:_snakeHeadView];
}

- (void)createGamerOverSquares
{
    NSMutableArray *gameOverArray = [[NSMutableArray alloc]init];

    
    for (int i = 0 ; i < 15; i ++ ) {
        for (int j = 0 ; j < 19 ; j++) {
            
            switch (i) {
                case 0:
                    if ( (j >2 &&  j < 8) || (j > 10 && j < 16)) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 1:
                    if ( j == 3 ||  j ==7  || j == 11 || j == 15 || j == 5) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 2:
                    if ( j == 3 ||  (j > 4 && j < 9) || (j > 10 && j < 16)) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 4:
                    if ( (j >3 &&  j < 8) || (j > 10 && j < 15)) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 5:
                    if ( j == 3 ||  j ==5 || j == 15) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 6:
                    
                    if ( (j >3 &&  j < 8) || (j > 10 && j < 15)) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 8:
                    
                    if (  (j > 2 && j < 8 ) ||  (j > 10 && j < 16 )) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 9:
                    
                    if ( j ==4  ||  j ==11 || j == 13 || j == 15) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    
                    break;
                case 10:
                    if ((j > 2 && j < 8 ) ||  j ==11 || j == 15 || j == 13) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 12:
                    if ( (j >2 &&  j < 8) || (j > 10 && j < 16)) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 13:
                    if ( j == 3 ||  j ==5 || j == 7 || j == 11 || j == 13 ) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
                case 14:
                    if ( j == 3 ||  j ==5 || j == 7 || (j > 10 && j < 16 ) ) {
                        [self addSquareIndexI:i indexJ:j squareArray:gameOverArray];
                    }
                    break;
            }
        }
    }
}
                        
- (void)addSquareIndexI:(NSInteger)i indexJ:(NSInteger)j squareArray:(NSMutableArray *)gameOverArray
{
    CGFloat dotPosX;
    CGFloat dotPosY;
    dotPosX = i * 21;
    dotPosY = j * 21;
    
    
//    SnakeDot *dot = [[SnakeDot alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 20, 20)];
//    dot.layer.cornerRadius = 8;
//    dot.smallDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000] ; //[self dotColor];
    UIView *square = [[UIView alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 20, 20)];
    
    square.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000] ; //[self dotColor];
    [_gamePad addSubview:square];
    [gameOverArray addObject:square];
}

- (void)counterDots:(NSInteger)count
{
    for (SnakeDot *d in dotArray) {
        
        d.smallDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    }

    
    UIColor *color = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];

    NSMutableArray *counterDotArray = [[NSMutableArray alloc]init];
    
    [counterDotArray addObject:[dotArray objectAtIndex:20]];
    [counterDotArray addObject:[dotArray objectAtIndex:29]];
    [counterDotArray addObject:[dotArray objectAtIndex:38]];
    [counterDotArray addObject:[dotArray objectAtIndex:24]];
    [counterDotArray addObject:[dotArray objectAtIndex:33]];
    [counterDotArray addObject:[dotArray objectAtIndex:42]];
    [counterDotArray addObject:[dotArray objectAtIndex:31]];

    
    if (count == 1) {
        
        [counterDotArray addObject:[dotArray objectAtIndex:30]];
        [counterDotArray addObject:[dotArray objectAtIndex:32]];

    } else  {
        [counterDotArray addObject:[dotArray objectAtIndex:39]];
        [counterDotArray addObject:[dotArray objectAtIndex:40]];
        [counterDotArray addObject:[dotArray objectAtIndex:22]];
        
        if (count == 2) {
            [counterDotArray addObject:[dotArray objectAtIndex:23]];

        } else if (count == 3) {
            [counterDotArray addObject:[dotArray objectAtIndex:41]];

        }
            
    }
    
    // Animation to show counter
    for (SnakeDot *d in counterDotArray) {
        d.smallDot.backgroundColor = color;
        d.alpha = 0;
        [UIView animateWithDuration:1 animations:^{
            d.alpha = 1;
        }];
    }
}

-(UIColor *)dotColor
{
    int index;
    if (level < 10) {
        index = arc4random()%4;
    }else if (level > 10) {
        index = arc4random()%5;
    } else if (level > 20) {
        index = arc4random()%6;
    }


    UIColor *color;
    switch (index) {
        case 0:
            color = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
            break;
        case 1:
            color = [UIColor colorWithRed:0.235 green:0.729 blue:0.784 alpha:1.000];
            break;
        case 2:
            color = [UIColor colorWithRed:0.682 green:0.933 blue:0.000 alpha:1.000];
            break;
        case 3:
            color = [UIColor colorWithRed:1.000 green:0.733 blue:0.125 alpha:1.000];
            break;
        case 4:
            color = [UIColor colorWithRed:0.592 green:0.408 blue:0.820 alpha:1.000];
            break;
        case 5:
            color = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
            break;
    }
    
    return color;
}

#pragma mark - Trap

- (void)createTraps
{
    dotArray = [[NSMutableArray alloc]init];
    CGFloat dotPosX;
    CGFloat dotPosY;
    
    for (int i = 0 ; i < 14; i ++ ) {
        for (int j = 0 ; j < 19 ; j++) {
            if (i%2==0 && j%2==0) {
                
                dotPosX = i * 21;
                dotPosY = j * 21;
                
                UIView *trap = [[UIView alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 20, 20)];
                trap.layer.cornerRadius = 8;
                trap.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000] ; //[self dotColor];
                [_gamePad addSubview:trap];
                [_gamePad sendSubviewToBack:trap];
                [dotArray addObject:trap];
            }
        }
    }
    
    [self.view bringSubviewToFront:_snakeHeadView];
}

#pragma mark - Hide statu bar

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Social

- (void)showShareSheet:(NSInteger )tag
{
    if ([self checkInternetConnection]) {
        NSString *serviceType;
        switch (tag) {
            case 0:
                serviceType = SLServiceTypeTwitter;
                break;
            case 1:
                serviceType = SLServiceTypeSinaWeibo;
                break;
            case 2:
                serviceType = SLServiceTypeFacebook;
                break;
            default:
                break;
        }

        //  Create an instance of the share Sheet , Service Type 有 Facebook/Twitter/微博 可以選
        SLComposeViewController *shareSheet = [SLComposeViewController composeViewControllerForServiceType: serviceType];

        
        shareSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    break;
            }
        };
        
        //  Set the initial body of the share sheet
        [shareSheet setInitialText:@"I have scored points @ Not A Snake Game!"];
        
        //  Share Photo
//        if (![shareSheet addImage:[fm loadCollectionImage]]) {
//            NSLog(@"Unable to add the image!");
//        }

        //  Presents the share Sheet to the user
        [self presentViewController:shareSheet animated:NO completion:nil];
    }
}

- (void)backToMenu
{
    if (_snakeButton.state == kSnakeButtonPause) 
        [self backgroundPauseGame];

    MenuController *controller = [[MenuController alloc]init];
    controller.state = kGameStateContinue;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)shareToFB:(UIButton *)sender
{
    [self showShareSheet:sender.tag];
}

- (IBAction)shareToTwitter:(UIButton *)sender
{
    [self showShareSheet:sender.tag];
}

- (BOOL)checkInternetConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *noInternetAlert = [[UIAlertView alloc]initWithTitle: NSLocalizedString(@"No Internet Connection", nil)
                                                                 message:NSLocalizedString(@"Check your internet connection and try again",nil)
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Close",nil)
                                                       otherButtonTitles:nil, nil];
        [noInternetAlert show];
        return NO;
    } else {
        return YES;
    }
}

@end
