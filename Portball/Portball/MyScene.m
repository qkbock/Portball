//
//  MyScene.m
//  Portball
//
//  Created by Quincy Bock on 3/11/14.
//  Copyright (c) 2014 Aero + Quincy. All rights reserved.
//


#import "MyScene.h"


typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    CNPhysicsCategoryBall = 1 << 0, // 0001 = 1
    CNPhysicsCategoryFloor = 1 << 1, // 0010 = 2
    CNPhysicsCategoryEnemy = 1 << 2, // 0100 = 4
    CNPhysicsCategoryFriend = 1 << 3, // 1000 = 8
};

@interface MyScene()<SKPhysicsContactDelegate>
@end

@implementation MyScene
{
    SKSpriteNode *_ball;
//    SKShapeNode *_ball;
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
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    bg.position = CGPointMake(self.size.width/2, self.size.height/2);
    
    self.physicsWorld.contactDelegate = self;
    self.physicsBody.categoryBitMask = CNPhysicsCategoryFloor;
    
    [self addChild: bg];
    [self spawnBall];

}

//--------------------------------------------------------------------------

-(void)spawnBall
{
    //with an image
    _ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    _ball.position = CGPointMake(self.size.width/8, self.size.height/2);
    
    _ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_ball.size.width/2];
    _ball.name = @"ball";
    _ball.physicsBody.restitution = 1.0;
//    _ball.physicsBody.density = 20.0;
    _ball.physicsBody.categoryBitMask = CNPhysicsCategoryBall;


    [self addChild:_ball];
    
    //With a path
//    _ball = [SKShapeNode node];
//    CGRect box = CGRectMake(self.size.width/4, self.size.height/2, 20, 20);
//    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:box];
//    _ball.path = circlePath.CGPath;
//    [self addChild:_ball];

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