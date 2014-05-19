//
//  GamePad.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GamePad : UIView

@property (strong,nonatomic) NSMutableArray *dotArray;

- (id)initGamePad;
- (void)counterDots:(NSInteger)count;
-(UIColor *)dotColor:(NSInteger)numDotAte;
- (void)setupDotForGameStart:(CGRect)headFrame;
- (void)hideAllDots;

@end
