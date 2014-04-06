//
//  MyScene.m
//  Portball
//
//  Created by Quincy Bock on 3/11/14.
//  Copyright (c) 2014 Aero + Quincy. All rights reserved.
//


#import "MyScene.h"

@import AVFoundation;

static inline CGPoint CGPointAdd(const CGPoint a,
                                 const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointSubtract(const CGPoint a,
                                      const CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a,
                                            const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
    return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a)
{
    return a >= 0 ? 1 : -1;
}

// Returns shortest angle between two angles,
// between -M_PI and M_PI
static inline CGFloat ScalarShortestAngleBetween(
                                                 const CGFloat a, const CGFloat b)
{
    CGFloat difference = b - a;
    CGFloat angle = fmodf(difference, M_PI * 2);
    if (angle >= M_PI) {
        angle -= M_PI * 2;
    }
    return angle;
}

#define ARC4RANDOM_MAX      0x100000000
static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) *
                  (max - min) + min);
}

static const float BG_SPEED = 50;

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    CNPhysicsCategoryBall = 1 << 0, // 0001 = 1
    CNPhysicsCategoryFloor = 1 << 1, // 0010 = 2
    CNPhysicsCategoryEnemy = 1 << 2, // 0100 = 4
    CNPhysicsCategoryFriend = 1 << 3, // 1000 = 8
    CNPhysicsCategoryShelf = 1 << 4, // 1000 = 8

};

@interface MyScene()<SKPhysicsContactDelegate>
@end

@implementation MyScene
{
    SKSpriteNode *_ball;
    SKSpriteNode *_container;
//    SKShapeNode *_ball;
    
    SKNode *_bgLayer;
    
    CGPoint _touchLocation;


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
//    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    for (int i = 0; i < 2; i++) {
        SKSpriteNode* bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        bg.anchorPoint = CGPointZero;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.name = @"bg";
        [self addChild: bg];
    }
    self.physicsWorld.contactDelegate = self;
    self.physicsBody.categoryBitMask = CNPhysicsCategoryFloor;
    [self ballContainer];
    [self spawnBall];
<<<<<<< HEAD
=======
}

-(void)moveBG
{
    [self enumerateChildNodesWithName:@"bg" usingBlock:^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode *bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_SPEED, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         if (bg.position.x <= -bg.size.width) {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2, bg.position.y);
         }
     }];
>>>>>>> master
}

//--------------------------------------------------------------------------

-(void)ballContainer
{
    _container = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:0] size:CGSizeMake(40, self.size.height)];
    CGRect body = _container.frame;
    _container.position = CGPointMake(40, 160);
    _container.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:body];
    [self addChild:_container];
//    SKShapeNode *stroke = [SKShapeNode node];
//    stroke.path = CGPathCreateWithRect(body,nil);
//    stroke.strokeColor = [SKColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
//    stroke.lineWidth = 1.0;
//    [self addChild:stroke];
}

-(void)spawnBall
{
    //with an image
    _ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    _ball.position = CGPointMake(0, 0);
    
    _ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_ball.size.width/2];
    _ball.name = @"ball";
    _ball.physicsBody.restitution = 1.0;
//    _ball.physicsBody.density = 20.0;
    _ball.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _ball.physicsBody.collisionBitMask = CNPhysicsCategoryFloor | CNPhysicsCategoryShelf;

    [_container addChild:_ball];
    
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
    double r = arc4random_uniform(3);
    
    if (r < 1) {
        NSLog(@"0");
        [self spawnFriend:position];
    }
    
    if (r >= 1 && r < 2) {
         NSLog(@"1");
        [self spawnEnemy:position];
    }
    
    if (r >= 2) {
        NSLog(@"2");
        [self spawnShelf:position];
    }
    
}

//--------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInNode:self];
    
    [self spawnShelf:_touchLocation];
    
    
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


-(void)spawnShelf:(CGPoint)position {
    //with an image
    SKSpriteNode* _shelf = [SKSpriteNode spriteNodeWithImageNamed:@"shelf"];
    _shelf.position = position;
    
    _shelf.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(_shelf.size.width-2, _shelf.size.height-2)];
    _shelf.name = @"shelf";
    
    _shelf.physicsBody.categoryBitMask = CNPhysicsCategoryShelf;
    [_shelf.physicsBody setDynamic:NO];
    
    //add it to a layer??
    [self addChild:_shelf];
}

//--------------------------------------------------------------------------

- (void)update:(CFTimeInterval)currentTime
{
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
    [self enumerateChildNodesWithName:@"shelf"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *_shelf = (SKSpriteNode *)node;
                               _shelf.position = CGPointMake(_shelf.position.x - 2, _shelf.position.y);
                           }];
    [self moveBG];
}
//--------------------------------------------------------------------------

@end