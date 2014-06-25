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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        fireEmitter = (CAEmitterLayer*)self.layer;
        
        // configure the emitter layer
        // fireEmitter.emitterPosition = CGPointMake(50, 50);
        // fireEmitter.emitterSize = CGSizeMake(320, 10);
        fireEmitter.emitterPosition = CGPointMake(self.bounds.size.width /2, 0);
        fireEmitter.emitterSize = self.bounds.size;
        fireEmitter.emitterMode = kCAEmitterLayerSurface;
       
        
        // Particles are emitted along a line
        // From : (emitterPosition.x - emitterSize.width/2, emitterPosition.y, emitterZPosition)
        // To   : (emitterPosition.x + emitterSize.width/2, emitterPosition.y, emitterZPosition)
        
        fireEmitter.emitterShape = kCAEmitterLayerRectangle;
        
        CAEmitterCell* fire = [CAEmitterCell emitterCell];
        fire.birthRate = 5;
        fire.lifetime = 5.0;
        fire.lifetimeRange = 0.5;
        //fire.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1]CGColor];
        fire.contents = (id)[[UIImage imageNamed:@"rain.png"] CGImage];
        [fire setName:@"fire"];
        
        fire.velocity = 10;
        fire.velocityRange = 3;
        fire.emissionRange = (CGFloat) 2*M_PI;
        //fire.emissionLongitude = (CGFloat) M_PI;
        fire.yAcceleration = 50;
        //fire.spinRange = 10.0;
        fire.scale = 1.0;
        fire.scaleRange = 0.2;
        
        
        //add the cell to the layer and we're done
        fireEmitter.emitterCells = [NSArray arrayWithObject:fire];
    }
    return self;
}

+ (Class)layerClass
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}


@end
