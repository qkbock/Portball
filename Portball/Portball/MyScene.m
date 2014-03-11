//
//  MyScene.m
//  Portball
//
//  Created by Quincy Bock on 3/11/14.
//  Copyright (c) 2014 Aero + Quincy. All rights reserved.
//


#import "MyScene.h"

@implementation MyScene
{
    SKSpriteNode *_circle;
}

//--------------------------------------------------------------------------

-(instancetype)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        [self initializeScene];
    }
    return self;
}

//--------------------------------------------------------------------------

- (void)initializeScene
{
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [self spawnBall];

}

//--------------------------------------------------------------------------

-(void)spawnBall
{
    _circle = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    _circle.position = CGPointMake(self.size.width * 0.50, self.size.height * 0.50);
    [self addChild:_circle];
}

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
@end