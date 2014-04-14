//
//  MyScene.m
//  Portball
//
//  Created by Quincy Bock on 3/11/14.
//  Copyright (c) 2014 Aero + Quincy. All rights reserved.
//


#import "MyScene.h"
#import "SKTAudio.h"
#import "SKTUtils.h"

@import AVFoundation;

static const float BG_SPEED = 50;

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    CNPhysicsCategoryBall   = 1 << 0,
    CNPhysicsCategoryFloor  = 1 << 1,
    CNPhysicsCategoryEnemy  = 1 << 2,
    CNPhysicsCategoryFriend = 1 << 3,
    CNPhysicsCategoryShelf  = 1 << 4,
    CNPhysicsCategoryWhite  = 1 << 5,
    CNPhysicsCategoryBlack  = 1 << 6,
    CNPhysicsCategoryInert  = 1 << 7,
};

@interface MyScene()<SKPhysicsContactDelegate>
@end

@implementation MyScene
{
    SKSpriteNode *_ball;
    SKSpriteNode *_container;
    SKSpriteNode *_whiteHole;
    SKSpriteNode *_blackHole;
//    SKShapeNode *_ball;
    SKEmitterNode *_bloodEmitter;
    SKNode *_bgLayer;
    SKNode *_portalNode;
    SKNode *_ballNode;
    SKNode *_bunnyNode;
    SKSpriteNode *_jaw;
    CGPoint _touchLocation;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    BOOL isWhite;
    BOOL isBlack;
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
    isWhite = NO;
    isBlack = NO;
    counter = 0;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    for (int i = 0; i < 2; i++) {
        SKSpriteNode* bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.anchorPoint = CGPointZero;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.name = @"bg";
        [self addChild: bg];
    }
    self.physicsWorld.contactDelegate = self;
    self.physicsBody.categoryBitMask = CNPhysicsCategoryFloor;
    _portalNode = [SKNode node];
    [self addChild:_portalNode];
    _ballNode = [SKNode node];
    [self addChild:_ballNode];
    [self spawnBall:CGPointMake(20, 160)];
    
    _bunnyNode = [SKNode node];
    [self addChild:_bunnyNode];
    [self spawnBunny:CGPointMake(self.size.width/2, self.size.height/2)];
    
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
}

//--------------------------------------------------------------------------

-(void)spawnBall:(CGPoint)position
{
    //with an image
    _ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    _ball.position = position;
    
    _ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_ball.size.width/2];
    _ball.name = @"ball";
    _ball.physicsBody.restitution = 1.0;
//    _ball.physicsBody.density = 20.0;
    _ball.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _ball.physicsBody.collisionBitMask = CNPhysicsCategoryFloor | CNPhysicsCategoryShelf;

    [_ballNode addChild:_ball];
    
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
        // NSLog(@"0");
        [self spawnFriend:position];
    }
    
    if (r >= 1 && r < 2) {
        // NSLog(@"1");
        [self spawnEnemy:position];
    }
    
    if (r >= 2) {
        // NSLog(@"2");
        [self spawnShelf:position];
    }
    
}

//--------------------------------------------------------------------------

-(void)makeBlood:(CGPoint)position
{
    _bloodEmitter =
    [NSKeyedUnarchiver unarchiveObjectWithFile: [[NSBundle mainBundle] pathForResource:@"blood"
                                                                                ofType:@"sks"]];
    _bloodEmitter.position = position;
    _bloodEmitter.name = @"ventingPlasma";
    [self addChild:_bloodEmitter];
}

//--------------------------------------------------------------------------


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInNode:self];
    // NSLog(@"%@", NSStringFromCGPoint(_touchLocation));
//    [self portals:_touchLocation];
    /* broken to be fixed
    if (isWhite) {
        [_whiteHole runAction:[SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"white"],[SKTexture textureWithImageNamed:@"white1"],[SKTexture textureWithImageNamed:@"white2"],[SKTexture textureWithImageNamed:@"white3"],[SKTexture textureWithImageNamed:@"white2"],[SKTexture textureWithImageNamed:@"white1"]] timePerFrame:0.15]];
    }
    */
//    _bunnyNode.position = CGPointMake(_bunnyNode.position.x, _bunnyNode.position.y +60);
    [self makeBlood:_jaw.position];
}

