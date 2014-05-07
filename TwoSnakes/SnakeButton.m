//
//  SnakeButton.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/7.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeButton.h"

@implementation SnakeButton
{
    UIView *snakeHead;
    UIView *mouth;
    UIView *leftEye;
    UIView *rightEye;
    CGFloat space;
    CGFloat blockSize;
    NSMutableArray *letterArray;
    CGFloat length;
    CGFloat headSize;
    CGFloat frameHeight;
    CGFloat frameWidth;
    CGRect newFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    length = title.length;
    space = 5;
    blockSize = 24;
    headSize = 40;
    frameWidth = (length*space) + ((length) * blockSize) + headSize + blockSize/2;
    frameHeight = 40;
    newFrame = CGRectMake((320-frameWidth-headSize - space - blockSize/2)/2, 500, frameWidth, frameHeight);
    
    self = [self initWithFrame:newFrame];
    if (self) {
        _state = kSnakeButtonPlay;
        [self setSnakeButton:title];
    }
    return self;
}

-(void)setSnakeButton:(NSString *)title
{
    
    CGFloat xPos = 0;
    CGFloat yPos = 0;

    snakeHead = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, headSize, headSize)];
    snakeHead.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    snakeHead.alpha = 0;
    
    CGFloat eyeSize = headSize/4;
    leftEye = [[UIView alloc]initWithFrame:CGRectMake(eyeSize, headSize/10, eyeSize, eyeSize)];
    leftEye.backgroundColor = [UIColor blackColor];
    leftEye.layer.borderWidth = eyeSize*.3;
    leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    leftEye.layer.cornerRadius = eyeSize/2;
    [snakeHead addSubview:leftEye];
    
    rightEye = [[UIView alloc]initWithFrame:CGRectMake(eyeSize, headSize - headSize/10 - eyeSize, eyeSize, eyeSize)];
    rightEye.backgroundColor = [UIColor blackColor];
    rightEye.layer.borderWidth = eyeSize*.3;
    rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    rightEye.layer.cornerRadius = eyeSize/2;
    [snakeHead addSubview:rightEye];
    
    CGFloat mouthSize = blockSize;
    mouth = [[UIView alloc]initWithFrame:CGRectMake(headSize - mouthSize/2, (frameHeight - blockSize) / 2, mouthSize, mouthSize)];
    mouth.backgroundColor = [UIColor whiteColor];
    mouth.layer.cornerRadius = mouthSize/2;
    mouth.hidden = YES;
    [snakeHead addSubview:mouth];
    
    [self addSubview:snakeHead];
    
    xPos = headSize + mouthSize/2 + space;
    yPos = (frameHeight - blockSize) / 2;
    
    letterArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < length ; i++) {
        UILabel *letterLabel = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, blockSize, blockSize)];
        letterLabel.text = [NSString stringWithFormat:@"%c",[title characterAtIndex:i]];
        letterLabel.textColor = [UIColor whiteColor];
        letterLabel.textAlignment = NSTextAlignmentCenter;
        letterLabel.backgroundColor = [self colorByState];
        letterLabel.layer.cornerRadius = blockSize/2;
        letterLabel.layer.masksToBounds = YES;
        letterLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
        [self addSubview:letterLabel];
        [letterArray addObject:letterLabel];
        xPos += (blockSize + space);
    }
    
    self.userInteractionEnabled = YES;
}

- (void)resetSnakeButton
{
    NSString *title;
    switch (_state) {
        case kSnakeButtonPlay:
            title = @"play";
            break;
        case kSnakeButtonPause:
            title = @"pause";
            break;
        case kSnakeButtonResume:
            title = @"resume";
            
            break;
        case kSnakeButtonReplay:
            title = @"replay";
            break;
    }

    
    length = title.length;
    space = 10;
    blockSize = 24;
    headSize = 40;
    frameWidth = (length*space) + ((length) * blockSize) + headSize + blockSize/2;
    frameHeight = 40;
    newFrame = CGRectMake((320-frameWidth-headSize - space - blockSize/2)/2, 500, frameWidth, frameHeight);
    self.frame = newFrame;
    
    [letterArray removeAllObjects];
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    [self setSnakeButton:title];
}

- (void)changeState:(SnakeButtonState)newState
{
    self.userInteractionEnabled = NO;
    _state = newState;
    [self showHead];
}

- (void)showHead
{
    [UIView animateWithDuration:1 animations:^{
        snakeHead.alpha = 1;
    } completion:^(BOOL finished) {
        mouth.hidden = NO;
        [self eatButton];
    }];
}

- (void)eatButton
{
    float duration = 3/(length*2+1);
    
    [UIView animateWithDuration:duration animations:^{
        
        snakeHead.frame = CGRectOffset(snakeHead.frame, (blockSize + space) , 0);
        
    } completion:^(BOOL finished) {
        
        [self eatNextLetter:[letterArray firstObject]];
        
    }];
}

- (void)eatNextLetter:(UIView *)letter
{
    
    float duration = 3/(length*2+1);
    
    [UIView animateWithDuration:duration animations:^{
        // Eating animation
//        letter.frame = CGRectInset(letter.frame, blockSize/2, blockSize/2);
        letter.transform = letter.transform = CGAffineTransformScale(letter.transform, 0.1 , 0.1);
        mouth.frame = CGRectInset(mouth.frame, blockSize/2, blockSize/2);
        
    } completion:^(BOOL finished) {
        
        [letter removeFromSuperview];
        [letterArray removeObject:letter];
        
        if ([letterArray firstObject]) {
            [UIView animateWithDuration:duration animations:^{
                
                snakeHead.frame = CGRectOffset(snakeHead.frame, (blockSize + space) , 0);
                mouth.frame = CGRectInset(mouth.frame, -blockSize/2, -blockSize/2);
                
            } completion:^(BOOL finished) {
                
                [self eatNextLetter:[letterArray firstObject]];

            }];
        } else {
            
            [self resetSnakeButton];
        }
        
    }];
}

- (UIColor *)colorByState
{
    UIColor *color;
    switch (_state) {
        case kSnakeButtonPlay:
            color = [UIColor colorWithWhite:0.200 alpha:1.000];
            break;
        case kSnakeButtonPause:
            color = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
            break;
        case kSnakeButtonResume:
            color = [UIColor colorWithRed:0.004 green:0.690 blue:0.941 alpha:1.000];
            break;
        case kSnakeButtonReplay:
            color = [UIColor colorWithWhite:0.200 alpha:1.000];
            break;
    }
    
    return color;
}

@end
