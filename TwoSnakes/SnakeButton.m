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
    CGFloat labelHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title gesture:(UITapGestureRecognizer *)gesture
{
    length = title.length;
    space = 5;
    blockSize = 24;
    headSize = 40;
    labelHeight = 30;
    frameWidth = (length*space) + ((length) * blockSize) + headSize + blockSize/2;
    frameHeight = 40;
    newFrame = CGRectMake((320-frameWidth-headSize - space - blockSize/2)/2, 480, frameWidth, frameHeight+labelHeight);
    
    self = [self initWithFrame:newFrame];
    if (self) {
        _state = kSnakeButtonPlay;
        _tapGesture = gesture;
        [self setSnakeButton:title];
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [[UIColor redColor]CGColor];
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
    snakeHead.layer.cornerRadius = headSize/4;
    
    CGFloat eyeSize = headSize/3;
    leftEye = [[UIView alloc]initWithFrame:CGRectMake(3, 3, eyeSize, eyeSize)];
    leftEye.backgroundColor = [UIColor blackColor];
    leftEye.layer.borderWidth = 4.5;
    leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    leftEye.layer.cornerRadius = eyeSize/2;
    [snakeHead addSubview:leftEye];
    
    rightEye = [[UIView alloc]initWithFrame:CGRectMake(3 , headSize - 3 - eyeSize, eyeSize, eyeSize)];
    rightEye.backgroundColor = [UIColor blackColor];
    rightEye.layer.borderWidth = 4.5;
    rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    rightEye.layer.cornerRadius = eyeSize/2;
    [snakeHead addSubview:rightEye];
    
    CGFloat mouthSize = blockSize;
    mouth = [[UIView alloc]initWithFrame:CGRectMake(headSize - mouthSize/2, (headSize - blockSize) / 2, mouthSize, mouthSize)];
    mouth.backgroundColor = [UIColor whiteColor];
    mouth.layer.cornerRadius = mouthSize/2;
    mouth.hidden = YES;
    [snakeHead addSubview:mouth];
    
    _letterButtons = [[UIView alloc]initWithFrame:CGRectMake(0, labelHeight, frameWidth, headSize)];
    [_letterButtons addSubview:snakeHead];
    [self addSubview:_letterButtons];
    
    [_letterButtons addGestureRecognizer:_tapGesture];
    
    xPos = headSize + mouthSize/2 + space;
    yPos = yPos + (headSize - blockSize) / 2;
    
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
        [_letterButtons addSubview:letterLabel];
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
    newFrame = CGRectMake((320-frameWidth-headSize - space - blockSize/2)/2, 480, frameWidth, frameHeight+labelHeight);
    self.frame = newFrame;
    
    [letterArray removeAllObjects];
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    [self setSnakeButton:title];
    [self hideLetters];
}

- (void)changeState:(SnakeButtonState)newState
{
    self.userInteractionEnabled = NO;
    _state = newState;
    [self showHead];
}

- (void)showHead
{
    float time;
    
    if (_state == kSnakeButtonPlay || _state == kSnakeButtonReplay)
        time = 2.5;
    else
        time = 2.5;
    
    float duration = time/(length+4);

    [UIView animateWithDuration:duration animations:^{
        snakeHead.alpha = 1;
    } completion:^(BOOL finished) {
        mouth.hidden = NO;
        [self eatButton:duration];
    }];
}

- (void)eatButton:(float)duration
{
    float insetSize = blockSize/10;
    
    [UIView animateWithDuration:duration animations:^{
        
        snakeHead.frame = CGRectOffset(snakeHead.frame, (blockSize + space) , 0);
        
        // Mouth open
        mouth.frame = CGRectInset(mouth.frame, -insetSize, -insetSize);

        
    } completion:^(BOOL finished) {
        
        [self eatNextLetter:[letterArray firstObject] inset:insetSize duration:duration];
        
    }];
}

- (void)eatNextLetter:(UIView *)letter inset:(float)inset duration:(float)duration
{
    
    float insetSize = blockSize/2+inset;
    
    [UIView animateWithDuration:duration animations:^{
        
        letter.transform = CGAffineTransformScale(letter.transform, 0.1 , 0.1);
        
        // Close mouth
        mouth.frame = CGRectInset(mouth.frame, insetSize, insetSize);
        
        snakeHead.backgroundColor = letter.backgroundColor;
        
    } completion:^(BOOL finished) {
        
        [letter removeFromSuperview];
        [letterArray removeObject:letter];
        
        if ([letterArray firstObject]) {
            [UIView animateWithDuration:duration animations:^{
                
                snakeHead.frame = CGRectOffset(snakeHead.frame, (blockSize + space) , 0);
                
                // Open mouth
                mouth.frame = CGRectInset(mouth.frame, -insetSize, -insetSize);
                
            } completion:^(BOOL finished) {
                
                [self eatNextLetter:[letterArray firstObject] inset:inset duration:duration];

            }];
        } else {

            UIView *newMouth = [[UIView alloc]initWithFrame:CGRectMake(headSize/2, headSize/2-8, 16, 16)];
            newMouth.layer.cornerRadius = 8;
            newMouth.backgroundColor = [UIColor whiteColor];
            [snakeHead addSubview:newMouth];
            newMouth.frame = CGRectInset(newMouth.frame, 8, 8);
            
            UILabel *exlamationLabel = [[UILabel alloc]initWithFrame:CGRectMake(frameWidth-labelHeight + 12 , 0, labelHeight, labelHeight)];
            exlamationLabel.text = @"!";
            exlamationLabel.textColor = letter.backgroundColor;
            exlamationLabel.textAlignment = NSTextAlignmentCenter;
            exlamationLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:30];
            [self addSubview:exlamationLabel];
            exlamationLabel.transform = CGAffineTransformRotate(exlamationLabel.transform, M_PI/6);
            
            exlamationLabel.alpha = 0;

            
            [UIView animateWithDuration:duration animations:^{

                snakeHead.transform = CGAffineTransformRotate(snakeHead.transform, M_PI/2);
                newMouth.frame = CGRectInset(newMouth.frame, -8, -11);


            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration animations:^{
                    exlamationLabel.alpha = 1;

                } completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:duration animations:^{
                        exlamationLabel.alpha = 0;
                        snakeHead.alpha = 0;
                        
                    } completion:^(BOOL finished) {

                        [self resetSnakeButton];
                    }];

                }];


            }];
        }
        
    }];
}

- (void)hideLetters
{
    NSMutableArray *hiddenLetters = [[NSMutableArray alloc]init];
    for (UILabel *letter in letterArray) {
        
        letter.alpha = 0;
        [hiddenLetters addObject:letter];
    }
    
    [self showLetters:hiddenLetters];
}

- (void)showLetters:(NSMutableArray *)hiddenLetters
{
    UILabel *hiddenLetter = [hiddenLetters firstObject];
    if (hiddenLetter) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            hiddenLetter.alpha = 1;
            
        } completion:^(BOOL finished) {
            [hiddenLetters removeObject:hiddenLetter];
            
            [self showLetters:hiddenLetters];

        }];
    }
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