-(void)portals:(CGPoint)position
{
    _whiteHole = [SKSpriteNode spriteNodeWithImageNamed:@"white"];
    _whiteHole.position = position;
    _whiteHole.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_ball.size.width/2];
    _whiteHole.physicsBody.dynamic = NO;
    _whiteHole.name = @"whiteHole";
    _whiteHole.physicsBody.categoryBitMask = CNPhysicsCategoryWhite;
    _whiteHole.physicsBody.collisionBitMask = kNilOptions;
    _whiteHole.physicsBody.contactTestBitMask = CNPhysicsCategoryBall;
    
    _blackHole = [SKSpriteNode spriteNodeWithImageNamed:@"black"];
    _blackHole.position = position;
    _blackHole.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_ball.size.width/2];
    _blackHole.physicsBody.dynamic = NO;
    _blackHole.name = @"blackHole";
    _blackHole.physicsBody.categoryBitMask = CNPhysicsCategoryBlack;
    _blackHole.physicsBody.collisionBitMask = kNilOptions;
    _blackHole.physicsBody.contactTestBitMask = CNPhysicsCategoryBall;
    if (!isWhite) {
        [_portalNode addChild:_whiteHole];
        isWhite = YES;
    } else if (!isBlack) {
        [_portalNode addChild:_blackHole];
        isBlack = YES;
        _blackHole.userData = [@{@"exist":@(YES)} mutableCopy];
    } else {
        [_portalNode removeAllChildren];
        isWhite = NO;
        isBlack = NO;
    }
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if (collision == (CNPhysicsCategoryBall|CNPhysicsCategoryWhite)) {
        if (_blackHole.userData[@"exist"]) {
            [_ballNode removeAllChildren];
            CGPoint position = _blackHole.position;
            [self spawnBall:position];
            [_portalNode removeAllChildren];
            isWhite = NO;
            isBlack = NO;
            
        }
    }
    if (collision == (CNPhysicsCategoryBall|CNPhysicsCategoryEnemy)) {
        NSLog(@"Enemy");
    }
    if (collision == (CNPhysicsCategoryBall|CNPhysicsCategoryFriend)) {
        NSLog(@"Friend");
//        [self makeBlood:_ballNode.position];
    }
}


//--------------------------------------------------------------------------

-(void)drawLoseScreen{
    SKSpriteNode* _loseBackground = [SKSpriteNode spriteNodeWithImageNamed:@"loseBackground"];
    _loseBackground.position = CGPointMake(self.size.width/2, self.size.height/2);
    SKSpriteNode* _loseButton = [SKSpriteNode spriteNodeWithImageNamed:@"loseButton"];
    _loseButton.position = CGPointMake(self.size.width/2, self.size.height/2);
    
    [self addChild:_loseBackground];
    [self addChild:_loseButton];
}


//--------------------------------------------------------------------------

