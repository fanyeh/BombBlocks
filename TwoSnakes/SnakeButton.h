//
//  SnakeButton.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/7.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SnakeButton : UIView

@property (strong,nonatomic) UIView *letterButtons;

- (id)initWithTitle:(NSString *)title;
- (void)showHead:(void(^)(void))completeBlock;


@end
