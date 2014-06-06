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
    NSMutableArray *bodyArray;
    NSString *introTitle;
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
    introTitle = title;
    length = title.length;
    space = 16;
    blockSize = 24;
    headSize = 40;
    labelHeight = 30;
    frameWidth = (length*space) + ((length) * blockSize) + headSize + blockSize/2;
    frameHeight = 40;
    newFrame = CGRectMake((320-frameWidth-headSize - space - blockSize/2)/2, 140, frameWidth, frameHeight+labelHeight);
    
    self = [self initWithFrame:newFrame];
    if (self) {
        [self setSnakeButton:title];
    }
    return self;
}

-(void)setSnakeButton:(NSString *)title
{
    
    CGFloat xPos = 0;
    CGFloat yPos = 0;

    snakeHead = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, headSize, headSize)];
    //snakeHead.backgroundColor = [UIColor colorWithRed:0.204 green:0.220 blue:0.247 alpha:1.000];
    //snakeHead.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];

    snakeHead.alpha = 0;
    snakeHead.layer.cornerRadius = headSize/4;
    
    UIImageView *snakeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, headSize, headSize)];
    snakeView.image = [UIImage imageNamed:@"snake.png"];
    //snakeView.transform = CGAffineTransformMakeRotation(-M_PI/2);
    [snakeHead addSubview:snakeView];

    
    CGFloat eyeSize = headSize/3;
    leftEye = [[UIView alloc]initWithFrame:CGRectMake(3, 3, eyeSize, eyeSize)];
    leftEye.backgroundColor = [UIColor blackColor];
    leftEye.layer.borderWidth = 4.5;
    leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    leftEye.layer.cornerRadius = eyeSize/2;
    //[snakeHead addSubview:leftEye];
    
    rightEye = [[UIView alloc]initWithFrame:CGRectMake(3 , headSize - 3 - eyeSize, eyeSize, eyeSize)];
    rightEye.backgroundColor = [UIColor blackColor];
    rightEye.layer.borderWidth = 4.5;
    rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    rightEye.layer.cornerRadius = eyeSize/2;
    //[snakeHead addSubview:rightEye];
    
    CGFloat mouthSize = blockSize;
    mouth = [[UIView alloc]initWithFrame:CGRectMake(headSize - mouthSize/2, (headSize - blockSize) / 2, mouthSize, mouthSize)];
    mouth.backgroundColor = [UIColor whiteColor];
    mouth.layer.cornerRadius = mouthSize/2;
    mouth.hidden = YES;
    [snakeHead addSubview:mouth];
    
    _letterButtons = [[UIView alloc]initWithFrame:CGRectMake(0, labelHeight, frameWidth, headSize)];
    [_letterButtons addSubview:snakeHead];
    [self addSubview:_letterButtons];
    
    xPos = headSize + mouthSize/2 + space;
    yPos = yPos + (headSize - blockSize) / 2;
    
    letterArray = [[NSMutableArray alloc]init];
    bodyArray = [[NSMutableArray alloc]init];
    [bodyArray addObject:snakeHead];
    
    for (int i = 0; i < length ; i++) {
        UILabel *letterLabel = [[UILabel alloc]initWithFrame:CGRectMake(xPos, yPos, blockSize, blockSize)];
        //letterLabel.text = [NSString stringWithFormat:@"%c",[title characterAtIndex:i]];
        letterLabel.textColor = [UIColor whiteColor];
        letterLabel.textAlignment = NSTextAlignmentCenter;
        letterLabel.backgroundColor = snakeHead.backgroundColor;
        letterLabel.layer.cornerRadius = blockSize/2;
        letterLabel.layer.masksToBounds = YES;
        letterLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
        [_letterButtons addSubview:letterLabel];
        [letterArray addObject:letterLabel];
        xPos += (blockSize + space);
    }
    
    self.userInteractionEnabled = YES;
}

- (void)showHead:(void(^)(void))completeBlock
{
    float time = 1.5;
    float duration = time/(length+4);
    
    [UIView animateWithDuration:duration animations:^{
        snakeHead.alpha = 1;
    } completion:^(BOOL finished) {
        mouth.hidden = NO;
        
        
        [self eatButton:duration complete:completeBlock];
    }];

}

- (void)eatButton:(float)duration complete:(void(^)(void))completeBlock
{
    float insetSize = blockSize/10;
    
    [UIView animateWithDuration:duration animations:^{
        
        UIView *head = [bodyArray firstObject];
        head.frame = CGRectOffset(head.frame, (blockSize + space) , 0);

        // Mouth open
        mouth.frame = CGRectInset(mouth.frame, -insetSize, -insetSize);

        
    } completion:^(BOOL finished) {
        
        [self eatNextLetter:[letterArray firstObject] inset:insetSize duration:duration complete:completeBlock];
        
    }];
}