-(void)spawnFriend:(CGPoint)position
{
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

-(void)spawnEnemy:(CGPoint)position
{
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


-(void)spawnShelf:(CGPoint)position
{
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

-(void)spawnBunny:(CGPoint)position
{
    SKSpriteNode *_backLeg = [SKSpriteNode spriteNodeWithImageNamed:@"backLeg"];
    SKSpriteNode *_backArm = [SKSpriteNode spriteNodeWithImageNamed:@"backArm"];
    SKSpriteNode *_backEar = [SKSpriteNode spriteNodeWithImageNamed:@"backEar"];
    SKSpriteNode *_tail = [SKSpriteNode spriteNodeWithImageNamed:@"tail"];
    SKSpriteNode *_body = [SKSpriteNode spriteNodeWithImageNamed:@"body"];
    SKSpriteNode *_frontArm = [SKSpriteNode spriteNodeWithImageNamed:@"frontArm"];
    SKSpriteNode *_frontEar = [SKSpriteNode spriteNodeWithImageNamed:@"frontEar"];
    SKSpriteNode *_frontLeg = [SKSpriteNode spriteNodeWithImageNamed:@"frontLeg"];
    _jaw = [SKSpriteNode spriteNodeWithImageNamed:@"jaw"];
    
//    SKSpriteNode *_earSpringHook = [SKSpriteNode spriteNodeWithImageNamed:@"hook"];
    SKNode *_earSpringHook = [SKNode node];
    SKNode *_jawSpringHook = [SKNode node];
    SKNode *_armSpringHook = [SKNode node];
    SKNode *_legSpringHook = [SKNode node];

    
    _backLeg.position = CGPointMake(position.x - 1.811, position.y - 21.889); //X
    _backArm.position = CGPointMake(position.x + 8.623, position.y - 9.081 ); //X
    _backEar.position = CGPointMake(position.x - 0.564, position.y + 43.339); //X
    _tail.position = CGPointMake(position.x - 24.746, position.y - 31.555); //X
    _body.position = position; //X
    _frontArm.position = CGPointMake(position.x + 3.654, position.y - 10.44); //X
    _frontEar.position = CGPointMake(position.x - 6.64, position.y + 40.222); //X
    _frontLeg.position = CGPointMake(position.x - 6.048, position.y - 26.655); //X
    _jaw.position = CGPointMake(position.x + 15.822, position.y + 16.962);
    
    _earSpringHook.position = CGPointMake(position.x -8.536, position.y + 69.237);
    _jawSpringHook.position = CGPointMake(position.x +20.813, position.y + 31.891);
    _armSpringHook.position = CGPointMake(position.x +27.388, position.y - 12.729);
    _legSpringHook.position = CGPointMake(position.x +15.535, position.y + -14.443);

    
    _backLeg.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_backLeg.size];
    _backArm.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_backArm.size];
    _backEar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_backEar.size];
    _tail.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_tail.size];
    _body.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _frontArm.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_frontArm.size];
    _frontEar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_frontEar.size];
    _frontLeg.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_frontLeg.size];
    _jaw.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_jaw.size];
    
    _earSpringHook.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
    _jawSpringHook.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
    _armSpringHook.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
    _legSpringHook.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];

    
    _backLeg.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _backArm.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _backEar.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _tail.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _body.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _frontArm.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _frontEar.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _frontLeg.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    _jaw.physicsBody.categoryBitMask = CNPhysicsCategoryBall;
    
    _backLeg.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;
    _backArm.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;
    _backEar.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;
    _tail.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;
    _frontArm.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;
    _frontEar.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;
    _frontLeg.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;
    _jaw.physicsBody.collisionBitMask = CNPhysicsCategoryFloor;
    
    _earSpringHook.physicsBody.categoryBitMask = CNPhysicsCategoryInert;
    _earSpringHook.physicsBody.collisionBitMask = kNilOptions;
    _jawSpringHook.physicsBody.categoryBitMask = CNPhysicsCategoryInert;
    _jawSpringHook.physicsBody.collisionBitMask = kNilOptions;
    _armSpringHook.physicsBody.categoryBitMask = CNPhysicsCategoryInert;
    _armSpringHook.physicsBody.collisionBitMask = kNilOptions;
    _legSpringHook.physicsBody.categoryBitMask = CNPhysicsCategoryInert;
    _legSpringHook.physicsBody.collisionBitMask = kNilOptions;
    
    [_bunnyNode addChild: _backLeg];
    [_bunnyNode addChild: _backArm];
    [_bunnyNode addChild: _backEar];
    [_bunnyNode addChild: _tail];
    [_bunnyNode addChild: _body];
    [_bunnyNode addChild: _frontArm];
    [_bunnyNode addChild: _frontEar];
    [_bunnyNode addChild: _frontLeg];
    [_bunnyNode addChild: _jaw];
    
    [_bunnyNode addChild: _earSpringHook];
    [_bunnyNode addChild: _jawSpringHook];
    [_bunnyNode addChild: _armSpringHook];
    [_bunnyNode addChild: _legSpringHook];

    
    SKPhysicsJointPin *leg1Joint = [SKPhysicsJointPin jointWithBodyA:_backLeg.physicsBody
                                                               bodyB:_body.physicsBody
                                                              anchor:CGPointMake(position.x - 7.95, position.y - 18.74)];
    SKPhysicsJointPin *leg2Joint = [SKPhysicsJointPin jointWithBodyA:_frontLeg.physicsBody
                                                               bodyB:_body.physicsBody
                                                              anchor:CGPointMake(position.x - 11.909, position.y - 24.312)];
    SKPhysicsJointPin *arm1Joint = [SKPhysicsJointPin jointWithBodyA:_backArm.physicsBody
                                                               bodyB:_body.physicsBody
                                                              anchor:CGPointMake(position.x + 6.713, position.y - 1.731 )];
    SKPhysicsJointPin *arm2Joint = [SKPhysicsJointPin jointWithBodyA:_frontArm.physicsBody
                                                               bodyB:_body.physicsBody
                                                              anchor:CGPointMake(position.x + 0.88, position.y - 2.904)];
    SKPhysicsJointPin *ear1Joint = [SKPhysicsJointPin jointWithBodyA:_backEar.physicsBody
                                                               bodyB:_body.physicsBody
                                                              anchor:CGPointMake(position.x + 2, position.y + 33.779)];
    SKPhysicsJointPin *ear2Joint = [SKPhysicsJointPin jointWithBodyA:_frontEar.physicsBody
                                                               bodyB:_body.physicsBody
                                                              anchor:CGPointMake(position.x - 0.472, position.y + 31.553)];
    SKPhysicsJointPin *tailJoint = [SKPhysicsJointPin jointWithBodyA:_tail.physicsBody
                                                               bodyB:_body.physicsBody
                                                              anchor:CGPointMake(position.x - 23.639, position.y - 31.644)];
    SKPhysicsJointPin *jawJoint = [SKPhysicsJointPin jointWithBodyA:_jaw.physicsBody
                                                               bodyB:_body.physicsBody
                                                              anchor:CGPointMake(position.x + 12.578, position.y + 18.503)];
