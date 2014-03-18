//
//  SKSpriteNode+DebugDraw.h
//  CatNap
//
//  Created by Quincy Bock on 3/8/14.
//  Copyright (c) 2014 Quincy Bock. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (DebugDraw)

- (void)attachDebugRectWithSize:(CGSize)s;
- (void)attachDebugFrameFromPath:(CGPathRef)bodyPath;

@end
