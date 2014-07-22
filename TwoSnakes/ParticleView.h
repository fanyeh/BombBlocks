//
//  ParticleView.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/6/23.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>


@interface ParticleView : SKScene

- (void)newExplosionWithPosX:(float)posX
                     andPosY:(float)posY
                    andColor:(UIColor *)color;

//- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color;
//
//-(void) startEmission;
//-(void) stopEmission;


@end
