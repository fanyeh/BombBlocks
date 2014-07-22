//
//  ParticleView.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/6/23.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "ParticleView.h"

@implementation ParticleView
{
    CAEmitterLayer* fireEmitter;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithCGColor:[UIColor colorWithRed:0.216 green:0.282 blue:0.322 alpha:1.000].CGColor];
        
    }
    return self;
}

- (void)newExplosionWithPosX:(float)posX
                     andPosY:(float)posY
                    andColor:(UIColor *)color
{
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MyParticle"ofType:@"sks"]];
    emitter.position = CGPointMake(posX, posY);
    emitter.particleColor =  color;
    emitter.particleColorBlendFactor = 1.0;
    emitter.particleColorSequence = nil;
    [emitter resetSimulation];
    [self addChild:emitter];
}


@end
