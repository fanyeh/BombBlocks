//
//  SnakeButton.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/7.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSnakeButtonPlay = 0,
    kSnakeButtonReplay,
    kSnakeButtonPause,
    kSnakeButtonResume
} SnakeButtonState;

@interface SnakeButton : UIView

@property (nonatomic) SnakeButtonState state;
@property (strong,nonatomic) UIView *letterButtons;
@property (strong,nonatomic) UITapGestureRecognizer *tapGesture;

- (id)initWithTitle:(NSString *)title gesture:(UITapGestureRecognizer *)gesture;
- (void)changeState:(SnakeButtonState)newState;

@end
