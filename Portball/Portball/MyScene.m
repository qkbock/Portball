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
    CNPhysicsCategoryBunny  = 1 << 7,
};

@interface MyScene()<SKPhysicsContactDelegate>
@end

@implementation MyScene
{
    SKNode *_ballNode;
    SKNode *_bgLayer;
    SKNode *_portalNode;
    SKSpriteNode *_container;
    SKSpriteNode *_whiteHole;
    SKSpriteNode *_blackHole;
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
    CGPoint position = CGPointMake(40, 360);
    self.physicsWorld.gravity = CGVectorMake(0, -2);
    self.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-100, 0) toPoint:CGPointMake(700, 0)];
    for (int i = 0; i < 2; i++) {
        SKSpriteNode* bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        bg.anchorPoint = CGPointZero;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.name = @"bg";
        [self addChild: bg];
    }
    self.physicsWorld.contactDelegate = self;
    self.physicsBody.categoryBitMask = CNPhysicsCategoryFloor;
    _portalNode = [SKNode node];
    [self addChild:_portalNode];
    [self spawnBall: position];
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
    _ballNode = [SKNode node];
    _ballNode.position = position;
    _ballNode.physicsBody   = [SKPhysicsBody bodyWithCircleOfRadius:30];
//    _ballNode.physicsBody.angularVelocity = 0.1;
//    _ballNode.physicsBody.angularDamping = 0.1;
//    _ballNode.physicsBody.allowsRotation = YES;
    _ballNode.physicsBody.restitution = 1;
    _ballNode.physicsBody.mass = 20;
    _ballNode.physicsBody.categoryBitMask       = CNPhysicsCategoryBall;
    _ballNode.physicsBody.collisionBitMask      = CNPhysicsCategoryFloor;
    _ballNode.physicsBody.contactTestBitMask    = CNPhysicsCategoryEnemy | CNPhysicsCategoryFriend;

    [self addChild:_ballNode];
    //[_ballNode addChild:_ball];
    [self spawnBunny:position];

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
    CGPoint position = CGPointMake(self.size.width, self.size.height*drand48() + 20);
    CGPoint shelfPos = CGPointMake(self.size.width + 30, 20);
    
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
        [self spawnShelf:shelfPos];
    }
    
}

//--------------------------------------------------------------------------

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInNode:self];
    // NSLog(@"%@", NSStringFromCGPoint(_touchLocation));
    [self portals:_touchLocation];
    /* broken to be fixed
    if (isWhite) {
        [_whiteHole runAction:[SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"white"],[SKTexture textureWithImageNamed:@"white1"],[SKTexture textureWithImageNamed:@"white2"],[SKTexture textureWithImageNamed:@"white3"],[SKTexture textureWithImageNamed:@"white2"],[SKTexture textureWithImageNamed:@"white1"]] timePerFrame:0.15]];
    }
    */
//    _bunnyNode.position = CGPointMake(_bunnyNode.position.x, _bunnyNode.position.y +60);
}

-(void)portals:(CGPoint)position
{
    _whiteHole = [SKSpriteNode spriteNodeWithImageNamed:@"white"];
    _whiteHole.position = position;
    _whiteHole.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_whiteHole.size.width/2];
    _whiteHole.physicsBody.dynamic = NO;
    _whiteHole.name = @"whiteHole";
    _whiteHole.physicsBody.categoryBitMask = CNPhysicsCategoryWhite;
    _whiteHole.physicsBody.collisionBitMask = kNilOptions;
    _whiteHole.physicsBody.contactTestBitMask = CNPhysicsCategoryBall;
    
    _blackHole = [SKSpriteNode spriteNodeWithImageNamed:@"black"];
    _blackHole.position = position;
    _blackHole.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_blackHole.size.width/2];
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
    }
}

-(void)didEndContact:(SKPhysicsContact *)contact
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
}

//--------------------------------------------------------------------------

