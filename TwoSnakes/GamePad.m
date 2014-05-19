//
//  GamePad.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GamePad.h"
#import "SnakeDot.h"

@implementation GamePad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initGamePad
{
    CGRect frame = CGRectMake(0, 0, 315, 399);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createAllDots];
        
    }
    return self;
}

// Generate dot colors
-(UIColor *)dotColor:(NSInteger)numDotAte
{
    int index;
    
    if (numDotAte/30 < 10) {
        
        index = arc4random()%4;
    }
    else if (numDotAte/30 > 10) {
        
        if (numDotAte/30 > 20)
            index = arc4random()%5;
        else
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

// Chnage dot color during count down
- (void)counterDots:(NSInteger)count
{
    for (SnakeDot *d in _dotArray) {
        
        d.smallDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    }
    
    
    UIColor *color = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
    
    NSMutableArray *counterDotArray = [[NSMutableArray alloc]init];
    
    [counterDotArray addObject:[_dotArray objectAtIndex:20]];
    [counterDotArray addObject:[_dotArray objectAtIndex:29]];
    [counterDotArray addObject:[_dotArray objectAtIndex:38]];
    [counterDotArray addObject:[_dotArray objectAtIndex:24]];
    [counterDotArray addObject:[_dotArray objectAtIndex:33]];
    [counterDotArray addObject:[_dotArray objectAtIndex:42]];
    [counterDotArray addObject:[_dotArray objectAtIndex:31]];
    
    
    if (count == 1) {
        
        [counterDotArray addObject:[_dotArray objectAtIndex:30]];
        [counterDotArray addObject:[_dotArray objectAtIndex:32]];
        
    } else  {
        [counterDotArray addObject:[_dotArray objectAtIndex:39]];
        [counterDotArray addObject:[_dotArray objectAtIndex:40]];
        [counterDotArray addObject:[_dotArray objectAtIndex:22]];
        
        if (count == 2) {
            [counterDotArray addObject:[_dotArray objectAtIndex:23]];
            
        } else if (count == 3) {
            [counterDotArray addObject:[_dotArray objectAtIndex:41]];
            
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

// Create and add all dots to game pad
- (void)createAllDots
{
    _dotArray = [[NSMutableArray alloc]init];
    CGFloat dotPosX;
    CGFloat dotPosY;
    
    for (int i = 0 ; i < 14; i ++ ) {
        for (int j = 0 ; j < 19 ; j++) {
            if (i%2==1 && j%2==1) {
                
                dotPosX = i * 21;
                dotPosY = j * 21;
                
                SnakeDot *dot = [[SnakeDot alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 20, 20) dotShape:kDotShapeCircle];
                dot.smallDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000] ; //[self dotColor];
                [self addSubview:dot];
                [self sendSubviewToBack:dot];
                [_dotArray addObject:dot];
            }
        }
    }
    
//    [self.view bringSubviewToFront:_snakeHeadView];
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
    [self addSubview:square];
    [gameOverArray addObject:square];
}

#pragma mark - Trap

- (void)createTraps
{
    _dotArray = [[NSMutableArray alloc]init];
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
                [self addSubview:trap];
                [self sendSubviewToBack:trap];
                [_dotArray addObject:trap];
            }
        }
    }
    
//    [self.view bringSubviewToFront:_snakeHeadView];
}

- (void)setupDotForGameStart:(CGRect)headFrame
{
    self.alpha = 1;
    for (SnakeDot *d in _dotArray) {
        d.smallDot.backgroundColor = [self dotColor:0];
        d.alpha = 1;
        if (CGRectIntersectsRect(d.frame, headFrame))
            d.hidden = YES;
    }
}

- (void)hideAllDots
{
    for (SnakeDot *d in _dotArray) {
        d.alpha = 0;
    }
}


@end
