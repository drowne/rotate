//
//  MVRTestView.m
//  Rotate!
//
//  Created by Movellas on 4/23/13.
//  Copyright (c) 2013 34BigThings. All rights reserved.
//

#import "MVRTestView.h"

@implementation MVRTestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    UIColor* fillColor = [UIColor colorWithRed: 255 green: 255 blue: 255 alpha: 100];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 100];
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(128,64)];
    [path addCurveToPoint: CGPointMake(64,128) controlPoint1: CGPointMake(125,113) controlPoint2: CGPointMake(93,128)];
    [path addCurveToPoint: CGPointMake(0,64) controlPoint1: CGPointMake(27,128) controlPoint2: CGPointMake(0,99)];
    [path addCurveToPoint: CGPointMake(64,0) controlPoint1: CGPointMake(0,0) controlPoint2: CGPointMake(64,0)];
    [path addCurveToPoint: CGPointMake(128,64) controlPoint1: CGPointMake(64,0) controlPoint2: CGPointMake(127,-1)];
    [fillColor setFill];
    [path fill];
    [strokeColor setStroke];
    path.lineWidth = 1;
    [path stroke];
    
}


@end