-(void)spawnFriend:(CGPoint)position
{
    //with an image
    SKSpriteNode* _friend = [SKSpriteNode spriteNodeWithImageNamed:@"swallow1"];
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
    SKSpriteNode* _enemy = [SKSpriteNode spriteNodeWithImageNamed:@"holyHandGrenade"];
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
    SKSpriteNode* _shelf = [SKSpriteNode spriteNodeWithImageNamed:@"shrubbery1"];
    _shelf.position = position;
    
    _shelf.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_shelf.size.width/2];
    _shelf.name = @"shelf";
    
    _shelf.physicsBody.categoryBitMask = CNPhysicsCategoryShelf;
    [_shelf.physicsBody setDynamic:NO];
    
    //add it to a layer??
    [self addChild:_shelf];
}

//Aero: Fixed bunny sandbox, not perfect. Please don't touch the code. Add seperate sandbox. And please add the tail (missing png).
-(void)spawnBunny:(CGPoint)position
{
    SKSpriteNode *_body = [SKSpriteNode spriteNodeWithImageNamed:@"body"];
    SKSpriteNode *_backLeg = [SKSpriteNode spriteNodeWithImageNamed:@"backLeg"];
    SKSpriteNode *_backArm = [SKSpriteNode spriteNodeWithImageNamed:@"backArm"];
    SKSpriteNode *_backEar = [SKSpriteNode spriteNodeWithImageNamed:@"backEar"];
    SKSpriteNode *_frontArm = [SKSpriteNode spriteNodeWithImageNamed:@"frontArm"];
    SKSpriteNode *_frontEar = [SKSpriteNode spriteNodeWithImageNamed:@"frontEar"];
    SKSpriteNode *_frontLeg = [SKSpriteNode spriteNodeWithImageNamed:@"frontLeg"];
    SKSpriteNode *_jaw = [SKSpriteNode spriteNodeWithImageNamed:@"jaw"];
    
    _backLeg.position      = CGPointMake(position.x - 1.811, position.y - 21.889);
    _backLeg.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _backLeg.physicsBody.density           = 0.1;
    _backLeg.physicsBody.categoryBitMask   = CNPhysicsCategoryBunny;
    _backLeg.physicsBody.collisionBitMask  = kNilOptions;
    [_ballNode addChild:_backLeg];
    _backArm.position      = CGPointMake(position.x + 8.623, position.y - 9.081 );
    _backArm.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _backArm.physicsBody.density           = 0.1;
    _backArm.physicsBody.categoryBitMask   = CNPhysicsCategoryBunny;
    _backArm.physicsBody.collisionBitMask  = kNilOptions;
    [_ballNode addChild:_backArm];
    _backEar.position      = CGPointMake(position.x - 0.564, position.y + 43.339);
    _backEar.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _backEar.physicsBody.density           = 0.1;
    _backEar.physicsBody.categoryBitMask   = CNPhysicsCategoryBunny;
    _backEar.physicsBody.collisionBitMask  = kNilOptions;
    [_ballNode addChild:_backEar];
    _body.position      = position;
    _body.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _body.physicsBody.density           = 0.1;
    _body.physicsBody.categoryBitMask   = CNPhysicsCategoryBunny;
    _body.physicsBody.collisionBitMask  = kNilOptions;
    [_ballNode addChild:_body];
    _frontLeg.position      = CGPointMake(position.x - 6.048, position.y - 26.655);
    _frontLeg.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _frontLeg.physicsBody.density           = 0.1;
    _frontLeg.physicsBody.categoryBitMask   = CNPhysicsCategoryBunny;
    _frontLeg.physicsBody.collisionBitMask  = kNilOptions;
    [_ballNode addChild:_frontLeg];
    _frontArm.position      = CGPointMake(position.x + 3.654, position.y - 10.44);
    _frontArm.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _frontArm.physicsBody.density           = 0.1;
    _frontArm.physicsBody.categoryBitMask   = CNPhysicsCategoryBunny;
    _frontArm.physicsBody.collisionBitMask  = kNilOptions;
    [_ballNode addChild:_frontArm];
    _frontEar.position      = CGPointMake(position.x - 6.64, position.y + 40.222);
    _frontEar.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _frontEar.physicsBody.density           = 0.1;
    _frontEar.physicsBody.categoryBitMask   = CNPhysicsCategoryBunny;
    _frontEar.physicsBody.collisionBitMask  = kNilOptions;
    [_ballNode addChild:_frontEar];
    _jaw.position      = CGPointMake(position.x + 15.822, position.y + 16.962);
    _jaw.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:_body.size];
    _jaw.physicsBody.density           = 0.1;
    _jaw.physicsBody.categoryBitMask   = CNPhysicsCategoryBunny;
    _jaw.physicsBody.collisionBitMask  = kNilOptions;
    [_ballNode addChild:_jaw];

    SKNode *_earSpringHook = [SKNode node];
    SKNode *_jawSpringHook = [SKNode node];
    SKNode *_armSpringHook = [SKNode node];
    SKNode *_legSpringHook = [SKNode node];
    _earSpringHook.position = CGPointMake(position.x -8.536, position.y + 69.237);
    _jawSpringHook.position = CGPointMake(position.x +20.813, position.y + 31.891);
    _armSpringHook.position = CGPointMake(position.x +27.388, position.y - 12.729);
    _legSpringHook.position = CGPointMake(position.x +15.535, position.y + -14.443);
    _earSpringHook.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
    _jawSpringHook.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
    _armSpringHook.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
    _legSpringHook.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
    _earSpringHook.physicsBody.density = 0.01;
    _jawSpringHook.physicsBody.density = 0.01;
    _armSpringHook.physicsBody.density = 0.01;
    _legSpringHook.physicsBody.density = 0.01;
    _earSpringHook.physicsBody.categoryBitMask = CNPhysicsCategoryBunny;
    _earSpringHook.physicsBody.collisionBitMask = kNilOptions;
    _jawSpringHook.physicsBody.categoryBitMask = CNPhysicsCategoryBunny;
    _jawSpringHook.physicsBody.collisionBitMask = kNilOptions;
    _armSpringHook.physicsBody.categoryBitMask = CNPhysicsCategoryBunny;
    _armSpringHook.physicsBody.collisionBitMask = kNilOptions;
    _legSpringHook.physicsBody.categoryBitMask = CNPhysicsCategoryBunny;
    _legSpringHook.physicsBody.collisionBitMask = kNilOptions;
    [_ballNode addChild: _earSpringHook];
    [_ballNode addChild: _jawSpringHook];
    [_ballNode addChild: _armSpringHook];
    [_ballNode addChild: _legSpringHook];
    
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
    SKPhysicsJointPin *jawJoint = [SKPhysicsJointPin jointWithBodyA:_jaw.physicsBody
                                                              bodyB:_body.physicsBody
                                                             anchor:CGPointMake(position.x + 12.578, position.y + 18.503)];
    
    SKPhysicsJointFixed *earSpringJointFix = [SKPhysicsJointFixed jointWithBodyA:_earSpringHook.physicsBody bodyB:_body.physicsBody anchor:_body.position ];
    SKPhysicsJointFixed *jawSpringJointFix = [SKPhysicsJointFixed jointWithBodyA:_jawSpringHook.physicsBody bodyB:_body.physicsBody anchor:_body.position ];
    SKPhysicsJointFixed *armSpringJointFix = [SKPhysicsJointFixed jointWithBodyA:_armSpringHook.physicsBody bodyB:_body.physicsBody anchor:_body.position ];
    SKPhysicsJointFixed *legSpringJointFix = [SKPhysicsJointFixed jointWithBodyA:_legSpringHook.physicsBody bodyB:_body.physicsBody anchor:_body.position ];
    
    SKPhysicsJointSpring *ear1SpringJoint = [SKPhysicsJointSpring jointWithBodyA:_earSpringHook.physicsBody bodyB:_backEar.physicsBody
                                                                         anchorA:_earSpringHook.position anchorB:CGPointMake(position.x - 2.818, position.y + 52.228)];
    SKPhysicsJointSpring *ear2SpringJoint = [SKPhysicsJointSpring jointWithBodyA:_earSpringHook.physicsBody bodyB:_frontEar.physicsBody
                                                                         anchorA:_earSpringHook.position anchorB:CGPointMake(position.x - 12.642, position.y + 49.148)];
    
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
    
    jawJoint.shouldEnableLimits = YES;
    jawJoint.upperAngleLimit = 1.2;
    jawJoint.lowerAngleLimit = -0.3;
    ear1SpringJoint.damping = -10;
    ear2SpringJoint.damping = -10;
    
    [self.physicsWorld addJoint:leg1Joint];
    [self.physicsWorld addJoint:leg2Joint];
    [self.physicsWorld addJoint:arm1Joint];
    [self.physicsWorld addJoint:arm2Joint];
    [self.physicsWorld addJoint:ear1Joint];
    [self.physicsWorld addJoint:ear2Joint];
    [self.physicsWorld addJoint:jawJoint];
    
    [self.physicsWorld addJoint:earSpringJointFix];
    [self.physicsWorld addJoint:jawSpringJointFix];
    [self.physicsWorld addJoint:armSpringJointFix];
    [self.physicsWorld addJoint:legSpringJointFix];
    
    [self.physicsWorld addJoint:ear1SpringJoint];
    [self.physicsWorld addJoint:ear2SpringJoint];
    
    SKPhysicsJointFixed *_mountBunny = [SKPhysicsJointFixed jointWithBodyA:_body.physicsBody bodyB:_ballNode.physicsBody anchor:position];
    [self.physicsWorld addJoint:_mountBunny];
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
        if (_ballNode.physicsBody.angularVelocity != 0) {
            [_ballNode.physicsBody applyAngularImpulse: -_ballNode.physicsBody.angularVelocity/10];
        }
        if (_ballNode.physicsBody.velocity.dx != 0) {
            _ballNode.physicsBody.velocity = CGVectorMake(0, _ballNode.physicsBody.velocity.dy);
        }
        if (isBlack && isWhite) {
            [_ballNode removeAllChildren];
            CGPoint newPosition = _blackHole.position;
            [self spawnBall:newPosition];
            [_portalNode removeAllChildren];
            isWhite = NO;
            isBlack = NO;
        }
        counter = 0;
    } else {
        counter ++;
    }
    