//    SKPhysicsJointSliding *jawJoint = [SKPhysicsJointSliding jointWithBodyA:_jaw.physicsBody bodyB:_body.physicsBody anchor:CGPointMake(position.x + 12.578, position.y + 18.503) axis: CGVectorMake(0, .1)];
    
    SKPhysicsJointFixed *earSpringJointFix = [SKPhysicsJointFixed jointWithBodyA:_earSpringHook.physicsBody bodyB:_body.physicsBody anchor:_body.position ];
    SKPhysicsJointFixed *jawSpringJointFix = [SKPhysicsJointFixed jointWithBodyA:_jawSpringHook.physicsBody bodyB:_body.physicsBody anchor:_body.position ];
    SKPhysicsJointFixed *armSpringJointFix = [SKPhysicsJointFixed jointWithBodyA:_armSpringHook.physicsBody bodyB:_body.physicsBody anchor:_body.position ];
    SKPhysicsJointFixed *legSpringJointFix = [SKPhysicsJointFixed jointWithBodyA:_legSpringHook.physicsBody bodyB:_body.physicsBody anchor:_body.position ];
    
    SKPhysicsJointSpring *ear1SpringJoint = [SKPhysicsJointSpring jointWithBodyA:_earSpringHook.physicsBody bodyB:_backEar.physicsBody anchorA:_earSpringHook.position anchorB:CGPointMake(position.x - 2.818, position.y + 52.228)];
    SKPhysicsJointSpring *ear2SpringJoint = [SKPhysicsJointSpring jointWithBodyA:_earSpringHook.physicsBody bodyB:_frontEar.physicsBody anchorA:_earSpringHook.position anchorB:CGPointMake(position.x - 12.642, position.y + 49.148)];
  
    arm1Joint.shouldEnableLimits = YES;
    arm1Joint.upperAngleLimit = 0.3;
    arm1Joint.lowerAngleLimit = -0.5;
    arm1Joint.frictionTorque = 0.001;
    arm2Joint.shouldEnableLimits = YES;
    arm2Joint.upperAngleLimit = 0.3;
    arm2Joint.lowerAngleLimit = -0.5;
    arm2Joint.frictionTorque = 0.001;
    
    leg1Joint.shouldEnableLimits = YES;
    leg1Joint.upperAngleLimit = 0.8;
    leg1Joint.lowerAngleLimit = -0.5;
    
    leg2Joint.shouldEnableLimits = YES;
    leg2Joint.upperAngleLimit = 0.8;
    leg2Joint.lowerAngleLimit = -0.5;
    
    tailJoint.shouldEnableLimits = YES;
    tailJoint.upperAngleLimit = 0.3;
    tailJoint.lowerAngleLimit = -0.3;
    
    jawJoint.shouldEnableLimits = YES;
    jawJoint.upperAngleLimit = 1.2;
    jawJoint.lowerAngleLimit = -0.3;
    
//    jawJoint.shouldEnableLimits = YES;
//    jawJoint.lowerDistanceLimit = 3;
//    jawJoint.upperDistanceLimit = 4;
    ear1SpringJoint.damping = -10;
    ear2SpringJoint.damping = -10;

    [self.physicsWorld addJoint:leg1Joint];
    [self.physicsWorld addJoint:leg2Joint];
    [self.physicsWorld addJoint:arm1Joint];
    [self.physicsWorld addJoint:arm2Joint];
    [self.physicsWorld addJoint:ear1Joint];
    [self.physicsWorld addJoint:ear2Joint];
    [self.physicsWorld addJoint:tailJoint];
    [self.physicsWorld addJoint:jawJoint];

    [self.physicsWorld addJoint:earSpringJointFix];
    [self.physicsWorld addJoint:jawSpringJointFix];
    [self.physicsWorld addJoint:armSpringJointFix];
    [self.physicsWorld addJoint:legSpringJointFix];
    
    [self.physicsWorld addJoint:ear1SpringJoint];
    [self.physicsWorld addJoint:ear2SpringJoint];

}

//--------------------------------------------------------------------------
-(void)update:(CFTimeInterval)currentTime
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
    while (_ball.physicsBody.angularVelocity != 0) {
        _ball.physicsBody.angularVelocity = 0;
        _ball.physicsBody.velocity = CGVectorMake(0, 0);
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