- (void)eatNextLetter:(UIView *)letter inset:(float)inset duration:(float)duration complete:(void(^)(void))completeBlock
{
    
    float insetSize = blockSize/2+inset;
    
    
    [UIView animateWithDuration:duration animations:^{
        
        // Shrink letter
        letter.transform = CGAffineTransformScale(letter.transform, 0.1 , 0.1);
        
        // Close mouth
        mouth.frame = CGRectInset(mouth.frame, insetSize, insetSize);
        
    } completion:^(BOOL finished) {
        
        [letter removeFromSuperview];
        [letterArray removeObject:letter];
        
        CGRect lastFrame = [[bodyArray lastObject]frame];
        CGRect bodyFrame = CGRectOffset(lastFrame, -headSize-2, 0);
        UILabel *body = [[UILabel alloc]initWithFrame:bodyFrame];
        body.layer.cornerRadius = headSize/4;
        body.layer.masksToBounds = YES;
        body.backgroundColor = snakeHead.backgroundColor;
        [_letterButtons addSubview:body];
        [bodyArray addObject:body];
        
        if ([letterArray firstObject]) {
            
            // Move Snake to next letter
            [UIView animateWithDuration:duration animations:^{
        
                for (UIView *v in bodyArray) {
                    
                    v.frame = CGRectOffset(v.frame, (blockSize + space) , 0);
                }
                
                // Open mouth
                mouth.frame = CGRectInset(mouth.frame, -insetSize, -insetSize);
                
            } completion:^(BOOL finished) {
                
                [self eatNextLetter:[letterArray firstObject] inset:inset duration:duration complete:completeBlock];

            }];
        } else {

            // Move Snake to next letter
            [UIView animateWithDuration:duration animations:^{
                
                for (UIView *v in bodyArray) {
                    
                    v.frame = CGRectOffset(v.frame, (blockSize + space) , 0);
                }
                
            } completion:^(BOOL finished) {
                UIView *newMouth = [[UIView alloc]initWithFrame:CGRectMake(headSize/2, headSize/2-8, 16, 16)];
                newMouth.layer.cornerRadius = 8;
                newMouth.backgroundColor = [UIColor whiteColor];
                [snakeHead addSubview:newMouth];
                newMouth.frame = CGRectInset(newMouth.frame, 8, 8);
                
                UILabel *exlamationLabel = [[UILabel alloc]initWithFrame:CGRectMake(frameWidth-labelHeight + 12 + headSize , 0, labelHeight, labelHeight)];
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
                        
                        NSInteger index  = [bodyArray count] - 1;
                        NSInteger charIndex = 0;
                        
                        for (NSInteger i = index ; i > 1 ; i -- ) {
                            
                            UILabel *label = [bodyArray objectAtIndex:i];
                            label.text = [NSString stringWithFormat:@"%c",[introTitle characterAtIndex:charIndex]];
                            label.textColor = [UIColor whiteColor];
                            label.textAlignment = NSTextAlignmentCenter;
                            label.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
                            charIndex++;
                        }
                        
                    } completion:^(BOOL finished) {
                        completeBlock();
                    }];
                    
                }];

                
            }];

        }
        
    }];
}

//- (void)showLetters:(UILabel *)exLabel  charIndex:(NSInteger)charIndex bodyIndex:(NSInteger)bodyIndex complete:(void(^)(void))completeBlock
//{
//    
//    if (length == charIndex) {
//        
//        [UIView animateWithDuration:0.5 animations:^{
//            
//            exLabel.alpha = 1;
//            
//            
//        } completion:^(BOOL finished) {
//            completeBlock();
//        }];
//
//        
//    } else {
//        UILabel *label = [bodyArray objectAtIndex:bodyIndex];
//        label.text = [NSString stringWithFormat:@"%c",[introTitle characterAtIndex:charIndex]];
//        label.textColor = [UIColor whiteColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:25];
//        label.alpha = 0;
//        
//        [UIView animateWithDuration:0.5 animations:^{
//            
//            label.alpha = 1;
//
//            
//        } completion:^(BOOL finished) {
//            
//            [self showLetters:exLabel charIndex:charIndex+1 bodyIndex:bodyIndex-1 complete:completeBlock];
//            
//        }];
//        
//    }
//}





@end
