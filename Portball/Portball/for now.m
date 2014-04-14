    SKEmitterNode *_bloodEmitter;





-(void)makeBlood:(CGPoint)position
{
    _bloodEmitter =
    [NSKeyedUnarchiver unarchiveObjectWithFile: [[NSBundle mainBundle] pathForResource:@"blood"
                        ofType:@"sks"]];
    _bloodEmitter.position = position;
    _bloodEmitter.name = @"blood";
    [self addChild:_bloodEmitter];
}


    [self makeBlood:_jaw.position];



