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
    
    SKNode *_bgLayer;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    int counter;
}

//--------------------------------------------------------------------------

-(instancetype)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        [self initializeScene];
        
        _bgLayer = [SKNode node];
        [self addChild:_bgLayer];
    }
    return self;
}

//--------------------------------------------------------------------------

- (void)initializeScene
{
    counter = 0;
    
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
    _ball.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;


    [self addChild:_ball];
    
    //With a path
//    _ball = [SKShapeNode node];
//    CGRect box = CGRectMake(self.size.width/4, self.size.height/2, 20, 20);
//    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:box];
//    _ball.path = circlePath.CGPath;
//    [self addChild:_ball];

}

//--------------------------------------------------------------------------

-(void)spawnObstacle
{
    //pick position
    CGPoint position = CGPointMake(self.size.width, self.size.height*drand48());
    
    //pick a thing to draw
    double r = arc4random_uniform(2);
    
    if (r < 1) {
        NSLog(@"0");
        [self spawnFriend:position];
    }
    
    if (r >= 1) {
         NSLog(@"1");
        [self spawnEnemy:position];
    }
    
}

//--------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    
    
}

//--------------------------------------------------------------------------

-(void)spawnFriend:(CGPoint)position {
    //with an image
    SKSpriteNode* _friend = [SKSpriteNode spriteNodeWithImageNamed:@"friend"];
    _friend.position = position;
    
    _friend.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_friend.size.width/2];
    _friend.name = @"friend";
    
    _friend.physicsBody.categoryBitMask = CNPhysicsCategoryFriend;
    [_friend.physicsBody setDynamic:NO];
    
    //add it to a layer??
    [self addChild:_friend];
}

//--------------------------------------------------------------------------

-(void)spawnEnemy:(CGPoint)position {
    //with an image
    SKSpriteNode* _enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    _enemy.position = position;
    
    _enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_enemy.size.width/2];
    _enemy.name = @"enemy";
    
    _enemy.physicsBody.categoryBitMask = CNPhysicsCategoryEnemy;
    [_enemy.physicsBody setDynamic:NO];
    
    //add it to a layer??
    [self addChild:_enemy];
}

//--------------------------------------------------------------------------

- (void)update:(CFTimeInterval)currentTime{
    
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    }
    else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    
    if (counter > 50) {
        [self spawnObstacle];
        counter = 0;
    } else {
        counter ++;
    }
    
    
    [self enumerateChildNodesWithName:@"friend"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *_friend = (SKSpriteNode *)node;
                               _friend.position = CGPointMake(_friend.position.x - 2, _friend.position.y);
                           }];
    [self enumerateChildNodesWithName:@"enemy"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *_friend = (SKSpriteNode *)node;
                               _friend.position = CGPointMake(_friend.position.x - 2, _friend.position.y);
                           }];
    
}
//--------------------------------------------------------------------------

- (void)moveBg
{
//    CGVector moveBackgroundVector = CGVectorMake(-1, 0);
//    _bgLayer.position = _bgLayer.position + moveBackgroundVector;
//    
//    CGPoint bgVelocity = CGPointMake(-BG_POINTS_PER_SEC, 0);
//    CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
//    _bgLayer.position = CGPointAdd(_bgLayer.position, amtToMove);
//    [_bgLayer enumerateChildNodesWithName:@"bg" usingBlock: 128
//     ^(SKNode *node, BOOL *stop) {
//         SKSpriteNode * bg = (SKSpriteNode *) node;
//         if (bg.position.x <= -bg.size.width) {
//             bg.position =
//             CGPointMake(bg.position.x + bg.size.width*2,
//                         bg.position.y);
//         }
//     }];
}

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
@end