//    int64_t delay = 1.0;
//    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
//    dispatch_after(time, dispatch_get_main_queue(), ^(void){
//        if (_ballNode.physicsBody.angularVelocity != 0) {
//            [_ballNode.physicsBody applyAngularImpulse: -_ballNode.physicsBody.angularVelocity/10];
//        }
//        if (_ballNode.physicsBody.velocity.dx != 0) {
//            _ballNode.physicsBody.velocity = CGVectorMake(0, _ballNode.physicsBody.velocity.dy);
//        }
//        if (isBlack && isWhite) {
//            CGPoint offset = CGPointMake(_whiteHole.position.x - _ballNode.position.x, _whiteHole.position.y - _ballNode.position.y);
//            CGFloat length = sqrtf(offset.x * offset.x + offset.y * offset.y);
//            NSLog(@"%f",length);
//            if (length <= 90) {
//                [_ballNode removeAllChildren];
//                CGPoint newPosition = _blackHole.position;
//                [self spawnBall:newPosition];
//                [_portalNode removeAllChildren];
//                isWhite = NO;
//                isBlack = NO;
//            }
//        }
//    });
    
    [self enumerateChildNodesWithName:@"friend"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *_friend = (SKSpriteNode *)node;
                               CGPoint friendVelocity = CGPointMake(-BG_SPEED*3, 0);
                               CGPoint amtToMove = CGPointMultiplyScalar(friendVelocity, _dt);
                               _friend.position = CGPointAdd(_friend.position, amtToMove);
                               if (_friend.position.x < 0) {
                                   [_friend removeFromParent];
                               }
                           }];
    [self enumerateChildNodesWithName:@"enemy"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *_enemy = (SKSpriteNode *)node;
                               CGPoint enemyVelocity = CGPointMake(-BG_SPEED*2, 0);
                               CGPoint amtToMove = CGPointMultiplyScalar(enemyVelocity, _dt);
                               _enemy.position = CGPointAdd(_enemy.position, amtToMove);
                               if (_enemy.position.x < 0) {
                                   [_enemy removeFromParent];
                               }
                           }];

    [self enumerateChildNodesWithName:@"shelf"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *_shelf = (SKSpriteNode *)node;
                               CGPoint shelfVelocity = CGPointMake(-BG_SPEED, 0);
                               CGPoint amtToMove = CGPointMultiplyScalar(shelfVelocity, _dt);
                               _shelf.position = CGPointAdd(_shelf.position, amtToMove);
                               if (_shelf.position.x < 0) {
                                   [_shelf removeFromParent];
                               }
                           }];
    [self moveBG];
}


//--------------------------------------------------------------------------

@end