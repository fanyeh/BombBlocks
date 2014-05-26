//
//  GameMenu.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/21.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameMenu.h"

@implementation GameMenu
{
    UIView *head;
    UIView *mouth;
    UIView *leftEye;
    UIView *rightEye;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat headSize = 150;
        head = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width-headSize)/2, (320-headSize)/2, headSize, headSize)];
        head.backgroundColor = [UIColor blackColor];
        [self addSubview:head];
        
        CGFloat eyeSize = headSize/4;
        CGFloat xoffset = 10;
        CGFloat yoffset = 10;
        leftEye = [[UIView alloc]initWithFrame:CGRectMake(xoffset,yoffset, eyeSize, eyeSize)];
        leftEye.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
        leftEye.layer.cornerRadius = leftEye.frame.size.width/2;
        leftEye.layer.borderWidth = 10;
        leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
        [head addSubview:leftEye];
        
        rightEye = [[UIView alloc]initWithFrame:CGRectMake(headSize-xoffset-eyeSize, yoffset, eyeSize, eyeSize)];
        rightEye.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
        rightEye.layer.cornerRadius = rightEye.frame.size.width/2;
        rightEye.layer.borderWidth = 10;
        rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
        [head addSubview:rightEye];
        
        CGFloat mountSize = headSize/2;
        mouth = [[UIView alloc]initWithFrame:CGRectMake((headSize-mountSize)/2, headSize - (mountSize/2), mountSize, mountSize)];
        mouth.backgroundColor = [UIColor whiteColor];
        mouth.layer.cornerRadius = mouth.frame.size.width/2;
//        mouth.frame = CGRectInset(mouth.frame, 0 , -20);
        [head addSubview:mouth];
        
        
        _resumeLabel = [[CircleLabel alloc]initWithFrame:CGRectMake((frame.size.width-mountSize)/2, mouth.frame.origin.y + mountSize*2, mountSize, mountSize)];
        _resumeLabel.text = @"Resume";
        _resumeLabel.backgroundColor = [UIColor redColor];
        [self addSubview:_resumeLabel];
        
        _retryLabel = [[CircleLabel alloc]initWithFrame:CGRectMake(_resumeLabel.frame.origin.x - mountSize*1.5, _resumeLabel.frame.origin.y, mountSize, mountSize)];
        _retryLabel.text = @"Retry";
        _retryLabel.backgroundColor = [UIColor blueColor];
        [self addSubview:_retryLabel];
        
        _homeLabel = [[CircleLabel alloc]initWithFrame:CGRectMake(_resumeLabel.frame.origin.x + mountSize*1.5, _resumeLabel.frame.origin.y, mountSize, mountSize)];
        _homeLabel.text = @"Home";
        _homeLabel.backgroundColor = [UIColor greenColor];
        [self addSubview:_homeLabel];
        

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
