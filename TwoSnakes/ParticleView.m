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
        
        self.backgroundColor = [SKColor colorWithCGColor:[UIColor blackColor].CGColor];
        
    }
    return self;
}

- (void)newExplosionWithPosX:(float)posX
                     andPosY:(float)posY
                   assetType:(AssetType)type
{
    SKEmitterNode *emitter;
    UIColor *color;
    
    switch (type) {
        case kAssetTypeBlue:
            //Circle
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"CircleParticle"ofType:@"sks"]];
            color = BlueDotColor;
            break;
        case kAssetTypeRed:
            // 菱形
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SquareParticle"ofType:@"sks"]];
            color = RedDotColor;

            break;
        case kAssetTypeGreen:
            // Square
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SquareParticle"ofType:@"sks"]];
            color = GreenDotColor;

            break;
        case kAssetTypeYellow:
            // Triangle
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"TriangleParticle"ofType:@"sks"]];
            color = YellowDotColor;

            break;
            
        case kAssetTypeEmpty:
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SquareParticle"ofType:@"sks"]];
            color = [UIColor clearColor];

            break;
    }
    emitter.position = CGPointMake(posX, posY);
    emitter.particleColor =  color;
    emitter.particleColorBlendFactor = 1.0;
    emitter.particleColorSequence = nil;
    [emitter resetSimulation];
    [self addChild:emitter];
}


@end
