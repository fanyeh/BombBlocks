//
//  SnakeDot.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/2.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kDotShapeCircle = 0,
    kDotShapeSquare
} DotShape;

@interface SnakeDot : UIView
@property (strong,nonatomic) UIView *smallDot;
@property (nonatomic) DotShape shape;

- (id)initWithFrame:(CGRect)frame dotShape:(DotShape)shape;

@end
